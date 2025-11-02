# Hướng dẫn Cài đặt Flutter trên Windows

## Bước 1: Tải Flutter SDK

1. Truy cập: https://flutter.dev/docs/get-started/install/windows
2. Tải file ZIP Flutter SDK (latest stable version)
3. Giải nén vào thư mục mong muốn, ví dụ: `C:\src\flutter`

**⚠️ LƯU Ý:** 
- KHÔNG giải nén vào `C:\Program Files\` vì quyền truy cập có thể bị hạn chế
- Nên giải nén vào `C:\src\flutter` hoặc `C:\dev\flutter`

## Bước 2: Thêm Flutter vào PATH

### Cách 1: Qua System Properties (Khuyên dùng)

1. Nhấn `Win + R`, gõ `sysdm.cpl` và nhấn Enter
2. Chọn tab **Advanced**
3. Click **Environment Variables**
4. Trong phần **User variables**, tìm biến **Path** và click **Edit**
5. Click **New** và thêm đường dẫn đến thư mục `flutter\bin`
   - Ví dụ: `C:\src\flutter\bin`
6. Click **OK** để lưu tất cả các cửa sổ

### Cách 2: Qua PowerShell (Chạy với quyền Administrator)

```powershell
# Thêm Flutter vào PATH (thay đường dẫn cho đúng)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", "User")
```

## Bước 3: Cài đặt Dependencies

Flutter yêu cầu các công cụ sau:

### Git (Bắt buộc)
- Tải từ: https://git-scm.com/download/win
- Hoặc cài qua Chocolatey: `choco install git`

### Android Studio (Cho phát triển Android)
1. Tải từ: https://developer.android.com/studio
2. Cài đặt Android Studio
3. Mở Android Studio, vào **More Actions > SDK Manager**
4. Cài đặt:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (nếu muốn dùng emulator)

### Visual Studio (Cho phát triển Windows desktop)
- Tải Visual Studio 2022 từ: https://visualstudio.microsoft.com/downloads/
- Khi cài đặt, chọn workload **Desktop development with C++**

## Bước 4: Kiểm tra Cài đặt

1. **Đóng và mở lại Terminal/PowerShell** (quan trọng!)
2. Chạy các lệnh sau:

```bash
# Kiểm tra Flutter
flutter --version

# Chạy doctor để kiểm tra toàn bộ môi trường
flutter doctor

# Kiểm tra chi tiết
flutter doctor -v
```

`flutter doctor` sẽ hiển thị:
- ✅ Những gì đã sẵn sàng
- ❌ Những gì cần cài đặt thêm
- ⚠️ Cảnh báo (có thể bỏ qua nếu không cần)

## Bước 5: Chấp nhận Android Licenses (Nếu dùng Android)

```bash
flutter doctor --android-licenses
```

Nhấn `y` để chấp nhận tất cả licenses.

## Bước 6: Cài đặt VS Code Extensions (Tùy chọn nhưng khuyên dùng)

1. Mở VS Code
2. Cài đặt extension: **Flutter** (từ Dart Code)
3. Cài đặt extension: **Dart** (tự động cài cùng Flutter extension)

## Bước 7: Cài đặt cho Dự án Bio App

Sau khi Flutter đã cài đặt thành công:

```bash
# Di chuyển vào thư mục dự án
cd C:\Users\tuana\OneDrive\Documents\bio-app

# Cài đặt dependencies
flutter pub get

# Kiểm tra xem có thể chạy được không
flutter run
```

## Troubleshooting

### Lỗi: "flutter is not recognized"
- Đảm bảo đã thêm Flutter vào PATH
- **Đóng và mở lại** Terminal/PowerShell
- Kiểm tra đường dẫn: `echo $env:PATH` (PowerShell) hoặc `echo %PATH%` (CMD)

### Lỗi: Android licenses
```bash
flutter doctor --android-licenses
```

### Lỗi: "Unable to locate Android SDK"
- Mở Android Studio
- Tools > SDK Manager
- Đảm bảo Android SDK đã được cài đặt
- Copy đường dẫn SDK (thường là `C:\Users\YourName\AppData\Local\Android\Sdk`)
- Thiết lập biến môi trường `ANDROID_HOME` trỏ đến thư mục đó

### Lỗi: Gradle build
- Đảm bảo Java JDK đã được cài đặt (Android Studio thường đi kèm)

## Cài đặt Nhanh với Chocolatey (Tùy chọn)

Nếu bạn đã cài Chocolatey:

```powershell
# Chạy PowerShell với quyền Administrator
choco install flutter -y
```

## Kiểm tra Nhanh

Sau khi cài đặt xong, chạy:

```bash
flutter doctor -v
```

Tất cả các mục phải có ✅ hoặc ít nhất không có ❌ màu đỏ.

## Tiếp theo

Sau khi Flutter đã được cài đặt và `flutter doctor` không có lỗi nghiêm trọng:

1. Chạy `flutter pub get` trong thư mục dự án
2. Kết nối thiết bị Android/iOS hoặc khởi động emulator
3. Chạy `flutter run` để khởi động ứng dụng

---

**Lưu ý:** Quá trình cài đặt có thể mất 30-60 phút tùy vào tốc độ internet và máy tính của bạn.



