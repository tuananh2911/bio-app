import 'package:intl/intl.dart';
import 'gps_point.dart';

enum LotStatus {
  preparing,
  planted,
  growing,
  flowering,
  fruiting,
  harvesting,
  completed,
  abandoned
}

class PlantingLot {
  final String id;
  String lotCode;
  String lotName;
  String farmZoneId;
  DateTime plantingDate;
  String? variety;
  String? seedSource;
  double? density;
  int? treeCount;
  String? soilTestResult;
  LotStatus status;
  List<String> lotImages;
  List<GPSPoint> boundary;
  DateTime createdAt;
  DateTime updatedAt;

  PlantingLot({
    required this.id,
    required this.lotCode,
    required this.lotName,
    required this.farmZoneId,
    required this.plantingDate,
    this.variety,
    this.seedSource,
    this.density,
    this.treeCount,
    this.soilTestResult,
    this.status = LotStatus.preparing,
    this.lotImages = const [],
    this.boundary = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get statusText {
    switch (status) {
      case LotStatus.preparing:
        return 'Chuẩn bị';
      case LotStatus.planted:
        return 'Đã trồng';
      case LotStatus.growing:
        return 'Đang sinh trưởng';
      case LotStatus.flowering:
        return 'Ra hoa';
      case LotStatus.fruiting:
        return 'Đậu quả';
      case LotStatus.harvesting:
        return 'Thu hoạch';
      case LotStatus.completed:
        return 'Hoàn thành';
      case LotStatus.abandoned:
        return 'Bỏ hoang';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lotCode': lotCode,
      'lotName': lotName,
      'farmZoneId': farmZoneId,
      'plantingDate': plantingDate.toIso8601String(),
      'variety': variety,
      'seedSource': seedSource,
      'density': density,
      'treeCount': treeCount,
      'soilTestResult': soilTestResult,
      'status': status.name,
      'lotImages': lotImages,
      'boundary': boundary.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PlantingLot.fromJson(Map<String, dynamic> json) {
    return PlantingLot(
      id: json['id'] as String,
      lotCode: json['lotCode'] as String,
      lotName: json['lotName'] as String,
      farmZoneId: json['farmZoneId'] as String,
      plantingDate: DateTime.parse(json['plantingDate'] as String),
      variety: json['variety'] as String?,
      seedSource: json['seedSource'] as String?,
      density: (json['density'] as num?)?.toDouble(),
      treeCount: json['treeCount'] as int?,
      soilTestResult: json['soilTestResult'] as String?,
      status: LotStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LotStatus.preparing,
      ),
      lotImages: List<String>.from(json['lotImages'] ?? []),
      boundary: (json['boundary'] as List<dynamic>?)
              ?.map((p) => GPSPoint.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

