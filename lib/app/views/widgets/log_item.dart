/*
import 'package:flutter/material.dart';
import 'package:netsim_mobile/app/models/log_model.dart';

class LogItem extends StatelessWidget {
  final LogModel log;

  const LogItem({super.key, required this.log});

  Color getStatusColor(String status) {
    switch (status) {
      case "online":
        return Colors.green;
      case "offline":
        return Colors.red;
      case "warning":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getStatusColor(log.status),
          child: const Icon(Icons.devices, color: Colors.white),
        ),
        title: Text("${log.device} - ${log.eventType}"),
        subtitle: Text(log.message),
        trailing: Text(
          "${log.timestamp.hour}:${log.timestamp.minute}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

*/