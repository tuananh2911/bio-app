import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/farm_zone.dart';
import '../models/planting_lot.dart';
import '../models/care_log.dart';
import '../models/harvest.dart';
import '../models/warehouse.dart';
import '../models/certification.dart';
import '../models/gps_point.dart';

// Import for nested classes
import '../models/iot_data.dart';
import '../models/care_log.dart' show WeatherData;
import '../models/harvest.dart' show Processing, ProcessingStep;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bio_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Farm Zones table
    await db.execute('''
      CREATE TABLE farm_zones (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        company TEXT,
        address TEXT,
        administrative_address TEXT,
        land_history TEXT,
        overview_images TEXT,
        boundary TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Planting Lots table
    await db.execute('''
      CREATE TABLE planting_lots (
        id TEXT PRIMARY KEY,
        lot_code TEXT NOT NULL,
        lot_name TEXT NOT NULL,
        farm_zone_id TEXT NOT NULL,
        planting_date TEXT NOT NULL,
        variety TEXT,
        seed_source TEXT,
        density REAL,
        tree_count INTEGER,
        soil_test_result TEXT,
        status TEXT NOT NULL,
        lot_images TEXT,
        boundary TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (farm_zone_id) REFERENCES farm_zones(id)
      )
    ''');

    // Care Logs table
    await db.execute('''
      CREATE TABLE care_logs (
        id TEXT PRIMARY KEY,
        planting_lot_id TEXT NOT NULL,
        activity_type TEXT NOT NULL,
        activity_date TEXT NOT NULL,
        description TEXT,
        materials_used TEXT,
        material_certification TEXT,
        performed_by TEXT,
        evidence_images TEXT,
        iot_data TEXT,
        weather_data TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (planting_lot_id) REFERENCES planting_lots(id)
      )
    ''');

    // Harvests table
    await db.execute('''
      CREATE TABLE harvests (
        id TEXT PRIMARY KEY,
        planting_lot_id TEXT NOT NULL,
        harvest_date TEXT NOT NULL,
        harvest_group TEXT,
        quantity REAL NOT NULL,
        dna_sample_taken INTEGER NOT NULL,
        harvest_images TEXT,
        processing TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (planting_lot_id) REFERENCES planting_lots(id)
      )
    ''');

    // Warehouse Entries table
    await db.execute('''
      CREATE TABLE warehouse_entries (
        id TEXT PRIMARY KEY,
        entry_date TEXT NOT NULL,
        material_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        location TEXT,
        storage_conditions TEXT,
        source_harvest_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (source_harvest_id) REFERENCES harvests(id)
      )
    ''');

    // Packaging table
    await db.execute('''
      CREATE TABLE packagings (
        id TEXT PRIMARY KEY,
        packaging_lot_code TEXT NOT NULL,
        packaging_date TEXT NOT NULL,
        sku TEXT NOT NULL,
        product_name TEXT NOT NULL,
        material_ids TEXT,
        quantity INTEGER NOT NULL,
        unit_weight REAL NOT NULL,
        packaging_certification TEXT,
        qr_code TEXT,
        evidence_images TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Certifications table
    await db.execute('''
      CREATE TABLE certifications (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        planting_lot_id TEXT NOT NULL,
        requirements TEXT,
        is_completed INTEGER NOT NULL,
        completed_date TEXT,
        certificate_number TEXT,
        certificate_file TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (planting_lot_id) REFERENCES planting_lots(id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_planting_lots_zone ON planting_lots(farm_zone_id)');
    await db.execute('CREATE INDEX idx_care_logs_lot ON care_logs(planting_lot_id)');
    await db.execute('CREATE INDEX idx_harvests_lot ON harvests(planting_lot_id)');
  }

  // Farm Zone methods
  Future<void> insertFarmZone(FarmZone zone) async {
    final db = await database;
    await db.insert('farm_zones', _zoneToDbMap(zone), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateFarmZone(FarmZone zone) async {
    final db = await database;
    await db.update(
      'farm_zones',
      _zoneToDbMap(zone),
      where: 'id = ?',
      whereArgs: [zone.id],
    );
  }

  Future<void> deleteFarmZone(String id) async {
    final db = await database;
    await db.delete('farm_zones', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FarmZone>> getAllFarmZones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('farm_zones', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => FarmZone.fromJson(_mapToZoneJson(maps[i])));
  }

  Future<FarmZone?> getFarmZoneById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'farm_zones',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FarmZone.fromJson(_mapToZoneJson(maps.first));
  }

  // Planting Lot methods
  Future<void> insertPlantingLot(PlantingLot lot) async {
    final db = await database;
    await db.insert('planting_lots', _lotToDbMap(lot), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePlantingLot(PlantingLot lot) async {
    final db = await database;
    await db.update(
      'planting_lots',
      _lotToDbMap(lot),
      where: 'id = ?',
      whereArgs: [lot.id],
    );
  }

  Future<void> deletePlantingLot(String id) async {
    final db = await database;
    await db.delete('planting_lots', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PlantingLot>> getAllPlantingLots() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('planting_lots', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => PlantingLot.fromJson(_mapToLotJson(maps[i])));
  }

  Future<PlantingLot?> getPlantingLotById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'planting_lots',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PlantingLot.fromJson(_mapToLotJson(maps.first));
  }

  Future<List<PlantingLot>> getPlantingLotsByZoneId(String zoneId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'planting_lots',
      where: 'farm_zone_id = ?',
      whereArgs: [zoneId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => PlantingLot.fromJson(_mapToLotJson(maps[i])));
  }

  // Care Log methods
  Future<void> insertCareLog(CareLog log) async {
    final db = await database;
    await db.insert('care_logs', _careLogToDbMap(log), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCareLog(CareLog log) async {
    final db = await database;
    await db.update('care_logs', _careLogToDbMap(log), where: 'id = ?', whereArgs: [log.id]);
  }

  Future<void> deleteCareLog(String id) async {
    final db = await database;
    await db.delete('care_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CareLog>> getAllCareLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('care_logs', orderBy: 'activity_date DESC');
    return List.generate(maps.length, (i) => CareLog.fromJson(_mapToCareLogJson(maps[i])));
  }

  Future<List<CareLog>> getCareLogsByLotId(String lotId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'care_logs',
      where: 'planting_lot_id = ?',
      whereArgs: [lotId],
      orderBy: 'activity_date DESC',
    );
    return List.generate(maps.length, (i) => CareLog.fromJson(_mapToCareLogJson(maps[i])));
  }

  // Harvest methods
  Future<void> insertHarvest(Harvest harvest) async {
    final db = await database;
    await db.insert('harvests', _harvestToDbMap(harvest), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHarvest(Harvest harvest) async {
    final db = await database;
    await db.update('harvests', _harvestToDbMap(harvest), where: 'id = ?', whereArgs: [harvest.id]);
  }

  Future<List<Harvest>> getAllHarvests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('harvests', orderBy: 'harvest_date DESC');
    return List.generate(maps.length, (i) => Harvest.fromJson(_mapToHarvestJson(maps[i])));
  }

  Future<List<Harvest>> getHarvestsByLotId(String lotId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'harvests',
      where: 'planting_lot_id = ?',
      whereArgs: [lotId],
      orderBy: 'harvest_date DESC',
    );
    return List.generate(maps.length, (i) => Harvest.fromJson(_mapToHarvestJson(maps[i])));
  }

  // Warehouse methods
  Future<void> insertWarehouseEntry(WarehouseEntry entry) async {
    final db = await database;
    await db.insert('warehouse_entries', _warehouseToDbMap(entry), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateWarehouseEntry(WarehouseEntry entry) async {
    final db = await database;
    await db.update('warehouse_entries', _warehouseToDbMap(entry), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<List<WarehouseEntry>> getAllWarehouseEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('warehouse_entries', orderBy: 'entry_date DESC');
    return List.generate(maps.length, (i) => WarehouseEntry.fromJson(_mapToWarehouseJson(maps[i])));
  }

  // Packaging methods
  Future<void> insertPackaging(Packaging packaging) async {
    final db = await database;
    await db.insert('packagings', _packagingToDbMap(packaging), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePackaging(Packaging packaging) async {
    final db = await database;
    await db.update('packagings', _packagingToDbMap(packaging), where: 'id = ?', whereArgs: [packaging.id]);
  }

  Future<List<Packaging>> getAllPackagings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('packagings', orderBy: 'packaging_date DESC');
    return List.generate(maps.length, (i) => Packaging.fromJson(_mapToPackagingJson(maps[i])));
  }

  // Certification methods
  Future<void> insertCertification(Certification certification) async {
    final db = await database;
    await db.insert('certifications', _certificationToDbMap(certification), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCertification(Certification certification) async {
    final db = await database;
    await db.update('certifications', _certificationToDbMap(certification), where: 'id = ?', whereArgs: [certification.id]);
  }

  Future<List<Certification>> getAllCertifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('certifications', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Certification.fromJson(_mapToCertificationJson(maps[i])));
  }

  Future<Certification?> getCertificationByLotIdAndType(String lotId, CertificationType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'certifications',
      where: 'planting_lot_id = ? AND type = ?',
      whereArgs: [lotId, type.name],
    );
    if (maps.isEmpty) return null;
    return Certification.fromJson(_mapToCertificationJson(maps.first));
  }

  // Helper methods to convert database maps to JSON format
  Map<String, dynamic> _mapToZoneJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'name': map['name'],
      'company': map['company'],
      'address': map['address'],
      'administrativeAddress': map['administrative_address'],
      'landHistory': map['land_history'],
      'overviewImages': map['overview_images'] != null ? (map['overview_images'] as String).split(',').where((s) => s.isNotEmpty).toList() : [],
      'boundary': map['boundary'] != null ? _parseBoundary(map['boundary'] as String) : [],
      'createdAt': map['created_at'],
      'updatedAt': map['updated_at'],
    };
  }

  Map<String, dynamic> _mapToLotJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'lotCode': map['lot_code'],
      'lotName': map['lot_name'],
      'farmZoneId': map['farm_zone_id'],
      'plantingDate': map['planting_date'],
      'variety': map['variety'],
      'seedSource': map['seed_source'],
      'density': map['density'],
      'treeCount': map['tree_count'],
      'soilTestResult': map['soil_test_result'],
      'status': map['status'],
      'lotImages': map['lot_images'] != null ? (map['lot_images'] as String).split(',').where((s) => s.isNotEmpty).toList() : [],
      'boundary': map['boundary'] != null ? _parseBoundary(map['boundary'] as String) : [],
      'createdAt': map['created_at'],
      'updatedAt': map['updated_at'],
    };
  }

  Map<String, dynamic> _mapToCareLogJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'plantingLotId': map['planting_lot_id'],
      'activityType': map['activity_type'],
      'activityDate': map['activity_date'],
      'description': map['description'],
      'materialsUsed': map['materials_used'],
      'materialCertification': map['material_certification'],
      'performedBy': map['performed_by'],
      'evidenceImages': map['evidence_images'] != null ? (map['evidence_images'] as String).split(',').where((s) => s.isNotEmpty).toList() : [],
      'iotData': map['iot_data'] != null && (map['iot_data'] as String).isNotEmpty ? IoTData.fromJson(_parseJson(map['iot_data'] as String)) : null,
      'weatherData': map['weather_data'] != null && (map['weather_data'] as String).isNotEmpty ? WeatherData.fromJson(_parseJson(map['weather_data'] as String)) : null,
      'createdAt': map['created_at'],
    };
  }

  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> _mapToHarvestJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'plantingLotId': map['planting_lot_id'],
      'harvestDate': map['harvest_date'],
      'harvestGroup': map['harvest_group'],
      'quantity': map['quantity'],
      'dnaSampleTaken': map['dna_sample_taken'] == 1,
      'harvestImages': map['harvest_images'] != null ? (map['harvest_images'] as String).split(',').where((s) => s.isNotEmpty).toList() : [],
      'processing': map['processing'] != null && (map['processing'] as String).isNotEmpty ? Processing.fromJson(_parseJson(map['processing'] as String)) : null,
      'createdAt': map['created_at'],
    };
  }

  Map<String, dynamic> _mapToWarehouseJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'entryDate': map['entry_date'],
      'materialName': map['material_name'],
      'quantity': map['quantity'],
      'location': map['location'],
      'storageConditions': map['storage_conditions'] != null && (map['storage_conditions'] as String).isNotEmpty ? IoTData.fromJson(_parseJson(map['storage_conditions'] as String)) : null,
      'sourceHarvestId': map['source_harvest_id'],
      'createdAt': map['created_at'],
    };
  }

  Map<String, dynamic> _mapToPackagingJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'packagingLotCode': map['packaging_lot_code'],
      'packagingDate': map['packaging_date'],
      'sku': map['sku'],
      'productName': map['product_name'],
      'materialIds': map['material_ids'] != null ? (map['material_ids'] as String).split(',').where((s) => s.isNotEmpty).toList() : [],
      'quantity': map['quantity'],
      'unitWeight': map['unit_weight'],
      'packagingCertification': map['packaging_certification'],
      'qrCode': map['qr_code'],
      'evidenceImages': map['evidence_images'] != null ? (map['evidence_images'] as String).split(',').where((s) => s.isNotEmpty).toList() : [],
      'createdAt': map['created_at'],
    };
  }

  Map<String, dynamic> _mapToCertificationJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'type': map['type'],
      'plantingLotId': map['planting_lot_id'],
      'requirements': map['requirements'] != null ? _parseRequirements(map['requirements'] as String) : {},
      'isCompleted': map['is_completed'] == 1,
      'completedDate': map['completed_date'],
      'certificateNumber': map['certificate_number'],
      'certificateFile': map['certificate_file'],
      'createdAt': map['created_at'],
      'updatedAt': map['updated_at'],
    };
  }

  List<GPSPoint> _parseBoundary(String boundaryStr) {
    if (boundaryStr.isEmpty) return [];
    try {
      final parts = boundaryStr.split(';');
      return parts.map((part) {
        final coords = part.split(',');
        if (coords.length == 2) {
          return GPSPoint(
            latitude: double.parse(coords[0]),
            longitude: double.parse(coords[1]),
          );
        }
        return null;
      }).whereType<GPSPoint>().toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, bool> _parseRequirements(String requirementsStr) {
    if (requirementsStr.isEmpty) return {};
    try {
      final Map<String, bool> result = {};
      final parts = requirementsStr.split(';');
      for (final part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          result[keyValue[0]] = keyValue[1] == 'true';
        }
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  String _serializeBoundary(List<GPSPoint> boundary) {
    return boundary.map((p) => '${p.latitude},${p.longitude}').join(';');
  }

  String _serializeRequirements(Map<String, bool> requirements) {
    return requirements.entries.map((e) => '${e.key}:${e.value}').join(';');
  }

  // Convert models to database maps
  Map<String, dynamic> _zoneToDbMap(FarmZone zone) {
    return {
      'id': zone.id,
      'name': zone.name,
      'company': zone.company,
      'address': zone.address,
      'administrative_address': zone.administrativeAddress,
      'land_history': zone.landHistory,
      'overview_images': zone.overviewImages.join(','),
      'boundary': _serializeBoundary(zone.boundary),
      'created_at': zone.createdAt.toIso8601String(),
      'updated_at': zone.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _lotToDbMap(PlantingLot lot) {
    return {
      'id': lot.id,
      'lot_code': lot.lotCode,
      'lot_name': lot.lotName,
      'farm_zone_id': lot.farmZoneId,
      'planting_date': lot.plantingDate.toIso8601String(),
      'variety': lot.variety,
      'seed_source': lot.seedSource,
      'density': lot.density,
      'tree_count': lot.treeCount,
      'soil_test_result': lot.soilTestResult,
      'status': lot.status.name,
      'lot_images': lot.lotImages.join(','),
      'boundary': _serializeBoundary(lot.boundary),
      'created_at': lot.createdAt.toIso8601String(),
      'updated_at': lot.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _careLogToDbMap(CareLog log) {
    return {
      'id': log.id,
      'planting_lot_id': log.plantingLotId,
      'activity_type': log.activityType.name,
      'activity_date': log.activityDate.toIso8601String(),
      'description': log.description,
      'materials_used': log.materialsUsed,
      'material_certification': log.materialCertification,
      'performed_by': log.performedBy,
      'evidence_images': log.evidenceImages.join(','),
      'iot_data': log.iotData != null ? jsonEncode(log.iotData!.toJson()) : null,
      'weather_data': log.weatherData != null ? jsonEncode(log.weatherData!.toJson()) : null,
      'created_at': log.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _harvestToDbMap(Harvest harvest) {
    return {
      'id': harvest.id,
      'planting_lot_id': harvest.plantingLotId,
      'harvest_date': harvest.harvestDate.toIso8601String(),
      'harvest_group': harvest.harvestGroup,
      'quantity': harvest.quantity,
      'dna_sample_taken': harvest.dnaSampleTaken ? 1 : 0,
      'harvest_images': harvest.harvestImages.join(','),
      'processing': harvest.processing != null ? jsonEncode(harvest.processing!.toJson()) : null,
      'created_at': harvest.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _warehouseToDbMap(WarehouseEntry entry) {
    return {
      'id': entry.id,
      'entry_date': entry.entryDate.toIso8601String(),
      'material_name': entry.materialName,
      'quantity': entry.quantity,
      'location': entry.location,
      'storage_conditions': entry.storageConditions != null ? jsonEncode(entry.storageConditions!.toJson()) : null,
      'source_harvest_id': entry.sourceHarvestId,
      'created_at': entry.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _packagingToDbMap(Packaging packaging) {
    return {
      'id': packaging.id,
      'packaging_lot_code': packaging.packagingLotCode,
      'packaging_date': packaging.packagingDate.toIso8601String(),
      'sku': packaging.sku,
      'product_name': packaging.productName,
      'material_ids': packaging.materialIds.join(','),
      'quantity': packaging.quantity,
      'unit_weight': packaging.unitWeight,
      'packaging_certification': packaging.packagingCertification,
      'qr_code': packaging.qrCode,
      'evidence_images': packaging.evidenceImages.join(','),
      'created_at': packaging.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _certificationToDbMap(Certification certification) {
    return {
      'id': certification.id,
      'type': certification.type.name,
      'planting_lot_id': certification.plantingLotId,
      'requirements': _serializeRequirements(certification.requirements),
      'is_completed': certification.isCompleted ? 1 : 0,
      'completed_date': certification.completedDate?.toIso8601String(),
      'certificate_number': certification.certificateNumber,
      'certificate_file': certification.certificateFile,
      'created_at': certification.createdAt.toIso8601String(),
      'updated_at': certification.updatedAt.toIso8601String(),
    };
  }
}

