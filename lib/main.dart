import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:netsim_mobile/app/core/widgets/bottom_nav_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';


void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Network Simulation Game',
      theme: ShadThemeData(
        colorScheme: ShadZincColorScheme.light(),
        brightness: Brightness.light,
      ),
      darkTheme: ShadThemeData(
        colorScheme: ShadZincColorScheme.dark(),
        brightness: Brightness.dark,
      ),
      routes: {
        "/": (context) => const BottomNavWidget(),
        "dashboard": (context) => DashboardScreen(),
        // 'new-device': (context) => const NewDevicePage(),
      },
    );
  }
}
