# 💡 Ví Dụ Cụ Thể Về Java Warnings

## 📚 Mục Đích

File này chứa các ví dụ code Java cụ thể để bạn hiểu rõ hơn về các warnings.

---

## ⚠️ Ví Dụ 1: Deprecated API

### ❌ Code Có Warning (Deprecated)

```java
// File: FlutterFirebaseMessagingPlugin.java (trong plugin)

// ❌ WARNING: setSmallIcon() với cách cũ - Deprecated
Notification notification = new Notification.Builder(context)
    .setSmallIcon(R.drawable.ic_notification)  // Deprecated API
    .setContentTitle("Title")
    .setContentText("Message")
    .build();

// ❌ WARNING: getSystemService() với cách cũ
NotificationManager nm = (NotificationManager) 
    context.getSystemService(Context.NOTIFICATION_SERVICE);  // Deprecated
```

### ✅ Code Modern (Không Có Warning)

```java
// ✅ Modern: Dùng NotificationCompat
NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
    .setSmallIcon(R.drawable.ic_notification)  // Modern API
    .setContentTitle("Title")
    .setContentText("Message");

Notification notification = builder.build();

// ✅ Modern: Dùng getSystemService() với type safety
NotificationManager nm = context.getSystemService(NotificationManager.class);
```

---

## ⚠️ Ví Dụ 2: Unchecked Operations

### ❌ Code Có Warning (Unchecked)

```java
// File: FlutterFirebaseMessagingPlugin.java (trong plugin)

// ❌ WARNING: Unchecked cast
// Java không thể verify 100% rằng getData() trả về Map<String, Object>
Map<String, Object> data = (Map<String, Object>) message.getData();

// ❌ WARNING: Raw type (không có generic)
List items = someMethod();  // Raw type, không có List<String>
items.add("test");  // Unsafe!
```

### ✅ Code Safe (Không Có Warning)

```java
// ✅ Safe: Kiểm tra type trước khi cast
Object rawData = message.getData();
if (rawData instanceof Map) {
    @SuppressWarnings("unchecked")
    Map<String, Object> data = (Map<String, Object>) rawData;
    // Safe vì đã check instanceof
}

// ✅ Safe: Dùng generic type
List<String> items = someMethod();  // Có generic type
items.add("test");  // Safe!
```

---

## 🔍 Ví Dụ 3: Code Trong Plugin Thực Tế

### Vị Trí Warning Trong Plugin

File: `~/.pub-cache/hosted/pub.dev/firebase_messaging-14.7.10/android/src/main/java/io/flutter/plugins/firebase/messaging/FlutterFirebaseMessagingPlugin.java`

### Có Thể Có Code Như Thế Này:

```java
// Dòng có thể gây warning "deprecated"
@Override
public void onMessageReceived(RemoteMessage message) {
    // ❌ Có thể dùng API cũ ở đây
    Notification notification = new Notification.Builder(context)  // Deprecated
        .setSmallIcon(R.drawable.ic_notification)
        .build();
}

// Dòng có thể gây warning "unchecked"
private Map<String, Object> parseMessageData(RemoteMessage message) {
    // ❌ Unchecked cast
    Map<String, Object> data = (Map<String, Object>) message.getData();
    return data;
}
```

---

## 🎯 So Sánh: Trước và Sau

### 🔴 Trước (Có Warnings)

```java
// Plugin code cũ
NotificationManager nm = (NotificationManager) 
    context.getSystemService("notification");  // Deprecated
    
Map<String, Object> data = (Map<String, Object>) message.getData();  // Unchecked
```

**Output:**
```
Note: Some input files use or override a deprecated API.
Note: ... uses unchecked or unsafe operations.
```

### 🟢 Sau (Không Có Warnings)

```java
// Plugin code mới (sẽ update trong tương lai)
NotificationManager nm = context.getSystemService(NotificationManager.class);  // Modern

@SuppressWarnings("unchecked")
Map<String, Object> data = (Map<String, Object>) message.getData();  // Suppressed
```

**Output:**
```
✅ No warnings
```

---

## 🔧 Cách Fix Warnings (Cho Plugin Developer)

### Fix 1: Thay Deprecated API

```java
// ❌ Cũ
NotificationManager nm = (NotificationManager) 
    context.getSystemService(Context.NOTIFICATION_SERVICE);

// ✅ Mới
NotificationManager nm = context.getSystemService(NotificationManager.class);
```

### Fix 2: Fix Unchecked Operations

```java
// ❌ Cũ
Map<String, Object> data = (Map<String, Object>) message.getData();

// ✅ Mới - Kiểm tra type
Object rawData = message.getData();
if (rawData instanceof Map) {
    @SuppressWarnings("unchecked")
    Map<String, Object> data = (Map<String, Object>) rawData;
    // Use data safely
}
```

---

## 📊 Tóm Tắt

| Warning Type | Ví Dụ Code | Cách Fix |
|--------------|-----------|----------|
| **Deprecated** | `getSystemService("notification")` | `getSystemService(NotificationManager.class)` |
| **Unchecked** | `(Map<String, Object>) message.getData()` | Check `instanceof` trước khi cast |
| **Raw Type** | `List items` | `List<String> items` |

---

**💡 Lưu ý**: Bạn **không cần fix** code này - đây là code của plugin developer. Plugin sẽ được update trong tương lai để fix các warnings này.

