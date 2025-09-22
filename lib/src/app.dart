import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/splash/splash_screen.dart';

class SocdoApp extends StatelessWidget {
  const SocdoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socdo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}


