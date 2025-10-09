import 'package:flutter/material.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../devices/presentation/screens/device_list_screen.dart';
import '../widgets/device_overview_item.dart';
import '../widgets/edit_scenario_modal.dart';
import '../widgets/metadata_row.dart';

class ScenarioViewScreen extends StatefulWidget {
  final Scenario scenario;

  const ScenarioViewScreen({super.key, required this.scenario});

  @override
  State<ScenarioViewScreen> createState() => _ScenarioViewScreenState();
}

class _ScenarioViewScreenState extends State<ScenarioViewScreen> {
  late Scenario _currentScenario;

  @override
  void initState() {
    super.initState();
    _currentScenario = widget.scenario;
  }

  void _showEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditScenarioModal(scenario: _currentScenario),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        if (result['success'] == true && result['scenario'] is Scenario) {
          setState(() {
            _currentScenario = result['scenario'] as Scenario;
          });
          if (context.mounted)
            SnackBarHelper.showSuccess(
              context,
              'Scenario updated successfully',
            );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentScenario.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditModal,
            tooltip: 'Edit Scenario',
          ),
        ],
      ),
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
                      value: _currentScenario.metadata.description,
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Difficulty',
                      value: _currentScenario.difficulty.toUpperCase(),
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Time Limit',
                      value: '${_currentScenario.timeLimit} seconds',
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Created By',
                      value: _currentScenario.metadata.createdBy,
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Created At',
                      value: DateFormatter.formatDate(
                        _currentScenario.metadata.createdAt,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Total Devices',
                      value: _currentScenario.devices.length.toString(),
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
                        builder: (context) =>
                            DeviceListScreen(devices: _currentScenario.devices),
                      ),
                    );
                  },
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _currentScenario.devices.isEmpty
                    ? Text(
                        'No devices in this scenario',
                        style: theme.textTheme.muted,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _currentScenario.devices.map((device) {
                          return DeviceOverviewItem(device: device);
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
