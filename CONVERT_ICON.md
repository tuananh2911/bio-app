# Hướng dẫn chuyển đổi icon.svg sang PNG

Để sử dụng icon SVG làm app icon, bạn cần chuyển đổi file `icon.svg` sang định dạng PNG.

## Cách 1: Sử dụng công cụ online (Khuyến nghị)
1. Truy cập: https://cloudconvert.com/svg-to-png hoặc https://convertio.co/svg-png/
2. Upload file `icon.svg`
3. Chọn kích thước: **1024x1024 pixels** (khuyến nghị)
4. Tải file `icon.png` về
5. Đặt file `icon.png` vào thư mục gốc của project (cùng cấp với `pubspec.yaml`)

## Cách 2: Sử dụng Inkscape (Miễn phí)
1. Tải Inkscape: https://inkscape.org/
2. Mở file `icon.svg` trong Inkscape
3. File → Export PNG Image
4. Chọn kích thước 1024x1024
5. Export và lưu thành `icon.png` trong thư mục gốc project

## Sau khi có icon.png
Chạy lệnh sau để generate icons cho tất cả platforms:
```bash
dart run flutter_launcher_icons
```

Lưu ý: File icon.png cần có kích thước tối thiểu 1024x1024 pixels để đảm bảo chất lượng tốt trên tất cả các thiết bị.

