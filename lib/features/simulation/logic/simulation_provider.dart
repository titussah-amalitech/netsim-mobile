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

/// The main simulation provider that manages game state
final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationState>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return SimulationNotifier(soundService);
});

/// Simulation logic controller using Riverpod's StateNotifier.
/// Handles device state, time, random errors, scoring, and leaderboard saving.
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

    const radius = 120; // placement radius
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

    // Set remaining time to 5 minutes (300s) for the gameplay session
    state = SimulationState(
      currentScenario: scenario,
      devices: positionedDevices,
      remainingTime: 5 * 60, // 5 minutes
      isRunning: true,
    );

    // Debug: print device positions
    for (var d in positionedDevices) {
      debugPrint('Device ${d.id} positioned at (${d.position.x}, ${d.position.y})');
    }

    // Start the game timer (counts down every second)
    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimer(),
    );

    // Generate random device errors every 10 seconds
    _errorTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _generateRandomError(),
    );
  }

  // ===============================
  // Update Timer
  // ===============================
  void _updateTimer() {
    if (!state.isRunning) return;

    if (state.remainingTime <= 0) {
      endSimulation();
      return;
    }

    state = state.copyWith(remainingTime: state.remainingTime - 1);
  }

  // ===============================
  // Generate Random Error
  // ===============================
  void _generateRandomError() {
    if (!state.isRunning) return;

    // Don't generate error if the last one was too recent
    if (state.lastErrorTime != null &&
        DateTime.now().difference(state.lastErrorTime!).inSeconds < 15) {
      return;
    }

    final devices = state.devices;
    if (devices.isEmpty) return;

    // Exclude devices already in error
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
    debugPrint('Error generated on ${errorDevice.id}');
  }

  // ===============================
  // Fix Device with Latency
  // ===============================
  Future<(bool success, int points)> fixDeviceWithLatency(String deviceId, double latency) async {
      if (!state.isRunning || !state.activeErrorStartTimes.containsKey(deviceId)) {
        return (false, 0);
      }

      // Check if latency is in valid range (80-100)
      if (latency < 80 || latency > 100) {
        return (false, 0);
      }

      final start = state.activeErrorStartTimes[deviceId] ?? DateTime.now();
      final durationSeconds = DateTime.now().difference(start).inSeconds;
      
      // Calculate score components
      final basePoints = (100 - (durationSeconds * 10)).clamp(10, 100);
      final bonus = 100 - (latency - 90).abs();
      final totalPoints = (basePoints + (bonus / 10)).clamp(10, 150).toInt();

      // Copy devices list
      final updatedDevices = List<Device>.from(state.devices);
      final deviceIndex = updatedDevices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) return (false, 0);

      // Update device status to online with new latency
      updatedDevices[deviceIndex] = updatedDevices[deviceIndex].copyWith(
        status: Status(
          online: true,
          latency: latency.toInt(),
          lastChecked: DateTime.now(),
        ),
      );

      // Remove this device from active errors
      final updatedStartTimes = Map<String, DateTime>.from(state.activeErrorStartTimes);
      updatedStartTimes.remove(deviceId);

      // Apply device + score updates and the updated errors map
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
  // End Simulation
  // ===============================
  void endSimulation() {
    _gameTimer?.cancel();
    _errorTimer?.cancel();

    state = state.copyWith(
      isRunning: false,
      isFinished: true,
    );

    debugPrint('Simulation Ended. Final Score: ${state.score}');
  }

  // ===============================
  // Reset Simulation
  // ===============================
  void resetSimulation() {
    _gameTimer?.cancel();
    _errorTimer?.cancel();
    state = const SimulationState();
  }
}