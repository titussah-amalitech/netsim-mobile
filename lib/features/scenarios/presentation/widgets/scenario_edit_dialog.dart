import 'package:flutter/material.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scenario_provider.dart';
import '../../../../core/widgets/root_scaffold.dart';

class ScenarioEditDialog {
  Future<void> showEditDialog(BuildContext context, Scenario scenario) async {
    final timeLimitController = TextEditingController(
      text: scenario.timeLimit.toString(),
    );
    final descriptionController = TextEditingController(
      text: scenario.metadata.description,
    );
    final formKey = GlobalKey<FormState>();

    String selectedDifficulty = scenario.difficulty;

    final result = await showDialog<Map<String, dynamic>?>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (consumerContext, ref, child) {
            return StatefulBuilder(
              builder: (statefulContext, setState) {
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
                          DropdownButtonFormField<String>(
                            value: selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Difficulty',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'easy',
                                child: Text('Easy'),
                              ),
                              DropdownMenuItem(
                                value: 'medium',
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: 'hard',
                                child: Text('Hard'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedDifficulty = value;
                                });
                              }
                            },
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please select difficulty'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: timeLimitController,
                            decoration: const InputDecoration(
                              labelText: 'Time Limit (seconds)',
                              border: OutlineInputBorder(),
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter a description'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(null);
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
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final newTimeLimit = int.parse(
                          timeLimitController.text.trim(),
                        );
                        final newDescription = descriptionController.text
                            .trim();

                        final updatedMetadata = scenario.metadata.copyWith(
                          description: newDescription,
                        );

                        final updatedScenario = scenario.copyWith(
                          difficulty: selectedDifficulty,
                          timeLimit: newTimeLimit,
                          metadata: updatedMetadata,
                        );

                        try {
                          final notifier = ref.read(
                            scenarioNotifierProvider.notifier,
                          );
                          await notifier.updateScenario(updatedScenario);

                          Navigator.of(dialogContext).pop({
                            'success': true,
                            'message': 'Scenario updated successfully',
                          });
                        } catch (e) {
                          Navigator.of(dialogContext).pop({
                            'success': false,
                            'message': 'Failed to update scenario: $e',
                          });
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (result != null && context.mounted) {
      if (result['success'] == true) {
        RootScaffold.showSuccessSnackBar(context, result['message'] as String);
      } else {
        RootScaffold.showErrorSnackBar(context, result['message'] as String);
      }
    }
  }
}
