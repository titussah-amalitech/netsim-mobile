import 'package:flutter/material.dart';
import '../../data/models/device_model.dart';

class DeviceParametersView extends StatelessWidget {
  final Device device;

  const DeviceParametersView({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        ParameterChip(
          label: 'Ping Interval',
          value: '${device.parameters.pingInterval}ms',
          icon: Icons.timer,
        ),
        ParameterChip(
          label: 'Latency',
          value: '${device.parameters.latencyThreshold}ms',
          icon: Icons.speed,
        ),
        ParameterChip(
          label: 'Failure Rate',
          value:
              '${(device.parameters.failureProbability * 100).toStringAsFixed(1)}%',
          icon: Icons.warning,
        ),
        ParameterChip(
          label: 'Traffic Load',
          value: '${device.parameters.trafficLoad}%',
          icon: Icons.analytics,
        ),
      ],
    );
  }
}

class ParameterChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ParameterChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.inverseSurface.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.inverseSurface),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.inverseSurface,
            ),
          ),
        ],
      ),
    );
  }
}
