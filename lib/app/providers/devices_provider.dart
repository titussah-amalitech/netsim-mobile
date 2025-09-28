import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/app/services/device_services.dart';

final devicesFutureProvider = FutureProvider.autoDispose((ref) async {
  final response = await DeviceServices.getDevices();
  if(response.success){
    return response.devices;
  } else {
    return [];
  }
});