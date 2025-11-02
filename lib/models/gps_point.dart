class GPSPoint {
  final double latitude;
  final double longitude;

  GPSPoint({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory GPSPoint.fromJson(Map<String, dynamic> json) {
    return GPSPoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}



