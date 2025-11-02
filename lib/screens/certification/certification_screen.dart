import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farm_provider.dart';
import '../../models/certification.dart';
import '../../models/planting_lot.dart';
import 'certification_detail_screen.dart';

class CertificationScreen extends StatelessWidget {
  const CertificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi Chứng nhận'),
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          if (farmProvider.certifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có chứng nhận nào',
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
            itemCount: farmProvider.certifications.length,
            itemBuilder: (context, index) {
              final cert = farmProvider.certifications[index];
              return FutureBuilder(
                future: farmProvider.getPlantingLotById(cert.plantingLotId),
                builder: (context, lotSnap) {
                  final lot = lotSnap.data;
                  return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cert.isCompleted
                        ? Colors.green[100]
                        : Colors.orange[100],
                    child: Icon(
                      cert.isCompleted ? Icons.verified : Icons.pending,
                      color: cert.isCompleted ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                  title: Text(cert.typeText),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lot != null) Text('Lô: ${lot.lotName}'),
                      Text(
                        'Tiến độ: ${(cert.completionPercentage * 100).toInt()}%',
                      ),
                      if (cert.isCompleted)
                        Text(
                          'Đã hoàn thành',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                    ],
                  ),
                  trailing: CircularProgressIndicator(
                    value: cert.completionPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      cert.isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CertificationDetailScreen(
                          certificationId: cert.id,
                        ),
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
    );
  }
}



