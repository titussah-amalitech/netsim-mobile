import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/core/providers/theme_provider.dart';
import 'package:netsim_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:netsim_mobile/features/onboarding/presentation/screens/onboarding.dart';
import 'package:netsim_mobile/features/scenarios/presentation/game_view.dart';
import 'package:netsim_mobile/features/scenarios/presentation/screens/scenario_list.dart';
import 'package:netsim_mobile/features/logs/presentation/screens/logs_list_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'features/devices/presentation/screens/device_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

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
      themeMode: themeMode,
      routes: {
        "dashboard": (context) => DashboardScreen(),
        "/": (context) => const Onboarding(),
        "/game": (context) => const GameView(),
        "/dashboard": (context) => const DashboardScreen(),
        "/scenario": (context) => const ScenarioListScreen(),
        "/logs": (context) => const LatestLogsList(),
  "/devices": (context) => DeviceListScreen(devices: const [], scenario: null),
      },
    );
  }
}
