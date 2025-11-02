# Hướng dẫn Cài đặt và Chạy Dự án

## Yêu cầu Hệ thống

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code với Flutter extension
- Android SDK hoặc Xcode (cho iOS)

## Cài đặt Dependencies

```bash
flutter pub get
```

## Chạy Ứng dụng

```bash
flutter run
```

## Cấu trúc Dự án

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── farm_zone.dart          # Vùng trồng
│   ├── planting_lot.dart       # Lô trồng
│   ├── care_log.dart           # Nhật ký chăm sóc
│   ├── harvest.dart            # Thu hoạch
│   ├── warehouse.dart          # Kho và đóng gói
│   ├── certification.dart      # Chứng nhận
│   └── gps_point.dart          # Điểm GPS
├── screens/                     # Màn hình UI
│   ├── auth/                   # Đăng nhập/Đăng ký
│   ├── home/                   # Dashboard
│   ├── farm_zone/              # Quản lý Vùng trồng
│   ├── planting_lot/           # Quản lý Lô trồng
│   ├── care_log/               # Nhật ký chăm sóc
│   ├── harvest/                # Thu hoạch
│   ├── warehouse/              # Quản lý Kho
│   └── certification/          # Chứng nhận
├── providers/                   # State management
│   ├── auth_provider.dart      # Authentication
│   └── farm_provider.dart      # Farm data management
└── utils/                       # Utilities
    └── image_helper.dart       # Image utilities
```

## Chức năng Đã Hoàn thành

### ✅ Quản lý Vùng trồng
- Tạo/Chỉnh sửa/Xem vùng trồng
- Quản lý thông tin vùng (tên, địa chỉ, doanh nghiệp, lịch sử đất)
- Tải ảnh tổng quan
- Xem danh sách lô trồng trong vùng

### ✅ Quản lý Lô trồng
- Tạo/Chỉnh sửa/Xem lô trồng
- Quản lý thông tin lô (mã, tên, giống, nguồn giống, mật độ, số cây)
- Quản lý trạng thái lô
- Tải ảnh lô

### ✅ Nhật ký Chăm sóc
- Ghi nhận các hoạt động: Tưới nước, Bón phân, Làm cỏ, Phòng trừ sâu bệnh, Cắt tỉa, Kiểm tra
- Mô tả hoạt động, vật tư sử dụng
- Tải ảnh minh chứng
- Tích hợp sẵn sàng cho dữ liệu IoT và thời tiết

### ✅ Thu hoạch & Sơ chế
- Ghi nhận thông tin thu hoạch
- Quản lý khối lượng, nhóm thực hiện
- Ghi nhận mẫu DNA
- Tải ảnh thu hoạch
- (Sơ chế sẽ được mở rộng sau)

### ✅ Quản lý Kho & Đóng gói
- Nhập kho nguyên liệu khô
- Đóng gói sản phẩm với QR Code
- Quản lý SKU, tên sản phẩm
- Tải ảnh minh chứng

### ✅ Theo dõi Chứng nhận
- Hiển thị trạng thái chứng nhận GACP, Organic, OCOP
- Checklist các yêu cầu
- Hiển thị tiến độ hoàn thành
- (Xuất PDF sẽ được mở rộng sau)

## Các Tính năng Cần Bổ sung

- [ ] Tích hợp bản đồ để vẽ ranh giới GPS
- [ ] Kết nối API IoT để lấy dữ liệu cảm biến
- [ ] Kết nối API thời tiết
- [ ] Đồng bộ dữ liệu với Dashboard trung tâm
- [ ] Xuất báo cáo PDF
- [ ] Quản lý sơ chế chi tiết
- [ ] Xác thực người dùng thực tế với backend

## Lưu ý

- Hiện tại dữ liệu được lưu trong memory (Provider). Cần tích hợp database thực tế (SQLite hoặc API backend).
- Authentication hiện tại là mock. Cần tích hợp với backend thực tế.
- Một số chức năng như vẽ GPS boundary và xuất PDF cần được triển khai đầy đủ.



