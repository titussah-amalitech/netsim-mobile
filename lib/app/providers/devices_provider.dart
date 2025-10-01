import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/app/services/device_services.dart';
import 'package:netsim_mobile/app/models/device_features.dart';

final devicesFutureProvider = FutureProvider.autoDispose<List<Device>>((ref) async {
  final response = await DeviceServices.getDevices();
  if (response.success) {
    return response.devices;
  } else {
    return <Device>[];
  }
});