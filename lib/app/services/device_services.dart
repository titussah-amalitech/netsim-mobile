import 'package:netsim_mobile/app/models/scenario_model.dart';
import 'package:netsim_mobile/app/models/device_features.dart';
import 'package:netsim_mobile/app/dummy_data/dummy_scenario.dart';

//class for devices calls
class DeviceServices {
 /* static final dio = Dio(                        //define the dio(the route where the data will be sent to and received from database)
    BaseOptions(
      baseUrl: 'http://10.0.2.2:1011/api/', // Replace with your API base URL
    ),
  );
 */
static Future<({bool success, String message, List<Device> devices})> getDevices() async {
  await Future.delayed(const Duration(milliseconds: 100));
  try {
    final model = ScenarioModel.fromMap(dummyScenario as Map<String, dynamic>);
    return (success: true, message: 'Devices retrieved from dummy data', devices: model.devices);
  } catch (e) {
    return (success: false, message: 'Error: $e', devices: <Device>[]);
  }
}
}