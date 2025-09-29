import 'package:dio/dio.dart';
import 'package:netsim_mobile/app/models/device_model.dart';

//class for devices calls
class DeviceServices {
  static final dio = Dio(                        //define the dio(the route where the data will be sent to and received from database)
    BaseOptions(
      baseUrl: 'http://10.0.2.2:1011/api/', // Replace with your API base URL
    ),
  );

//function to add a device to the database
  static Future<({bool success, String message,DeviceModel ?device})> addDevice(DeviceModel deviceData) async {
    try {
      final response = await dio.post('/devices', data: deviceData.toMap()); //Cange object to map before sending to the database
      if (response.statusCode == 201) {
        return (success: true, message: 'Device added successfully', device: DeviceModel.fromMap(response.data)); //Change map to object after receiving from the database
      } else {
        return (success: false, message: response.statusMessage??'Failed to add device', device:null); //if failed to add device send message and null device
      }
    } catch (e) {
      return (success: false, message: 'Error: $e', device:null); //if error occurs send message and null device
    }
  }
// Function to get all devices from the database
static Future<({bool success, String message, List<DeviceModel> devices})> getDevices() async {
  try {
    final response = await dio.get('/devices'); 
    if (response.statusCode == 200) {
      var data =response.data['data'] as List; //Assuming the response data is a list of devices
      List<DeviceModel> devices = data.map((device) => DeviceModel.fromMap(device)).toList();
       //Convert each map to DeviceModel object
      return (success: true,message: 'Devices retrieved successfully',devices: devices);
    
    } else {
      return (success: false, message: response.statusMessage ?? 'Failed to get devices',devices: <DeviceModel>[]);
    }
  } catch (e) {
    print("Errpr: $e");
    return (success: false,message: 'Error: $e',devices: <DeviceModel>[]);
  }
}
}
