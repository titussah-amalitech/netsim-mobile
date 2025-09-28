// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


// How the device status is presented in the database(object form)
class DeviceStatus {
  bool online;
  double latency;
  DateTime lastChecked;
  DeviceStatus(
    this.online,
    this.latency,
    this.lastChecked,
  );

// Allow making a copy of the object
  DeviceStatus copyWith({
    bool? online,
    double? latency,
    DateTime? lastChecked,
  }) {
    return DeviceStatus(
      online ?? this.online,
      latency ?? this.latency,
      lastChecked ?? this.lastChecked,
    );
  }

// Convert from object to map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'online': online,
      'latency': latency,
      'lastChecked': lastChecked.millisecondsSinceEpoch,
    };
  }

// Convert from map to object
  factory DeviceStatus.fromMap(Map<String, dynamic> map) {
    return DeviceStatus(
      map['online'] as bool,
      map['latency'] as double,
      DateTime.fromMillisecondsSinceEpoch(map['lastChecked'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceStatus.fromJson(String source) => DeviceStatus.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DeviceStatus(online: $online, latency: $latency, lastChecked: $lastChecked)';

  @override
  bool operator ==(covariant DeviceStatus other) {
    if (identical(this, other)) return true;
  
    return 
      other.online == online &&
      other.latency == latency &&
      other.lastChecked == lastChecked;
  }

  @override
  int get hashCode => online.hashCode ^ latency.hashCode ^ lastChecked.hashCode;
}
