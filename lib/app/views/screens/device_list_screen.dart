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
                  leading: Icon(Icons.devices),
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
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to device details screen
                    Navigator.pushNamed(
                      context,
                      'device-details',
                      arguments: device,
                    );
                  },
                ),
              );
            },

          );
        },
      ),
    );
  }
}
