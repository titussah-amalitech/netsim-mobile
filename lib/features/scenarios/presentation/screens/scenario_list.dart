// scenario/presentation/scenario_list_screen.dart
import 'package:flutter/material.dart';
import 'package:netsim_mobile/core/widgets/theme_toggle_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scenario_provider.dart';
import '../widgets/difficulty_tag.dart';
import 'scenario_view.dart';


class ScenarioListScreen extends ConsumerWidget {
  const ScenarioListScreen({super.key});

  // List of built-in scenario names that should not be deletable
  static const _builtInScenarios = {'Basic Networking', 'Advanced Routing'};
  
  bool isBuiltInScenario(String name) => _builtInScenarios.contains(name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioNotifierProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scenarios"),
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
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(scenario.name, style: theme.textTheme.h4),
                      ),
                      // Show delete button for non-built-in scenarios
                      if (!isBuiltInScenario(scenario.name))
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24,),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Scenario'),
                                content: Text(
                                  'Are you sure you want to delete "${scenario.name}"? This cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              await ref
                                  .read(scenarioNotifierProvider.notifier)
                                  .deleteScenario(scenario.name);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Deleted scenario "${scenario.name}"'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
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
