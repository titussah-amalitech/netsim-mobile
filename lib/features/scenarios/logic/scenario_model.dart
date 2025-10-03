import 'dart:convert';

import 'scenario_device.dart';
import 'scenario_metadata.dart';

class Scenario {
  final String name;
  final String difficulty;
  final int timeLimit;
  final List<Device> devices;
  final Metadata metadata;

  Scenario({
    required this.name,
    required this.difficulty,
    required this.timeLimit,
    required this.devices,
    required this.metadata,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) => Scenario(
    name: json['name'] as String,
    difficulty: json['difficulty'] as String,
    timeLimit: (json['timeLimit'] as num).toInt(),
    devices: (json['devices'] as List<dynamic>? ?? [])
        .map((e) => Device.fromJson(e as Map<String, dynamic>))
        .toList(),
    metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'difficulty': difficulty,
    'timeLimit': timeLimit,
    'devices': devices.map((d) => d.toJson()).toList(),
    'metadata': metadata.toJson(),
  };

  static Scenario fromJsonString(String source) =>
      Scenario.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonString({bool pretty = false}) => pretty
      ? const JsonEncoder.withIndent('  ').convert(toJson())
      : jsonEncode(toJson());

  Scenario copyWith({
    String? name,
    String? difficulty,
    int? timeLimit,
    List<Device>? devices,
    Metadata? metadata,
  }) => Scenario(
    name: name ?? this.name,
    difficulty: difficulty ?? this.difficulty,
    timeLimit: timeLimit ?? this.timeLimit,
    devices: devices ?? this.devices,
    metadata: metadata ?? this.metadata,
  );
}

List<Scenario> scenariosFromJsonString(String source) {
  final decoded = jsonDecode(source);
  if (decoded is List) {
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Scenario.fromJson)
        .toList();
  }
  throw FormatException('Expected a JSON array of scenarios');
}

String scenariosToJsonString(List<Scenario> scenarios, {bool pretty = false}) {
  final list = scenarios.map((s) => s.toJson()).toList();
  return pretty
      ? const JsonEncoder.withIndent('  ').convert(list)
      : jsonEncode(list);
}
