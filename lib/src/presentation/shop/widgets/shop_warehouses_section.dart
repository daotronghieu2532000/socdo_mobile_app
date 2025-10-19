import 'package:flutter/material.dart';
import '../../../core/models/shop_detail.dart';

class ShopWarehousesSection extends StatelessWidget {
  final List<ShopWarehouse> warehouses;

  const ShopWarehousesSection({
    super.key,
    required this.warehouses,
  });

  @override
  Widget build(BuildContext context) {
    if (warehouses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Shop chưa có kho hàng nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: warehouses.length,
      itemBuilder: (context, index) {
        final warehouse = warehouses[index];
        return _buildWarehouseCard(warehouse);
      },
    );
  }

  Widget _buildWarehouseCard(ShopWarehouse warehouse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warehouse, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warehouse.warehouseName?.isNotEmpty == true 
                        ? warehouse.warehouseName! 
                        : 'Kho hàng #${warehouse.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (warehouse.isDefault == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact info
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      warehouse.contactName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      warehouse.contactPhone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        warehouse.fullAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Services
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (warehouse.isPickup == 1)
                      _buildServiceChip('Nhận hàng', Colors.green),
                    if (warehouse.isReturn == 1)
                      _buildServiceChip('Trả hàng', Colors.orange),
                  ],
                ),
                
                // Freeship info
                if (warehouse.freeshipDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warehouse.freeshipDescription,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Coordinates (if available)
                if (warehouse.latitude != 0 && warehouse.longitude != 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.map, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Tọa độ: ${warehouse.latitude.toStringAsFixed(6)}, ${warehouse.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
