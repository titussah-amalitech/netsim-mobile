enum DeviceType { router, networkSwitch, server, pc, other }

DeviceType deviceTypeFromString(String value) {
  return DeviceType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => DeviceType.other,
  );
}

String deviceTypeToString(DeviceType type) => type.name;

class DeviceParameters {
  final int pingInterval; // seconds
  final int latencyThreshold; // ms
  final double failureProbability; // 0–1
  final int trafficLoad; // %

  const DeviceParameters({
    this.pingInterval = 30,
    this.latencyThreshold = 100,
    this.failureProbability = 0.1,
    this.trafficLoad = 0,
  });

  factory DeviceParameters.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeviceParameters();
    return DeviceParameters(
      pingInterval: json['pingInterval'] is int
          ? json['pingInterval']
          : (json['pingInterval'] ?? 30),
      latencyThreshold: json['latencyThreshold'] is int
          ? json['latencyThreshold']
          : (json['latencyThreshold'] ?? 100),
      failureProbability:
          (json['failureProbability'] is num
                  ? json['failureProbability']
                  : (json['failureProbability'] ?? 0.1))
              .toDouble(),
      trafficLoad: json['trafficLoad'] is int
          ? json['trafficLoad']
          : (json['trafficLoad'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'pingInterval': pingInterval,
    'latencyThreshold': latencyThreshold,
    'failureProbability': failureProbability,
    'trafficLoad': trafficLoad,
  };

  DeviceParameters copyWith({
    int? pingInterval,
    int? latencyThreshold,
    double? failureProbability,
    int? trafficLoad,
  }) {
    return DeviceParameters(
      pingInterval: pingInterval ?? this.pingInterval,
      latencyThreshold: latencyThreshold ?? this.latencyThreshold,
      failureProbability: failureProbability ?? this.failureProbability,
      trafficLoad: trafficLoad ?? this.trafficLoad,
    );
  }
}

class Device {
  final String name;
  final DeviceType type;
  final DeviceParameters parameters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Device({
    required this.name,
    required this.type,
    this.parameters = const DeviceParameters(),
    this.createdAt,
    this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'] as String,
      type: deviceTypeFromString(json['type'] as String),
      parameters: DeviceParameters.fromJson(
        (json['parameters'] as Map<String, dynamic>?),
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': deviceTypeToString(type),
    'parameters': parameters.toJson(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  Device copyWith({
    String? name,
    DeviceType? type,
    DeviceParameters? parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      name: name ?? this.name,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
