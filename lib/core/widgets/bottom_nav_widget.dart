import 'package:flutter/material.dart';
import 'package:netsim_mobile/features//logs/presentation/screens/logs_list_screen.dart';
import 'package:netsim_mobile/features//onboarding/presentation/screens/onboarding.dart';
import 'package:netsim_mobile/features//devices/presentation/screens/device_list_screen.dart';

class BottomNavWidget extends StatefulWidget {
  const BottomNavWidget({super.key});

  @override
  State<BottomNavWidget> createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  final appScreens = [
    const Onboarding(),
    const DeviceListScreen(),
    const LatestLogsList(),
  ];

  int _currentIndex = 0;

  void onTapped(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Logs'),
        ],
      ),
      body: appScreens[_currentIndex],
    );
  }
}
