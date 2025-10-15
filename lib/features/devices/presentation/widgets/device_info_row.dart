import 'package:flutter/material.dart';
import '../../data/models/device_model.dart';

class DeviceInfoRow extends StatelessWidget {
  final Device device;

  const DeviceInfoRow({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final statusColor = device.status.online ? Colors.green : Colors.red;

    return Row(
      children: [
        Expanded(
          child: _buildInfoChip(
            icon: Icons.wifi,
            label: device.status.online ? 'Online' : 'Offline',
            color: statusColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoChip(
            icon: Icons.location_on,
            label: 'x:${device.position.x}, y:${device.position.y}',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
