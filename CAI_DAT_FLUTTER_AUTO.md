# Tự động Cài đặt Flutter

Script này sẽ tự động tải và cài đặt Flutter SDK cho Windows.

## Cách sử dụng

### Cách 1: Chạy với quyền bình thường (khuyên dùng)

```powershell
powershell -ExecutionPolicy Bypass -File auto_install_flutter.ps1
```

Sau đó thêm Flutter vào PATH thủ công:
1. Nhấn `Win + R`, gõ `sysdm.cpl`
2. Advanced → Environment Variables
3. Tìm `Path` trong User variables → Edit
4. New → thêm: `C:\src\flutter\bin`
5. OK để lưu

### Cách 2: Chạy với quyền Administrator (tự động thêm vào PATH)

1. Mở PowerShell với quyền Administrator (Right-click → Run as Administrator)
2. Chạy:

```powershell
cd C:\Users\tuana\OneDrive\Documents\bio-app
powershell -ExecutionPolicy Bypass -File auto_install_flutter.ps1
```

## Tùy chọn cài đặt

Bạn có thể chỉnh sửa đường dẫn cài đặt:

```powershell
# Cài vào C:\dev\flutter thay vì C:\src\flutter
powershell -ExecutionPolicy Bypass -File auto_install_flutter.ps1 -InstallPath "C:\dev\flutter"
```

## Quy trình

1. ✅ Kiểm tra Git (bắt buộc)
2. ✅ Tạo thư mục cài đặt
3. ✅ Tải Flutter SDK từ GitHub (stable channel)
4. ✅ Khởi tạo Flutter
5. ✅ Thêm vào PATH (nếu có quyền Admin)

## Sau khi cài đặt

1. **Đóng và mở lại Terminal/PowerShell**

2. Kiểm tra cài đặt:
```bash
flutter --version
flutter doctor
```

3. Chấp nhận Android licenses (nếu cần):
```bash
flutter doctor --android-licenses
```

4. Cài dependencies cho dự án:
```bash
cd C:\Users\tuana\OneDrive\Documents\bio-app
flutter pub get
```

5. Chạy ứng dụng:
```bash
flutter run
```

## Lưu ý

- Quá trình tải có thể mất 5-15 phút tùy tốc độ internet
- Cần có Git đã được cài đặt
- Nếu gặp lỗi, hãy kiểm tra kết nối internet và thử lại

## Troubleshooting

### Lỗi: "Git is required"
- Cài Git từ: https://git-scm.com/download/win

### Lỗi: "Access denied"
- Chạy PowerShell với quyền Administrator

### Lỗi: "flutter is not recognized"
- Đảm bảo đã đóng và mở lại Terminal
- Kiểm tra PATH: `echo $env:PATH` (PowerShell) hoặc `echo %PATH%` (CMD)



