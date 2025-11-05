import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/simulation/logic/simulation_provider.dart';
import 'package:netsim_mobile/features/simulation/data/models/simulation_state.dart';
import 'package:netsim_mobile/features/simulation/presentation/widgets/network_canvas.dart';
import 'package:netsim_mobile/features/simulation/presentation/widgets/game_over_dialog.dart';
import 'package:netsim_mobile/features/simulation/presentation/widgets/fix_device_dialog.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  final Scenario scenario;

  const SimulationScreen({super.key, required this.scenario});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final Map<String, DeviceWidgetController> _deviceControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simulationProvider.notifier).startSimulation(widget.scenario);
    });
  }

  @override
  Widget build(BuildContext context) {
    final simulationState = ref.watch(simulationProvider);

    // Listen for auto-recovered devices and new errors to show alerts
    ref.listen<SimulationState>(simulationProvider, (previous, next) {
      // Avoid showing on initial registration
      if (previous == null) return;
      if (!mounted) return;

      // Show error alerts
      if (next.recentErrors.isNotEmpty) {
        final deviceId = next.recentErrors.first;
        final message = 'Error detected on device $deviceId!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Clear the error notification
        ref.read(simulationProvider.notifier).clearErrorNotifications();
      }

      // Show auto-recovery alerts
      if (next.recentAutoRecoveredDevices.isNotEmpty) {
        final ids = next.recentAutoRecoveredDevices;
        final message = ids.length == 1
            ? 'Device ${ids.first} auto-recovered — penalty applied.'
            : '${ids.length} devices auto-recovered — penalties applied.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear notifications so we don't show them again
        ref.read(simulationProvider.notifier).clearAutoRecoveredNotifications();
      }
    });

    // Game Over dialog (only show once)
    if (simulationState.isFinished && !simulationState.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => GameOverDialog(
              scenario: widget.scenario,
              score: simulationState.score,
            ),
          );
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, simulationState),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _buildNetworkCanvas(context, simulationState),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // Time Formatter
  // ===============================
  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  // ===============================
  // Header Controls (Timer, Buttons, Score)
  // ===============================
  Widget _buildHeader(BuildContext context, SimulationState simulationState) {
    final notifier = ref.read(simulationProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scenario Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  // Show confirmation dialog
                  final shouldExit = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Exit Simulation?'),
                      content: const Text(
                        'Are you sure you want to exit the simulation? '
                        'Your current progress will be lost.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false), // Cancel
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, true), // Confirm
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Exit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  // Handle user decision
                  if (shouldExit == true) {
                    ref.read(simulationProvider.notifier).resetSimulation();
                    Navigator.pop(context); // Go back to previous screen
                  }
                },
                child: const Icon(Icons.arrow_back_ios, size: 24),
              ),

              Text(
                widget.scenario.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTime(simulationState.remainingTime),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer

              // Control Buttons: Pulse, Pause/Resume
              Row(
                children: [
                   ElevatedButton(
                    onPressed: () {
                          if (simulationState.isRunning) {
                        notifier.pauseSimulation();
                      }
                      Navigator.pushNamed(context, '/logs');
                    },
                       style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('View logs',style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                   ),
                   const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final shouldRestart = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: const Text('Restart Simulation'),
                          content: const Text(
                            'Are you sure you want to restart the simulation? All progress and score will be lost.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text('Restart'),
                            ),
                          ],
                        ),
                      );

                      // If user confirmed restart
                      if (shouldRestart == true) {
                        ref.read(simulationProvider.notifier).resetSimulation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulation restarted successfully!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (simulationState.isRunning) {
                        notifier.pauseSimulation();
                      } else {
                        notifier.resumeSimulation();
                      }
                    },
                    icon: Icon(
                      simulationState.isRunning
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      simulationState.isRunning ? 'Pause' : 'Resume',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: simulationState.isRunning
                          ? Colors.orange
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // Score Display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Score: ${simulationState.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================
  //  Network Canvas
  // ===============================
  Widget _buildNetworkCanvas(
    BuildContext context,
    SimulationState simulationState,
  ) {
    for (final d in simulationState.devices) {
      _deviceControllers.putIfAbsent(d.id, () => DeviceWidgetController());
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.80,
      padding: const EdgeInsets.all(6),
      child: NetworkCanvas(
        showLabels: true,
        devices: simulationState.devices,
        activeErrorDeviceIds: simulationState.activeErrorStartTimes.keys
            .toSet(),
        controllers: _deviceControllers,
        onDeviceTap: (deviceId) {
          if (simulationState.activeErrorStartTimes.containsKey(deviceId)) {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => FixDeviceDialog(
                deviceId: deviceId,
                onConfirm: (id, latency) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await ref
                      .read(simulationProvider.notifier)
                      .fixDeviceWithLatency(id, latency);

                  if (!mounted) return;

                  final controller = _deviceControllers[id];

                  if (result.$1) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Device restored! +${result.$2} points'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    controller?.playSuccess();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect adjustment. Try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    controller?.playFailure();
                  }
                },
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No active error on this device.')),
            );
          }
        },
      ),
    );
  }
}
