import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/scenarios/presentation/widgets/scenario_edit_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../devices/presentation/screens/device_list_screen.dart';
import '../widgets/device_overview_item.dart';
import '../widgets/metadata_row.dart';
import '../providers/scenario_provider.dart';

class ScenarioViewScreen extends ConsumerWidget {
  final Scenario scenario;

  const ScenarioViewScreen({super.key, required this.scenario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final scenariosAsync = ref.watch(scenarioNotifierProvider);

    return scenariosAsync.when(
      data: (scenarios) {
        final current = scenarios.firstWhere(
          (s) =>
              identical(s, scenario) ||
              (s.name == scenario.name &&
                  s.metadata.createdAt == scenario.metadata.createdAt),
          orElse: () => scenario,
        );

        return Scaffold(
          appBar: AppBar(title: Text(current.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metadata Card
                ShadCard(
                  width: double.infinity,
                  title: Text('Scenario Details', style: theme.textTheme.h4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MetadataRow(
                          label: 'Description',
                          value: current.metadata.description,
                        ),
                        const SizedBox(height: 8),
                        MetadataRow(
                          label: 'Difficulty',
                          value: current.difficulty.toUpperCase(),
                        ),
                        const SizedBox(height: 8),
                        MetadataRow(
                          label: 'Time Limit',
                          value: '${current.timeLimit} seconds',
                        ),
                        const SizedBox(height: 8),
                        MetadataRow(
                          label: 'Created By',
                          value: current.metadata.createdBy,
                        ),
                        const SizedBox(height: 8),
                        MetadataRow(
                          label: 'Created At',
                          value: DateFormatter.formatDate(
                            current.metadata.createdAt,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MetadataRow(
                          label: 'Total Devices',
                          value: current.devices.length.toString(),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(350, 40),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScenarioEditDialog().showEditDialog(
                              context,
                              current,
                            );
                          },
                          child: Text(
                            "Edit Scenario",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Devices Overview Card
                ShadCard(
                  width: double.infinity,
                  title: Text('Devices Overview', style: theme.textTheme.h4),
                  footer: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ShadButton(
                      width: double.infinity,
                      child: const Text('Show Devices Details'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceListScreen(
                              devices: current.devices,
                              scenario: current,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: current.devices.isEmpty
                        ? Text(
                            'No devices in this scenario',
                            style: theme.textTheme.muted,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: current.devices.map((device) {
                              return DeviceOverviewItem(device: device);
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(scenario.name)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(scenario.name)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading scenarios: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(scenarioNotifierProvider.notifier).loadScenarios();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
