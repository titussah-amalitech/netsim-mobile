import 'dart:math';
import 'package:netsim_mobile/features/devices/data/models/device_model.dart';
import 'package:netsim_mobile/features/simulation/data/models/device_error.dart';

/// Helper class for generating errors based on device parameters
class ErrorGenerator {
  static final _random = Random();

  /// Generates a potential error for a device based on its parameters and connections
  static DeviceError? generateError(
    Device device,
    List<List<String>> connections,
    Set<DeviceErrorType> usedErrorTypes,
  ) {
    // Get all connections for this device
    final deviceConnections = connections
        .where((c) => c.contains(device.id))
        .expand((c) => c)
        .where((id) => id != device.id)
        .toList();

    // List of possible errors based on device state
    final possibleErrors = <DeviceErrorType, double>{};

    // High latency check
    if (_random.nextDouble() * device.parameters.latencyThreshold > 80) {
      possibleErrors[DeviceErrorType.highLatency] = 0.4;
    }

    // Packet loss check
    if (device.parameters.failureProbability > 0.5 ||
        _random.nextDouble() < device.parameters.failureProbability) {
      possibleErrors[DeviceErrorType.packetLoss] = 0.3;
    }

    // Overload check
    if (device.parameters.trafficLoad > 70) {
      possibleErrors[DeviceErrorType.overload] = 0.6;
    }

    // Ping timeout check
    if (device.parameters.pingInterval > 45 && _random.nextDouble() < 0.3) {
      possibleErrors[DeviceErrorType.pingTimeout] = 0.25;
    }

    // Offline check (low probability)
    if (_random.nextDouble() < 0.15) {
      possibleErrors[DeviceErrorType.offline] = 0.2;
    }

    // Routing error check
    if (deviceConnections.length > 1 && _random.nextDouble() < 0.35) {
      possibleErrors[DeviceErrorType.routingError] = 0.4;
    }

    // Remove already used error types
    possibleErrors.removeWhere((type, _) => usedErrorTypes.contains(type));

    // If no possible errors, return null
    if (possibleErrors.isEmpty) return null;

    // Select an error type based on probabilities
    final totalProbability = possibleErrors.values.reduce((a, b) => a + b);
    var randomValue = _random.nextDouble() * totalProbability;

    DeviceErrorType? selectedType;
    for (final entry in possibleErrors.entries) {
      randomValue -= entry.value;
      if (randomValue <= 0) {
        selectedType = entry.key;
        break;
      }
    }

    // If no error was selected, return null
    if (selectedType == null) return null;

    // Generate error-specific metadata
    final metadata = <String, dynamic>{};
    switch (selectedType) {
      case DeviceErrorType.highLatency:
        metadata['latencyValue'] =
            device.parameters.latencyThreshold + _random.nextInt(100);
        break;
      case DeviceErrorType.packetLoss:
        metadata['lossRate'] = 0.3 + (_random.nextDouble() * 0.4);
        break;
      case DeviceErrorType.overload:
        metadata['currentLoad'] = device.parameters.trafficLoad + _random.nextInt(30);
        break;
      case DeviceErrorType.pingTimeout:
        metadata['lastPingTime'] = DateTime.now()
            .subtract(Duration(seconds: _random.nextInt(30)))
            .toIso8601String();
        break;
      case DeviceErrorType.offline:
        // Provide four parameters for offline error
        metadata['parameters'] = {
          'pingInterval': device.parameters.pingInterval,
          'latencyThreshold': device.parameters.latencyThreshold,
          'failureProbability': device.parameters.failureProbability,
          'trafficLoad': device.parameters.trafficLoad,
        };
        break;
      case DeviceErrorType.routingError:
        final otherConnections = deviceConnections.toList();
        metadata['correctRoute'] = otherConnections[_random.nextInt(otherConnections.length)];
        break;
    }

    return DeviceError(
      deviceId: device.id,
      type: selectedType,
      startTime: DateTime.now(),
      metadata: metadata,
    );
  }
}