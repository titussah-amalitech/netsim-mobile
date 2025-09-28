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
      floatingActionButton: FloatingActionButton( 
        onPressed: () {
          Navigator.pushNamed(context, 'new-device');
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: () {
          //     //Refresh device list logic here
          //   },
          // ),
        ],
      ),
      body: getDevices.when(
        loading:()=> Center(child: CircularProgressIndicator()),
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
              return ListTile(
                leading: Icon(Icons.devices),
                title: Text(device.name),
                subtitle: Text('Type: ${device.type}'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to device details screen
                  Navigator.pushNamed(context, 'device-details', arguments: device);
                },
              );
            },
            // children: [
            //   Padding(
            //     padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            //     child: Card(
            //       elevation: 2.0,
            //       color: Colors.grey[200],
            //       child: SizedBox(
            //         height: 100,
            //         width: double.infinity,
            //         child: Column(
                      
            //           children: [
            //             Padding(
            //               padding: const EdgeInsets.only(
            //                 left: 8.0,
            //                 right: 8.0,
            //                 top: 20.0,
            //               ),
            //               child: Row(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   CircleAvatar(backgroundColor: Colors.red, radius: 10),
            //                   SizedBox(width: 20),
            //                   Text("Device 1", style: TextStyle(fontSize: 15)),
            //                   SizedBox(width: 170),
            //                   Text('Status', style: TextStyle(fontSize: 15)),
            //                   SizedBox(width: 30),
            //                   Icon(Icons.info_outline, size: 20),
            //                 ],
            //               ),
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.only(left: 30.0,right: 8.0,top: 20.0),
            //               child: Row(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   SizedBox(width: 20),
            //                   Text("Type", style: TextStyle(fontSize: 15)),
            //                   SizedBox(width: 10),
            //                   Text('Position', style: TextStyle(fontSize: 15)),
            //                   SizedBox(width: 10),
            //                   Text('Parameter', style: TextStyle(fontSize: 15)),
            //                 ],
            //               ),
            //             ),
                        
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
          
          
          );
        }
      ),
    );
  }
}
