import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:netsim_mobile/features/logs/data/models/log_model.dart';
import 'package:netsim_mobile/features/logs/logic/logs_provider.dart';
import 'package:netsim_mobile/core/widgets/theme_toggle_button.dart';
import 'package:netsim_mobile/features/simulation/logic/simulation_provider.dart';
import 'package:netsim_mobile/features/simulation/data/models/simulation_state.dart';

Color _statusBadgeColor(String? status) {
  if (status == null) return Colors.grey;
  switch (status.toLowerCase()) {
    case 'online':
      return Colors.green;
    case 'warning':
      return Colors.orange;
    case 'offline':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class LatestLogsList extends ConsumerStatefulWidget {
  const LatestLogsList({super.key});

  @override
  ConsumerState<LatestLogsList> createState() => _LatestLogsListState();
}

class _LatestLogsListState extends ConsumerState<LatestLogsList> {
  @override
  Widget build(BuildContext context) {
    final List<LogModel> logs = ref.watch(latestLogsProvider);

    // Listen to simulation state changes to control log update frequency
    ref.listen<SimulationState>(simulationProvider, (previous, next) {
      // Toggle gameplay mode in logs notifier based on simulation state
      ref
          .read(latestLogsProvider.notifier)
          .setGameplayMode(next.isRunning || false);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs"),
        centerTitle: true,
        actions: [ThemeToggleButton()],
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Expanded(child: SizedBox()),
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
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    title: const Text('Clear all logs?'),
                                    content: const Text(
                                      'This will remove all loaded logs. Continue?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Clear'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  ref
                                      .read(latestLogsProvider.notifier)
                                      .clearAll();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 17,
                          ),
                          minimumSize: const Size(0, 0),
                          visualDensity: VisualDensity.compact,
                          textStyle: Theme.of(context).textTheme.labelSmall,
                        ),
                        child: const Text('Clear All'),
                      ),

                      ElevatedButton(
                        onPressed: () =>
                            ref.read(latestLogsProvider.notifier).loadMore(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 17,
                          ),
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

            // Logs list
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
                          color: Theme.of(context).colorScheme.onPrimary,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // content column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.eventTypeCapitalized,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(log.message),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Device: ${log.deviceTypeCapitalized}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                          Text(
                                            DateFormat(
                                              'h:mm a',
                                            ).format(log.timestamp.toLocal()),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    // color: Theme.of(
                                    //   context,
                                    // ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _statusBadgeColor(log.status),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      log.status.toLowerCase() == 'online'
                                          ? Icons.check
                                          : log.status.toLowerCase() ==
                                                'offline'
                                          ? Icons.close
                                          : Icons.error,
                                      color: _statusBadgeColor(log.status),
                                      size: 15,
                                    ),
                                  ),
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
      ),
    );
  }
}
