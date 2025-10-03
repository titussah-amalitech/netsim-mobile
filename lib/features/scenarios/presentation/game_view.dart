import 'package:flutter/material.dart';
import 'package:netsim_mobile/features/dashboard/presentation/widgets/dashboard_simplified.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Placeholder(),
          Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: DashboardSimplified(),
          ),
        ],
      ),
    );
  }
}
