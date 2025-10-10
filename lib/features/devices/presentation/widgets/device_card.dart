import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../data/models/device_model.dart';
import 'device_header.dart';
import 'device_info_row.dart';
import 'device_parameters_view.dart';
import 'device_parameters_edit.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final int index;
  final bool isEditing;
  final Map<String, dynamic> editingValues;
  final VoidCallback onToggleEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Function(String, dynamic) onValueChanged;

  const DeviceCard({
    super.key,
    required this.device,
    required this.index,
    required this.isEditing,
    required this.editingValues,
    required this.onToggleEdit,
    required this.onSave,
    required this.onCancel,
    required this.onValueChanged,
  });

  Color _getDeviceColor(String type) {
    switch (type.toLowerCase()) {
      case 'server':
        return Colors.blue;
      case 'router':
        return Colors.purple;
      case 'switch':
        return Colors.green;
      case 'pc':
        return Colors.orange;
      case 'firewall':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceColor = _getDeviceColor(device.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            deviceColor.withValues(alpha: 0.15),
            deviceColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: deviceColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeviceHeader(
            device: device,
            deviceColor: deviceColor,
            isEditing: isEditing,
            onToggleEdit: onToggleEdit,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeviceInfoRow(device: device),
                const SizedBox(height: 16),
                Text(
                  'Parameters',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (isEditing) ...[
                  DeviceParametersEdit(
                    device: device,
                    editingValues: editingValues,
                    onValueChanged: onValueChanged,
                  ),
                  const SizedBox(height: 16),
                  _buildEditActions(),
                ] else ...[
                  DeviceParametersView(device: device),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: ShadButton.outline(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShadButton(onPressed: onSave, child: const Text('Save')),
        ),
      ],
    );
  }
}
