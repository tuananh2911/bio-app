import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../models/harvest.dart';
import '../../models/planting_lot.dart';
import '../../widgets/image_gallery_widget.dart';

class HarvestDetailScreen extends StatelessWidget {
  final String harvestId;

  const HarvestDetailScreen({super.key, required this.harvestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Thu hoạch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<Harvest?>(
        future: _loadHarvest(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final harvest = snapshot.data;
          if (harvest == null) {
            return const Center(child: Text('Không tìm thấy thu hoạch'));
          }

          return FutureBuilder<PlantingLot?>(
            future: Provider.of<FarmProvider>(context, listen: false)
                .getPlantingLotById(harvest.plantingLotId),
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
                                  Icons.agriculture,
                                  color: Colors.purple[700],
                                  size: 32,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Thu hoạch',
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
                              label: 'Ngày thu hoạch',
                              value: DateFormat('dd/MM/yyyy').format(harvest.harvestDate),
                            ),
                            _InfoRow(
                              label: 'Khối lượng',
                              value: '${harvest.quantity} kg',
                            ),
                            if (harvest.harvestGroup != null)
                              _InfoRow(
                                label: 'Nhóm thực hiện',
                                value: harvest.harvestGroup!,
                              ),
                            _InfoRow(
                              label: 'Mẫu DNA',
                              value: harvest.dnaSampleTaken ? 'Đã lấy' : 'Chưa lấy',
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (harvest.harvestImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ImageGalleryWidget(
                        imagePaths: harvest.harvestImages,
                        title: 'Ảnh thu hoạch',
                      ),
                    ],
                    if (harvest.processing != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thông tin Sơ chế',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                              _InfoRow(
                                label: 'Ngày sơ chế',
                                value: DateFormat('dd/MM/yyyy').format(harvest.processing!.processingDate),
                              ),
                              if (harvest.processing!.operator != null)
                                _InfoRow(
                                  label: 'Người vận hành',
                                  value: harvest.processing!.operator!,
                                ),
                              if (harvest.processing!.steps.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Các bước sơ chế:',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                ...harvest.processing!.steps.map((step) => Padding(
                                  padding: const EdgeInsets.only(left: 16, top: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ${step.stepName}',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      if (step.description != null)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Text(step.description!),
                                        ),
                                    ],
                                  ),
                                )),
                              ],
                              if (harvest.processing!.processingImages.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                ImageGalleryWidget(
                                  imagePaths: harvest.processing!.processingImages,
                                  title: 'Ảnh sơ chế',
                                ),
                              ],
                              if (harvest.processing!.labTestResults.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Kết quả kiểm nghiệm:',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...harvest.processing!.labTestResults.map((result) => Padding(
                                  padding: const EdgeInsets.only(left: 16, top: 4),
                                  child: Text('• $result'),
                                )),
                              ],
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

  Future<Harvest?> _loadHarvest(BuildContext context) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final harvests = farmProvider.harvests;
    try {
      return harvests.firstWhere((h) => h.id == harvestId);
    } catch (e) {
      return null;
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

