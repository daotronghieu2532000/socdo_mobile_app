import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/profile/profile_edit_screen.dart';
import 'presentation/profile/address_book_screen.dart';
import 'presentation/orders/orders_screen.dart';
import 'presentation/notifications/notifications_screen.dart';
import 'presentation/orders/order_success_screen.dart';
import 'presentation/auth/login_screen.dart';

class SocdoApp extends StatelessWidget {
  const SocdoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socdo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile/edit': (context) => const ProfileEditScreen(),
        '/profile/address': (context) => const AddressBookScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        // order success requires argument maDon
        '/order/success': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final maDon = args?['ma_don']?.toString() ?? '';
          return OrderSuccessScreen(maDon: maDon);
        },
      },
    );
  }
}




