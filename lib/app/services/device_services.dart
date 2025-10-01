import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:netsim_mobile/app/models/device_model.dart';
import 'package:netsim_mobile/app/models/device_features.dart';

//class for devices calls
class DeviceServices {
  static final dio = Dio(                        //define the dio(the route where the data will be sent to and received from database)
    BaseOptions(
      baseUrl: 'http://10.0.2.2:1011/api/', // Replace with your API base URL
    ),
  );

static Future<({bool success, String message, List<Device> devices})> getDevices() async {
  try {
      final response = await dio.get('scenarios/load/68dd3238f375f9b56c4f5c90');
      if (response.statusCode == 200) {
        dynamic payload = response.data;
        if (payload is Map && payload.containsKey('data')) payload = payload['data'];
        // Convert the (unwrapped) scenario map into DeviceModel which will parse nested devices
        final model = DeviceModel.fromMap(payload as Map<String, dynamic>);
        return (success: true, message: 'Devices retrieved successfully', devices: model.devices);
      } else {
        return (success: false, message: response.statusMessage ?? 'Failed to get devices', devices: <Device>[]);
      }
  } catch (e) {
      if (kDebugMode) print('Error in getDevices: $e');
      return (success: false, message: 'Error: $e', devices: <Device>[]);
  }
}
}
