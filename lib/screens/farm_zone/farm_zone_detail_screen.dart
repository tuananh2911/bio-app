import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farm_provider.dart';
import '../../models/farm_zone.dart';
import '../../models/planting_lot.dart';
import '../../widgets/image_gallery_widget.dart';
import 'farm_zone_form_screen.dart';
import '../planting_lot/planting_lot_list_screen.dart';
import '../planting_lot/planting_lot_detail_screen.dart';

class FarmZoneDetailScreen extends StatefulWidget {
  final String zoneId;

  const FarmZoneDetailScreen({super.key, required this.zoneId});

  @override
  State<FarmZoneDetailScreen> createState() => _FarmZoneDetailScreenState();
}

class _FarmZoneDetailScreenState extends State<FarmZoneDetailScreen> {
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
    final zone = await farmProvider.getFarmZoneById(widget.zoneId);
    final lots = zone != null ? await farmProvider.getPlantingLotsByZoneId(widget.zoneId) : [];
    return {'zone': zone, 'lots': lots};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Vùng trồng'),
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
              final zone = await farmProvider.getFarmZoneById(widget.zoneId);
              if (zone != null && context.mounted) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmZoneFormScreen(zone: zone),
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

          final zone = snapshot.data?['zone'] as FarmZone?;
          final lots = snapshot.data?['lots'] as List<PlantingLot>? ?? [];

          if (zone == null) {
            return const Center(child: Text('Không tìm thấy vùng trồng'));
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
                          zone.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Divider(),
                        if (zone.company != null) ...[
                          _InfoRow(label: 'Doanh nghiệp', value: zone.company!),
                        ],
                        if (zone.address != null) ...[
                          _InfoRow(label: 'Địa chỉ', value: zone.address!),
                        ],
                        if (zone.administrativeAddress != null) ...[
                          _InfoRow(
                              label: 'Địa chỉ hành chính',
                              value: zone.administrativeAddress!),
                        ],
                        if (zone.landHistory != null) ...[
                          _InfoRow(
                              label: 'Lịch sử đất', value: zone.landHistory!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ảnh tổng quan (${zone.overviewImages.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (zone.overviewImages.isEmpty)
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
                    imagePaths: zone.overviewImages,
                    title: null,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lô trồng (${lots.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm lô'),
                      onPressed: () {
                        // Navigate to add lot screen with zoneId pre-filled
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantingLotListScreen(
                              initialZoneId: widget.zoneId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (lots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Chưa có lô trồng nào trong vùng này',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  )
                else
                  ...lots.map((lot) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Icon(Icons.eco, color: Colors.green[700]),
                          ),
                          title: Text(lot.lotName),
                          subtitle: Text('Mã: ${lot.lotCode}'),
                          trailing: Chip(
                            label: Text(lot.statusText),
                            backgroundColor: Colors.green[50],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlantingLotDetailScreen(lotId: lot.id),
                              ),
                            );
                          },
                        ),
                      )),
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



