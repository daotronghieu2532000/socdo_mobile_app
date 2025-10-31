import 'package:flutter/material.dart';

/// Xử lý deep linking khi user tap vào notification
class NotificationHandler {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Handle notification data và navigate đến màn hình phù hợp
  void handleNotificationData(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final relatedId = data['related_id'] as String?;
      
      if (type == null) return;

      switch (type) {
        case 'order':
        case 'affiliate_order':
          // Navigate đến order detail
          if (relatedId != null) {
            final orderId = int.tryParse(relatedId);
            if (orderId != null) {
              _navigateToOrderDetail(orderId);
            }
          }
          break;

        case 'deposit':
        case 'withdrawal':
          // Navigate đến transaction/balance screen
          _navigateToBalance();
          break;

        case 'voucher_new':
        case 'voucher_expiring':
          // Navigate đến voucher list
          _navigateToVouchers();
          break;

        default:
          // Navigate đến notifications list
          _navigateToNotifications();
          break;
      }
    } catch (e) {
      print('❌ Error handling notification data: $e');
      // Fallback: navigate to notifications list
      _navigateToNotifications();
    }
  }

  void _navigateToOrderDetail(int orderId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Import và navigate đến OrderDetailScreen
      // Navigator.pushNamed(context, '/order-detail', arguments: orderId);
      print('📱 Navigate to order detail: $orderId');
      // TODO: Implement navigation khi có OrderDetailScreen route
    }
  }

  void _navigateToBalance() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Navigate đến balance/transaction screen
      print('📱 Navigate to balance screen');
      // TODO: Implement navigation
    }
  }

  void _navigateToVouchers() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Navigate đến voucher list
      print('📱 Navigate to vouchers');
      // TODO: Implement navigation
    }
  }

  void _navigateToNotifications() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Navigate đến notifications list
      print('📱 Navigate to notifications');
      // TODO: Implement navigation khi có route
      // Navigator.pushNamed(context, '/notifications');
    }
  }
}

