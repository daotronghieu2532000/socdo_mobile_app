import 'package:flutter/material.dart';

class TimeSlotsTabBar extends StatelessWidget {
  final TabController tabController;
  final int selectedTab;
  final List<String> timeSlots;
  final List<String> statusTexts;

  const TimeSlotsTabBar({
    super.key,
    required this.tabController,
    required this.selectedTab,
    required this.timeSlots,
    required this.statusTexts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        indicatorColor: Colors.red,
        labelColor: Colors.red,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: List.generate(4, (index) => Tab(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(timeSlots[index]),
              const SizedBox(height: 4),
              Text(
                statusTexts[index],
                style: TextStyle(
                  fontSize: 12,
                  color: index == selectedTab ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
