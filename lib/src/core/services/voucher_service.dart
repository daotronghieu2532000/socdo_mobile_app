import 'package:flutter/foundation.dart';
import '../models/voucher.dart';

class VoucherService extends ChangeNotifier {
  static final VoucherService _instance = VoucherService._internal();
  factory VoucherService() => _instance;
  VoucherService._internal();

  // Voucher đã chọn cho từng shop
  final Map<int, Voucher> _selectedVouchers = {};
  
  // Voucher đã áp dụng (đã confirm)
  final Map<int, Voucher> _appliedVouchers = {};

  // Voucher sàn hiện tại
  Voucher? _platformVoucher;

  Map<int, Voucher> get selectedVouchers => Map.unmodifiable(_selectedVouchers);
  Map<int, Voucher> get appliedVouchers => Map.unmodifiable(_appliedVouchers);
  Voucher? get platformVoucher => _platformVoucher;

  /// Chọn voucher cho shop
  void selectVoucher(int shopId, Voucher voucher) {
    _selectedVouchers[shopId] = voucher;
    notifyListeners();
  }

  /// Bỏ chọn voucher cho shop
  void removeVoucher(int shopId) {
    _selectedVouchers.remove(shopId);
    notifyListeners();
  }

  /// Áp dụng voucher (confirm)
  void applyVoucher(int shopId, Voucher voucher) {
    _appliedVouchers[shopId] = voucher;
    _selectedVouchers.remove(shopId); // Xóa khỏi selected sau khi apply
    notifyListeners();
  }

  /// Hủy áp dụng voucher
  void cancelVoucher(int shopId) {
    _appliedVouchers.remove(shopId);
    notifyListeners();
  }

  /// Chọn/áp dụng voucher sàn
  void setPlatformVoucher(Voucher? voucher) {
    _platformVoucher = voucher;
    notifyListeners();
  }

  /// Lấy voucher đã áp dụng cho shop
  Voucher? getAppliedVoucher(int shopId) {
    return _appliedVouchers[shopId];
  }

  /// Lấy voucher đã chọn cho shop
  Voucher? getSelectedVoucher(int shopId) {
    return _selectedVouchers[shopId];
  }

  /// Kiểm tra shop có voucher đã áp dụng không
  bool hasAppliedVoucher(int shopId) {
    return _appliedVouchers.containsKey(shopId);
  }

  /// Kiểm tra shop có voucher đã chọn không
  bool hasSelectedVoucher(int shopId) {
    return _selectedVouchers.containsKey(shopId);
  }

  /// Tính tổng tiền giảm giá từ các voucher shop đã áp dụng (không gồm voucher sàn)
  int calculateTotalDiscount(int totalPrice) {
    int totalDiscount = 0;
    
    for (final voucher in _appliedVouchers.values) {
      if (voucher.discountValue != null) {
        if (voucher.discountType == 'percentage') {
          // Giảm theo phần trăm
          final discount = (totalPrice * voucher.discountValue! / 100).round();
          if (voucher.maxDiscountValue != null) {
            totalDiscount += discount > voucher.maxDiscountValue! 
                ? voucher.maxDiscountValue!.round() 
                : discount;
          } else {
            totalDiscount += discount;
          }
        } else {
          // Giảm theo số tiền cố định
          totalDiscount += voucher.discountValue!.round();
        }
      }
    }
    return totalDiscount;
  }

  /// Tính giảm giá của voucher sàn dựa trên danh sách sản phẩm trong giỏ
  /// - subtotal: tổng tiền hàng của các item đang thanh toán
  /// - cartProductIds: danh sách product id trong giỏ (để kiểm tra applicable_products)
  int calculatePlatformDiscountWithItems(int subtotal, List<int> cartProductIds) {
    final pv = _platformVoucher;
    if (pv == null || pv.discountValue == null) return 0;

    // Kiểm tra min order
    if (pv.minOrderValue != null && subtotal < pv.minOrderValue!.round()) {
      if (kDebugMode) {
        print('🎯 PlatformVoucher ${pv.code}: NOT APPLIED - subtotal $subtotal < min ${pv.minOrderValue}');
      }
      return 0;
    }

    // Kiểm tra danh sách sản phẩm áp dụng (nếu có)
    final allowIds = <int>{};
    if (pv.applicableProductsDetail != null && pv.applicableProductsDetail!.isNotEmpty) {
      for (final m in pv.applicableProductsDetail!) {
        final id = int.tryParse(m['id'] ?? '');
        if (id != null) allowIds.add(id);
      }
    } else if (pv.applicableProducts != null && pv.applicableProducts!.isNotEmpty) {
      for (final s in pv.applicableProducts!) {
        final id = int.tryParse(s);
        if (id != null) allowIds.add(id);
      }
    }
    if (allowIds.isNotEmpty) {
      final hasApplicable = cartProductIds.toSet().intersection(allowIds).isNotEmpty;
      if (!hasApplicable) {
        if (kDebugMode) {
          print('🎯 PlatformVoucher ${pv.code}: NOT APPLIED - no applicable product in cart. allowIds=$allowIds cartIds=${cartProductIds.toSet()}');
        }
        return 0;
      }
    }

    // Tính tiền giảm theo kiểu
    if (pv.discountType == 'percentage') {
      final discount = (subtotal * pv.discountValue! / 100).round();
      if (pv.maxDiscountValue != null && pv.maxDiscountValue! > 0) {
        final applied = discount > pv.maxDiscountValue!.round() ? pv.maxDiscountValue!.round() : discount;
        if (kDebugMode) {
          print('🎯 PlatformVoucher ${pv.code}: APPLY percentage ${pv.discountValue}% -> $applied (raw $discount, max ${pv.maxDiscountValue})');
        }
        return applied;
      }
      if (kDebugMode) {
        print('🎯 PlatformVoucher ${pv.code}: APPLY percentage ${pv.discountValue}% -> $discount');
      }
      return discount;
    } else {
      final applied = pv.discountValue!.round();
      if (kDebugMode) {
        print('🎯 PlatformVoucher ${pv.code}: APPLY fixed $applied');
      }
      return applied;
    }
  }

  /// Tính tiền giảm cho shop cụ thể
  int calculateShopDiscount(int shopId, int shopTotal) {
    final voucher = _appliedVouchers[shopId];
    if (voucher == null || voucher.discountValue == null) return 0;
    
    if (voucher.discountType == 'percentage') {
      final discount = (shopTotal * voucher.discountValue! / 100).round();
      if (voucher.maxDiscountValue != null) {
        return discount > voucher.maxDiscountValue! 
            ? voucher.maxDiscountValue!.round() 
            : discount;
      }
      return discount;
    } else {
      return voucher.discountValue!.round();
    }
  }

  /// Kiểm tra voucher có thể áp dụng cho đơn hàng không
  bool canApplyVoucher(Voucher voucher, int orderTotal) {
    // Kiểm tra giá tối thiểu
    if (voucher.minOrderValue != null && orderTotal < voucher.minOrderValue!) {
      return false;
    }
    
    // Kiểm tra thời gian
    final now = DateTime.now();
    if (voucher.startDate != null && now.isBefore(voucher.startDate!)) {
      return false;
    }
    if (voucher.endDate != null && now.isAfter(voucher.endDate!)) {
      return false;
    }
    
    // Kiểm tra trạng thái
    if (!voucher.isActive) {
      return false;
    }
    
    return true;
  }

  /// Xóa tất cả voucher (khi logout hoặc clear cart)
  void clearAllVouchers() {
    _selectedVouchers.clear();
    _appliedVouchers.clear();
    _platformVoucher = null;
    notifyListeners();
  }

  /// Lấy tất cả voucher đã áp dụng
  List<Voucher> getAllAppliedVouchers() {
    return _appliedVouchers.values.toList();
  }

  /// Lấy tất cả voucher đã chọn
  List<Voucher> getAllSelectedVouchers() {
    return _selectedVouchers.values.toList();
  }
}
