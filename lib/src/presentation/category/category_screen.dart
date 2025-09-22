import 'package:flutter/material.dart';
import 'widgets/left_menu_item.dart';
import 'widgets/right_content.dart';
import 'models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  final List<Category> leftMenu = const [
    Category('Thực phẩm chức năng', 'lib/src/core/assets/images/danhmuc_1.png'),
    Category('Mẹ và Bé', 'lib/src/core/assets/images/danhmuc_2.png'),
    Category('Mỹ phẩm', 'lib/src/core/assets/images/danhmuc_3.png'),
    Category('Thời trang', 'lib/src/core/assets/images/danhmuc_4.png'),
    Category('Đồ gia dụng nhà bếp', 'lib/src/core/assets/images/danhmuc_5.png'),
    Category('Thiết bị chăm sóc sức khoẻ', null),
    Category('Đồ thể thao - Du lịch', null),
  ];

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục sản phẩm'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined)),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 110,
            child: ListView.builder(
              itemCount: leftMenu.length,
              itemBuilder: (context, index) => LeftMenuItem(
                label: leftMenu[index].label,
                imagePath: leftMenu[index].assetPath,
                selected: index == selected,
                onTap: () => setState(() => selected = index),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: RightContent(title: leftMenu[selected].label),
          ),
        ],
      ),
    );
  }
}



