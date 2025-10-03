class Parameters {
  final int pingInterval;
  final int latencyThreshold;
  final double failureProbability;
  final int trafficLoad;

  Parameters({
    required this.pingInterval,
    required this.latencyThreshold,
    required this.failureProbability,
    required this.trafficLoad,
  });

  factory Parameters.fromJson(Map<String, dynamic> json) => Parameters(
    pingInterval: (json['pingInterval'] as num).toInt(),
    latencyThreshold: (json['latencyThreshold'] as num).toInt(),
    failureProbability: (json['failureProbability'] as num).toDouble(),
    trafficLoad: (json['trafficLoad'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'pingInterval': pingInterval,
    'latencyThreshold': latencyThreshold,
    'failureProbability': failureProbability,
    'trafficLoad': trafficLoad,
  };

  Parameters copyWith({
    int? pingInterval,
    int? latencyThreshold,
    double? failureProbability,
    int? trafficLoad,
  }) => Parameters(
    pingInterval: pingInterval ?? this.pingInterval,
    latencyThreshold: latencyThreshold ?? this.latencyThreshold,
    failureProbability: failureProbability ?? this.failureProbability,
    trafficLoad: trafficLoad ?? this.trafficLoad,
  );
}
