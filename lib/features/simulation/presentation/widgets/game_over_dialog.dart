import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/simulation/logic/simulation_provider.dart';
import 'package:netsim_mobile/features/simulation/presentation/screens/simulation_screen.dart';

class GameOverDialog extends ConsumerWidget {
  final Scenario scenario;
  final int score;

  const GameOverDialog({
    super.key,
    required this.scenario,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text("Simulation Over"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Your final score: $score"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  ref.read(simulationProvider.notifier).resetSimulation();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to scenario list
                },
                child: const Text("Exit"),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  ref.read(simulationProvider.notifier).resetSimulation();
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SimulationScreen(
                        scenario: scenario,
                      ),
                    ),
                  );
                },
                child: const Text("Restart"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}