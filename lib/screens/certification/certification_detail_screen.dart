import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farm_provider.dart';
import '../../models/certification.dart';

class CertificationDetailScreen extends StatelessWidget {
  final String certificationId;

  const CertificationDetailScreen({super.key, required this.certificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Chứng nhận'),
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          final cert = farmProvider.certifications.firstWhere(
            (c) => c.id == certificationId,
            orElse: () => Certification(
              id: '',
              type: CertificationType.gacp,
              plantingLotId: '',
            ),
          );

          if (cert.id.isEmpty) {
            return const Center(child: Text('Không tìm thấy chứng nhận'));
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
                        Row(
                          children: [
                            Icon(
                              cert.isCompleted
                                  ? Icons.verified
                                  : Icons.pending,
                              color: cert.isCompleted ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cert.typeText,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: cert.completionPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            cert.isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(cert.completionPercentage * 100).toInt()}% hoàn thành',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Yêu cầu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...cert.requirementNames.map((requirement) {
                  final isCompleted =
                      cert.requirements[requirement] ?? false;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      title: Text(requirement),
                      value: isCompleted,
                      onChanged: null,
                      secondary: Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                }),
                if (cert.isCompleted && cert.certificateNumber != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Đã được chứng nhận',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Số chứng nhận: ${cert.certificateNumber}'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Generate PDF report
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng xuất PDF đang phát triển')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Xuất báo cáo PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



