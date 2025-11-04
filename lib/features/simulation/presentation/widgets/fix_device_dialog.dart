import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FixDeviceDialog extends ConsumerStatefulWidget {
  final String deviceId;
  final Function(String deviceId, double latency) onConfirm;
  
  const FixDeviceDialog({
    super.key,
    required this.deviceId,
    required this.onConfirm,
  });

  @override
  ConsumerState<FixDeviceDialog> createState() => _FixDeviceDialogState();
}

class _FixDeviceDialogState extends ConsumerState<FixDeviceDialog> {
  double _latency = 120; // Default value in the middle of valid range
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Start 20 second timer
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        Navigator.of(context).pop(); // Auto-close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fix attempt timed out!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fix Device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_latency.round()} ms',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust Latency (ms)',
            style: TextStyle(fontSize: 16),
          ),
          Slider(
            value: _latency,
            min: 0,
            max: 150,
            divisions: 150,
            label: _latency.round().toString(),
            onChanged: (value) {
              setState(() {
                _latency = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            _timeoutTimer?.cancel(); // Cancel timeout timer
            Navigator.of(context).pop();
            widget.onConfirm(widget.deviceId, _latency);
          },
          child: const Text('Confirm Fix'),
        ),
      ],
    );
  }
}