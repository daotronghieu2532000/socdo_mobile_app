# 📱 APP INTEGRATION GUIDE - SHOP DETAIL API FREESHIP LOGIC

## 🎯 **TỔNG QUAN:**

API `shop_detail.php` đã được sửa để hiển thị **chính xác** thông tin freeship theo logic tongkho. App cần cập nhật để hiển thị đúng các loại freeship.

---

## 🔧 **API ENDPOINT:**

```
GET https://api.socdo.vn/v1/API_socdo/shop_detail.php?shop_id={shop_id}
```

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

---

## 📊 **RESPONSE STRUCTURE:**

### **Products Array:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": 5892,
        "name": "Dầu xả thảo dược...",
        "price": 180000,
        "old_price": 500000,
        "freeship_icon": "Hỗ trợ ship 15.000₫",  // ⭐ KEY FIELD
        "voucher_icon": "Voucher",
        "chinhhang_icon": "Chính hãng",
        "badges": ["Giảm 64%"],
        "warehouse_name": "",
        "province_name": "Thành phố Hà Nội"
      }
    ],
    "flash_sales": [
      {
        "id": 123,
        "title": "Flash Sale...",
        "sub_products": {
          "5892": {
            "product_info": {
              "id": 5892,
              "name": "Dầu xả thảo dược...",
              "freeship_icon": "Hỗ trợ ship 15.000₫",  // ⭐ KEY FIELD
              "voucher_icon": "Voucher",
              "chinhhang_icon": "Chính hãng"
            },
            "variants": {...}
          }
        }
      }
    ]
  }
}
```

---

## 🎨 **FREESHIP ICON VALUES:**

### **1. Mode 0: Giảm ship theo số tiền cố định**
```json
"freeship_icon": "Giảm 30.000đ ship"
```
- **Điều kiện:** `free_ship_all = 0` AND `free_ship_discount > 0` AND `free_ship_min_order > 0`
- **Hiển thị:** Nút màu xanh lá với text "Giảm Xđ ship"

### **2. Mode 1: Miễn phí ship hoàn toàn**
```json
"freeship_icon": "Freeship 100%"
```
- **Điều kiện:** `free_ship_all = 1`
- **Hiển thị:** Nút màu xanh lá với text "Freeship 100%"

### **3. Mode 2: Giảm ship theo %**
```json
"freeship_icon": "Giảm 50% ship"
```
- **Điều kiện:** `free_ship_all = 2` AND `free_ship_discount > 0` AND `free_ship_min_order > 0`
- **Hiển thị:** Nút màu xanh lá với text "Giảm X% ship"

### **4. Mode 3: Ưu đãi ship theo sản phẩm cụ thể**
```json
"freeship_icon": "Hỗ trợ ship 15.000₫"
```
- **Điều kiện:** `free_ship_all = 3` AND sản phẩm có trong `fee_ship_products` JSON
- **Hiển thị:** Nút màu xanh lá với text "Hỗ trợ ship X₫"

### **5. Không có freeship**
```json
"freeship_icon": ""
```
- **Điều kiện:** Không có cấu hình freeship
- **Hiển thị:** Không hiển thị nút freeship

---

## 📱 **APP IMPLEMENTATION:**

### **1. React Native Example:**

```javascript
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const ProductCard = ({ product }) => {
  const renderFreeshipIcon = () => {
    if (!product.freeship_icon) return null;
    
    return (
      <View style={styles.freeshipContainer}>
        <Text style={styles.freeshipText}>
          {product.freeship_icon}
        </Text>
      </View>
    );
  };

  const renderVoucherIcon = () => {
    if (!product.voucher_icon) return null;
    
    return (
      <View style={styles.voucherContainer}>
        <Text style={styles.voucherText}>
          {product.voucher_icon}
        </Text>
      </View>
    );
  };

  const renderChinhhangIcon = () => {
    if (!product.chinhhang_icon) return null;
    
    return (
      <View style={styles.chinhhangContainer}>
        <Text style={styles.chinhhangText}>
          {product.chinhhang_icon}
        </Text>
      </View>
    );
  };

  return (
    <View style={styles.productCard}>
      {/* Product Image */}
      <Image source={{ uri: product.image }} style={styles.productImage} />
      
      {/* Product Info */}
      <View style={styles.productInfo}>
        <Text style={styles.productName}>{product.name}</Text>
        
        {/* Price */}
        <View style={styles.priceContainer}>
          <Text style={styles.currentPrice}>
            {product.price_formatted}
          </Text>
          {product.old_price > 0 && (
            <Text style={styles.oldPrice}>
              {product.old_price_formatted}
            </Text>
          )}
        </View>
        
        {/* Icons Row */}
        <View style={styles.iconsRow}>
          {renderFreeshipIcon()}
          {renderVoucherIcon()}
          {renderChinhhangIcon()}
        </View>
        
        {/* Badges */}
        {product.badges.length > 0 && (
          <View style={styles.badgesContainer}>
            {product.badges.map((badge, index) => (
              <View key={index} style={styles.badge}>
                <Text style={styles.badgeText}>{badge}</Text>
              </View>
            ))}
          </View>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  productCard: {
    backgroundColor: '#fff',
    borderRadius: 8,
    margin: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  productImage: {
    width: '100%',
    height: 200,
    borderTopLeftRadius: 8,
    borderTopRightRadius: 8,
  },
  productInfo: {
    padding: 12,
  },
  productName: {
    fontSize: 14,
    fontWeight: '500',
    color: '#333',
    marginBottom: 8,
  },
  priceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  currentPrice: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#e74c3c',
  },
  oldPrice: {
    fontSize: 14,
    color: '#999',
    textDecorationLine: 'line-through',
    marginLeft: 8,
  },
  iconsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 8,
  },
  freeshipContainer: {
    backgroundColor: '#27ae60',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginRight: 4,
    marginBottom: 4,
  },
  freeshipText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '500',
  },
  voucherContainer: {
    backgroundColor: '#3498db',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginRight: 4,
    marginBottom: 4,
  },
  voucherText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '500',
  },
  chinhhangContainer: {
    backgroundColor: '#f39c12',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginRight: 4,
    marginBottom: 4,
  },
  chinhhangText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '500',
  },
  badgesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  badge: {
    backgroundColor: '#e74c3c',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 3,
    marginRight: 4,
    marginBottom: 4,
  },
  badgeText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: '500',
  },
});

export default ProductCard;
```

### **2. React Web Example:**

```jsx
import React from 'react';
import './ProductCard.css';

const ProductCard = ({ product }) => {
  const renderFreeshipIcon = () => {
    if (!product.freeship_icon) return null;
    
    return (
      <span className="freeship-icon">
        {product.freeship_icon}
      </span>
    );
  };

  const renderVoucherIcon = () => {
    if (!product.voucher_icon) return null;
    
    return (
      <span className="voucher-icon">
        {product.voucher_icon}
      </span>
    );
  };

  const renderChinhhangIcon = () => {
    if (!product.chinhhang_icon) return null;
    
    return (
      <span className="chinhhang-icon">
        {product.chinhhang_icon}
      </span>
    );
  };

  return (
    <div className="product-card">
      <div className="product-image">
        <img src={product.image} alt={product.name} />
      </div>
      
      <div className="product-info">
        <h3 className="product-name">{product.name}</h3>
        
        <div className="price-container">
          <span className="current-price">
            {product.price_formatted}
          </span>
          {product.old_price > 0 && (
            <span className="old-price">
              {product.old_price_formatted}
            </span>
          )}
        </div>
        
        <div className="icons-row">
          {renderFreeshipIcon()}
          {renderVoucherIcon()}
          {renderChinhhangIcon()}
        </div>
        
        {product.badges.length > 0 && (
          <div className="badges-container">
            {product.badges.map((badge, index) => (
              <span key={index} className="badge">
                {badge}
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ProductCard;
```

### **3. CSS Styles:**

```css
.product-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin: 8px;
  overflow: hidden;
}

.product-image img {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.product-info {
  padding: 12px;
}

.product-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 8px;
  line-height: 1.4;
}

.price-container {
  margin-bottom: 8px;
}

.current-price {
  font-size: 16px;
  font-weight: bold;
  color: #e74c3c;
}

.old-price {
  font-size: 14px;
  color: #999;
  text-decoration: line-through;
  margin-left: 8px;
}

.icons-row {
  display: flex;
  flex-wrap: wrap;
  margin-bottom: 8px;
}

.freeship-icon {
  background: #27ae60;
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  margin-right: 4px;
  margin-bottom: 4px;
}

.voucher-icon {
  background: #3498db;
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  margin-right: 4px;
  margin-bottom: 4px;
}

.chinhhang-icon {
  background: #f39c12;
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  margin-right: 4px;
  margin-bottom: 4px;
}

.badges-container {
  display: flex;
  flex-wrap: wrap;
}

.badge {
  background: #e74c3c;
  color: #fff;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 10px;
  font-weight: 500;
  margin-right: 4px;
  margin-bottom: 4px;
}
```

---

## 🔄 **FLASH SALE PRODUCTS:**

Flash sale products có cùng logic freeship trong `sub_products`:

```javascript
// Xử lý flash sale products
const renderFlashSaleProducts = (flashSale) => {
  return Object.values(flashSale.sub_products).map((productData) => {
    const product = productData.product_info;
    
    return (
      <ProductCard 
        key={product.id} 
        product={product} 
        isFlashSale={true}
      />
    );
  });
};
```

---

## 🧪 **TESTING:**

### **1. Test Cases:**

```javascript
// Test freeship icons
const testCases = [
  {
    freeship_icon: "Giảm 30.000đ ship",
    expected: "Mode 0 - Giảm ship cố định"
  },
  {
    freeship_icon: "Freeship 100%",
    expected: "Mode 1 - Miễn phí ship hoàn toàn"
  },
  {
    freeship_icon: "Giảm 50% ship",
    expected: "Mode 2 - Giảm ship theo %"
  },
  {
    freeship_icon: "Hỗ trợ ship 15.000₫",
    expected: "Mode 3 - Hỗ trợ ship theo sản phẩm"
  },
  {
    freeship_icon: "",
    expected: "Không có freeship"
  }
];
```

### **2. API Testing:**

```bash
# Test shop với Mode 3
curl -X GET "https://api.socdo.vn/v1/API_socdo/shop_detail.php?shop_id=23933" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Test shop với Mode 0
curl -X GET "https://api.socdo.vn/v1/API_socdo/shop_detail.php?shop_id=31469" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 📋 **CHECKLIST:**

- [ ] **API Integration**: Đã tích hợp API shop_detail.php
- [ ] **Freeship Icons**: Hiển thị đúng các loại freeship icon
- [ ] **Voucher Icons**: Hiển thị voucher icon khi có
- [ ] **Chinhhang Icons**: Hiển thị chính hãng icon khi có
- [ ] **Badges**: Hiển thị badges giảm giá
- [ ] **Flash Sale**: Xử lý freeship cho flash sale products
- [ ] **Error Handling**: Xử lý lỗi khi API không trả về freeship_icon
- [ ] **Testing**: Test với các shop có Mode khác nhau

---

## 🎯 **KEY POINTS:**

1. **freeship_icon** là field chính để hiển thị thông tin freeship
2. **Mode 3** hiển thị số tiền cụ thể (ví dụ: "Hỗ trợ ship 15.000₫")
3. **Empty string** có nghĩa là không có freeship
4. **Flash sale products** có cùng logic freeship trong `sub_products`
5. **Consistent** với logic checkout/view/shopcart của tongkho

---

**📞 Support**: Liên hệ team dev nếu cần hỗ trợ tích hợp!
