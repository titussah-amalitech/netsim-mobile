import 'package:flutter/material.dart';
import 'package:netsim_mobile/features/devices/data/models/device_model.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../devices/presentation/screens/device_list_screen.dart';
import '../widgets/device_overview_item.dart';
import '../widgets/metadata_row.dart';

class ScenarioViewScreen extends StatelessWidget {
  final Scenario scenario;

  const ScenarioViewScreen({super.key, required this.scenario});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(scenario.name)),
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
                      value: scenario.metadata.description,
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Difficulty',
                      value: scenario.difficulty.toUpperCase(),
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Time Limit',
                      value: '${scenario.timeLimit} seconds',
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Created By',
                      value: scenario.metadata.createdBy,
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Created At',
                      value: _formatDate(scenario.metadata.createdAt),
                    ),
                    const SizedBox(height: 8),
                    MetadataRow(
                      label: 'Total Devices',
                      value: scenario.devices.length.toString(),
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
                    _showDevicesModal(context, scenario.devices, scenario.name);
                  },
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: scenario.devices.isEmpty
                    ? Text(
                        'No devices in this scenario',
                        style: theme.textTheme.muted,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: scenario.devices.map((device) {
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

  void _showDevicesModal(
    BuildContext context,
    List<Device> devices,
    String scenarioName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text('$scenarioName - Devices'),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Flexible(child: DeviceListScreen(devices: devices)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${_padZero(dt.month)}-${_padZero(dt.day)} ${_padZero(dt.hour)}:${_padZero(dt.minute)}';
  }

  String _padZero(int v) => v.toString().padLeft(2, '0');
}
