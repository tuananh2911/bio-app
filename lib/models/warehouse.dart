import 'iot_data.dart';

class WarehouseEntry {
  final String id;
  DateTime entryDate;
  String materialName;
  double quantity; // kg
  String? location;
  IoTData? storageConditions;
  String? sourceHarvestId;
  DateTime createdAt;

  WarehouseEntry({
    required this.id,
    required this.entryDate,
    required this.materialName,
    required this.quantity,
    this.location,
    this.storageConditions,
    this.sourceHarvestId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entryDate': entryDate.toIso8601String(),
      'materialName': materialName,
      'quantity': quantity,
      'location': location,
      'storageConditions': storageConditions?.toJson(),
      'sourceHarvestId': sourceHarvestId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WarehouseEntry.fromJson(Map<String, dynamic> json) {
    return WarehouseEntry(
      id: json['id'] as String,
      entryDate: DateTime.parse(json['entryDate'] as String),
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      location: json['location'] as String?,
      storageConditions: json['storageConditions'] != null
          ? IoTData.fromJson(json['storageConditions'] as Map<String, dynamic>)
          : null,
      sourceHarvestId: json['sourceHarvestId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class Packaging {
  final String id;
  String packagingLotCode;
  DateTime packagingDate;
  String sku;
  String productName;
  List<String> materialIds; // IDs từ WarehouseEntry
  int quantity;
  double unitWeight; // kg
  String? packagingCertification;
  String? qrCode;
  List<String> evidenceImages;
  DateTime createdAt;

  Packaging({
    required this.id,
    required this.packagingLotCode,
    required this.packagingDate,
    required this.sku,
    required this.productName,
    this.materialIds = const [],
    required this.quantity,
    required this.unitWeight,
    this.packagingCertification,
    this.qrCode,
    this.evidenceImages = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packagingLotCode': packagingLotCode,
      'packagingDate': packagingDate.toIso8601String(),
      'sku': sku,
      'productName': productName,
      'materialIds': materialIds,
      'quantity': quantity,
      'unitWeight': unitWeight,
      'packagingCertification': packagingCertification,
      'qrCode': qrCode,
      'evidenceImages': evidenceImages,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Packaging.fromJson(Map<String, dynamic> json) {
    return Packaging(
      id: json['id'] as String,
      packagingLotCode: json['packagingLotCode'] as String,
      packagingDate: DateTime.parse(json['packagingDate'] as String),
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      materialIds: List<String>.from(json['materialIds'] ?? []),
      quantity: json['quantity'] as int,
      unitWeight: (json['unitWeight'] as num).toDouble(),
      packagingCertification: json['packagingCertification'] as String?,
      qrCode: json['qrCode'] as String?,
      evidenceImages: List<String>.from(json['evidenceImages'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// IoTData moved to iot_data.dart to avoid conflicts



