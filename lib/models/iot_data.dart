class IoTData {
  final double? temperature;
  final double? humidity;
  final double? lightIntensity; // Optional - only for care logs
  final DateTime timestamp;

  IoTData({
    this.temperature,
    this.humidity,
    this.lightIntensity, // Can be null for warehouse entries
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory for warehouse entries (no lightIntensity)
  factory IoTData.warehouse({
    double? temperature,
    double? humidity,
    DateTime? timestamp,
  }) {
    return IoTData(
      temperature: temperature,
      humidity: humidity,
      lightIntensity: null,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
    };
    if (temperature != null) map['temperature'] = temperature;
    if (humidity != null) map['humidity'] = humidity;
    if (lightIntensity != null) map['lightIntensity'] = lightIntensity;
    return map;
  }

  factory IoTData.fromJson(Map<String, dynamic> json) {
    return IoTData(
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      lightIntensity: (json['lightIntensity'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

