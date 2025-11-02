import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../models/harvest.dart';
import 'harvest_form_screen.dart';
import 'harvest_detail_screen.dart';

class HarvestListScreen extends StatelessWidget {
  const HarvestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thu hoạch'),
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          if (farmProvider.harvests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thu hoạch nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          final sortedHarvests = List<Harvest>.from(farmProvider.harvests)
            ..sort((a, b) => b.harvestDate.compareTo(a.harvestDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedHarvests.length,
            itemBuilder: (context, index) {
              final harvest = sortedHarvests[index];
              return FutureBuilder(
                future: farmProvider.getPlantingLotById(harvest.plantingLotId),
                builder: (context, lotSnap) {
                  final lot = lotSnap.data;
                  return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Icon(Icons.agriculture, color: Colors.purple[700]),
                  ),
                  title: Text(
                    lot?.lotName ?? 'Không xác định',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày: ${DateFormat('dd/MM/yyyy').format(harvest.harvestDate)}'),
                      Text('Khối lượng: ${harvest.quantity} kg'),
                      if (harvest.dnaSampleTaken)
                        const Text('✓ Đã lấy mẫu DNA'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HarvestDetailScreen(harvestId: harvest.id),
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
              builder: (context) => const HarvestFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ghi thu hoạch'),
      ),
    );
  }
}



