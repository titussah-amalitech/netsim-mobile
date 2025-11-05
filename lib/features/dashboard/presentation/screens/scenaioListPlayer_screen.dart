// scenario/presentation/scenario_list_screen.dart
import 'package:flutter/material.dart';
import 'package:netsim_mobile/core/widgets/theme_toggle_button.dart';
import 'package:netsim_mobile/features/scenarios/presentation/providers/scenario_provider.dart';
import 'package:netsim_mobile/features/scenarios/presentation/widgets/difficulty_tag.dart';
import 'package:netsim_mobile/features/simulation/presentation/screens/simulation_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ScenarioListScreenPlayer extends ConsumerWidget {
  const ScenarioListScreenPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioNotifierProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Scenarios"),
        centerTitle: true,
        actions: [ThemeToggleButton()],
      ),
      body: scenariosAsync.when(
        data: (scenarios) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            final scenario = scenarios[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShadCard(
                width: double.infinity,
                title: Text(scenario.name, style: theme.textTheme.h4),
                description: Text(
                  scenario.metadata.description,
                  style: theme.textTheme.muted,
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                       Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: DifficultyTag(difficulty: scenario.difficulty),
                ),
                 ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SimulationScreen(scenario: scenario),
                      ),
                    );
                  },
                  label: const Text('Start'),
                  icon: const Icon(Icons.play_arrow),
                  style: ButtonStyle(
                    backgroundColor:WidgetStateProperty.all<Color>(Colors.blueGrey),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  ),
                ),
                  ],
                )
                )
              
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading scenarios: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(scenarioNotifierProvider.notifier).loadScenarios();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
