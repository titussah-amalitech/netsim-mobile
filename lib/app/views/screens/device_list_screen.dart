import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/app/providers/devices_provider.dart';

import '../../core/constant_data.dart';

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
 
  @override
  Widget build(BuildContext context) {
    var getDevices = ref.watch(devicesFutureProvider);
    return Scaffold(
     
      appBar: AppBar(
        title: const Text('Devices'),
        
      ),
      body: getDevices.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          print('Error: $error');
          return Center(child: Text('Error: $error'));
        },
        data: (devices) {
          print("Devices length: ${devices.length}");
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.devices),
                      const SizedBox(width: 8),
                      //_statusBadge(device.status),
                    ],
                  ),
                  title: Text(device.name),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Type: ${device.type}'),
                      Text(
                        'Status: ${device.status}',
                        style: TextStyle(
                          fontSize: 12,
                          color: device.status == DeviceStatusTypes.onlineStatus
                              ? Colors.green
                              : device.status == DeviceStatusTypes.offlineStatus
                              ? Colors.red
                              : Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      // Show device details dialog
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(device.name),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Text('Type: ${device.type}'),
                                const SizedBox(height: 8),
                                Text('Status: ${device.status}'),
                                const SizedBox(height: 8),
                                if (device.position != null) ...[
                                  Text('Position:'),
                                  Text('  x: ${device.position!.x}'),
                                  Text('  y: ${device.position!.y}'),
                                  const SizedBox(height: 8),
                                ],
                                Text('Parameters:'),
                                Text('  ${device.parameters.toMap().entries.map((e) => '${e.key}: ${e.value}').join('\n  ')}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                           
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },

          );
        },
      ),
    );
  }
}
