import 'gps_point.dart';

class FarmZone {
  final String id;
  String name;
  String? company;
  String? address;
  String? administrativeAddress;
  String? landHistory;
  List<String> overviewImages;
  List<GPSPoint> boundary;
  DateTime createdAt;
  DateTime updatedAt;

  FarmZone({
    required this.id,
    required this.name,
    this.company,
    this.address,
    this.administrativeAddress,
    this.landHistory,
    this.overviewImages = const [],
    this.boundary = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'address': address,
      'administrativeAddress': administrativeAddress,
      'landHistory': landHistory,
      'overviewImages': overviewImages,
      'boundary': boundary.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FarmZone.fromJson(Map<String, dynamic> json) {
    return FarmZone(
      id: json['id'] as String,
      name: json['name'] as String,
      company: json['company'] as String?,
      address: json['address'] as String?,
      administrativeAddress: json['administrativeAddress'] as String?,
      landHistory: json['landHistory'] as String?,
      overviewImages: List<String>.from(json['overviewImages'] ?? []),
      boundary: (json['boundary'] as List<dynamic>?)
              ?.map((p) => GPSPoint.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

