import 'package:flutter/foundation.dart';
import '../models/farm_zone.dart';
import '../models/planting_lot.dart';
import '../models/care_log.dart';
import '../models/harvest.dart';
import '../models/warehouse.dart';
import '../models/certification.dart';
import '../services/database_service.dart';

class FarmProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<FarmZone> _farmZones = [];
  List<PlantingLot> _plantingLots = [];
  List<CareLog> _careLogs = [];
  List<Harvest> _harvests = [];
  List<WarehouseEntry> _warehouseEntries = [];
  List<Packaging> _packagings = [];
  List<Certification> _certifications = [];
  
  bool _isLoading = false;

  List<FarmZone> get farmZones => _farmZones;
  List<PlantingLot> get plantingLots => _plantingLots;
  List<CareLog> get careLogs => _careLogs;
  List<Harvest> get harvests => _harvests;
  List<WarehouseEntry> get warehouseEntries => _warehouseEntries;
  List<Packaging> get packagings => _packagings;
  List<Certification> get certifications => _certifications;
  bool get isLoading => _isLoading;

  // Initialize and load data from database
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await loadAllData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllData() async {
    _farmZones = await _dbService.getAllFarmZones();
    _plantingLots = await _dbService.getAllPlantingLots();
    _careLogs = await _dbService.getAllCareLogs();
    _harvests = await _dbService.getAllHarvests();
    _warehouseEntries = await _dbService.getAllWarehouseEntries();
    _packagings = await _dbService.getAllPackagings();
    _certifications = await _dbService.getAllCertifications();
    notifyListeners();
  }

  // Farm Zone methods
  Future<void> addFarmZone(FarmZone zone) async {
    await _dbService.insertFarmZone(zone);
    _farmZones = await _dbService.getAllFarmZones();
    notifyListeners();
  }

  Future<void> updateFarmZone(FarmZone zone) async {
    await _dbService.updateFarmZone(zone);
    _farmZones = await _dbService.getAllFarmZones();
    notifyListeners();
  }

  Future<void> deleteFarmZone(String id) async {
    await _dbService.deleteFarmZone(id);
    _farmZones = await _dbService.getAllFarmZones();
    notifyListeners();
  }

  Future<FarmZone?> getFarmZoneById(String id) async {
    return await _dbService.getFarmZoneById(id);
  }

  // Planting Lot methods
  Future<void> addPlantingLot(PlantingLot lot) async {
    await _dbService.insertPlantingLot(lot);
    _plantingLots = await _dbService.getAllPlantingLots();
    notifyListeners();
  }

  Future<void> updatePlantingLot(PlantingLot lot) async {
    await _dbService.updatePlantingLot(lot);
    _plantingLots = await _dbService.getAllPlantingLots();
    notifyListeners();
  }

  Future<void> deletePlantingLot(String id) async {
    await _dbService.deletePlantingLot(id);
    _plantingLots = await _dbService.getAllPlantingLots();
    notifyListeners();
  }

  Future<PlantingLot?> getPlantingLotById(String id) async {
    return await _dbService.getPlantingLotById(id);
  }

  Future<List<PlantingLot>> getPlantingLotsByZoneId(String zoneId) async {
    return await _dbService.getPlantingLotsByZoneId(zoneId);
  }

  // Care Log methods
  Future<void> addCareLog(CareLog log) async {
    await _dbService.insertCareLog(log);
    _careLogs = await _dbService.getAllCareLogs();
    notifyListeners();
  }

  Future<void> updateCareLog(CareLog log) async {
    await _dbService.updateCareLog(log);
    _careLogs = await _dbService.getAllCareLogs();
    notifyListeners();
  }

  Future<void> deleteCareLog(String id) async {
    await _dbService.deleteCareLog(id);
    _careLogs = await _dbService.getAllCareLogs();
    notifyListeners();
  }

  Future<List<CareLog>> getCareLogsByLotId(String lotId) async {
    return await _dbService.getCareLogsByLotId(lotId);
  }

  // Harvest methods
  Future<void> addHarvest(Harvest harvest) async {
    await _dbService.insertHarvest(harvest);
    _harvests = await _dbService.getAllHarvests();
    notifyListeners();
  }

  Future<void> updateHarvest(Harvest harvest) async {
    await _dbService.updateHarvest(harvest);
    _harvests = await _dbService.getAllHarvests();
    notifyListeners();
  }

  Future<List<Harvest>> getHarvestsByLotId(String lotId) async {
    return await _dbService.getHarvestsByLotId(lotId);
  }

  // Warehouse methods
  Future<void> addWarehouseEntry(WarehouseEntry entry) async {
    await _dbService.insertWarehouseEntry(entry);
    _warehouseEntries = await _dbService.getAllWarehouseEntries();
    notifyListeners();
  }

  Future<void> updateWarehouseEntry(WarehouseEntry entry) async {
    await _dbService.updateWarehouseEntry(entry);
    _warehouseEntries = await _dbService.getAllWarehouseEntries();
    notifyListeners();
  }

  // Packaging methods
  Future<void> addPackaging(Packaging packaging) async {
    await _dbService.insertPackaging(packaging);
    _packagings = await _dbService.getAllPackagings();
    notifyListeners();
  }

  Future<void> updatePackaging(Packaging packaging) async {
    await _dbService.updatePackaging(packaging);
    _packagings = await _dbService.getAllPackagings();
    notifyListeners();
  }

  // Certification methods
  Future<void> addCertification(Certification certification) async {
    await _dbService.insertCertification(certification);
    _certifications = await _dbService.getAllCertifications();
    notifyListeners();
  }

  Future<void> updateCertification(Certification certification) async {
    await _dbService.updateCertification(certification);
    _certifications = await _dbService.getAllCertifications();
    notifyListeners();
  }

  Future<Certification?> getCertificationByLotIdAndType(String lotId, CertificationType type) async {
    return await _dbService.getCertificationByLotIdAndType(lotId, type);
  }
}
