import 'package:flutter/material.dart';
import '../../../core/models/shop_detail.dart';
import '../../../core/services/cached_api_service.dart';
import 'shop_section_wrapper.dart';

class ShopWarehousesSection extends StatefulWidget {
  final int shopId;

  const ShopWarehousesSection({
    super.key,
    required this.shopId,
  });

  @override
  State<ShopWarehousesSection> createState() => _ShopWarehousesSectionState();
}

class _ShopWarehousesSectionState extends State<ShopWarehousesSection> {
  final CachedApiService _cachedApiService = CachedApiService();
  
  List<ShopWarehouse> _warehouses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final warehousesData = await _cachedApiService.getShopWarehousesCached(
        shopId: widget.shopId,
      );

      if (mounted) {
        final warehouses = warehousesData.map((data) => ShopWarehouse.fromJson(data)).toList();
        
        setState(() {
          _warehouses = warehouses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Lỗi kết nối: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopSectionWrapper(
      isLoading: _isLoading,
      error: _error,
      emptyMessage: 'Shop chưa có kho hàng nào',
      emptyIcon: Icons.warehouse_outlined,
      onRetry: _loadWarehouses,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _warehouses.length,
        itemBuilder: (context, index) {
          final warehouse = _warehouses[index];
          return _buildWarehouseCard(warehouse);
        },
      ),
    );
  }

  Widget _buildWarehouseCard(ShopWarehouse warehouse) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    warehouse.warehouseName ?? 'Kho hàng',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (warehouse.isDefault == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MẶC ĐỊNH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              warehouse.fullAddress,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (warehouse.freeshipDescription.isNotEmpty)
              Text(
                warehouse.freeshipDescription,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}