class Harvest {
  final String id;
  String plantingLotId;
  DateTime harvestDate;
  String? harvestGroup;
  double quantity; // kg
  bool dnaSampleTaken;
  List<String> harvestImages;
  Processing? processing;
  DateTime createdAt;

  Harvest({
    required this.id,
    required this.plantingLotId,
    required this.harvestDate,
    this.harvestGroup,
    required this.quantity,
    this.dnaSampleTaken = false,
    this.harvestImages = const [],
    this.processing,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantingLotId': plantingLotId,
      'harvestDate': harvestDate.toIso8601String(),
      'harvestGroup': harvestGroup,
      'quantity': quantity,
      'dnaSampleTaken': dnaSampleTaken,
      'harvestImages': harvestImages,
      'processing': processing?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Harvest.fromJson(Map<String, dynamic> json) {
    return Harvest(
      id: json['id'] as String,
      plantingLotId: json['plantingLotId'] as String,
      harvestDate: DateTime.parse(json['harvestDate'] as String),
      harvestGroup: json['harvestGroup'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      dnaSampleTaken: json['dnaSampleTaken'] as bool? ?? false,
      harvestImages: List<String>.from(json['harvestImages'] ?? []),
      processing: json['processing'] != null
          ? Processing.fromJson(json['processing'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class Processing {
  final String id;
  DateTime processingDate;
  List<ProcessingStep> steps;
  List<String> processingImages;
  List<String> labTestResults;
  String? operator;

  Processing({
    required this.id,
    required this.processingDate,
    this.steps = const [],
    this.processingImages = const [],
    this.labTestResults = const [],
    this.operator,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'processingDate': processingDate.toIso8601String(),
      'steps': steps.map((s) => s.toJson()).toList(),
      'processingImages': processingImages,
      'labTestResults': labTestResults,
      'operator': operator,
    };
  }

  factory Processing.fromJson(Map<String, dynamic> json) {
    return Processing(
      id: json['id'] as String,
      processingDate: DateTime.parse(json['processingDate'] as String),
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => ProcessingStep.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      processingImages: List<String>.from(json['processingImages'] ?? []),
      labTestResults: List<String>.from(json['labTestResults'] ?? []),
      operator: json['operator'] as String?,
    );
  }
}

class ProcessingStep {
  final String stepName;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? equipment;
  final String? operator;

  ProcessingStep({
    required this.stepName,
    this.description,
    this.startTime,
    this.endTime,
    this.equipment,
    this.operator,
  });

  Map<String, dynamic> toJson() {
    return {
      'stepName': stepName,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'equipment': equipment,
      'operator': operator,
    };
  }

  factory ProcessingStep.fromJson(Map<String, dynamic> json) {
    return ProcessingStep(
      stepName: json['stepName'] as String,
      description: json['description'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      equipment: json['equipment'] as String?,
      operator: json['operator'] as String?,
    );
  }
}

