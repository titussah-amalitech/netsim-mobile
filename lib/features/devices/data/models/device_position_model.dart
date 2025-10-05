// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// How the device position is presented in the database(object form)
class DevicePosition {
  double x;
  double y;
  DevicePosition(
    this.x,
    this.y,
  );

  DevicePosition copyWith({
    double? x,
    double? y,
  }) {
    return DevicePosition(
      x ?? this.x,
      y ?? this.y,
    );
  }

// Convert from object to map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
    };
  }

// Convert from map to object
  factory DevicePosition.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return DevicePosition(
      parseDouble(map['x'] ?? map['pos_x'] ?? 0.0),
      parseDouble(map['y'] ?? map['pos_y'] ?? 0.0),
    );
  }

  String toJson() => json.encode(toMap());

  factory DevicePosition.fromJson(String source) => DevicePosition.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DevicePosition(x: $x, y: $y)';

  @override
  bool operator ==(covariant DevicePosition other) {
    if (identical(this, other)) return true;
  
    return 
      other.x == x &&
      other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
