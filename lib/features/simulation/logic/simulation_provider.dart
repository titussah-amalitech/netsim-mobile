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
import 'package:netsim_mobile/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:netsim_mobile/features/logs/logic/logs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences.dart';

/// Provider for the sound service
final soundServiceProvider = Provider<SoundService>((ref) => SoundService());

/// Main simulation provider that manages simulation logic and state
final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationState>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  final leaderboardController = ref.watch(leaderboardControllerProvider);
  final latestLogs = ref.watch(latestLogsProvider.notifier);
  return SimulationNotifier(soundService, leaderboardController, latestLogs);
});

/// Simulation logic controller using Riverpod's StateNotifier.
class SimulationNotifier extends StateNotifier<SimulationState> {
  Timer? _gameTimer;
  Timer? _errorTimer;
  final Random _random = Random();
  final SoundService _soundService;
  final LeaderboardController _leaderboardController;
  final LatestLogsNotifier _logsNotifier;
  // Grace period for player to manually fix an error (in seconds)
  static const int _errorGracePeriodSeconds = 30;
  // Penalty points when a device auto-recovers after grace period
  static const int _autoRecoveryPenalty = 30;

  String? _cachedPlayerName;
  
  SimulationNotifier(this._soundService, this._leaderboardController, this._logsNotifier) : super(const SimulationState()) {
    // Start background music when the notifier is created
    _soundService.startBackgroundMusic();
    // Cache the player name on initialization
    _initializePlayerName();
  }

  Future<void> _initializePlayerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedPlayerName = prefs.getString('userName');
      if (_cachedPlayerName == null || _cachedPlayerName!.isEmpty) {
        debugPrint('Warning: No userName found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error initializing player name: $e');
    }
  }

  /// Helper to retrieve the currently active player name from SharedPreferences.
  /// Falls back to the cached name or 'Unknown Player' if not available.
  Future<String> _fetchPlayerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('userName');
      if (name != null && name.isNotEmpty) return name;
    } catch (_) {
      // ignore and fallback
    }
    return _cachedPlayerName ?? 'Unknown Player';
  }

  String get _playerName => _cachedPlayerName ?? 'Unknown Player';

 

  // ===============================
  //  Start Simulation
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
      remainingTime: 1 * 60,
      isRunning: true,
    );

    // Start timers
    _startTimers();

    for (var d in positionedDevices) {
      debugPrint('Device ${d.id} positioned at (${d.position.x}, ${d.position.y})');
    }
  }

  // ===============================
  //  Timer Helpers
  // ===============================
  void _startTimers() {
    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimer(),
    );

    _errorTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        await _generateRandomError();
      },
    );
  }

  void _updateTimer() {
    if (!state.isRunning) return;

    if (state.remainingTime <= 0) {
      endSimulation();
      return;
    }

    state = state.copyWith(remainingTime: state.remainingTime - 1);

    // Check for any active errors that have exceeded the grace period and auto-recover them
    _autoRecoverExpiredErrors();
  }

  // ===============================
  //  Random Error Generator
  // ===============================
  Future<void> _generateRandomError() async {
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
      recentErrors: [errorDevice.id],
    );

    // Log the error event (ensure we use the current persisted player name)
    final _player = await _fetchPlayerName();
    _logsNotifier.addGameplayLog(
      device: errorDevice.id,
      deviceType: errorDevice.type,
      eventType: "ERROR",
      message: "Device went offline during simulation",
      status: "offline",
      playerName: _player,
    );

    _soundService.playErrorSound();
    debugPrint(' Error generated on ${errorDevice.id}');
  }

  // ===============================
  //  Fix Device
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

    // Log the recovery event (use persisted player name to associate logs correctly)
    final _player = await _fetchPlayerName();
    _logsNotifier.addGameplayLog(
      device: deviceId,
      deviceType: updatedDevices[deviceIndex].type,
      eventType: "RECOVERY",
      message: "Device restored manually (Latency: ${latency}ms, Points: +$totalPoints)",
      status: "online",
      playerName: _player,
    );

    _soundService.playSuccessSound();
    debugPrint('Fixed $deviceId | +$totalPoints points | Total: ${state.score}');
    return (true, totalPoints);
  }

  // ===============================
  //  End Simulation
  // ===============================
  Future<void> endSimulation() async {
    try {
      _gameTimer?.cancel();
      _errorTimer?.cancel();
      _gameTimer = null;
      _errorTimer = null;

      state = state.copyWith(isRunning: false, isFinished: true);
      _soundService.stopBackgroundMusic();
      // Get devices that need auto-recovery
      final expiredDevices = state.activeErrorStartTimes.entries
          .where((entry) => DateTime.now().difference(entry.value).inSeconds > _errorGracePeriodSeconds)
          .map((entry) => entry.key)
          .toList();

      if (expiredDevices.isNotEmpty) {
        // Apply penalty for each expired device
        final penaltyScore = max(0, state.score - (expiredDevices.length * _autoRecoveryPenalty));

        state = state.copyWith(
          score: penaltyScore,
          recentAutoRecoveredDevices: expiredDevices,
        );

        // Log auto-recoveries
        final _player = await _fetchPlayerName();
        for (final deviceId in expiredDevices) {
          final device = state.devices.firstWhere((d) => d.id == deviceId);
          _logsNotifier.addGameplayLog(
            device: deviceId,
            deviceType: device.type,
            eventType: "AUTO_RECOVERY",
            message: "Device auto-recovered (Penalty: -$_autoRecoveryPenalty)",
            status: "warning",
            playerName: _player,
          );
        }
    }

    _soundService.playGameOverSound();

      // Update leaderboard with the final score
      final prefs = await SharedPreferences.getInstance();
      final playerName = prefs.getString('userName');
      
      if (playerName == null || playerName.isEmpty) {
        debugPrint(' Warning: userName not found in SharedPreferences');
        return;
      }

      debugPrint('Updating leaderboard: Player=$playerName, Score=${state.score}');
      await _leaderboardController.updateLeaderboard(playerName, state.score);
      debugPrint(' Leaderboard updated successfully');
    } catch (e, stackTrace) {
      debugPrint(' Error updating leaderboard: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      debugPrint('Simulation Ended | Final Score: ${state.score}');
    }
  }

  // ===============================
  //  Pause /  Resume / Reset
  // ===============================
  void pauseSimulation() {
    if (!state.isRunning || state.isFinished) return;

    _gameTimer?.cancel();
    _errorTimer?.cancel();
    _gameTimer = null;
    _errorTimer = null;

    state = state.copyWith(isRunning: false);
    debugPrint(' Simulation paused');
  }

  void resumeSimulation() {
    if (state.isFinished || state.isRunning) return;

    _startTimers();
    state = state.copyWith(isRunning: true);
    debugPrint(' Simulation resumed');
  }

  void pulse() {
    if (state.isFinished) return;

    if (state.remainingTime > 0) {
      state = state.copyWith(remainingTime: state.remainingTime - 1);
      debugPrint(' Pulse tick: ${state.remainingTime}s left');
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

  // Auto-recover any active errors that exceeded the grace period.
  Future<void> _autoRecoverExpiredErrors() async {
    if (state.activeErrorStartTimes.isEmpty) return;

    final now = DateTime.now();
    final expired = <String>[];

    state.activeErrorStartTimes.forEach((deviceId, startTime) {
      final elapsed = now.difference(startTime).inSeconds;
      if (elapsed >= _errorGracePeriodSeconds) expired.add(deviceId);
    });

    if (expired.isEmpty) return;

    final updatedDevices = List<Device>.from(state.devices);
    final updatedStartTimes = Map<String, DateTime>.from(state.activeErrorStartTimes);
    var scoreDelta = 0;

    for (final deviceId in expired) {
      final idx = updatedDevices.indexWhere((d) => d.id == deviceId);
      if (idx == -1) continue;

      final device = updatedDevices[idx];

      // Auto-recover: set device online, keep previous latency
      updatedDevices[idx] = device.copyWith(
        status: Status(
          online: true,
          latency: device.status.latency,
          lastChecked: DateTime.now(),
        ),
      );

      // Remove from active errors
      updatedStartTimes.remove(deviceId);

      // Apply penalty
      scoreDelta -= _autoRecoveryPenalty;

      _soundService.playErrorSound();
      debugPrint('Auto-recovered $deviceId after grace period; penalty ${_autoRecoveryPenalty}');
    }

    // Update state with recovered devices and deducted score (clamp at 0)
    final newScore = (state.score + scoreDelta).clamp(0, double.infinity).toInt();
    state = state.copyWith(
      devices: updatedDevices,
      activeErrorStartTimes: updatedStartTimes,
      score: newScore,
      recentAutoRecoveredDevices: expired,
    );

    // Log auto-recovery events
    for (final deviceId in expired) {
      final deviceIndex = updatedDevices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex != -1) {
     _logsNotifier.addGameplayLog(
  device: deviceId,
  deviceType: updatedDevices[deviceIndex].type,
  eventType: "ERROR",
  message: "Device went offline during simulation",
  status: "offline",
  playerName: _playerName,
);
      }
    }
  }

  /// Clear the auto-recovered notification list after UI consumes it
  void clearAutoRecoveredNotifications() {
    if (state.recentAutoRecoveredDevices.isEmpty) return;
    state = state.copyWith(recentAutoRecoveredDevices: []);
  }

  void clearErrorNotifications() {
    if (state.recentErrors.isEmpty) return;
    state = state.copyWith(recentErrors: []);
  }

  // ===============================
  // 🔄 Reset Simulation
  // ===============================

  void resetSimulation({bool restart = false}) {
    _gameTimer?.cancel();
    _errorTimer?.cancel();
    _gameTimer = null;
    _errorTimer = null;

    _soundService.stopBackgroundMusic();

    // When restarting, start fresh from the same scenario
    if (restart && state.currentScenario != null) {
      final scenario = state.currentScenario!;
      state = const SimulationState(); // clear first
      debugPrint('🔄 Simulation reset — restarting scenario "${scenario.name}"');
      startSimulation(scenario);
    } else {
      // Fully clear simulation (used when exiting the game)
      state = const SimulationState();
      debugPrint('🧹 Simulation completely stopped and cleared');
    }
  }

  @override
  void dispose() {
    // Ensure timers and music are stopped when provider is disposed
    _gameTimer?.cancel();
    _errorTimer?.cancel();
    _soundService.stopBackgroundMusic();
    _gameTimer = null;
    _errorTimer = null;
    debugPrint('🛑 SimulationNotifier disposed — timers and sounds cleared');
    super.dispose();
  }

}
