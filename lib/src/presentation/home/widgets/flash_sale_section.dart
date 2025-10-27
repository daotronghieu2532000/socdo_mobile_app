import 'dart:async';
import 'package:flutter/material.dart';
import '../../flash_sale/flash_sale_screen.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/services/cached_api_service.dart';
import '../../../core/models/flash_sale_product.dart';
import '../../../core/models/flash_sale_deal.dart';
import 'flash_sale_product_card_horizontal.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({super.key});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  Duration _timeLeft = const Duration(hours: 2, minutes: 6, seconds: 49);
  late Timer _timer;
  final CachedApiService _cachedApiService = CachedApiService();
  List<FlashSaleDeal> _deals = [];
  bool _isLoading = true;
  String? _error;
  bool _expanded = false; // Hiển thị 10 sản phẩm mặc định, mở rộng để xem thêm

  @override
  void initState() {
    super.initState();
    // Load từ cache ngay lập tức
    _loadFlashSaleDealsFromCache();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
          });
        }
      } else {
        // Khi hết giờ, reload flash sale để lấy timeline mới
        // Tắt logging để tránh spam terminal
        // print('⏰ Timeline ended, reloading flash sale...');
        if (mounted) {
          _loadFlashSaleDeals();
        }
        // Reset timer để tránh gọi liên tục
        _timeLeft = const Duration(hours: 1); // Tạm thời set 1 giờ
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadFlashSaleDealsFromCache() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Xác định timeline hiện tại theo logic website
      final now = DateTime.now();
      final hour = now.hour;
      String currentTimeline;
      
      if (hour >= 0 && hour < 9) {
        currentTimeline = '00:00';
      } else if (hour >= 9 && hour < 16) {
        currentTimeline = '09:00';
      } else {
        currentTimeline = '16:00';
      }

      // Chỉ load từ cache
      final flashSaleData = await _cachedApiService.getHomeFlashSale();
      
      if (!mounted) return;
      
      if (flashSaleData.isNotEmpty) {
        // Convert Map to FlashSaleDeal
        final deals = flashSaleData.map((data) => FlashSaleDeal.fromJson(data)).toList();
        
        setState(() {
          _isLoading = false;
          _deals = deals;
          // Cập nhật countdown theo mốc hiện tại (đến cuối slot)
          final slotEnd = _currentSlotEnd(currentTimeline);
          final nowTs = DateTime.now();
          final remaining = slotEnd.difference(nowTs).inSeconds;
          _timeLeft = Duration(seconds: remaining > 0 ? remaining : 0);
        });
        
        print('✅ Flash sale loaded from cache (${deals.length} deals)');
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Không có flash sale trong cache';
        });
        print('⚠️ No cached flash sale');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Lỗi kết nối: $e';
        });
      }
      print('❌ Error loading flash sale from cache: $e');
    }
  }

  Future<void> _loadFlashSaleDeals() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Xác định timeline hiện tại theo logic website
      final now = DateTime.now();
      final hour = now.hour;
      String currentTimeline;
      
      if (hour >= 0 && hour < 9) {
        currentTimeline = '00:00';
      } else if (hour >= 9 && hour < 16) {
        currentTimeline = '09:00';
      } else {
        currentTimeline = '16:00';
      }

      print('🕐 Current timeline: $currentTimeline (hour: $hour)');

      // Sử dụng cached API service
      final flashSaleData = await _cachedApiService.getHomeFlashSale();
      
      if (!mounted) return;
      
      if (flashSaleData.isNotEmpty) {
        // Convert Map to FlashSaleDeal
        final deals = flashSaleData.map((data) => FlashSaleDeal.fromJson(data)).toList();
        
        setState(() {
          _isLoading = false;
          _deals = deals;
          // Cập nhật countdown theo mốc hiện tại (đến cuối slot)
          final slotEnd = _currentSlotEnd(currentTimeline);
          final nowTs = DateTime.now();
          final remaining = slotEnd.difference(nowTs).inSeconds;
          _timeLeft = Duration(seconds: remaining > 0 ? remaining : 0);
        });
        
        print('✅ Flash sale loaded successfully (${deals.length} deals)');
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Không có flash sale cho khung giờ $currentTimeline';
        });
        print('⚠️ No flash sale found for timeline $currentTimeline');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Lỗi kết nối: $e';
        });
      }
      print('❌ Error loading flash sale: $e');
    }
  }

  DateTime _currentSlotEnd(String slot) {
    final now = DateTime.now();
    if (slot == '00:00') {
      return DateTime(now.year, now.month, now.day, 9, 0, 0);
    } else if (slot == '09:00') {
      return DateTime(now.year, now.month, now.day, 16, 0, 0);
    } else {
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
  }

  String _formatTime(int seconds) {
    return FormatUtils.formatTime(seconds).replaceAll(':', ' : ');
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: Colors.pink),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadFlashSaleDeals,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_deals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.flash_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Không có flash sale',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Lấy tất cả sản phẩm từ các deals của timeline hiện tại
    final List<FlashSaleProduct> allProducts = [];
    
    // Xác định timeline hiện tại
    final now = DateTime.now();
    final hour = now.hour;
    String currentTimeline;
    if (hour >= 0 && hour < 9) {
      currentTimeline = '00:00';
    } else if (hour >= 9 && hour < 16) {
      currentTimeline = '09:00';
    } else {
      currentTimeline = '16:00';
    }
    
    for (var deal in _deals) {
      // Chỉ lấy sản phẩm của timeline hiện tại
      // Sửa logic: không dựa vào isTimelineActive từ API, mà check timeline trực tiếp
      if (deal.timeline == currentTimeline) {
        allProducts.addAll(deal.allProducts);
      }
    }
    
    // Loại bỏ sản phẩm trùng lặp dựa trên ID
    final uniqueProducts = <int, FlashSaleProduct>{};
    for (var product in allProducts) {
      uniqueProducts[product.id] = product;
    }
    final deduplicatedProducts = uniqueProducts.values.toList();
    
    // Tắt logging để tránh spam terminal
    // if (deduplicatedProducts.length != allProducts.length) {
    //   print('⚠️ Found ${allProducts.length - deduplicatedProducts.length} duplicate products');
    // }
    // print('🎯 Flash Sale: ${deduplicatedProducts.length} unique products for timeline $currentTimeline');

    if (deduplicatedProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.flash_off, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Không có sản phẩm flash sale cho khung giờ hiện tại',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadFlashSaleDeals,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }

    // Chuẩn bị countdown theo slot cho UI
    final slotEnd = _currentSlotEnd(currentTimeline);
    final slotCountdown = (() {
      final secs = slotEnd.difference(now).inSeconds;
      final s = secs <= 0 ? 0 : secs;
      final h = s ~/ 3600;
      final m = (s % 3600) ~/ 60;
      final sec = s % 60;
      return '${h.toString().padLeft(2, '0')} : ${m.toString().padLeft(2, '0')} : ${sec.toString().padLeft(2, '0')}';
    })();

    // Xác định số lượng item hiển thị theo trạng thái thu gọn/mở rộng
    final int visibleCount = _expanded
        ? deduplicatedProducts.length
        : (deduplicatedProducts.length > 10 ? 10 : deduplicatedProducts.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(
          visibleCount,
          (index) {
            final product = deduplicatedProducts[index];
            return FlashSaleProductCardHorizontal(
              product: product,
              index: index,
              countdownText: slotCountdown,
            );
          },
        ),
        if (deduplicatedProducts.length > 10)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1), // Giảm từ 2 xuống 1 để giảm thêm khoảng trống
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_expanded ? 'Ẩn bớt' : 'Xem thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF2F2), // nền đỏ rất nhẹ xung quanh sản phẩm
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12), // Giảm horizontal từ 12 xuống 4
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.pink, size: 20),
                    const SizedBox(width: 4),
                    Text('FLASH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.pink)),
                    const SizedBox(width: 4),
                    Text('SALE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.orange)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FlashSaleScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_timeLeft.inSeconds),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Giảm giá sốc, đừng bỏ lỡ!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Hiển thị sản phẩm theo dạng dọc
          _buildProductsList(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
