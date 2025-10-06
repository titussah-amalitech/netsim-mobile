// scenario/presentation/scenario_list_screen.dart
import 'package:flutter/material.dart';
import 'package:netsim_mobile/shared/widgets/theme_toggle_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../data/sources/mock_scenarios.dart';
import '../widgets/difficulty_tag.dart';
import 'scenario_view.dart';

class ScenarioListScreen extends StatelessWidget {
  const ScenarioListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenarios = MockScenarios.scenarios;
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scenarios"),
        centerTitle: true,
        actions: [ThemeToggleButton()],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: scenarios.length,
        itemBuilder: (context, index) {
          final scenario = scenarios[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScenarioViewScreen(scenario: scenario),
                  ),
                );
              },
              child: ShadCard(
                width: double.infinity,
                title: Text(scenario.name, style: theme.textTheme.h4),
                description: Text(
                  scenario.metadata.description,
                  style: theme.textTheme.muted,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: DifficultyTag(difficulty: scenario.difficulty),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
