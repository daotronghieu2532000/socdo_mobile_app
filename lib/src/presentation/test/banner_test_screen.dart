import 'package:flutter/material.dart';
import 'widgets/mobile_banner_slider.dart';
import 'widgets/partner_banner_slider.dart';

class BannerTestScreen extends StatelessWidget {
  const BannerTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Test'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            // Test Mobile Banner
            Text(
              'Mobile Banner (295px height)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            MobileBannerSlider(),
            SizedBox(height: 20),
            
            // Test Partner Banner
            Text(
              'Partner Banner (160px height)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PartnerBannerSlider(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
