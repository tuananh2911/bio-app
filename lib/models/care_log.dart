import 'package:intl/intl.dart';
import 'iot_data.dart';

enum ActivityType {
  watering,
  fertilizing,
  weeding,
  pestControl,
  pruning,
  inspection,
  other
}

class CareLog {
  final String id;
  String plantingLotId;
  ActivityType activityType;
  DateTime activityDate;
  String? description;
  String? materialsUsed;
  String? materialCertification;
  String? performedBy;
  List<String> evidenceImages;
  IoTData? iotData;
  WeatherData? weatherData;
  DateTime createdAt;

  CareLog({
    required this.id,
    required this.plantingLotId,
    required this.activityType,
    required this.activityDate,
    this.description,
    this.materialsUsed,
    this.materialCertification,
    this.performedBy,
    this.evidenceImages = const [],
    this.iotData,
    this.weatherData,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get activityTypeText {
    switch (activityType) {
      case ActivityType.watering:
        return 'Tưới nước';
      case ActivityType.fertilizing:
        return 'Bón phân';
      case ActivityType.weeding:
        return 'Làm cỏ';
      case ActivityType.pestControl:
        return 'Phòng trừ sâu bệnh';
      case ActivityType.pruning:
        return 'Cắt tỉa';
      case ActivityType.inspection:
        return 'Kiểm tra';
      case ActivityType.other:
        return 'Khác';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantingLotId': plantingLotId,
      'activityType': activityType.name,
      'activityDate': activityDate.toIso8601String(),
      'description': description,
      'materialsUsed': materialsUsed,
      'materialCertification': materialCertification,
      'performedBy': performedBy,
      'evidenceImages': evidenceImages,
      'iotData': iotData?.toJson(),
      'weatherData': weatherData?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CareLog.fromJson(Map<String, dynamic> json) {
    return CareLog(
      id: json['id'] as String,
      plantingLotId: json['plantingLotId'] as String,
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == json['activityType'],
        orElse: () => ActivityType.other,
      ),
      activityDate: DateTime.parse(json['activityDate'] as String),
      description: json['description'] as String?,
      materialsUsed: json['materialsUsed'] as String?,
      materialCertification: json['materialCertification'] as String?,
      performedBy: json['performedBy'] as String?,
      evidenceImages: List<String>.from(json['evidenceImages'] ?? []),
      iotData: json['iotData'] != null
          ? IoTData.fromJson(json['iotData'] as Map<String, dynamic>)
          : null,
      weatherData: json['weatherData'] != null
          ? WeatherData.fromJson(json['weatherData'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// IoTData moved to iot_data.dart to avoid conflicts

class WeatherData {
  final double? temperature;
  final double? humidity;
  final double? rainfall;
  final String? condition;
  final DateTime timestamp;

  WeatherData({
    this.temperature,
    this.humidity,
    this.rainfall,
    this.condition,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'condition': condition,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      rainfall: (json['rainfall'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

