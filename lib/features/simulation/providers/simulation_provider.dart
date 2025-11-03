// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/simulation_state.dart';

// final simulationProvider =
//     NotifierProvider<SimulationNotifier, SimulationState>(SimulationNotifier.new);

// class SimulationNotifier extends Notifier<SimulationState> {
//   Timer? _errorTimer;

//   @override
//   SimulationState build() {
//     ref.onDispose(() {
//       _errorTimer?.cancel();
//     });
//     return SimulationState.initial();
//   }

//   void startSimulation() {
//     state = state.copyWith(isRunning: true);
//     _startErrorGeneration();
//   }

//   void stopSimulation() {
//     state = state.copyWith(isRunning: false);
//     _errorTimer?.cancel();
//   }

//   void _startErrorGeneration() {
//     _errorTimer?.cancel();
//     _errorTimer = Timer.periodic(const Duration(seconds: 30), (_) {
//       _generateRandomError();
//     });
//   }

//   void _generateRandomError() {
//     if (!state.isRunning) return;

//     // TODO: Implement random error generation logic
//     // This is where you'll randomly select a device and set its error state
//   }

//   void setDeviceError(String deviceId, bool hasError) {
//     final now = DateTime.now();
//     final updatedErrors = Map<String, bool>.from(state.deviceErrors);
//     final updatedTimes = Map<String, DateTime>.from(state.lastErrorTimes);

//     if (hasError) {
//       updatedErrors[deviceId] = true;
//       updatedTimes[deviceId] = now;
//     } else {
//       updatedErrors.remove(deviceId);
//       updatedTimes.remove(deviceId);
//     }

//     state = state.copyWith(
//       deviceErrors: updatedErrors,
//       lastErrorTimes: updatedTimes,
//     );
//   }

//   bool hasDeviceError(String deviceId) {
//     return state.deviceErrors[deviceId] ?? false;
//   }

//   DateTime? getLastErrorTime(String deviceId) {
//     return state.lastErrorTimes[deviceId];
//   }

//   void clearAllErrors() {
//     state = state.copyWith(
//       deviceErrors: {},
//       lastErrorTimes: {},
//     );
//   }
// }