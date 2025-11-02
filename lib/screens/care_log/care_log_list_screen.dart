import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../models/care_log.dart';
import 'care_log_form_screen.dart';
import 'care_log_detail_screen.dart';

class CareLogListScreen extends StatelessWidget {
  const CareLogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký Chăm sóc'),
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          if (farmProvider.careLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nhật ký nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          final sortedLogs = List<CareLog>.from(farmProvider.careLogs)
            ..sort((a, b) => b.activityDate.compareTo(a.activityDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedLogs.length,
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return FutureBuilder(
                future: farmProvider.getPlantingLotById(log.plantingLotId),
                builder: (context, lotSnap) {
                  final lot = lotSnap.data;
                  return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActivityColor(log.activityType).withOpacity(0.2),
                    child: Icon(
                      _getActivityIcon(log.activityType),
                      color: _getActivityColor(log.activityType),
                    ),
                  ),
                  title: Text(log.activityTypeText),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lot != null) Text('Lô: ${lot.lotName}'),
                      Text(DateFormat('dd/MM/yyyy HH:mm').format(log.activityDate)),
                      if (log.description != null)
                        Text(
                          log.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CareLogDetailScreen(logId: log.id),
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
              builder: (context) => const CareLogFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ghi nhật ký'),
      ),
    );
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



