enum CertificationType {
  gacp,
  organic,
  ocop,
}

class Certification {
  final String id;
  CertificationType type;
  String plantingLotId;
  Map<String, bool> requirements;
  bool isCompleted;
  DateTime? completedDate;
  String? certificateNumber;
  String? certificateFile;
  DateTime createdAt;
  DateTime updatedAt;

  Certification({
    required this.id,
    required this.type,
    required this.plantingLotId,
    this.requirements = const {},
    this.isCompleted = false,
    this.completedDate,
    this.certificateNumber,
    this.certificateFile,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get typeText {
    switch (type) {
      case CertificationType.gacp:
        return 'GACP';
      case CertificationType.organic:
        return 'Organic';
      case CertificationType.ocop:
        return 'OCOP';
    }
  }

  List<String> get requirementNames {
    switch (type) {
      case CertificationType.gacp:
        return [
          'Hồ sơ vùng trồng',
          'Hồ sơ lịch sử đất',
          'Hồ sơ giống và nguồn gốc',
          'Nhật ký chăm sóc đầy đủ',
          'Hồ sơ thu hoạch',
          'Hồ sơ sơ chế',
          'Kết quả kiểm nghiệm',
          'Hồ sơ kho và đóng gói',
        ];
      case CertificationType.organic:
        return [
          'Chứng nhận vùng trồng hữu cơ',
          'Giống hữu cơ được chứng nhận',
          'Vật tư hữu cơ được phê duyệt',
          'Nhật ký chăm sóc hữu cơ',
          'Quy trình sơ chế hữu cơ',
          'Chứng nhận sản phẩm hữu cơ',
        ];
      case CertificationType.ocop:
        return [
          'Đăng ký OCOP',
          'Hồ sơ sản phẩm',
          'Chứng nhận chất lượng',
          'Nhãn hiệu và bao bì',
          'Truy xuất nguồn gốc',
        ];
    }
  }

  double get completionPercentage {
    if (requirements.isEmpty) return 0.0;
    int completed = requirements.values.where((v) => v == true).length;
    return completed / requirements.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'plantingLotId': plantingLotId,
      'requirements': requirements,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'certificateNumber': certificateNumber,
      'certificateFile': certificateFile,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'] as String,
      type: CertificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CertificationType.gacp,
      ),
      plantingLotId: json['plantingLotId'] as String,
      requirements: Map<String, bool>.from(json['requirements'] ?? {}),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      certificateNumber: json['certificateNumber'] as String?,
      certificateFile: json['certificateFile'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}



