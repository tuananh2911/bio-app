import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/farm_provider.dart';
import '../../models/farm_zone.dart';
import 'farm_zone_detail_screen.dart';
import 'farm_zone_form_screen.dart';

class FarmZoneListScreen extends StatelessWidget {
  const FarmZoneListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Vùng trồng'),
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          if (farmProvider.farmZones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có vùng trồng nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn nút + để thêm vùng trồng mới',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: farmProvider.farmZones.length,
            itemBuilder: (context, index) {
              final zone = farmProvider.farmZones[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.location_on, color: Colors.green[700]),
                  ),
                  title: Text(
                    zone.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (zone.company != null)
                        Text('DN: ${zone.company}'),
                      if (zone.address != null)
                        Text('Địa chỉ: ${zone.address}'),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmZoneDetailScreen(zoneId: zone.id),
                      ),
                    );
                  },
                ),
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
              builder: (context) => const FarmZoneFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm vùng'),
      ),
    );
  }
}



