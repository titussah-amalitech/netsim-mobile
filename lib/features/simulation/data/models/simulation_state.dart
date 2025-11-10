import 'package:netsim_mobile/features/devices/data/models/device_model.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/simulation/data/models/device_error.dart';

/// Represents the current state of an active network simulation game
class SimulationState {
  final Scenario? currentScenario;
  final List<Device> devices;
  final List<List<String>> connections;
  final int score;
  final int remainingTime; // in seconds
  // Track multiple concurrent errors: map deviceId -> error start time
  final Map<String, DeviceError> activeErrors;
  final bool isRunning;
  final bool isFinished;
  final DateTime? lastErrorTime; // Track when the last error was generated
  // Recent auto-recovered device IDs (for UI notifications). Cleared after UI consumes.
  final List<String> recentAutoRecoveredDevices;
  // Track recently generated errors for UI notifications
  final List<String> recentErrors;

  const SimulationState({
    this.currentScenario,
    this.devices = const [],
    this.connections = const [],
    this.score = 0,
    this.remainingTime = 0,
    this.activeErrors = const {},
    this.isRunning = false,
    this.isFinished = false,
    this.lastErrorTime,
    this.recentAutoRecoveredDevices = const [],
    this.recentErrors = const [],
  });

  SimulationState copyWith({
    Scenario? currentScenario,
    List<Device>? devices,
    List<List<String>>? connections,
    int? score,
    int? remainingTime,
    Map<String, DeviceError>? activeErrors,
    bool? isRunning,
    bool? isFinished,
    DateTime? lastErrorTime,
    List<String>? recentAutoRecoveredDevices,
    List<String>? recentErrors,
  }) {
    return SimulationState(
      currentScenario: currentScenario ?? this.currentScenario,
      devices: devices ?? this.devices,
      connections: connections ?? this.connections,
      score: score ?? this.score,
      remainingTime: remainingTime ?? this.remainingTime,
      activeErrors: activeErrors ?? this.activeErrors,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
      recentAutoRecoveredDevices: recentAutoRecoveredDevices ?? this.recentAutoRecoveredDevices,
      recentErrors: recentErrors ?? this.recentErrors,
    );
  }
}