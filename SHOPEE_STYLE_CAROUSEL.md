# Shopee-Style Product Carousel Implementation

## ✅ Cách hoạt động mới (như Shopee):

### **🎯 Chính xác 2 sản phẩm/khung**
- **Trang 1**: Hiển thị sản phẩm 1, 2
- **Trang 2**: Hiển thị sản phẩm 3, 4  
- **Trang 3**: Hiển thị sản phẩm 5, 6
- **Không bị cắt dở**: Mỗi trang chỉ hiển thị đúng 2 sản phẩm đầy đủ

### **🔄 Navigation như Shopee**
- **Next button**: Chuyển sang trang tiếp theo (2 sản phẩm mới)
- **Previous button**: Chuyển về trang trước (2 sản phẩm cũ)
- **Smooth transition**: Animation 300ms mượt mà
- **No partial display**: Không bao giờ hiển thị sản phẩm bị cắt

## 🏗️ Technical Implementation:

### **PageView với Full Width:**
```dart
PageController(
  viewportFraction: 1.0, // Full width cho page-based navigation
)
```

### **Page-based Item Distribution:**
```dart
itemBuilder: (context, pageIndex) {
  final startIndex = pageIndex * widget.itemsPerPage;
  final endIndex = min(startIndex + widget.itemsPerPage, widget.children.length);
  final pageItems = widget.children.sublist(startIndex, endIndex);
  
  return Row(
    children: pageItems.map((child) => Expanded(child: child)).toList(),
  );
}
```

### **Smart Navigation:**
```dart
void _nextPage() {
  if (_currentPage < _totalPages - 1) {
    _pageController.nextPage(duration: Duration(milliseconds: 300));
  }
}
```

## 📱 User Experience:

### **Before (Scroll-based):**
```
[Sản phẩm 1] [Sản phẩm 2] [Sản phẩm 3...] (cắt)
↓ (scroll)
[Sản phẩm 2] [Sản phẩm 3] [Sản phẩm 4...] (cắt)
```

### **After (Page-based như Shopee):**
```
Trang 1: [Sản phẩm 1] [Sản phẩm 2]     [Next]
↓ (click Next)
Trang 2: [Sản phẩm 3] [Sản phẩm 4]     [Prev] [Next]
↓ (click Next)  
Trang 3: [Sản phẩm 5] [Sản phẩm 6]     [Prev]
```

## 🎨 Visual Behavior:

### **Initial State:**
- Hiển thị trang 1: 2 sản phẩm đầy đủ
- Next button active, Previous button hidden
- No partial products visible

### **After Next Click:**
- Smooth transition to trang 2
- Hiển thị 2 sản phẩm mới đầy đủ
- Both Previous and Next buttons active
- No cutoff products

### **Navigation States:**
- **First page**: Only Next button visible
- **Middle pages**: Both buttons visible  
- **Last page**: Only Previous button visible

## 🔧 Key Differences from Previous:

### **Old Implementation (Scroll-based):**
```dart
ListView.separated(
  scrollDirection: Axis.horizontal,
  itemBuilder: (context, index) => SizedBox(width: calculatedWidth, child: children[index]),
)
```

### **New Implementation (Page-based):**
```dart
PageView.builder(
  itemCount: totalPages,
  itemBuilder: (context, pageIndex) {
    final pageItems = children.sublist(startIndex, endIndex);
    return Row(children: pageItems.map((child) => Expanded(child: child)).toList());
  },
)
```

## 📊 Benefits:

1. **Perfect Layout**: Chính xác 2 sản phẩm mỗi trang
2. **No Cutoff**: Không bao giờ hiển thị sản phẩm bị cắt
3. **Shopee-like UX**: Navigation quen thuộc với người dùng
4. **Smooth Animation**: Transition mượt mà giữa các trang
5. **Predictable**: Người dùng biết trước sẽ thấy gì
6. **Mobile Optimized**: Tối ưu cho touch navigation

## 🎯 Responsive Behavior:

### **Small Screens (320px):**
- 2 products per page: ~150px each
- Perfect fit with 12px spacing

### **Medium Screens (375px):**
- 2 products per page: ~175px each  
- Perfect fit with 12px spacing

### **Large Screens (414px):**
- 2 products per page: ~195px each
- Perfect fit with 12px spacing

## 🚀 Performance:

- **PageView**: More efficient than ListView for page-based navigation
- **Expanded widgets**: Automatic width distribution
- **Minimal rebuilds**: Only rebuilds when page changes
- **Memory efficient**: Disposes PageController properly
