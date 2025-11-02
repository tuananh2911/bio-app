import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farm_provider.dart';
import '../../models/planting_lot.dart';
import 'planting_lot_detail_screen.dart';
import 'planting_lot_form_screen.dart';

class PlantingLotListScreen extends StatelessWidget {
  final String? initialZoneId;

  const PlantingLotListScreen({super.key, this.initialZoneId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lô trồng'),
      ),
      body: FutureBuilder<List<PlantingLot>>(
        future: _loadLots(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lots = snapshot.data ?? [];

          if (lots.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lô trồng nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: lots.length,
            itemBuilder: (context, index) {
              final lot = lots[index];
              return FutureBuilder(
                future: Provider.of<FarmProvider>(context, listen: false)
                    .getFarmZoneById(lot.farmZoneId),
                builder: (context, zoneSnap) {
                  final zone = zoneSnap.data;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Icon(Icons.eco, color: Colors.green[700]),
                      ),
                      title: Text(
                        lot.lotName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã: ${lot.lotCode}'),
                          if (zone != null) Text('Vùng: ${zone.name}'),
                          Text('Ngày trồng: ${lot.plantingDate.day}/${lot.plantingDate.month}/${lot.plantingDate.year}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(lot.statusText),
                        backgroundColor: Colors.green[50],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlantingLotDetailScreen(lotId: lot.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantingLotFormScreen(
                initialZoneId: initialZoneId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm lô'),
      ),
    );
  }

  Future<List<PlantingLot>> _loadLots(BuildContext context) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (initialZoneId != null) {
      return await farmProvider.getPlantingLotsByZoneId(initialZoneId!);
    }
    return farmProvider.plantingLots;
  }
}
