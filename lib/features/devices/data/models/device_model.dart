import 'package:netsim_mobile/features/devices/data/models/device_parameters.dart';
import 'package:netsim_mobile/features/devices/data/models/device_position.dart';
import 'package:netsim_mobile/features/devices/data/models/device_status.dart';

class Device {
  final String id;
  final Position position;
  final Parameters parameters;
  final Status status;

  Device({
    required this.id,
    required this.position,
    required this.parameters,
    required this.status,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'] as String,
    position: Position.fromJson(json['position'] as Map<String, dynamic>),
    parameters: Parameters.fromJson(json['parameters'] as Map<String, dynamic>),
    status: Status.fromJson(json['status'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position.toJson(),
    'parameters': parameters.toJson(),
    'status': status.toJson(),
  };

  Device copyWith({
    String? id,
    Position? position,
    Parameters? parameters,
    Status? status,
  }) => Device(
    id: id ?? this.id,
    position: position ?? this.position,
    parameters: parameters ?? this.parameters,
    status: status ?? this.status,
  );
}
