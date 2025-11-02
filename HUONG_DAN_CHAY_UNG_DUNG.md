# Hướng dẫn Chạy Ứng dụng Bio App

## ✅ Đã Hoàn Thành

- ✅ Flutter đã được cài đặt
- ✅ Dependencies đã được cài đặt (117 packages)
- ✅ Platform configurations đã được tạo (Android, iOS, Windows, Web)
- ✅ Thiết bị đã được phát hiện

## Chạy Ứng dụng

### Cách 1: Chạy trên điện thoại Android (Pixel 7a)

```bash
flutter run -d 2C121JEHN10372
```

Hoặc đơn giản:
```bash
flutter run
```
Flutter sẽ tự động chọn thiết bị Android nếu chỉ có một thiết bị Android kết nối.

### Cách 2: Chạy trên Windows Desktop

```bash
flutter run -d windows
```

### Cách 3: Chạy trên Chrome (Web)

```bash
flutter run -d chrome
```

### Cách 4: Chạy trên Edge (Web)

```bash
flutter run -d edge
```

## Chọn Thiết bị Tương tác

Khi chạy `flutter run` mà có nhiều thiết bị, Flutter sẽ hỏi bạn chọn:

```
Multiple devices found:
1 • Pixel 7a (mobile) • android-arm64
2 • Windows (desktop) • windows-x64
3 • Chrome (web) • web-javascript

Please choose one (1-3):
```

Nhập số tương ứng với thiết bị bạn muốn.

## Lưu ý

### Về cảnh báo Developer Mode

Nếu thấy cảnh báo về symlink:
- **Không cần thiết** nếu chỉ chạy trên thiết bị thật (Android phone)
- **Cần thiết** nếu muốn build APK hoặc chạy emulator
- Để bật: Chạy `start ms-settings:developers` và bật Developer Mode

### Android Permissions

Khi chạy trên Android, ứng dụng cần các quyền:
- Camera (cho chụp ảnh)
- Storage (cho lưu trữ file)
- Location (cho GPS - sẽ thêm sau)

Các quyền này sẽ được yêu cầu khi cần sử dụng tính năng tương ứng.

## Lệnh Hữu Ích

```bash
# Xem danh sách thiết bị
flutter devices

# Chạy với hot reload (mặc định)
flutter run

# Build APK (sau khi fix symlink warning)
flutter build apk

# Build app bundle cho Google Play
flutter build appbundle

# Chạy với debug mode
flutter run --debug

# Chạy với release mode
flutter run --release

# Hot restart (nhấn 'R' trong terminal khi app đang chạy)
# Hot reload (nhấn 'r' trong terminal khi app đang chạy)
```

## Troubleshooting

### Lỗi: "No supported devices connected"
- Đảm bảo đã chạy `flutter create .` để tạo platform configs
- Kiểm tra thiết bị với `flutter devices`

### Lỗi: "Multiple devices found"
- Chỉ định thiết bị cụ thể: `flutter run -d <device-id>`

### Lỗi: Android build failed
- Chấp nhận licenses: `flutter doctor --android-licenses`
- Kiểm tra Android SDK đã được cài đặt đầy đủ

### Lỗi: Symlink required
- Bật Developer Mode (không bắt buộc cho chạy trên thiết bị thật)
- Chạy: `start ms-settings:developers`

## Bước Tiếp Theo

1. **Chạy ứng dụng lần đầu:**
   ```bash
   flutter run
   ```

2. **Nếu chạy trên Android:**
   - Ứng dụng sẽ tự động cài đặt trên điện thoại
   - Cho phép cài đặt từ nguồn không xác định nếu được hỏi

3. **Phát triển:**
   - Sử dụng hot reload để xem thay đổi nhanh
   - Nhấn `r` để hot reload
   - Nhấn `R` để hot restart
   - Nhấn `q` để thoát

---

**Chúc bạn phát triển thành công! 🚀**

