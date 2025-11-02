# Tích hợp SQLite - Tóm tắt

## ✅ Đã Hoàn Thành

### 1. Database Service (`lib/services/database_service.dart`)
- ✅ Tạo singleton `DatabaseService` để quản lý SQLite
- ✅ Tạo schema cho tất cả các bảng:
  - `farm_zones` - Vùng trồng
  - `planting_lots` - Lô trồng
  - `care_logs` - Nhật ký chăm sóc
  - `harvests` - Thu hoạch
  - `warehouse_entries` - Kho nguyên liệu
  - `packagings` - Đóng gói
  - `certifications` - Chứng nhận
- ✅ Tạo indexes để tối ưu truy vấn
- ✅ Serialize/Deserialize dữ liệu phức tạp (GPS, JSON, lists)

### 2. Cập nhật Farm Provider (`lib/providers/farm_provider.dart`)
- ✅ Thay đổi từ lưu trong memory sang SQLite
- ✅ Tất cả methods giờ là async và lưu vào database
- ✅ Thêm method `initialize()` để load dữ liệu khi app khởi động
- ✅ Tự động reload dữ liệu sau khi thêm/sửa/xóa

### 3. Hiển thị Ảnh
- ✅ Tạo widget `ImageGalleryWidget` để hiển thị gallery ảnh
- ✅ Hiển thị ảnh trong màn hình chi tiết Vùng trồng
- ✅ Hiển thị ảnh trong màn hình chi tiết Lô trồng
- ✅ Có thể tap để xem fullscreen

### 4. Cập nhật Main App (`lib/main.dart`)
- ✅ Thêm `AppInitializer` để khởi tạo database khi app start
- ✅ Hiển thị loading indicator trong lúc khởi tạo

### 5. Cập nhật Tất cả Forms
- ✅ Tất cả forms giờ lưu vào database (async)
- ✅ Forms sẽ tự động reload dữ liệu sau khi save

## Cấu trúc Database

### Vị trí Database
Database được lưu tại: `{databasesPath}/bio_app.db`

Trên Android: `/data/data/{package_name}/databases/bio_app.db`

### Schema Tables

#### farm_zones
- id (TEXT PRIMARY KEY)
- name, company, address, administrative_address, land_history (TEXT)
- overview_images (TEXT - comma separated)
- boundary (TEXT - serialized GPS points)
- created_at, updated_at (TEXT - ISO8601)

#### planting_lots
- id (TEXT PRIMARY KEY)
- lot_code, lot_name, farm_zone_id (TEXT)
- planting_date (TEXT - ISO8601)
- variety, seed_source, soil_test_result (TEXT)
- density (REAL)
- tree_count (INTEGER)
- status (TEXT - enum name)
- lot_images (TEXT - comma separated)
- boundary (TEXT - serialized)
- created_at, updated_at (TEXT)

#### care_logs
- id (TEXT PRIMARY KEY)
- planting_lot_id, activity_type (TEXT)
- activity_date (TEXT - ISO8601)
- description, materials_used, material_certification, performed_by (TEXT)
- evidence_images (TEXT - comma separated)
- iot_data, weather_data (TEXT - JSON encoded)
- created_at (TEXT)

#### harvests
- id (TEXT PRIMARY KEY)
- planting_lot_id (TEXT)
- harvest_date (TEXT - ISO8601)
- harvest_group (TEXT)
- quantity (REAL)
- dna_sample_taken (INTEGER - 0/1)
- harvest_images (TEXT - comma separated)
- processing (TEXT - JSON encoded)
- created_at (TEXT)

#### warehouse_entries
- id (TEXT PRIMARY KEY)
- entry_date (TEXT - ISO8601)
- material_name (TEXT)
- quantity (REAL)
- location (TEXT)
- storage_conditions (TEXT - JSON encoded)
- source_harvest_id (TEXT)
- created_at (TEXT)

#### packagings
- id (TEXT PRIMARY KEY)
- packaging_lot_code, sku, product_name (TEXT)
- packaging_date (TEXT - ISO8601)
- material_ids (TEXT - comma separated)
- quantity (INTEGER)
- unit_weight (REAL)
- packaging_certification, qr_code (TEXT)
- evidence_images (TEXT - comma separated)
- created_at (TEXT)

#### certifications
- id (TEXT PRIMARY KEY)
- type, planting_lot_id (TEXT)
- requirements (TEXT - serialized map)
- is_completed (INTEGER - 0/1)
- completed_date, certificate_number, certificate_file (TEXT)
- created_at, updated_at (TEXT)

## Cách Sử dụng

### Lưu Dữ liệu
Tất cả dữ liệu tự động được lưu vào SQLite khi:
- Tạo mới (addFarmZone, addPlantingLot, etc.)
- Cập nhật (updateFarmZone, updatePlantingLot, etc.)
- Xóa (deleteFarmZone, deletePlantingLot, etc.)

### Load Dữ liệu
Dữ liệu tự động được load khi:
- App khởi động (trong `AppInitializer`)
- Sau khi thêm/sửa/xóa (provider tự reload)

### Hiển thị Ảnh
- Ảnh được lưu dưới dạng file paths trong database
- Sử dụng `ImageGalleryWidget` để hiển thị
- Tap vào ảnh để xem fullscreen

## Lưu Ý

1. **Ảnh được lưu dưới dạng paths**: Ảnh được lưu trong storage của device, chỉ lưu path vào database
2. **Database tự động tạo**: Database sẽ được tạo tự động lần đầu chạy app
3. **Data persistence**: Tất cả dữ liệu sẽ được giữ lại khi app restart
4. **Async operations**: Tất cả database operations là async, đảm bảo UI không bị block

## Kiểm tra Database

Để xem database đã được tạo:
- Database nằm trong thư mục databases của app
- Có thể dùng SQLite browser để mở file `bio_app.db`

## Migration (nếu cần)

Nếu cần thay đổi schema trong tương lai:
1. Tăng version trong `_initDatabase()`
2. Thêm migration logic trong `onUpgrade` callback

