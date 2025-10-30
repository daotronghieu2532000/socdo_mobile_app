import 'dart:async';
import 'package:flutter/material.dart';

class FlashSaleTimer extends StatefulWidget {
  final int timeRemaining; // in seconds
  final String timeFormatted; // HH:mm:ss

  const FlashSaleTimer({
    super.key,
    required this.timeRemaining,
    required this.timeFormatted,
  });

  @override
  State<FlashSaleTimer> createState() => _FlashSaleTimerState();
}

class _FlashSaleTimerState extends State<FlashSaleTimer> {
  late Timer _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeRemaining;
    _startTimer();
  }

  @override
  void didUpdateWidget(FlashSaleTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeRemaining != oldWidget.timeRemaining) {
      _remaining = widget.timeRemaining;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _remaining > 0) {
        setState(() {
          _remaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.orange.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fire icon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          // Text "FLASH SALE"
          const Text(
            'FLASH SALE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          // Divider
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          // Timer
          Text(
            _formatTime(_remaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
