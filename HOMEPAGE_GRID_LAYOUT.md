# Homepage Grid Layout - Shopee Style

## ✅ Thay đổi layout trang chủ thành Shopee style

### **🎯 Mục tiêu:**
Thay đổi 2 mục "Flash Sale" và "Gợi ý sản phẩm" từ layout 1 sản phẩm/hàng thành 2 sản phẩm/hàng với chức năng "Xem thêm"/"Ẩn bớt".

## 🔄 Thay đổi từ:

### **Trước (Vertical List):**
```
Flash Sale:
[Product 1 - Full Width]
[Product 2 - Full Width]  
[Product 3 - Full Width]
[Product 4 - Full Width]
...

Gợi ý sản phẩm:
[Product 1 - Full Width]
[Product 2 - Full Width]
[Product 3 - Full Width]
[Product 4 - Full Width]
...
```

### **Sau (Grid Layout):**
```
Flash Sale:
[Product 1] [Product 2]
[Product 3] [Product 4]
[Product 5] [Product 6]
[Product 7] [Product 8]
[Product 9] [Product 10]
[Xem thêm] / [Ẩn bớt]

Gợi ý sản phẩm:
[Product 1] [Product 2]
[Product 3] [Product 4]
[Product 5] [Product 6]
[Product 7] [Product 8]
[Product 9] [Product 10]
[Xem thêm] / [Ẩn bớt]
```

## 🏗️ Technical Implementation:

### **1. 📱 FlashSaleSection Changes:**

#### **Added State Management:**
```dart
bool _expanded = false; // Hiển thị 10 sản phẩm mặc định
```

#### **Changed from ListView to GridView:**
```dart
// Trước
ListView.separated(
  itemBuilder: (context, index) => FlashSaleProductCardVertical(...),
  itemCount: allProducts.length,
)

// Sau
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 0.75,
  ),
  itemBuilder: (context, index) => FlashSaleProductCardVertical(...),
  itemCount: visibleCount, // 10 hoặc allProducts.length
)
```

#### **Added View More/Less Functionality:**
```dart
if (allProducts.length > 10)
  TextButton.icon(
    onPressed: () => setState(() => _expanded = !_expanded),
    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
    label: Text(_expanded ? 'Ẩn bớt' : 'Xem thêm'),
  )
```

### **2. 🛍️ ProductGrid Changes:**

#### **Updated Limit Logic:**
```dart
// Trước: 6 sản phẩm
final int visibleCount = _expanded ? _products.length : (_products.length > 6 ? 6 : _products.length);

// Sau: 10 sản phẩm
final int visibleCount = _expanded ? _products.length : (_products.length > 10 ? 10 : _products.length);
```

#### **Changed from ListView to GridView:**
```dart
// Trước
ListView.separated(
  itemBuilder: (context, index) => ProductSuggestCardVertical(...),
  itemCount: visibleCount,
)

// Sau
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 0.75,
  ),
  itemBuilder: (context, index) => ProductSuggestCardVertical(...),
  itemCount: visibleCount,
)
```

## 📊 Grid Configuration:

### **SliverGridDelegateWithFixedCrossAxisCount:**
```dart
crossAxisCount: 2,           // 2 sản phẩm/hàng
mainAxisSpacing: 8,          // 8px khoảng cách dọc
crossAxisSpacing: 8,         // 8px khoảng cách ngang  
childAspectRatio: 0.75,      // Tỷ lệ width/height = 0.75
```

### **Benefits:**
- **Consistent spacing**: 8px giữa các items
- **Proper aspect ratio**: 0.75 phù hợp với product cards
- **Responsive**: Tự động điều chỉnh theo màn hình
- **Performance**: GridView hiệu quả hơn ListView cho grid layout

## 🎨 User Experience:

### **View More/Less Logic:**
```dart
// Hiển thị 10 sản phẩm đầu tiên
final int visibleCount = _expanded 
    ? _products.length           // Tất cả sản phẩm
    : (_products.length > 10 
        ? 10                     // 10 sản phẩm đầu
        : _products.length);     // Tất cả nếu < 10
```

### **Button States:**
- **Collapsed**: Hiển thị "Xem thêm" với icon expand_more
- **Expanded**: Hiển thị "Ẩn bớt" với icon expand_less
- **Conditional**: Chỉ hiển thị khi có > 10 sản phẩm

## 📱 Mobile Optimization:

### **Grid Layout Benefits:**
- **Better space utilization**: 2 sản phẩm/hàng thay vì 1
- **Faster scanning**: Người dùng thấy nhiều sản phẩm hơn
- **Shopee-like UX**: Quen thuộc với người dùng
- **Vertical scrolling**: Phù hợp với mobile behavior

### **Performance:**
- **GridView**: Hiệu quả hơn ListView cho grid
- **ShrinkWrap**: Không chiếm hết không gian
- **NeverScrollableScrollPhysics**: Không scroll độc lập

## 🚀 Benefits:

### **User Experience:**
1. **More products visible**: Thấy nhiều sản phẩm hơn cùng lúc
2. **Familiar layout**: Giống Shopee, quen thuộc với người dùng
3. **Better browsing**: Dễ dàng so sánh sản phẩm
4. **Controlled content**: "Xem thêm" giúp không overwhelm

### **Technical Benefits:**
1. **Consistent layout**: Cả Flash Sale và Gợi ý đều dùng grid
2. **Reusable pattern**: Có thể áp dụng cho sections khác
3. **Performance optimized**: GridView hiệu quả hơn
4. **State management**: Clean expand/collapse logic

## 📊 Comparison:

### **Before (Vertical List):**
- Layout: 1 sản phẩm/hàng
- Limit: 6 sản phẩm (Gợi ý), Tất cả (Flash Sale)
- Navigation: Scroll dọc liên tục
- Space usage: Ít hiệu quả

### **After (Grid Layout):**
- Layout: 2 sản phẩm/hàng
- Limit: 10 sản phẩm với "Xem thêm"
- Navigation: Grid + "Xem thêm"/"Ẩn bớt"
- Space usage: Hiệu quả hơn

## 🎯 Final Result:

### **Homepage Sections:**
✅ **Flash Sale**: 2x5 grid với "Xem thêm" sau 10 sản phẩm  
✅ **Gợi ý sản phẩm**: 2x5 grid với "Xem thêm" sau 10 sản phẩm  
✅ **Shopee-like UX**: Layout quen thuộc với người dùng  
✅ **Performance optimized**: GridView thay vì ListView  
✅ **Consistent behavior**: Cả 2 sections hoạt động giống nhau  

### **User Journey:**
1. **Initial load**: Thấy 10 sản phẩm (2x5 grid)
2. **Want more**: Click "Xem thêm" → Hiển thị tất cả
3. **Too much**: Click "Ẩn bớt" → Quay về 10 sản phẩm
4. **Seamless**: Smooth transition giữa các states
