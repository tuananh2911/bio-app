import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../models/care_log.dart';
import '../../models/planting_lot.dart';
import '../../widgets/image_gallery_widget.dart';
import 'care_log_form_screen.dart';

class CareLogDetailScreen extends StatelessWidget {
  final String logId;

  const CareLogDetailScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Nhật ký'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<CareLog?>(
        future: _loadLog(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final log = snapshot.data;
          if (log == null) {
            return const Center(child: Text('Không tìm thấy nhật ký'));
          }

          return FutureBuilder<PlantingLot?>(
            future: Provider.of<FarmProvider>(context, listen: false)
                .getPlantingLotById(log.plantingLotId),
            builder: (context, lotSnap) {
              final lot = lotSnap.data;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getActivityIcon(log.activityType),
                                  color: _getActivityColor(log.activityType),
                                  size: 32,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  log.activityTypeText,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'Lô trồng',
                              value: lot?.lotName ?? 'Không xác định',
                            ),
                            _InfoRow(
                              label: 'Ngày hoạt động',
                              value: DateFormat('dd/MM/yyyy HH:mm').format(log.activityDate),
                            ),
                            if (log.performedBy != null)
                              _InfoRow(
                                label: 'Người thực hiện',
                                value: log.performedBy!,
                              ),
                            if (log.description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Mô tả:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(log.description!),
                            ],
                            if (log.materialsUsed != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Vật tư sử dụng:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(log.materialsUsed!),
                            ],
                            if (log.materialCertification != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Giấy chứng nhận vật tư:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(log.materialCertification!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (log.evidenceImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ImageGalleryWidget(
                        imagePaths: log.evidenceImages,
                        title: 'Ảnh minh chứng',
                      ),
                    ],
                    if (log.iotData != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dữ liệu IoT',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                              if (log.iotData!.temperature != null)
                                _InfoRow(
                                  label: 'Nhiệt độ',
                                  value: '${log.iotData!.temperature!.toStringAsFixed(1)}°C',
                                ),
                              if (log.iotData!.humidity != null)
                                _InfoRow(
                                  label: 'Độ ẩm',
                                  value: '${log.iotData!.humidity!.toStringAsFixed(1)}%',
                                ),
                              if (log.iotData!.lightIntensity != null)
                                _InfoRow(
                                  label: 'Ánh sáng',
                                  value: '${log.iotData!.lightIntensity!.toStringAsFixed(1)} lux',
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (log.weatherData != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dữ liệu Thời tiết',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                              if (log.weatherData!.temperature != null)
                                _InfoRow(
                                  label: 'Nhiệt độ',
                                  value: '${log.weatherData!.temperature!.toStringAsFixed(1)}°C',
                                ),
                              if (log.weatherData!.humidity != null)
                                _InfoRow(
                                  label: 'Độ ẩm',
                                  value: '${log.weatherData!.humidity!.toStringAsFixed(1)}%',
                                ),
                              if (log.weatherData!.rainfall != null)
                                _InfoRow(
                                  label: 'Lượng mưa',
                                  value: '${log.weatherData!.rainfall!.toStringAsFixed(1)} mm',
                                ),
                              if (log.weatherData!.condition != null)
                                _InfoRow(
                                  label: 'Điều kiện',
                                  value: log.weatherData!.condition!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<CareLog?> _loadLog(BuildContext context) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final logs = farmProvider.careLogs;
    try {
      return logs.firstWhere((l) => l.id == logId);
    } catch (e) {
      return null;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.watering:
        return Icons.water_drop;
      case ActivityType.fertilizing:
        return Icons.science;
      case ActivityType.weeding:
        return Icons.grass;
      case ActivityType.pestControl:
        return Icons.bug_report;
      case ActivityType.pruning:
        return Icons.content_cut;
      case ActivityType.inspection:
        return Icons.search;
      default:
        return Icons.assignment;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.watering:
        return Colors.blue;
      case ActivityType.fertilizing:
        return Colors.orange;
      case ActivityType.weeding:
        return Colors.green;
      case ActivityType.pestControl:
        return Colors.red;
      case ActivityType.pruning:
        return Colors.purple;
      case ActivityType.inspection:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

