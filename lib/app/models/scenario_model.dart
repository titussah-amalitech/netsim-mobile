// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:netsim_mobile/features/devices/data/models/device_features.dart';
import 'package:netsim_mobile/features/devices/data/models/device_metadata.dart';
import 'package:netsim_mobile/features/devices/data/models/device_parameters_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_position_model.dart';
import 'package:netsim_mobile/features/devices/data/models/device_status_model.dart'
    show DeviceStatus;

// How the device is presented in the database(Database Schema)
// They are in object form

class ScenarioModel {
  final String id;
  final String name;
  final String difficulty;
  final int timeLimit;
  final List<Device> devices;
  final Metadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScenarioModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.timeLimit,
    required this.devices,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  ScenarioModel copyWith({
    String? id,
    String? name,
    String? difficulty,
    int? timeLimit,
    List<Device>? devices,
    Metadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScenarioModel(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      devices: devices ?? this.devices,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
      'devices': devices.map((x) => x.toMap()).toList(),
      'metadata': metadata.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ScenarioModel.fromMap(Map<String, dynamic> map) {
    // Defensive parsing: accept camelCase or snake_case keys, handle nulls and different types
    final idVal = map['id'] ?? map['_id'] ?? '';
    final nameVal = map['name'] ?? '';
    final difficultyVal = map['difficulty'] ?? map['level'] ?? '';

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      final s = v.toString();
      return int.tryParse(s) ?? fallback;
    }

    int timeLimitVal = parseInt(
      map['timeLimit'] ?? map['time_limit'] ?? map['time'],
    );

    List<Device> devicesVal = [];
    try {
      final rawDevices = map['devices'] ?? map['device_list'];
      if (rawDevices is List) {
        devicesVal = rawDevices
            .map((x) {
              try {
                // Case A: item is already a Device-shaped map
                if (x is Map<String, dynamic>) {
                  // Backend may wrap device under 'device' key: { device: {...}, position: {...}, parameters: {...}, status: {...} }
                  if (x.containsKey('device')) {
                    final dev = x['device'];
                    // If 'device' is a nested document (Map), merge fields
                    if (dev is Map) {
                      final merged = <String, dynamic>{};
                      merged.addAll(Map<String, dynamic>.from(dev));
                      // move/override position/parameters/status from wrapper if present
                      if (x.containsKey('position'))
                        merged['position'] = x['position'];
                      if (x.containsKey('parameters'))
                        merged['parameters'] = x['parameters'];
                      if (x.containsKey('status'))
                        merged['status'] = x['status'];
                      // ensure id fields use common keys
                      if (merged.containsKey('_id') &&
                          !merged.containsKey('id'))
                        merged['id'] = merged['_id'];
                      try {
                        return Device.fromMap(merged);
                      } catch (e) {
                        return null;
                      }
                    }

                    // If 'device' is just an id/string, construct a flattened map
                    if (dev is String || dev is int) {
                      // Build Device directly when device is just an ObjectId string
                      try {
                        final deviceIdStr = dev.toString();
                        // Build position, parameters, status using their fromMap factories
                        DevicePosition positionVal;
                        try {
                          final rawPos = x['position'] ?? <String, dynamic>{};
                          positionVal = rawPos is Map<String, dynamic>
                              ? DevicePosition.fromMap(rawPos)
                              : DevicePosition.fromMap(
                                  Map<String, dynamic>.from(rawPos),
                                );
                        } catch (_) {
                          positionVal = DevicePosition(0.0, 0.0);
                        }

                        DeviceParameters parametersVal;
                        try {
                          final rawParams =
                              x['parameters'] ?? <String, dynamic>{};
                          parametersVal = rawParams is Map<String, dynamic>
                              ? DeviceParameters.fromMap(rawParams)
                              : DeviceParameters.fromMap(
                                  Map<String, dynamic>.from(rawParams),
                                );
                        } catch (_) {
                          parametersVal = DeviceParameters(0.0, 0.0, 0.0, 0.0);
                        }

                        DeviceStatus statusVal;
                        try {
                          final rawStatus = x['status'] ?? <String, dynamic>{};
                          statusVal = rawStatus is Map<String, dynamic>
                              ? DeviceStatus.fromMap(rawStatus)
                              : DeviceStatus.fromMap(
                                  Map<String, dynamic>.from(rawStatus),
                                );
                        } catch (_) {
                          statusVal = DeviceStatus(false, 0.0, DateTime.now());
                        }

                        final idFromWrapper = x['_id'] ?? x['id'] ?? '';
                        final devType = x['type'] ?? x['device_type'] ?? '';
                        final devObj = Device(
                          id: idFromWrapper.toString(),
                          deviceId: deviceIdStr,
                          type: devType.toString(),
                          position: positionVal,
                          parameters: parametersVal,
                          status: statusVal,
                        );
                        return devObj;
                      } catch (e) {
                        return null;
                      }
                    }
                  }

                  // Normal Device-shaped map
                  try {
                    return Device.fromMap(x);
                  } catch (e) {
                    return null;
                  }
                }

                // If x is a generic Map (not typed) convert and try
                if (x is Map)
                  return Device.fromMap(Map<String, dynamic>.from(x));
              } catch (_) {
                // ignore per-item parsing errors and continue
              }
              return null;
            })
            .whereType<Device>()
            .toList();
      }
    } catch (_) {
      devicesVal = [];
    }

    Metadata metadataVal;
    try {
      final rawMeta = map['metadata'] ?? map['meta'] ?? <String, dynamic>{};
      metadataVal = rawMeta is Map<String, dynamic>
          ? Metadata.fromMap(rawMeta)
          : Metadata.fromMap(Map<String, dynamic>.from(rawMeta));
    } catch (_) {
      metadataVal = Metadata(
        createdBy: '',
        createdAt: DateTime.now(),
        description: '',
      );
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      final s = v.toString();
      final parsedInt = int.tryParse(s);
      if (parsedInt != null)
        return DateTime.fromMillisecondsSinceEpoch(parsedInt);
      return DateTime.tryParse(s) ?? DateTime.now();
    }

    final createdAtVal = parseDate(
      map['createdAt'] ??
          map['created_at'] ??
          map['created_at_ms'] ??
          map['created'],
    );
    final updatedAtVal = parseDate(
      map['updatedAt'] ??
          map['updated_at'] ??
          map['updated_at_ms'] ??
          map['updated'],
    );

    return ScenarioModel(
      id: idVal.toString(),
      name: nameVal.toString(),
      difficulty: difficultyVal.toString(),
      timeLimit: timeLimitVal,
      devices: devicesVal,
      metadata: metadataVal,
      createdAt: createdAtVal,
      updatedAt: updatedAtVal,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScenarioModel.fromJson(String source) =>
      ScenarioModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeviceModel(id: $id, name: $name, difficulty: $difficulty, timeLimit: $timeLimit, devices: $devices, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant ScenarioModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.difficulty == difficulty &&
        other.timeLimit == timeLimit &&
        listEquals(other.devices, devices) &&
        other.metadata == metadata &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        difficulty.hashCode ^
        timeLimit.hashCode ^
        devices.hashCode ^
        metadata.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
