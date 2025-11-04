import 'package:netsim_mobile/features/devices/data/models/device_model.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';

/// Represents the current state of an active network simulation game
class SimulationState {
  final Scenario? currentScenario;
  final List<Device> devices;
  final int score;
  final int remainingTime; // in seconds
  // Track multiple concurrent errors: map deviceId -> error start time
  final Map<String, DateTime> activeErrorStartTimes;
  final bool isRunning;
  final bool isFinished;
  final DateTime? lastErrorTime; // Track when the last error was generated
  // Recent auto-recovered device IDs (for UI notifications). Cleared after UI consumes.
  final List<String> recentAutoRecoveredDevices;

  const SimulationState({
    this.currentScenario,
    this.devices = const [],
    this.score = 0,
    this.remainingTime = 0,
  this.activeErrorStartTimes = const {},
    this.isRunning = false,
    this.isFinished = false,
    this.lastErrorTime,
    this.recentAutoRecoveredDevices = const [],
  });

  SimulationState copyWith({
    Scenario? currentScenario,
    List<Device>? devices,
    int? score,
    int? remainingTime,
  Map<String, DateTime>? activeErrorStartTimes,
    bool? isRunning,
    bool? isFinished,
    DateTime? lastErrorTime,
    List<String>? recentAutoRecoveredDevices,
  }) {
    return SimulationState(
      currentScenario: currentScenario ?? this.currentScenario,
      devices: devices ?? this.devices,
      score: score ?? this.score,
      remainingTime: remainingTime ?? this.remainingTime,
  activeErrorStartTimes: activeErrorStartTimes ?? this.activeErrorStartTimes,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
      recentAutoRecoveredDevices:
          recentAutoRecoveredDevices ?? this.recentAutoRecoveredDevices,
    );
  }
}