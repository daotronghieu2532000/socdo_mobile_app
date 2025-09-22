import 'package:flutter/material.dart';
import 'product_description_screen.dart';
import 'widgets/bottom_actions.dart';
import 'widgets/variant_selector.dart';
import 'widgets/row_tile.dart';
import 'widgets/voucher_row.dart';
import 'widgets/rating_preview.dart';
import 'widgets/shop_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/related_card.dart';
import 'widgets/specs_table.dart';
import 'widgets/description_text.dart';
import 'widgets/viewed_product_card.dart';
import 'widgets/similar_product_card.dart';
import '../../core/utils/format_utils.dart';

class ProductDetailScreen extends StatelessWidget {
  final String title;
  final String image;
  final int price;
  const ProductDetailScreen({super.key, required this.title, required this.image, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomActions(price: price),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(image, fit: BoxFit.cover),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                      child: const Text('2/3', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(FormatUtils.formatCurrency(price),
                          style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Text(FormatUtils.formatCurrency(price * 12 ~/ 10),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('[Mẫu mới] Viên Uống Collagen + Biotin Youtheory 390 viên của Mỹ', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Đã bán 217', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          Icon(Icons.help_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Icon(Icons.favorite_border, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  VariantSelector(
                    variants: const ['390 viên', '290 viên'],
                    selectedIndex: 0,
                  ),
                  const SizedBox(height: 12),
                  RowTile(icon: Icons.autorenew, title: 'Đổi trả hàng trong vòng 15 ngày'),
                  const SizedBox(height: 8),
                  VoucherRow(),
                  const SizedBox(height: 20),
                  const RatingPreview(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const ShopBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SectionHeader('Sản phẩm cùng gian hàng'),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) => RelatedCard(index: i),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader('Chi tiết sản phẩm'),
                  SpecsTable(),
                  const SizedBox(height: 12),
                  DescriptionText(
                    onViewMore: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDescriptionScreen(
                            productName: '[Mẫu mới] Viên Uống Collagen + Biotin Youtheory 390 viên của Mỹ',
                            productImage: 'lib/src/core/assets/images/product_1.png',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader('Sản phẩm đã xem'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (_, i) => ViewedProductCard(index: i),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader('Sản phẩm tương tự'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (_, i) => SimilarProductCard(index: i),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
















