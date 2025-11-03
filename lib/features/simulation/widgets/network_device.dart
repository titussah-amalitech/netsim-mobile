// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/simulation_provider.dart';

// class NetworkDevice extends ConsumerWidget {
//   final String deviceId;
//   final bool isOnline;

//   const NetworkDevice({
//     super.key,
//     required this.deviceId,
//     required this.isOnline,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final hasError = ref.watch(simulationProvider
//         .select((state) => state.deviceErrors[deviceId] ?? false));

//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: _getBorderColor(isOnline, hasError),
//           width: 2,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: Text(deviceId),
//       ),
//     );
//   }

//   Color _getBorderColor(bool isOnline, bool hasError) {
//     if (hasError) return Colors.red;
//     if (isOnline) return Colors.green;
//     return Colors.grey;
//   }
// }