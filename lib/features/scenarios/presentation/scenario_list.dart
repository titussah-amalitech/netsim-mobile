// scenario/presentation/scenario_list_screen.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../devices/data/models/device_model.dart';
import '../data/mock_scenarios.dart';
import '../../devices/presentation/screens/device_list_screen.dart';

class ScenarioListScreen extends StatelessWidget {
  const ScenarioListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenarios = MockScenarios.scenarios;
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Scenarios")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: scenarios.length,
        itemBuilder: (context, index) {
          final scenario = scenarios[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShadCard(
              width: double.infinity,
              title: Text(scenario.name, style: theme.textTheme.h4),
              description: Text(
                scenario.metadata.description,
                style: theme.textTheme.muted,
              ),
              footer: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShadButton(
                      child: const Text('Show Devices'),
                      onPressed: () {
                        _showDevicesModal(
                          context,
                          scenario.devices,
                          scenario.name,
                        );
                      },
                    ),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label: 'Difficulty',
                          value: scenario.difficulty,
                        ),
                        _InfoChip(
                          label: 'Time limit',
                          value: '${scenario.timeLimit} s',
                        ),
                        _InfoChip(
                          label: 'Devices',
                          value: scenario.devices.length.toString(),
                        ),
                        _InfoChip(
                          label: 'Created by',
                          value: scenario.metadata.createdBy,
                        ),
                        _InfoChip(
                          label: 'Created',
                          value: _formatDate(scenario.metadata.createdAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Devices', style: theme.textTheme.h4),
                    const SizedBox(height: 8),
                    ...scenario.devices.map(
                      (d) => _DeviceBlock(device: d, theme: theme),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Shows devices in a modal dialog
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
                  title: Text('$scenarioName Devices'),
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
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.muted,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(value, style: theme.textTheme.small),
        ],
      ),
    );
  }
}

class _DeviceBlock extends StatelessWidget {
  final dynamic device;
  final ShadThemeData theme;
  const _DeviceBlock({required this.device, required this.theme});

  @override
  Widget build(BuildContext context) {
    final params = device.parameters;
    final status = device.status;
    final position = device.position;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            device.id,
            style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _mini('Pos', '(${position.x},${position.y})'),
              _mini('Ping', '${params.pingInterval}s'),
              _mini('LatThr', '${params.latencyThreshold}ms'),
              _mini('FailP', params.failureProbability.toStringAsFixed(2)),
              _mini('Load', '${params.trafficLoad}%'),
              _mini('Online', status.online ? 'Yes' : 'No'),
              _mini('Latency', '${status.latency}ms'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String k, String v) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$k: ', style: theme.textTheme.muted.copyWith(fontSize: 11)),
      Text(v, style: theme.textTheme.small.copyWith(fontSize: 11)),
    ],
  );
}

String _formatDate(DateTime dt) {
  return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
}

String _two(int v) => v.toString().padLeft(2, '0');
