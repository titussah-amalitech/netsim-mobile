import 'package:flutter/material.dart';
import '../../data/models/device_model.dart';

class DeviceHeader extends StatelessWidget {
  final Device device;
  final Color deviceColor;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const DeviceHeader({
    super.key,
    required this.device,
    required this.deviceColor,
    required this.isEditing,
    required this.onToggleEdit,
  });

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'server':
        return Icons.dns;
      case 'router':
        return Icons.router;
      case 'switch':
        return Icons.hub;
      case 'pc':
        return Icons.computer;
      case 'firewall':
        return Icons.security;
      default:
        return Icons.device_hub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: deviceColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: deviceColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device.type),
              color: deviceColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: deviceColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${device.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onToggleEdit,
              color: deviceColor,
            ),
        ],
      ),
    );
  }
}
