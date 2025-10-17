import 'package:flutter/material.dart';
import 'widgets/left_menu_item.dart';
import 'widgets/right_content.dart';
import '../../core/services/api_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _parentCategories = [];
  List<Map<String, dynamic>> _childCategories = [];
  bool _isLoading = true;
  int _selectedParentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadParentCategories();
  }

  Future<void> _loadParentCategories() async {
    try {
      setState(() => _isLoading = true);
      
      final categories = await _apiService.getCategoriesList(
        type: 'parents',
        includeChildren: true,
        includeProductsCount: true,
      );
      
      if (categories != null && mounted) {
        setState(() {
          _parentCategories = categories;
          _isLoading = false;
          // Load children of first category
          if (categories.isNotEmpty) {
            _loadChildrenFromParent(categories.first);
          }
        });
      }
    } catch (e) {
      print('❌ Lỗi khi tải danh mục cha: $e');
      setState(() => _isLoading = false);
    }
  }

  void _loadChildrenFromParent(Map<String, dynamic> parentCategory) {
    try {
      // Kiểm tra xem parent category có children không
      final children = parentCategory['children'] as List?;
      if (children != null && children.isNotEmpty) {
        print('🔍 Loaded ${children.length} child categories from parent: ${parentCategory['name'] ?? parentCategory['cat_tieude']}');
        
        // Kiểm tra xem children có đủ thông tin không (có image field)
        final firstChild = children.first as Map<String, dynamic>;
        final hasImageInfo = firstChild.containsKey('image') || 
                            firstChild.containsKey('cat_minhhoa') || 
                            firstChild.containsKey('cat_img');
        
        if (hasImageInfo) {
          // Sử dụng children từ parent data
          for (var child in children) {
            print('  - ${child['name'] ?? child['cat_tieude']} (ID: ${child['id'] ?? child['cat_id']})');
            print('    Image: image=${child['image']}, cat_minhhoa=${child['cat_minhhoa']}, cat_img=${child['cat_img']}');
          }
          setState(() {
            _childCategories = List<Map<String, dynamic>>.from(children);
          });
        } else {
          // Children không có đủ thông tin, gọi API riêng
          print('⚠️ Children không có đủ thông tin, gọi API riêng');
          final parentId = parentCategory['id'] ?? parentCategory['cat_id'];
          _loadChildCategories(parentId);
        }
      } else {
        // Nếu không có children trong parent data, gọi API riêng
        final parentId = parentCategory['id'] ?? parentCategory['cat_id'];
        _loadChildCategories(parentId);
      }
    } catch (e) {
      print('❌ Lỗi khi load children from parent: $e');
      // Fallback to API call
      final parentId = parentCategory['id'] ?? parentCategory['cat_id'];
      _loadChildCategories(parentId);
    }
  }

  Future<void> _loadChildCategories(int parentId) async {
    try {
      final children = await _apiService.getCategoriesList(
        type: 'children',
        parentId: parentId,
        includeProductsCount: true,
      );
      
      if (children != null && mounted) {
        print('🔍 Loaded ${children.length} child categories for parent ID: $parentId');
        for (var child in children) {
          print('  - ${child['name'] ?? child['cat_tieude']} (ID: ${child['id'] ?? child['cat_id']})');
        }
        setState(() {
          _childCategories = children;
        });
      }
    } catch (e) {
      print('❌ Lỗi khi tải danh mục con: $e');
    }
  }

  void _onParentCategorySelected(int index) {
    if (index != _selectedParentIndex) {
      setState(() {
        _selectedParentIndex = index;
      });
      
      if (_parentCategories.isNotEmpty && index < _parentCategories.length) {
        _loadChildrenFromParent(_parentCategories[index]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục sản phẩm'),
        // Ẩn icon giỏ hàng góc phải theo yêu cầu
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Row(
            children: [
              SizedBox(
                width: 110,
                child: ListView.builder(
                  itemCount: _parentCategories.length,
                  itemBuilder: (context, index) => LeftMenuItem(
                    label: _parentCategories[index]['name'] ?? _parentCategories[index]['cat_tieude'] ?? 'Danh mục',
                    imageUrl: _parentCategories[index]['image'] ?? _parentCategories[index]['cat_minhhoa'] ?? _parentCategories[index]['cat_img'],
                    selected: index == _selectedParentIndex,
                    onTap: () => _onParentCategorySelected(index),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: RightContent(
                  title: _parentCategories.isNotEmpty 
                    ? _parentCategories[_selectedParentIndex]['name'] ?? _parentCategories[_selectedParentIndex]['cat_tieude'] ?? 'Danh mục'
                    : 'Danh mục',
                  parentCategoryId: _parentCategories.isNotEmpty 
                    ? _parentCategories[_selectedParentIndex]['id'] ?? _parentCategories[_selectedParentIndex]['cat_id'] ?? 0
                    : 0,
                  childCategories: _childCategories,
                ),
              ),
            ],
          ),
    );
  }
}



