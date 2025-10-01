

import 'package:dio/dio.dart';
import 'package:netsim_mobile/app/models/log_model.dart';

class LogServices {
   static final dio = Dio(                    
    BaseOptions(
      baseUrl: 'http://10.0.2.2:1011/api/', // Replace with your API base URL
    ),
  );

 static Future<List<LogModel>> fetchLogs() async {
    try {
      final response = await dio.get('/logs');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return data.map((log) => LogModel.fromMap(Map<String, dynamic>.from(log as Map))).toList();
      }
      
      return <LogModel>[];
    } catch (e) {
  
      return <LogModel>[];
    }
  }

 
  static Future<LogModel?> fetchLatestLog() async {
    try {
      // Try a dedicated endpoint first (if backend provides it)
      final response = await dio.get('/logs/latest');
      if (response.statusCode == 200) {
        // If the response contains data as an object
        final raw = response.data['data'] ?? response.data;
        if (raw is Map) return LogModel.fromMap(Map<String, dynamic>.from(raw));
      }
    } catch (_) {
     
    }

    try {
      final all = await fetchLogs();
      if (all.isEmpty) return null;
      all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return all.first;
    } catch (_) {
      return null;
    }
  }
}
