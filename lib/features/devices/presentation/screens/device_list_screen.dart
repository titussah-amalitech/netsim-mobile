import 'package:flutter/material.dart';

import '../../data/models/device_model.dart';

class DeviceListScreen extends StatelessWidget {
  final List<Device> devices;
  const DeviceListScreen({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: devices.isEmpty
          ? const Center(child: Text('No devices found'))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.devices),
                        const SizedBox(width: 8),
                      ],
                    ),
                    title: Text(device.id),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Status: ${device.status.online ? "online" : "offline"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: device.status.online
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text(
                          'Position: x=${device.position.x}, y=${device.position.y}',
                        ),
                        Text(
                          'Parameters: pingInterval=${device.parameters.pingInterval}, latencyThreshold=${device.parameters.latencyThreshold}, failureProbability=${device.parameters.failureProbability}, trafficLoad=${device.parameters.trafficLoad}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
