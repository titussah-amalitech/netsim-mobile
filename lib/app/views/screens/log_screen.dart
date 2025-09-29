import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/logs_provider.dart';

class LogsPage extends ConsumerStatefulWidget {
  const LogsPage({super.key});

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {

  @override
  Widget build(BuildContext context) {
    final logFutureProvider = ref.watch(logsFutureProvider);
    //final notifier = ref.read(logProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs"),
      ),
      body:  logFutureProvider.when(data: (data){
        var logs= ref.watch(logsProvider);
        return ListView.builder(
          itemCount: logs.filteredLogs.length,
          itemBuilder: (context, index) {
            final log = logs.filteredLogs[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(12),
                leading: Icon(Icons.event_note),
                title: Text(log.message),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Type: ${log.eventType}"),
                    Text("Status: ${log.status}",
                        style: TextStyle(
                          fontSize: 12,
                          color: log.status == "online"
                              ? Colors.green
                              : log.status == "offline"
                              ? Colors.red
                              : Colors.orange,
                        )),
                    Text("Time: ${log.timestamp.toLocal().toString()}"),
                  ],
                ),
              ),
            );
          },
        );
      
      },
       error: (error,stack){
          return Center(child: Text("Error: $error"));
       },
        loading: (){
          return const Center(child: CircularProgressIndicator());
        
        })   );
  }
}
