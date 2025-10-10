import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/devices/presentation/screens/device_edit_dialog.dart';

import '../../data/models/device_model.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/scenarios/logic/scenarios_provider.dart';

class DeviceListScreen extends ConsumerWidget {
  final List<Device> devices;
  final Scenario? scenario;

  /// If [scenario] is provided, devices will be read from and edited on that scenario.
  const DeviceListScreen({super.key, required this.devices, this.scenario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If a parent scenario is provided, read its up-to-date value from the provider
    List<Device> currentDevices = devices;
    String appBarTitle = 'Devices';
    if (scenario != null) {
      final scenarios = ref.watch(scenariosProvider);
      final current = scenarios.firstWhere(
        (s) => identical(s, scenario) || (s.name == scenario!.name && s.metadata.createdAt == scenario!.metadata.createdAt),
        orElse: () => scenario!,
      );
      currentDevices = current.devices;
      appBarTitle = current.name;
    }

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: currentDevices.isEmpty
          ? const Center(child: Text('No devices found'))
          : ListView.builder(
              itemCount: currentDevices.length,
              itemBuilder: (context, index) {
                final device = currentDevices[index];
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
              trailing: ElevatedButton(
                  onPressed: () {
                        DeviceEditDialog().showEditDialog(context, device, parentScenario: scenario, deviceIndex: index);
                      },  
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(60, 30),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ), 
                          ),
                           child:Text('Edit', style: TextStyle(color: Colors.white),),
                        ),
                    title: Text(device.type,style: TextStyle(fontWeight: FontWeight.bold),),
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
