// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:netsim_mobile/features/devices/data/models/device_parameters_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_position_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_status_model.dart';

class Device {
  final String id;
  final String deviceId;
  final String type;
  final DevicePosition position;
  final DeviceParameters parameters;
  final DeviceStatus status;

  Device({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.position,
    required this.parameters,
    required this.status,
  });

  Device copyWith({
    String? id,
    String? deviceId,
    String? type,
    DevicePosition? position,
    DeviceParameters? parameters,
    DeviceStatus? status,
  }) {
    return Device(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      position: position ?? this.position,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'deviceId': deviceId,
      'type': type,
      'position': position.toMap(),
      'parameters': parameters.toMap(),
      'status': status.toMap(),
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as String,
      deviceId: map['deviceId'] as String,
      type: map['type'] as String,
      position: DevicePosition.fromMap(map['position'] as Map<String, dynamic>),
      parameters: DeviceParameters.fromMap(
        map['parameters'] as Map<String, dynamic>,
      ),
      status: DeviceStatus.fromMap(map['status'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Device.fromJson(String source) =>
      Device.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Device(id: $id, deviceId: $deviceId, type: $type, position: $position, parameters: $parameters, status: $status)';
  }

  @override
  bool operator ==(covariant Device other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.deviceId == deviceId &&
        other.type == type &&
        other.position == position &&
        other.parameters == parameters &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        type.hashCode ^
        position.hashCode ^
        parameters.hashCode ^
        status.hashCode;
  }
}
