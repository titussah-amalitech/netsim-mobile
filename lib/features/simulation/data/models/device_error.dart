import 'dart:convert';

/// Represents different types of errors that can occur on network devices
enum DeviceErrorType {
  highLatency,
  packetLoss,
  overload,
  pingTimeout,
  offline,
  routingError,
}

/// Extension methods for DeviceErrorType
extension DeviceErrorTypeX on DeviceErrorType {
  /// Gets the display name for the error type
  String get displayName {
    switch (this) {
      case DeviceErrorType.highLatency:
        return 'High Latency';
      case DeviceErrorType.packetLoss:
        return 'Packet Loss';
      case DeviceErrorType.overload:
        return 'Network Overload';
      case DeviceErrorType.pingTimeout:
        return 'Ping Timeout';
      case DeviceErrorType.offline:
        return 'Offline Device';
      case DeviceErrorType.routingError:
        return 'Routing Error';
    }
  }

  /// Gets the base score for fixing this error type
  int get baseScore {
    switch (this) {
      case DeviceErrorType.highLatency:
        return 50;
      case DeviceErrorType.packetLoss:
        return 75;
      case DeviceErrorType.overload:
        return 60;
      case DeviceErrorType.pingTimeout:
        return 40;
      case DeviceErrorType.offline:
        return 100;
      case DeviceErrorType.routingError:
        return 80;
    }
  }

  /// Gets the penalty score when auto-recovered
  int get penaltyScore {
    switch (this) {
      case DeviceErrorType.highLatency:
        return 20;
      case DeviceErrorType.packetLoss:
        return 35;
      case DeviceErrorType.overload:
        return 25;
      case DeviceErrorType.pingTimeout:
        return 20;
      case DeviceErrorType.offline:
        return 50;
      case DeviceErrorType.routingError:
        return 40;
    }
  }

  /// Gets the color for this error type
  int get color {
    switch (this) {
      case DeviceErrorType.highLatency:
        return 0xFFFFC107; // yellow
      case DeviceErrorType.packetLoss:
        return 0xFFE53935; // red
      case DeviceErrorType.overload:
        return 0xFFFF5722; // deep orange
      case DeviceErrorType.pingTimeout:
        return 0xFF90A4AE; // blue grey
      case DeviceErrorType.offline:
        return 0xFF9C27B0; // purple
      case DeviceErrorType.routingError:
        return 0xFFFF9800; // orange
    }
  }
}

/// Represents an active error on a device
class DeviceError {
  final String deviceId;
  final DeviceErrorType type;
  final DateTime startTime;
  final Map<String, dynamic> metadata;

  const DeviceError({
    required this.deviceId,
    required this.type,
    required this.startTime,
    this.metadata = const {},
  });

  /// Creates a DeviceError from JSON
  factory DeviceError.fromJson(Map<String, dynamic> json) => DeviceError(
        deviceId: json['deviceId'] as String,
        type: DeviceErrorType.values.firstWhere(
            (e) => e.toString() == 'DeviceErrorType.${json['type']}'),
        startTime: DateTime.parse(json['startTime'] as String),
        metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      );

  /// Converts this DeviceError to JSON
  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'type': type.toString().split('.').last,
        'startTime': startTime.toIso8601String(),
        'metadata': metadata,
      };

  /// Creates a copy of this DeviceError with some fields replaced
  DeviceError copyWith({
    String? deviceId,
    DeviceErrorType? type,
    DateTime? startTime,
    Map<String, dynamic>? metadata,
  }) =>
      DeviceError(
        deviceId: deviceId ?? this.deviceId,
        type: type ?? this.type,
        startTime: startTime ?? this.startTime,
        metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      );

  /// Converts this DeviceError to a string
  String toJsonString() => jsonEncode(toJson());

  /// Creates a DeviceError from a string
  static DeviceError fromJsonString(String jsonString) =>
      DeviceError.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  /// Checks if this error should auto-recover
  bool shouldAutoRecover(DateTime now) =>
      now.difference(startTime).inSeconds >= 30;
}