

import 'package:dio/dio.dart';
import 'package:netsim_mobile/app/models/log_model.dart';

class LogServices {
   static final dio = Dio(                    
    BaseOptions(
      baseUrl: 'http://10.0.2.2:1011/api/', // Replace with your API base URL
    ),
  );

 static Future<List<LogModel>> fetchLogs() async {

    final response = await dio.get('/logs',);

    if (response.statusCode == 200) {
      final data =response.data['data'] as List;
      return data.map((log) => LogModel.fromMap(log)).toList();
    } else {
      throw Exception("Failed to fetch logs");
    }
  }
}
