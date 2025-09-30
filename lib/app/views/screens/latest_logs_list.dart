import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/log_model.dart';
import '../../providers/logs_provider.dart';

Color _statusCardColor(String? status, BuildContext context) {
  if (status == null) return Theme.of(context).cardColor;
  switch (status.toLowerCase()) {
    case 'online':
      return Colors.green.shade50;
    case 'warning':
      return Colors.yellow.shade100;
    case 'offline':
      return Colors.red.shade50;
    default:
      return Theme.of(context).cardColor;
  }
}

class LatestLogsList extends ConsumerWidget {
  const LatestLogsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<LogModel> logs = ref.watch(latestLogsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs"),
      ),

      body:
    Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            child: Row(
              children: [
                const Expanded(child: SizedBox()), // push buttons to far right
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: logs.isEmpty
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Clear all logs?'),
                                  content: const Text('This will remove all loaded logs. Continue?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                ref.read(latestLogsProvider.notifier).clearAll();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        minimumSize: const Size(0, 0),
                        visualDensity: VisualDensity.compact,
                        textStyle: Theme.of(context).textTheme.labelSmall,
                      ),
                      child: const Text('Clear All'),
                    ),
                    ElevatedButton(
                      onPressed: () => ref.read(latestLogsProvider.notifier).loadMore(),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        minimumSize: const Size(0, 0),
                        visualDensity: VisualDensity.compact,
                        textStyle: Theme.of(context).textTheme.labelSmall,
                      ),
                      child: const Text('Load more'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No logs yet'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Card(
                        color: _statusCardColor(log.status, context),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.eventTypeCapitalized, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 6),
                              Text(log.message),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: Text('Device: ${log.deviceTypeCapitalized}', overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 40),
                                  Text(DateFormat('h:mm a').format(log.timestamp.toLocal()), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    )
    );
  }
}
