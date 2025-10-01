// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// how the device parameters are presented in the database(in object form)
class DeviceParameters {
  double pingInterval;
  double latencyThreshold;
  double failureProbability;
  double trafficLoad;

  DeviceParameters(
    this.pingInterval,
    this.latencyThreshold,
    this.failureProbability,
    this.trafficLoad,
  );
      
//Allow making a copy of the object
  DeviceParameters copyWith({
    double? pingInterval,
    double? latencyThreshold,
    double? failureProbability,
    double? trafficLoad,
  }) {
    return DeviceParameters(
      pingInterval ?? this.pingInterval,
      latencyThreshold ?? this.latencyThreshold,
      failureProbability ?? this.failureProbability,
      trafficLoad ?? this.trafficLoad,
    );
  }

// Convert from object to map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pingInterval': pingInterval,
      'latencyThreshold': latencyThreshold,
      'failureProbability': failureProbability,
      'trafficLoad': trafficLoad,
    };
  }

// Convert from map to object
  factory DeviceParameters.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return DeviceParameters(
      parseDouble(map['pingInterval'] ?? map['ping_interval'] ?? map['ping']),
      parseDouble(map['latencyThreshold'] ?? map['latency_threshold'] ?? map['latency']),
      parseDouble(map['failureProbability'] ?? map['failure_probability'] ?? map['failure']),
      parseDouble(map['trafficLoad'] ?? map['traffic_load'] ?? map['traffic']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceParameters.fromJson(String source) => DeviceParameters.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeviceParameters(pingInterval: $pingInterval, latencyThreshold: $latencyThreshold, failureProbability: $failureProbability, trafficLoad: $trafficLoad)';
  }

  @override
  bool operator ==(covariant DeviceParameters other) {
    if (identical(this, other)) return true;
  
    return 
      other.pingInterval == pingInterval &&
      other.latencyThreshold == latencyThreshold &&
      other.failureProbability == failureProbability &&
      other.trafficLoad == trafficLoad;
  }

  @override
  int get hashCode {
    return pingInterval.hashCode ^
      latencyThreshold.hashCode ^
      failureProbability.hashCode ^
      trafficLoad.hashCode;
  }
}
