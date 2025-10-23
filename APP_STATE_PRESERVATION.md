# App State Preservation System

## Tổng quan

Hệ thống **App State Preservation** được thiết kế để giải quyết vấn đề app bị reload khi người dùng chuyển sang app khác và quay lại sau một thời gian ngắn (1-2 phút).

## Vấn đề được giải quyết

- **Trước:** Khi người dùng chuyển sang Facebook 5 phút rồi quay lại app, app sẽ reload và quay về trang chủ
- **Sau:** Khi người dùng chuyển sang Facebook 1-2 phút rồi quay lại app, app sẽ giữ nguyên vị trí scroll và tab hiện tại

## Các thành phần chính

### 1. AppLifecycleManager (`lib/src/core/services/app_lifecycle_manager.dart`)

Quản lý lifecycle của app và lưu trữ state:

- **Theo dõi trạng thái:** `AppLifecycleState.resumed`, `AppLifecycleState.paused`
- **Lưu trữ state:** Tab hiện tại, vị trí scroll của từng tab
- **Timeout:** State sẽ hết hạn sau 5 phút (có thể điều chỉnh)
- **Khôi phục state:** Tự động khôi phục khi app resume

**Các phương thức chính:**
```dart
// Lưu tab hiện tại
await _lifecycleManager.saveCurrentTab(tabIndex);

// Lưu vị trí scroll
await _lifecycleManager.saveScrollPosition(tabIndex, scrollPosition);

// Khôi phục tab đã lưu
final savedTab = await _lifecycleManager.getSavedTab();

// Khôi phục vị trí scroll
final savedPosition = await _lifecycleManager.getSavedScrollPosition(tabIndex);
```

### 2. ScrollPreservationWrapper (`lib/src/core/widgets/scroll_preservation_wrapper.dart`)

Widget wrapper để tự động lưu trữ và khôi phục vị trí scroll:

- **Tự động lưu:** Lưu vị trí scroll khi người dùng scroll
- **Tự động khôi phục:** Khôi phục vị trí scroll khi widget được khởi tạo
- **Animation:** Smooth scroll animation khi khôi phục

**Cách sử dụng:**
```dart
ScrollPreservationWrapper(
  tabIndex: 0, // Home tab
  scrollController: _scrollController,
  child: Scaffold(...),
)
```

### 3. RootShell Integration

`RootShell` được cập nhật để:

- **Khởi tạo AppLifecycleManager** khi app start
- **Lưu tab hiện tại** khi người dùng chuyển tab
- **Khôi phục tab** khi app resume từ background

### 4. Screen Integration

Các screen chính được wrap với `ScrollPreservationWrapper`:

- **HomeScreen** (tab 0): Lưu vị trí scroll của ListView
- **CategoryScreen** (tab 1): Lưu vị trí scroll của danh mục
- **AffiliateScreen** (tab 2): Lưu vị trí scroll của nội dung

## Cách hoạt động

### 1. Khi app đi vào background (pause)
```
User chuyển sang Facebook
    ↓
AppLifecycleManager.didChangeAppLifecycleState(AppLifecycleState.paused)
    ↓
Lưu thời gian pause: DateTime.now()
    ↓
Lưu tab hiện tại và vị trí scroll
```

### 2. Khi app resume từ background
```
User quay lại app
    ↓
AppLifecycleManager.didChangeAppLifecycleState(AppLifecycleState.resumed)
    ↓
Kiểm tra thời gian: DateTime.now() - lastPauseTime
    ↓
Nếu < 5 phút: Khôi phục state
Nếu > 5 phút: Bỏ qua, app reload bình thường
```

### 3. Khôi phục state
```
RootShell.initState()
    ↓
AppLifecycleManager.getSavedTab()
    ↓
Nếu có tab đã lưu: setState(_currentIndex = savedTab)
    ↓
ScrollPreservationWrapper.initState()
    ↓
AppLifecycleManager.getSavedScrollPosition(tabIndex)
    ↓
Nếu có vị trí đã lưu: scrollController.animateTo(savedPosition)
```

## Cấu hình

### Thời gian timeout
```dart
// Trong AppLifecycleManager
static const Duration _stateTimeout = Duration(minutes: 5);
```

### Keys cho SharedPreferences
```dart
static const String _currentTabKey = 'app_current_tab';
static const String _homeScrollPositionKey = 'home_scroll_position';
static const String _categoryScrollPositionKey = 'category_scroll_position';
static const String _affiliateScrollPositionKey = 'affiliate_scroll_position';
static const String _lastActiveTimeKey = 'app_last_active_time';
```

## Debug và Monitoring

Hệ thống có logging chi tiết:

```
📱 App paused
💾 Saved current tab: 1
💾 Saved scroll position for tab 1: 250.0
📱 App resumed
📂 Restored tab: 1
📂 Restored scroll position for tab 1: 250.0
```

## Lợi ích

1. **Trải nghiệm người dùng tốt hơn:** Không bị mất vị trí khi chuyển app
2. **Tiết kiệm băng thông:** Không cần reload data không cần thiết
3. **Tự động:** Không cần can thiệp thủ công
4. **Linh hoạt:** Có thể điều chỉnh timeout và các tham số
5. **Hiệu suất:** Chỉ lưu trữ state cần thiết

## Mở rộng

Hệ thống có thể được mở rộng để:

- Lưu trữ state của các screen con (product detail, cart, etc.)
- Lưu trữ form data chưa submit
- Lưu trữ filter/search state
- Lưu trữ user preferences

## Kết luận

Hệ thống App State Preservation đã giải quyết thành công vấn đề app reload khi người dùng chuyển sang app khác trong thời gian ngắn. Người dùng giờ đây có thể:

- Chuyển sang Facebook 1-2 phút và quay lại app mà không bị mất vị trí
- Tiếp tục scroll từ vị trí đã dừng lại
- Ở đúng tab đã chọn trước đó

Thời gian timeout 5 phút đảm bảo rằng nếu người dùng rời app quá lâu, app sẽ reload để đảm bảo data được cập nhật mới nhất.
