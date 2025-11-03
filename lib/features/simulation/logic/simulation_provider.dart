import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:netsim_mobile/features/devices/data/models/device_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_position.dart';
import 'package:netsim_mobile/features/devices/data/models/device_status.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/simulation/data/models/simulation_state.dart';
import 'package:netsim_mobile/features/simulation/services/sound_service.dart';

/// Provider for the sound service
final soundServiceProvider = Provider<SoundService>((ref) => SoundService());

/// Main simulation provider that manages simulation logic and state
final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationState>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return SimulationNotifier(soundService);
});

/// Simulation logic controller using Riverpod's StateNotifier.
class SimulationNotifier extends StateNotifier<SimulationState> {
  Timer? _gameTimer;
  Timer? _errorTimer;
  final Random _random = Random();
  final SoundService _soundService;

  SimulationNotifier(this._soundService) : super(const SimulationState());

  @override
  void dispose() {
    _gameTimer?.cancel();
    _errorTimer?.cancel();
    super.dispose();
  }

  // ===============================
  // 🎮 Start Simulation
  // ===============================
  void startSimulation(Scenario scenario) {
    if (state.isRunning) return;

    final deviceCount = scenario.devices.length;
    if (deviceCount == 0) return;

    const radius = 120;
    const centerX = 400;
    const centerY = 300;

    debugPrint('Starting simulation with $deviceCount devices');

    // Position devices in a circular layout
    final positionedDevices = List.generate(deviceCount, (index) {
      final angle = (2 * pi * index) / deviceCount;
      final x = centerX + (radius * cos(angle)).round();
      final y = centerY + (radius * sin(angle)).round();

      final device = scenario.devices[index];
      return Device(
        id: device.id,
        type: device.type,
        position: Position(x: x, y: y),
        parameters: device.parameters,
        status: Status(
          online: true,
          latency: 0,
          lastChecked: DateTime.now(),
        ),
      );
    });

    // Set initial state
    state = SimulationState(
      currentScenario: scenario,
      devices: positionedDevices,
      remainingTime: 5 * 60,
      isRunning: true,
    );

    // Start timers
    _startTimers();

    for (var d in positionedDevices) {
      debugPrint('Device ${d.id} positioned at (${d.position.x}, ${d.position.y})');
    }
  }

  // ===============================
  // 🕒 Timer Helpers
  // ===============================
  void _startTimers() {
    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimer(),
    );

    _errorTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _generateRandomError(),
    );
  }

  void _updateTimer() {
    if (!state.isRunning) return;

    if (state.remainingTime <= 0) {
      endSimulation();
      return;
    }

    state = state.copyWith(remainingTime: state.remainingTime - 1);
  }

  // ===============================
  // ⚠️ Random Error Generator
  // ===============================
  void _generateRandomError() {
    if (!state.isRunning) return;

    if (state.lastErrorTime != null &&
        DateTime.now().difference(state.lastErrorTime!).inSeconds < 15) {
      return;
    }

    final devices = state.devices;
    if (devices.isEmpty) return;

    final currentErrors = state.activeErrorStartTimes.keys.toSet();
    final candidateDevices =
        devices.where((d) => d.status.online && !currentErrors.contains(d.id)).toList();
    if (candidateDevices.isEmpty) return;

    final errorDevice = candidateDevices[_random.nextInt(candidateDevices.length)];
    final deviceIndex = devices.indexWhere((d) => d.id == errorDevice.id);
    if (deviceIndex == -1) return;

    final updatedDevices = List<Device>.from(devices);
    updatedDevices[deviceIndex] = errorDevice.copyWith(
      status: Status(
        online: false,
        latency: errorDevice.status.latency,
        lastChecked: DateTime.now(),
      ),
    );

    final updatedStartTimes = Map<String, DateTime>.from(state.activeErrorStartTimes);
    updatedStartTimes[errorDevice.id] = DateTime.now();

    state = state.copyWith(
      devices: updatedDevices,
      activeErrorStartTimes: updatedStartTimes,
      lastErrorTime: DateTime.now(),
    );

    _soundService.playErrorSound();
    debugPrint('❌ Error generated on ${errorDevice.id}');
  }

  // ===============================
  // 🛠️ Fix Device
  // ===============================
  Future<(bool success, int points)> fixDeviceWithLatency(String deviceId, double latency) async {
    if (!state.isRunning || !state.activeErrorStartTimes.containsKey(deviceId)) {
      return (false, 0);
    }

    if (latency < 80 || latency > 100) {
      return (false, 0);
    }

    final start = state.activeErrorStartTimes[deviceId] ?? DateTime.now();
    final durationSeconds = DateTime.now().difference(start).inSeconds;

    final basePoints = (100 - (durationSeconds * 10)).clamp(10, 100);
    final bonus = 100 - (latency - 90).abs();
    final totalPoints = (basePoints + (bonus / 10)).clamp(10, 150).toInt();

    final updatedDevices = List<Device>.from(state.devices);
    final deviceIndex = updatedDevices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex == -1) return (false, 0);

    updatedDevices[deviceIndex] = updatedDevices[deviceIndex].copyWith(
      status: Status(
        online: true,
        latency: latency.toInt(),
        lastChecked: DateTime.now(),
      ),
    );

    final updatedStartTimes = Map<String, DateTime>.from(state.activeErrorStartTimes);
    updatedStartTimes.remove(deviceId);

    state = state.copyWith(
      devices: updatedDevices,
      score: state.score + totalPoints,
      activeErrorStartTimes: updatedStartTimes,
    );

    _soundService.playSuccessSound();
    debugPrint('✅ Fixed $deviceId | +$totalPoints points | Total: ${state.score}');
    return (true, totalPoints);
  }

  // ===============================
  // 🏁 End Simulation
  // ===============================
  void endSimulation() {
    _gameTimer?.cancel();
    _errorTimer?.cancel();
    _gameTimer = null;
    _errorTimer = null;

    state = state.copyWith(isRunning: false, isFinished: true);
    debugPrint('🏁 Simulation Ended | Final Score: ${state.score}');
  }

  // ===============================
  // ⏸️ Pause / ▶️ Resume / 🔁 Pulse
  // ===============================
  void pauseSimulation() {
    if (!state.isRunning || state.isFinished) return;

    _gameTimer?.cancel();
    _errorTimer?.cancel();
    _gameTimer = null;
    _errorTimer = null;

    state = state.copyWith(isRunning: false);
    debugPrint('⏸️ Simulation paused');
  }

  void resumeSimulation() {
    if (state.isFinished || state.isRunning) return;

    _startTimers();
    state = state.copyWith(isRunning: true);
    debugPrint('▶️ Simulation resumed');
  }

  void pulse() {
    if (state.isFinished) return;

    if (state.remainingTime > 0) {
      state = state.copyWith(remainingTime: state.remainingTime - 1);
      debugPrint('⏱️ Pulse tick: ${state.remainingTime}s left');
    } else {
      endSimulation();
      return;
    }

    _maybeGenerateRandomError();

    if (!state.isRunning) {
      resumeSimulation();
    }
  }

  void _maybeGenerateRandomError() {
    if (state.lastErrorTime != null &&
        DateTime.now().difference(state.lastErrorTime!).inSeconds < 15) {
      return;
    }

    final devices = state.devices;
    if (devices.isEmpty) return;

    final currentErrors = state.activeErrorStartTimes.keys.toSet();
    final candidateDevices =
        devices.where((d) => d.status.online && !currentErrors.contains(d.id)).toList();
    if (candidateDevices.isEmpty) return;

    final errorDevice = candidateDevices[_random.nextInt(candidateDevices.length)];
    final deviceIndex = devices.indexWhere((d) => d.id == errorDevice.id);
    if (deviceIndex == -1) return;

    final updatedDevices = List<Device>.from(devices);
    updatedDevices[deviceIndex] = errorDevice.copyWith(
      status: Status(
        online: false,
        latency: errorDevice.status.latency,
        lastChecked: DateTime.now(),
      ),
    );

    final updatedStartTimes = Map<String, DateTime>.from(state.activeErrorStartTimes);
    updatedStartTimes[errorDevice.id] = DateTime.now();

    state = state.copyWith(
      devices: updatedDevices,
      activeErrorStartTimes: updatedStartTimes,
      lastErrorTime: DateTime.now(),
    );

    _soundService.playErrorSound();
    debugPrint('⚡ Error generated on ${errorDevice.id} (pulse)');
  }

  // ===============================
  // 🔄 Reset Simulation
  // ===============================
void resetSimulation() {
  _gameTimer?.cancel();
  _errorTimer?.cancel();
  _gameTimer = null;
  _errorTimer = null;

  if (state.currentScenario != null) {
    final scenario = state.currentScenario!;
    state = const SimulationState(); // clear current
    debugPrint('🔄 Simulation reset — restarting scenario "${scenario.name}"');
    startSimulation(scenario); // restart fresh
  } else {
    state = const SimulationState();
    debugPrint('🔄 Simulation reset — no scenario loaded');
  }
}

}
