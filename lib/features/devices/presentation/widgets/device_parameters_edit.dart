import 'package:flutter/material.dart';
import '../../data/models/device_model.dart';

class DeviceParametersEdit extends StatelessWidget {
  final Device device;
  final Map<String, dynamic> editingValues;
  final Function(String, dynamic) onValueChanged;

  const DeviceParametersEdit({
    super.key,
    required this.device,
    required this.editingValues,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pingInterval =
        editingValues['pingInterval'] ?? device.parameters.pingInterval;
    final latencyThreshold =
        editingValues['latencyThreshold'] ?? device.parameters.latencyThreshold;
    final failureProbability =
        editingValues['failureProbability'] ??
        device.parameters.failureProbability;
    final trafficLoad =
        editingValues['trafficLoad'] ?? device.parameters.trafficLoad;
    final online = editingValues['online'] ?? device.status.online;

    // Clamp values to ensure they're within slider ranges
    final clampedPingInterval = (pingInterval as int).clamp(100, 10000);
    final clampedLatencyThreshold = (latencyThreshold as int).clamp(0, 1000);
    final clampedFailureProbability = (failureProbability as double).clamp(
      0.0,
      1.0,
    );
    final clampedTrafficLoad = (trafficLoad as int).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Toggle
        SwitchListTile(
          title: const Text('Device Status'),
          subtitle: Text(online ? 'Online' : 'Offline'),
          value: online,
          activeTrackColor: Colors.green,
          onChanged: (value) => onValueChanged('online', value),
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 12),

        // Latency Threshold Slider
        Text(
          'Latency Threshold: ${clampedLatencyThreshold}ms',
          style: theme.textTheme.bodyMedium,
        ),
        Slider(
          value: clampedLatencyThreshold.toDouble(),
          min: 0,
          max: 1000,
          divisions: 100,
          label: '${clampedLatencyThreshold}ms',
          onChanged: (value) =>
              onValueChanged('latencyThreshold', value.toInt()),
        ),

        const SizedBox(height: 12),

        // Ping Interval Slider
        Text(
          'Ping Interval: ${clampedPingInterval}ms',
          style: theme.textTheme.bodyMedium,
        ),
        Slider(
          value: clampedPingInterval.toDouble(),
          min: 100,
          max: 10000,
          divisions: 99,
          label: '${clampedPingInterval}ms',
          onChanged: (value) => onValueChanged('pingInterval', value.toInt()),
        ),

        const SizedBox(height: 12),

        // Failure Probability Slider
        Text(
          'Failure Probability: ${(clampedFailureProbability * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.bodyMedium,
        ),
        Slider(
          value: clampedFailureProbability,
          min: 0,
          max: 1,
          divisions: 100,
          label: '${(clampedFailureProbability * 100).toStringAsFixed(1)}%',
          onChanged: (value) => onValueChanged('failureProbability', value),
        ),

        const SizedBox(height: 12),

        // Traffic Load Slider
        Text(
          'Traffic Load: $clampedTrafficLoad%',
          style: theme.textTheme.bodyMedium,
        ),
        Slider(
          value: clampedTrafficLoad.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: '$clampedTrafficLoad%',
          onChanged: (value) => onValueChanged('trafficLoad', value.toInt()),
        ),
      ],
    );
  }
}
