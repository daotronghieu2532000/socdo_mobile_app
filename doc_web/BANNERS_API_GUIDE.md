# 🎨 API BANNERS (SLIDE BANNER)

## 📌 Endpoint
```
GET https://api.socdo.vn/v1/API_socdo/banners
```

---

## 🎯 Tính năng

API lấy danh sách banner/slide theo vị trí hiển thị:
- ✅ Banner trang chủ mobile
- ✅ Banner trang chủ desktop
- ✅ Banner lớn
- ✅ Banner đối tác
- ✅ Support group by position

---

## 📝 Parameters

| Tham số | Kiểu | Bắt buộc | Mặc định | Mô tả |
|---------|------|----------|----------|-------|
| `position` | string | Không | all | Vị trí banner |
| `limit` | int | Không | 0 | Số lượng (0 = không giới hạn, max: 100) |
| `shop_id` | int | Không | 0 | ID shop (0 = banner hệ thống) |

### **Position values:**

| Position | Mô tả | Sử dụng |
|----------|-------|---------|
| `banner_index_mobile` | Banner trang chủ mobile | ⭐ App mobile |
| `banner_index` | Banner trang chủ desktop | 🖥️ Web |
| `banner_big` | Banner lớn | 🖼️ Promotion |
| `banner_doitac` | Banner đối tác 1 | 🤝 Partners |
| `banner_doitac_hai` | Banner đối tác 2 | 🤝 Partners |
| `all` | Tất cả banner | 📦 All positions |

---

## 🚀 Ví dụ sử dụng

### **1. Lấy banner mobile (khuyến nghị cho app)**
```
GET /v1/API_socdo/banners?position=banner_index_mobile&limit=10
```

### **2. Lấy banner trang chủ desktop**
```
GET /v1/API_socdo/banners?position=banner_index&limit=5
```

### **3. Lấy TẤT CẢ banner**
```
GET /v1/API_socdo/banners?position=all
```

### **4. Lấy banner của shop cụ thể**
```
GET /v1/API_socdo/banners?position=banner_index_mobile&shop_id=12345
```

---

## 📤 Response mẫu

### **1. Response cho position cụ thể:**
```json
{
  "success": true,
  "message": "Lấy danh sách banner thành công",
  "data": {
    "banners": [
      {
        "id": 1,
        "title": "Flash Sale Cuối Tuần",
        "image": "https://socdo.cdn.vccloud.vn/uploads/thumbs/banner_mobile_default/flash-sale-banner.jpg",
        "link": "https://socdo.vn/flash-sale",
        "position": "banner_index_mobile",
        "order": 1,
        "shop_id": 0,
        "type": "image",
        "is_active": true
      },
      {
        "id": 2,
        "title": "Khuyến Mãi Tháng 10",
        "image": "https://socdo.cdn.vccloud.vn/uploads/thumbs/banner_mobile_default/khuyen-mai-thang-10.jpg",
        "link": "https://socdo.vn/khuyen-mai",
        "position": "banner_index_mobile",
        "order": 2,
        "shop_id": 0,
        "type": "image",
        "is_active": true
      }
    ],
    "total": 2,
    "position": "banner_index_mobile"
  }
}
```

### **2. Response cho position=all (grouped):**
```json
{
  "success": true,
  "message": "Lấy danh sách banner thành công",
  "data": {
    "banners": [
      {
        "id": 1,
        "title": "Banner Mobile 1",
        "image": "https://socdo.cdn.vccloud.vn/uploads/thumbs/banner_mobile_default/mobile-1.jpg",
        "link": "https://socdo.vn/sale",
        "position": "banner_index_mobile",
        "order": 1,
        "shop_id": 0,
        "type": "image",
        "is_active": true
      },
      {
        "id": 2,
        "title": "Banner Desktop 1",
        "image": "https://socdo.cdn.vccloud.vn/uploads/minh-hoa/desktop-1.jpg",
        "link": "https://socdo.vn/sale",
        "position": "banner_index",
        "order": 1,
        "shop_id": 0,
        "type": "image",
        "is_active": true
      }
    ],
    "total": 2,
    "position": "all",
    "grouped": {
      "banner_index_mobile": [
        {
          "id": 1,
          "title": "Banner Mobile 1",
          "image": "https://socdo.cdn.vccloud.vn/uploads/thumbs/banner_mobile_default/mobile-1.jpg",
          "link": "https://socdo.vn/sale",
          "position": "banner_index_mobile",
          "order": 1,
          "shop_id": 0,
          "type": "image",
          "is_active": true
        }
      ],
      "banner_index": [
        {
          "id": 2,
          "title": "Banner Desktop 1",
          "image": "https://socdo.cdn.vccloud.vn/uploads/minh-hoa/desktop-1.jpg",
          "link": "https://socdo.vn/sale",
          "position": "banner_index",
          "order": 1,
          "shop_id": 0,
          "type": "image",
          "is_active": true
        }
      ]
    }
  }
}
```

---

## 🎨 UI/UX Integration

### **React/Vue Example - Slider/Carousel:**
```javascript
import { useState, useEffect } from 'react';
import { Swiper, SwiperSlide } from 'swiper/react';
import 'swiper/css';

const BannerSlider = () => {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchBanners();
  }, []);
  
  const fetchBanners = async () => {
    try {
      const response = await fetch(
        '/v1/API_socdo/banners?position=banner_index_mobile&limit=10'
      );
      const data = await response.json();
      
      if (data.success) {
        setBanners(data.data.banners);
      }
    } catch (error) {
      console.error('Error fetching banners:', error);
    } finally {
      setLoading(false);
    }
  };
  
  const handleBannerClick = (banner) => {
    if (banner.link) {
      window.location.href = banner.link;
    }
  };
  
  return (
    <div className="banner-slider">
      {loading ? (
        <div>Loading...</div>
      ) : (
        <Swiper
          spaceBetween={10}
          slidesPerView={1}
          autoplay={{ delay: 3000 }}
          loop={true}
          pagination={{ clickable: true }}
        >
          {banners.map((banner) => (
            <SwiperSlide key={banner.id}>
              <div 
                className="banner-item"
                onClick={() => handleBannerClick(banner)}
              >
                <img 
                  src={banner.image} 
                  alt={banner.title}
                  className="banner-image"
                />
              </div>
            </SwiperSlide>
          ))}
        </Swiper>
      )}
    </div>
  );
};
```

---

## 📱 React Native Example:

```javascript
import React, { useState, useEffect } from 'react';
import { View, Image, TouchableOpacity, Dimensions } from 'react-native';
import Carousel from 'react-native-snap-carousel';

const BannerCarousel = () => {
  const [banners, setBanners] = useState([]);
  const [activeIndex, setActiveIndex] = useState(0);
  const { width } = Dimensions.get('window');
  
  useEffect(() => {
    fetchBanners();
  }, []);
  
  const fetchBanners = async () => {
    try {
      const response = await fetch(
        'https://api.socdo.vn/v1/API_socdo/banners?position=banner_index_mobile&limit=10'
      );
      const data = await response.json();
      
      if (data.success) {
        setBanners(data.data.banners);
      }
    } catch (error) {
      console.error('Error fetching banners:', error);
    }
  };
  
  const handleBannerPress = (banner) => {
    if (banner.link) {
      // Navigate to link or open webview
      navigation.navigate('WebView', { url: banner.link });
    }
  };
  
  const renderBanner = ({ item }) => (
    <TouchableOpacity 
      onPress={() => handleBannerPress(item)}
      activeOpacity={0.8}
    >
      <Image
        source={{ uri: item.image }}
        style={{
          width: width - 40,
          height: 200,
          borderRadius: 10,
        }}
        resizeMode="cover"
      />
    </TouchableOpacity>
  );
  
  return (
    <View style={{ marginVertical: 20 }}>
      <Carousel
        data={banners}
        renderItem={renderBanner}
        sliderWidth={width}
        itemWidth={width - 40}
        onSnapToItem={(index) => setActiveIndex(index)}
        autoplay={true}
        autoplayInterval={3000}
        loop={true}
      />
      
      {/* Pagination dots */}
      <View style={styles.pagination}>
        {banners.map((_, index) => (
          <View
            key={index}
            style={[
              styles.dot,
              index === activeIndex && styles.activeDot
            ]}
          />
        ))}
      </View>
    </View>
  );
};

const styles = {
  pagination: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 10,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#ccc',
    marginHorizontal: 4,
  },
  activeDot: {
    backgroundColor: '#ff6b00',
    width: 20,
  },
};
```

---

## ⚡ Performance Tips

### **1. Caching:**
```javascript
const CACHE_KEY = 'banners_mobile';
const CACHE_TTL = 30 * 60 * 1000; // 30 phút

const getCachedBanners = () => {
  const cached = localStorage.getItem(CACHE_KEY);
  
  if (cached) {
    const data = JSON.parse(cached);
    if (Date.now() - data.timestamp < CACHE_TTL) {
      return data.banners;
    }
  }
  return null;
};

const setCachedBanners = (banners) => {
  localStorage.setItem(CACHE_KEY, JSON.stringify({
    banners,
    timestamp: Date.now()
  }));
};

const fetchBanners = async () => {
  // Try cache first
  const cached = getCachedBanners();
  if (cached) {
    setBanners(cached);
    return;
  }
  
  // Fetch from API
  const response = await fetch('/v1/API_socdo/banners?position=banner_index_mobile');
  const data = await response.json();
  
  if (data.success) {
    setBanners(data.data.banners);
    setCachedBanners(data.data.banners);
  }
};
```

### **2. Preload Images:**
```javascript
const preloadBannerImages = (banners) => {
  banners.forEach(banner => {
    const img = new Image();
    img.src = banner.image;
  });
};

useEffect(() => {
  if (banners.length > 0) {
    preloadBannerImages(banners);
  }
}, [banners]);
```

### **3. Lazy Loading:**
```javascript
// React Native - Lazy load images
import FastImage from 'react-native-fast-image';

<FastImage
  source={{ 
    uri: banner.image,
    priority: FastImage.priority.high,
    cache: FastImage.cacheControl.immutable
  }}
  style={{ width: '100%', height: 200 }}
  resizeMode={FastImage.resizeMode.cover}
/>
```

---

## 🔄 Auto-refresh banners

### **Refresh on app resume (React Native):**
```javascript
import { useEffect } from 'react';
import { AppState } from 'react-native';

const BannerScreen = () => {
  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (nextAppState === 'active') {
        // Refresh banners when app comes to foreground
        fetchBanners();
      }
    });
    
    return () => subscription.remove();
  }, []);
  
  // ... rest of component
};
```

---

## 📊 Image Size Recommendations

| Position | Desktop | Mobile | Aspect Ratio |
|----------|---------|--------|--------------|
| `banner_index_mobile` | - | 750 x 300px | 5:2 |
| `banner_index` | 1920 x 600px | - | 16:5 |
| `banner_big` | 1920 x 800px | 750 x 400px | varies |
| `banner_doitac` | 400 x 200px | 300 x 150px | 2:1 |

---

## 🎯 Analytics Tracking

### **Track banner clicks:**
```javascript
const handleBannerClick = (banner) => {
  // Track analytics
  analytics.track('Banner Clicked', {
    banner_id: banner.id,
    banner_title: banner.title,
    banner_position: banner.position,
    banner_order: banner.order,
    link: banner.link
  });
  
  // Navigate
  if (banner.link) {
    window.location.href = banner.link;
  }
};
```

### **Track banner impressions:**
```javascript
useEffect(() => {
  if (banners.length > 0) {
    analytics.track('Banners Loaded', {
      total_banners: banners.length,
      position: 'banner_index_mobile',
      banner_ids: banners.map(b => b.id)
    });
  }
}, [banners]);
```

---

## ✅ Checklist tích hợp

- [ ] **Backend**: API đã test
- [ ] **Home Screen**:
  - [ ] Banner slider/carousel
  - [ ] Auto-play 3-5 giây
  - [ ] Pagination dots
  - [ ] Click to navigate
- [ ] **Performance**:
  - [ ] Cache banners 30 phút
  - [ ] Preload images
  - [ ] Fast Image (RN)
- [ ] **Analytics**:
  - [ ] Track impressions
  - [ ] Track clicks
  - [ ] Track conversion
- [ ] **UX**:
  - [ ] Loading skeleton
  - [ ] Error fallback
  - [ ] Refresh on app resume

---

## 🔍 Debugging

### **Check banner data in database:**
```sql
-- Lấy banner mobile
SELECT id, tieu_de, vi_tri, thu_tu, link_url, minh_hoa 
FROM banner 
WHERE vi_tri = 'banner_index_mobile' AND shop_id = 0 
ORDER BY thu_tu ASC;

-- Lấy tất cả banner
SELECT vi_tri, COUNT(*) as total 
FROM banner 
WHERE shop_id = 0 
GROUP BY vi_tri;
```

---

**📞 Support**: Liên hệ team dev nếu cần hỗ trợ!

