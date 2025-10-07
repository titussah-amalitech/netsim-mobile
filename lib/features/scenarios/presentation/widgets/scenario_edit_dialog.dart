import 'package:flutter/material.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/scenarios/data/sources/mock_scenarios.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/scenarios_provider.dart';

class ScenarioEditDialog {
  Future<void> showEditDialog(BuildContext context, Scenario scenario) async {
    final nameController = TextEditingController(text: scenario.name);
    final difficultyController = TextEditingController(
      text: scenario.difficulty,
    );
    final timeLimitController = TextEditingController(
      text: scenario.timeLimit.toString(),
    );
    final descriptionController = TextEditingController(
      text: scenario.metadata.description,
    );
    final formKey = GlobalKey<FormState>();

    final parentContext = context;

    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Edit Scenario: ${scenario.name}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Scenario Name',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a name'
                        : null,
                  ),
                  TextFormField(
                    controller: difficultyController,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter difficulty'
                        : null,
                  ),
                  TextFormField(
                    controller: timeLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Time Limit (seconds)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter time limit';
                      }
                      if (int.tryParse(v.trim()) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Save action
                          if (!formKey.currentState!.validate()) return;

                          final newName = nameController.text.trim();
                          final newDifficulty = difficultyController.text
                              .trim();
                          final newTimeLimit = int.parse(
                            timeLimitController.text.trim(),
                          );
                          final newDescription = descriptionController.text
                              .trim();

                          final updatedMetadata = scenario.metadata.copyWith(
                            description: newDescription,
                          );

                          final updatedScenario = scenario.copyWith(
                            name: newName,
                            difficulty: newDifficulty,
                            timeLimit: newTimeLimit,
                            metadata: updatedMetadata,
                          );

                          // Replace the scenario in the mock list. Try identity first, fall back to matching createdAt+name
                          var index = MockScenarios.scenarios.indexWhere(
                            (s) => identical(s, scenario),
                          );
                          if (index == -1) {
                            index = MockScenarios.scenarios.indexWhere(
                              (s) =>
                                  s.name == scenario.name &&
                                  s.metadata.createdAt ==
                                      scenario.metadata.createdAt,
                            );
                          }

                          // Update via provider so UI refreshes immediately.
                          try {
                            final container = ProviderScope.containerOf(
                              parentContext,
                            );
                            final notifier = container.read(
                              scenariosProvider.notifier,
                            );
                            notifier.updateScenario(scenario, updatedScenario);
                          } catch (_) {
                            // Fallback: keep MockScenarios in sync
                            var idx = MockScenarios.scenarios.indexWhere(
                              (s) => identical(s, scenario),
                            );
                            if (idx == -1) {
                              idx = MockScenarios.scenarios.indexWhere(
                                (s) =>
                                    s.name == scenario.name &&
                                    s.metadata.createdAt ==
                                        scenario.metadata.createdAt,
                              );
                            }
                            if (idx != -1)
                              MockScenarios.scenarios[idx] = updatedScenario;
                          }

                          Navigator.of(context).pop();
                          try {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('Scenario updated successfully'),
                              ),
                            );
                          } catch (_) {
                            // If ScaffoldMessenger isn't present, show a dialog instead.
                            showDialog<void>(
                              context: parentContext,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Success'),
                                content: const Text(
                                  'Scenario updated successfully',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
