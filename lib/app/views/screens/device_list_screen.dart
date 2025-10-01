import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/app/providers/devices_provider.dart';

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
                  title: Text(device.type),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      Text(
                        'Status: ${device.status.online ? "online" : "offline"}',
                        style: TextStyle(
                          fontSize: 13,
                          color: device.status.online ? Colors.green : Colors.red,
                        ),
                      ),
                      Text('Parameters: ....'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      // Show device details dialog
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(device.type),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Text('ID: ${device.deviceId}'),
                                const SizedBox(height: 8),
                                Text('Status: ${device.status.online ? "online" : "offline"}'),
                                const SizedBox(height: 8),
                                Text('Position:'),
                                Text('  x: ${device.position.x}'),
                                Text('  y: ${device.position.y}'),
                                const SizedBox(height: 8),
                                Text('Parameters:'),
                                Text('  pingInterval: ${device.parameters.pingInterval}\n  latencyThreshold: ${device.parameters.latencyThreshold}\n  failureProbability: ${device.parameters.failureProbability}\n  trafficLoad: ${device.parameters.trafficLoad}'),
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
