// import 'package:flutter/foundation.dart';

// @immutable
// class SimulationState {
//   final Map<String, bool> deviceErrors;
//   final Map<String, DateTime> lastErrorTimes;
//   final bool isRunning;

//   const SimulationState({
//     required this.deviceErrors,
//     required this.lastErrorTimes,
//     required this.isRunning,
//   });

//   SimulationState copyWith({
//     Map<String, bool>? deviceErrors,
//     Map<String, DateTime>? lastErrorTimes,
//     bool? isRunning,
//   }) {
//     return SimulationState(
//       deviceErrors: deviceErrors ?? this.deviceErrors,
//       lastErrorTimes: lastErrorTimes ?? this.lastErrorTimes,
//       isRunning: isRunning ?? this.isRunning,
//     );
//   }

//   factory SimulationState.initial() {
//     return const SimulationState(
//       deviceErrors: {},
//       lastErrorTimes: {},
//       isRunning: false,
//     );
//   }
// }