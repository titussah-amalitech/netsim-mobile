import 'package:flutter/material.dart';
import '../../data/models/device_model.dart';

class DeviceParametersView extends StatelessWidget {
  final Device device;

  const DeviceParametersView({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildParameterChip(
          'Ping Interval',
          '${device.parameters.pingInterval}ms',
          Icons.timer,
          Colors.purple,
        ),
        _buildParameterChip(
          'Latency',
          '${device.parameters.latencyThreshold}ms',
          Icons.speed,
          Colors.orange,
        ),
        _buildParameterChip(
          'Failure Rate',
          '${(device.parameters.failureProbability * 100).toStringAsFixed(1)}%',
          Icons.warning,
          Colors.red,
        ),
        _buildParameterChip(
          'Traffic Load',
          '${device.parameters.trafficLoad}%',
          Icons.analytics,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildParameterChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
