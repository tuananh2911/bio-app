import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../models/planting_lot.dart';
import '../../models/farm_zone.dart';
import '../../widgets/image_gallery_widget.dart';
import 'planting_lot_form_screen.dart';

class PlantingLotDetailScreen extends StatefulWidget {
  final String lotId;

  const PlantingLotDetailScreen({super.key, required this.lotId});

  @override
  State<PlantingLotDetailScreen> createState() => _PlantingLotDetailScreenState();
}

class _PlantingLotDetailScreenState extends State<PlantingLotDetailScreen> {
  Future<Map<String, dynamic>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData(context);
  }

  void _refresh() {
    setState(() {
      _dataFuture = _loadData(context);
    });
  }

  Future<Map<String, dynamic>> _loadData(BuildContext context) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final lot = await farmProvider.getPlantingLotById(widget.lotId);
    final zone = lot != null ? await farmProvider.getFarmZoneById(lot.farmZoneId) : null;
    return {'lot': lot, 'zone': zone};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Lô trồng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final farmProvider =
                  Provider.of<FarmProvider>(context, listen: false);
              final lot = await farmProvider.getPlantingLotById(widget.lotId);
              if (lot != null && context.mounted) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantingLotFormScreen(lot: lot),
                  ),
                );
                // Refresh when coming back from edit
                if (result == true || mounted) {
                  _refresh();
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lot = snapshot.data?['lot'] as PlantingLot?;
          final zone = snapshot.data?['zone'] as FarmZone?;

          if (lot == null) {
            return const Center(child: Text('Không tìm thấy lô trồng'));
          }

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
                        Text(
                          lot.lotName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(lot.statusText),
                          backgroundColor: Colors.green[50],
                        ),
                        const Divider(),
                        _InfoRow(
                          label: 'Mã lô',
                          value: lot.lotCode,
                        ),
                        if (zone != null)
                          _InfoRow(
                            label: 'Vùng trồng',
                            value: zone.name,
                          ),
                        _InfoRow(
                          label: 'Ngày trồng',
                          value: DateFormat('dd/MM/yyyy').format(lot.plantingDate),
                        ),
                        if (lot.variety != null)
                          _InfoRow(
                            label: 'Giống',
                            value: lot.variety!,
                          ),
                        if (lot.seedSource != null)
                          _InfoRow(
                            label: 'Nguồn giống',
                            value: lot.seedSource!,
                          ),
                        if (lot.density != null)
                          _InfoRow(
                            label: 'Mật độ',
                            value: lot.density!.toString(),
                          ),
                        if (lot.treeCount != null)
                          _InfoRow(
                            label: 'Số cây',
                            value: lot.treeCount!.toString(),
                          ),
                        if (lot.soilTestResult != null)
                          _InfoRow(
                            label: 'Kết quả kiểm nghiệm đất',
                            value: lot.soilTestResult!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ảnh lô trồng (${lot.lotImages.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (lot.lotImages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Chưa có ảnh nào',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  )
                else
                  ImageGalleryWidget(
                    imagePaths: lot.lotImages,
                    title: null,
                  ),
              ],
            ),
          );
        },
      ),
    );
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
            width: 150,
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



