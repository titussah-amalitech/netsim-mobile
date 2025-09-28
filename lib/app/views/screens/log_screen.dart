import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogCard extends StatelessWidget {

  const LogCard({super.key});

  @override
  Widget build(BuildContext context) {
    DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              //Refresh device list logic here
            },
          ),
        ],
      ),
    
     body: ListView(
      
      children: [
        Table(
          children: [
            
          ],
        )
      ]
    ),
    );
  }
}
