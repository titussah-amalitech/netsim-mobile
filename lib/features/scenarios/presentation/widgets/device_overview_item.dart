import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DeviceOverviewItem extends StatelessWidget {
  final dynamic device;

  const DeviceOverviewItem({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.background,
      ),
      child: Row(
        children: [
          Icon(
            Icons.devices,
            size: 20,
            color: device.status.online ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type: ${device.type}',
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Position: (${device.position.x}, ${device.position.y}) • ${device.status.online ? "Online" : "Offline"}',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
