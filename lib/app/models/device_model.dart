// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:netsim_mobile/app/models/device_parameters_model.dart';
import 'package:netsim_mobile/app/models/device_status_model.dart';

import 'device_position_model.dart';

// How the device is presented in the database(Database Schema)
// They are in object form
class DeviceModel {
  String name;
  String type;
  DevicePosition? position;
  DeviceStatus? status;
  DeviceParameters parameters;
  DeviceModel({
    required this.name,
    required this.type,
    this.position,
    this.status,
    required this.parameters,
  });


   
// Make a copy of the objects
  DeviceModel copyWith({
    String? name,
    String? type,
    DevicePosition? position,
    DeviceStatus? status,
    DeviceParameters? parameters,
  }) {
    return DeviceModel(
      name: name ?? this.name,
      type: type ?? this.type,
      position: position ?? this.position,
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
    );
  }

//convert from object to map so that it can be stored in the database
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'type': type,
      'position': position?.toMap(),
      'status': status?.toMap(),
      'parameters': parameters.toMap(),
    };
  }

// convert from map to object so that it can be used in the app
  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      name: map['name'] as String,
      type: map['type'] as String,
      position: map['position'] != null ? DevicePosition.fromMap(map['position'] as Map<String,dynamic>) : null,
      status: map['status'] != null ? DeviceStatus.fromMap(map['status'] as Map<String,dynamic>) : null,
      parameters: DeviceParameters.fromMap(map['parameters'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceModel.fromJson(String source) => DeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeviceModel(name: $name, type: $type, position: $position, status: $status, parameters: $parameters)';
  }

  @override
  bool operator ==(covariant DeviceModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.type == type &&
      other.position == position &&
      other.status == status &&
      other.parameters == parameters;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      type.hashCode ^
      position.hashCode ^
      status.hashCode ^
      parameters.hashCode;
  }
}
