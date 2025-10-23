import 'package:flutter/foundation.dart';

class ShippingQuoteStore extends ChangeNotifier {
  static final ShippingQuoteStore _instance = ShippingQuoteStore._internal();
  factory ShippingQuoteStore() => _instance;
  ShippingQuoteStore._internal();

  int _lastFee = 0;
  String? _etaText;
  String? _provider;
  int _shipSupport = 0; // Tổng ship support đã được áp dụng

  int get lastFee => _lastFee;
  String? get etaText => _etaText;
  String? get provider => _provider;
  int get shipSupport => _shipSupport;

  void setQuote({required int fee, String? etaText, String? provider, int shipSupport = 0}) {
    _lastFee = fee;
    _etaText = etaText;
    _provider = provider;
    _shipSupport = shipSupport;
    notifyListeners(); // Thông báo cho các widget đang lắng nghe
  }
}



