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
    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      final s = v.toString();
      final parsedInt = int.tryParse(s);
      if (parsedInt != null) return DateTime.fromMillisecondsSinceEpoch(parsedInt);
      return DateTime.tryParse(s) ?? DateTime.now();
    }

    return DeviceStatus(
      parseBool(map['online'] ?? map['isOnline'] ?? map['online_status']),
      parseDouble(map['latency'] ?? map['lag'] ?? 0.0),
      parseDate(map['lastChecked'] ?? map['last_checked'] ?? map['lastPing']),
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
