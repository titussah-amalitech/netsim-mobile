import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:netsim_mobile/features/devices/data/models/device_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_status.dart';
import 'package:netsim_mobile/features/scenarios/data/models/scenario_model.dart';
import 'package:netsim_mobile/features/simulation/data/models/simulation_state.dart';
import 'package:netsim_mobile/features/simulation/data/models/device_error.dart';
import 'package:netsim_mobile/features/simulation/services/sound_service.dart';
import 'package:netsim_mobile/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:netsim_mobile/features/logs/logic/logs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the sound service
final soundServiceProvider = Provider<SoundService>((ref) => SoundService());

/// Main simulation provider that manages simulation logic and state
final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationState>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  final leaderboardController = ref.watch(leaderboardControllerProvider);
  final logsNotifier = ref.watch(latestLogsProvider.notifier);
  return SimulationNotifier(soundService, leaderboardController, logsNotifier);
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
  
  SimulationNotifier(
    this._soundService, 
    this._leaderboardController, 
    this._logsNotifier,
  ) : super(const SimulationState()) {
    // Start background music when the notifier is created
    // _soundService.startBackgroundMusic();
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

  /// Validates if the fix attempt is correct for the given error type
  bool _validateFix(DeviceError error, Map<String, dynamic> fixData) {
    switch (error.type) {
      case DeviceErrorType.highLatency:
        final newLatency = fixData['newLatency'] as int;
        return newLatency < (error.metadata['latencyValue'] as int);

      case DeviceErrorType.packetLoss:
        final steps = fixData['completedSteps'] as List<dynamic>;
        return steps.length == 3;

      case DeviceErrorType.overload:
        final newLoad = fixData['newLoad'] as int;
        return newLoad < 70;

      case DeviceErrorType.pingTimeout:
        final pingCount = fixData['pingCount'] as int;
        return pingCount >= 3;

      case DeviceErrorType.offline:
        // All four parameters must be present and within valid ranges
        final ping = fixData['pingInterval'] as int?;
        final latency = fixData['latencyThreshold'] as int?;
        final overload = fixData['overload'] as int?;
        
        if (ping == null || latency == null || overload == null) {
          return false;
        }
        
        final bool pingOK = ping >= 40 && ping <= 80;
        final bool latencyOK = latency >= 60 && latency <= 120;
        final bool overloadOK = overload >= 10 && overload <= 60;
       
        
        return pingOK && latencyOK && overloadOK;

      case DeviceErrorType.routingError:
        final selectedRoute = fixData['selectedRoute'] as String;
        return selectedRoute == error.metadata['correctRoute'];
    }
  }

  /// Generates appropriate metadata for each error type
  Map<String, dynamic> _generateErrorMetadata(DeviceErrorType type, Device device) {
    switch (type) {
      case DeviceErrorType.highLatency:
        return {'latencyValue': 120 + _random.nextInt(50)}; // 120-170ms
      
      case DeviceErrorType.packetLoss:
        return {'lossRate': 15 + _random.nextInt(25)}; // 15-40%
      
      case DeviceErrorType.overload:
        return {'currentLoad': 85 + _random.nextInt(15)}; // 85-100%
      
      case DeviceErrorType.pingTimeout:
        return {'timeoutCount': 3 + _random.nextInt(3)}; // 3-6 timeouts
      
      case DeviceErrorType.offline:
        // Provide all four parameters for offline error
        return {
          'pingInterval': device.parameters.pingInterval,
          'latencyThreshold': device.parameters.latencyThreshold,
          'overload': device.parameters.trafficLoad, // Using trafficLoad as overload
          
        };
      
      case DeviceErrorType.routingError:
        final otherDevices = state.devices
            .where((d) => d.id != device.id)
            .map((d) => d.id)
            .toList();
        return {
          'correctRoute': otherDevices.isEmpty 
              ? 'Device_1' 
              : otherDevices[_random.nextInt(otherDevices.length)]
        };
    }
  }

  // ===============================
  //  Start Simulation
  // ===============================
  void startSimulation(Scenario scenario) {
    if (state.isRunning) return;

    final deviceCount = scenario.devices.length;
    if (deviceCount == 0) return;

    debugPrint('Starting simulation with $deviceCount devices');

    // Use the saved device positions but initialize with online status
    final positionedDevices = scenario.devices.map((device) => 
      device.copyWith(
        status: Status(
          online: true,
          latency: 0,
          lastChecked: DateTime.now(),
        ),
      )
    ).toList();

    // Set initial state
    state = SimulationState(
      currentScenario: scenario,
      devices: positionedDevices,
  connections: scenario.connections,
      remainingTime: scenario.timeLimit,
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

    // Check for any active errors that have exceeded the grace period and auto-recover them
    _autoRecoverExpiredErrors();
  }

  // ===============================
  //  Random Error Generator
  // ===============================
  Future<void> _generateRandomError() async {
    if (!state.isRunning) return;

    if (state.lastErrorTime != null &&
        DateTime.now().difference(state.lastErrorTime!).inSeconds < 10) {
      return;
    }

    final devices = state.devices;
    if (devices.isEmpty) return;

    final currentErrors = state.activeErrors.keys.toSet();
    final candidateDevices =
        devices.where((d) => d.status.online && !currentErrors.contains(d.id)).toList();
    if (candidateDevices.isEmpty) return;

    final errorDevice = candidateDevices[_random.nextInt(candidateDevices.length)];
    final deviceIndex = devices.indexWhere((d) => d.id == errorDevice.id);
    if (deviceIndex == -1) return;

    // Generate a random error type
    final errorType = DeviceErrorType.values[_random.nextInt(DeviceErrorType.values.length)];
    
    // Create error with appropriate metadata
    final error = DeviceError(
      deviceId: errorDevice.id,
      type: errorType,
      startTime: DateTime.now(),
      metadata: _generateErrorMetadata(errorType, errorDevice),
    );

    final updatedDevices = List<Device>.from(devices);
    // Only mark device offline when the error type is offline. Other errors
    // should be treated as warnings (device remains online but flagged).
    updatedDevices[deviceIndex] = errorDevice.copyWith(
      status: Status(
        online: errorType == DeviceErrorType.offline ? false : true,
        latency: errorDevice.status.latency,
        lastChecked: DateTime.now(),
      ),
    );

    final updatedErrors = Map<String, DeviceError>.from(state.activeErrors);
    updatedErrors[errorDevice.id] = error;

    state = state.copyWith(
      devices: updatedDevices,
      activeErrors: updatedErrors,
      lastErrorTime: DateTime.now(),
      recentErrors: [...state.recentErrors, errorDevice.id],
    );

    // Log the error event. Use different messages/status for warnings vs offline
    final player = await _fetchPlayerName();
    final logMessage = errorType == DeviceErrorType.offline
        ? "Device ${errorDevice.id} is offline"
        : "Warning: ${errorType.displayName}";
    final logStatus = errorType == DeviceErrorType.offline ? 'offline' : 'warning';

    _logsNotifier.addGameplayLog(
      device: errorDevice.id,
      deviceType: errorDevice.type,
      eventType: errorType == DeviceErrorType.offline ? "ERROR" : "WARNING",
      message: logMessage,
      status: logStatus,
      playerName: player,
    );

    _soundService.playErrorSound();
    debugPrint('Error generated on ${errorDevice.id}');
  }

  // ===============================
  //  Fix Device
  // ===============================
  Future<(bool success, int points)> fixDevice(String deviceId, Map<String, dynamic> fixData) async {
    if (!state.isRunning || !state.activeErrors.containsKey(deviceId)) {
      return (false, 0);
    }

    final error = state.activeErrors[deviceId]!;
    final durationSeconds = DateTime.now().difference(error.startTime).inSeconds;

    // Validate the fix first
    final success = _validateFix(error, fixData);
    if (!success) {
      return (false, 0);
    }

    int basePoints = 0;
    String fixMessage = '';

    switch (error.type) {
      case DeviceErrorType.highLatency:
        final newLatency = fixData['newLatency'] as int;
        basePoints = (100 - (durationSeconds * 10)).clamp(10, 100);
        fixMessage = "Latency reduced to ${newLatency}ms";
        break;

      case DeviceErrorType.packetLoss:
        final steps = fixData['completedSteps'] as List<String>;
        basePoints = (120 - (durationSeconds * 8)).clamp(20, 120);
        fixMessage = "Packet loss resolved (Steps: ${steps.join(', ')})";
        break;

      case DeviceErrorType.overload:
        final newLoad = fixData['newLoad'] as int;
        basePoints = (110 - (durationSeconds * 9)).clamp(15, 110);
        fixMessage = "Traffic load reduced to $newLoad%";
        break;

      case DeviceErrorType.pingTimeout:
        final pingCount = fixData['pingCount'] as int;
        basePoints = (130 - (durationSeconds * 7)).clamp(25, 130);
        fixMessage = "Connection restored after $pingCount pings";
        break;

      case DeviceErrorType.offline:
        final ping = fixData['pingInterval'] as int;
        final latency = fixData['latencyThreshold'] as int;
        final overload = fixData['overload'] as int;
       

        basePoints = (150 - (durationSeconds * 6)).clamp(50, 150);
        fixMessage = "Device restored: ping=$ping, latency=$latency, overload=$overload";
        break;

      case DeviceErrorType.routingError:
        final selectedRoute = fixData['selectedRoute'] as String;
        basePoints = (140 - (durationSeconds * 5)).clamp(40, 140);
        fixMessage = "Routing corrected to $selectedRoute";
        break;
    }

    final updatedDevices = List<Device>.from(state.devices);
    final deviceIndex = updatedDevices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex == -1) return (false, 0);

    updatedDevices[deviceIndex] = updatedDevices[deviceIndex].copyWith(
      status: Status(
        online: true,
        latency: 0,
        lastChecked: DateTime.now(),
      ),
    );

    final updatedErrors = Map<String, DeviceError>.from(state.activeErrors);
    updatedErrors.remove(deviceId);

    // Remove from recent errors if present
    final updatedRecentErrors = List<String>.from(state.recentErrors)..remove(deviceId);

    state = state.copyWith(
      devices: updatedDevices,
      score: state.score + basePoints,
      activeErrors: updatedErrors,
      recentErrors: updatedRecentErrors,
    );

    // Log the recovery event
    final player = await _fetchPlayerName();
    _logsNotifier.addGameplayLog(
      device: deviceId,
      deviceType: updatedDevices[deviceIndex].type,
      eventType: "RECOVERY",
      message: "Device restored manually ($fixMessage, Points: +$basePoints)",
      status: "online",
      playerName: player,
    );

    _soundService.playSuccessSound();
    debugPrint('Fixed $deviceId | +$basePoints points | Total: ${state.score}');
    return (true, basePoints);
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

      // Get devices that need auto-recovery
      final expiredDevices = state.activeErrors.entries
          .where((entry) => DateTime.now().difference(entry.value.startTime).inSeconds > _errorGracePeriodSeconds)
          .map((entry) => entry.key)
          .toList();

      var finalScore = state.score;
      
      if (expiredDevices.isNotEmpty) {
        // Apply penalty for each expired device
        finalScore = max(0, state.score - (expiredDevices.length * _autoRecoveryPenalty));
      }

      // Update state first
      state = state.copyWith(
        isRunning: false, 
        isFinished: true,
        score: finalScore,
        recentAutoRecoveredDevices: expiredDevices,
      );

      // _soundService.stopBackgroundMusic();

      // Log auto-recoveries
      if (expiredDevices.isNotEmpty) {
        final player = await _fetchPlayerName();
        for (final deviceId in expiredDevices) {
          final device = state.devices.firstWhere((d) => d.id == deviceId);
          _logsNotifier.addGameplayLog(
            device: deviceId,
            deviceType: device.type,
            eventType: "AUTO_RECOVERY",
            message: "Device auto-recovered (Penalty: -$_autoRecoveryPenalty)",
            status: "warning",
            playerName: player,
          );
        }
      }

      _soundService.playGameOverSound();

      // Update leaderboard with the final score
      final prefs = await SharedPreferences.getInstance();
      final playerName = prefs.getString('userName');
      
      if (playerName == null || playerName.isEmpty) {
        debugPrint('Warning: userName not found in SharedPreferences');
        return;
      }

      debugPrint('Updating leaderboard: Player=$playerName, Score=$finalScore');
      await _leaderboardController.updateLeaderboard(playerName, finalScore);
      debugPrint('Leaderboard updated successfully');
    } catch (e, stackTrace) {
      debugPrint('Error updating leaderboard: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      debugPrint('Simulation Ended | Final Score: ${state.score}');
    }
  }

  // ===============================
  //  Pause / Resume / Reset
  // ===============================
  void pauseSimulation() {
    if (!state.isRunning || state.isFinished) return;

    _gameTimer?.cancel();
    _errorTimer?.cancel();
    _gameTimer = null;
    _errorTimer = null;

    state = state.copyWith(isRunning: false);
    debugPrint('Simulation paused');
  }

  void resumeSimulation() {
    if (state.isFinished || state.isRunning) return;

    _startTimers();
    state = state.copyWith(isRunning: true);
    debugPrint('Simulation resumed');
  }

  void pulse() {
    if (state.isFinished) return;

    if (state.remainingTime > 0) {
      state = state.copyWith(remainingTime: state.remainingTime - 1);
      debugPrint('Pulse tick: ${state.remainingTime}s left');
    } else {
      endSimulation();
      return;
    }

    // Use the existing error generation logic instead of duplicating it
    _generateRandomError();

    if (!state.isRunning) {
      resumeSimulation();
    }
  }

  // Auto-recover any active errors that exceeded the grace period.
  Future<void> _autoRecoverExpiredErrors() async {
    if (state.activeErrors.isEmpty) return;

    final now = DateTime.now();
    final expired = <String>[];

    state.activeErrors.forEach((deviceId, error) {
      final elapsed = now.difference(error.startTime).inSeconds;
      if (elapsed >= _errorGracePeriodSeconds) expired.add(deviceId);
    });

    if (expired.isEmpty) return;

    final updatedDevices = List<Device>.from(state.devices);
    final updatedErrors = Map<String, DeviceError>.from(state.activeErrors);
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
      updatedErrors.remove(deviceId);

      // Apply penalty
      scoreDelta -= _autoRecoveryPenalty;

      _soundService.playErrorSound();
      debugPrint('Auto-recovered $deviceId after grace period; penalty $_autoRecoveryPenalty');
    }

    // Remove from recent errors
    final updatedRecentErrors = List<String>.from(state.recentErrors)
      ..removeWhere((id) => expired.contains(id));

    // Update state with recovered devices and deducted score (clamp at 0)
    final newScore = (state.score + scoreDelta).clamp(0, double.infinity).toInt();
    state = state.copyWith(
      devices: updatedDevices,
      activeErrors: updatedErrors,
      score: newScore,
      recentAutoRecoveredDevices: [...state.recentAutoRecoveredDevices, ...expired],
      recentErrors: updatedRecentErrors,
    );

    // Log auto-recovery events
    final player = await _fetchPlayerName();
    for (final deviceId in expired) {
      final deviceIndex = updatedDevices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex != -1) {
        _logsNotifier.addGameplayLog(
          device: deviceId,
          deviceType: updatedDevices[deviceIndex].type,
          eventType: "AUTO_RECOVERY",
          message: "Device auto-recovered (Penalty: -$_autoRecoveryPenalty)",
          status: "warning",
          playerName: player,
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
  // Reset Simulation
  // ===============================
  void resetSimulation({bool restart = false}) {
    _gameTimer?.cancel();
    _errorTimer?.cancel();
    _gameTimer = null;
    _errorTimer = null;
  

    // _soundService.stopBackgroundMusic();

    // When restarting, start fresh from the same scenario
    if (restart && state.currentScenario != null) {
      final scenario = state.currentScenario!;
      state = const SimulationState(); // clear first
      debugPrint('Simulation reset — restarting scenario "${scenario.name}"');
      startSimulation(scenario);
    } else {
      // Fully clear simulation (used when exiting the game)
      state = const SimulationState();
      debugPrint('Simulation completely stopped and cleared');
    }
  }

  @override
  void dispose() {
    // Ensure timers and music are stopped when provider is disposed
    _gameTimer?.cancel();
    _errorTimer?.cancel();
    // _soundService.stopBackgroundMusic();
    _gameTimer = null;
    _errorTimer = null;
    debugPrint('SimulationNotifier disposed — timers and sounds cleared');
    super.dispose();
  }
}