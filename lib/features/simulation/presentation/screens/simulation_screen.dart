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

  const SimulationScreen({
    super.key,
    required this.scenario,
  });

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final Map<String, DeviceWidgetController> _deviceControllers = {};
  @override
  void initState() {
    super.initState();
    // Start the simulation once the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(simulationProvider.notifier).startSimulation(widget.scenario);
    });
  }

  @override
  Widget build(BuildContext context) {
    final simulationState = ref.watch(simulationProvider);

    // Show game over dialog when simulation finishes
    if (simulationState.isFinished && !simulationState.isRunning) {
      // Use a post-frame callback to avoid showing dialog during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GameOverDialog(
            scenario: widget.scenario,
            score: simulationState.score,
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(simulationState),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _buildNetworkCanvas(simulationState),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Widget _buildHeader(SimulationState simulationState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Scenario name
          Text(
            widget.scenario.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Timer
          Text(
            _formatTime(simulationState.remainingTime),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
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
    );
  }
  Widget _buildNetworkCanvas(SimulationState simulationState) {
    // Ensure a controller exists for each device so we can trigger animations
    for (final d in simulationState.devices) {
      _deviceControllers.putIfAbsent(d.id, () => DeviceWidgetController());
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: NetworkCanvas(
        devices: simulationState.devices,
        // pass the set of device ids currently in error
        activeErrorDeviceIds: simulationState.activeErrorStartTimes.keys.toSet(),
        controllers: _deviceControllers,
        onDeviceTap: (deviceId) {
          // Only show the fix dialog if this device currently has an error
          if (simulationState.activeErrorStartTimes.containsKey(deviceId)) {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => FixDeviceDialog(
                deviceId: deviceId,
                onConfirm: (id, latency) async {
                  // Capture messenger before async gap to avoid using BuildContext after await
                  final messenger = ScaffoldMessenger.of(context);

                  // Call provider to attempt fix
                  final result = await ref
                      .read(simulationProvider.notifier)
                      .fixDeviceWithLatency(id, latency);

                  if (!mounted) return;

                  final controller = _deviceControllers[id];

                  if (result.$1) {
                    // Success: show snackbar (UI will rebuild via Riverpod state change)
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Device Restored! +${result.$2} points'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Trigger success glow animation on the device widget if controller exists
                    controller?.playSuccess();
                  } else {
                    // Failure: show error and allow retry
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Device unstable. Try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Trigger failure shake animation if controller exists
                    controller?.playFailure();
                  }
                },
              ),
            );
          } else {
            // If no error, show a simple info snack
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No active error on this device')),
            );
          }
        },
      ),
    );
  }
}