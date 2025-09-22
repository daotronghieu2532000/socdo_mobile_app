import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/time_slots_tab_bar.dart';
import 'widgets/countdown_banner.dart';
import 'widgets/flash_sale_product_card.dart';

class FlashSaleScreen extends StatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  State<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends State<FlashSaleScreen> with TickerProviderStateMixin {
  Duration _timeLeft = const Duration(hours: 1, minutes: 59, seconds: 28);
  late Timer _timer;
  late TabController _tabController;
  int _selectedTab = 0;

  final List<String> _timeSlots = ['06:00', '12:00', '18:00', '00:00 Ngày mai'];
  final List<String> _statusTexts = ['Đang diễn ra', 'Sắp diễn ra', 'Sắp diễn ra', 'Sắp diễn ra'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Flash Sale',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          // Time slots tabs
          TimeSlotsTabBar(
            tabController: _tabController,
            selectedTab: _selectedTab,
            timeSlots: _timeSlots,
            statusTexts: _statusTexts,
          ),
          
          // Countdown banner
          CountdownBanner(timeLeft: _timeLeft),
          
          // Product list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 10,
              itemBuilder: (context, index) => FlashSaleProductCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

