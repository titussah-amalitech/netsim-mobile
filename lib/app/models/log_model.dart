// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class LogModel {
  final String id;
  final String device;
  final String eventType;
  final String message;
  final String status;
  final DateTime timestamp;
  LogModel({
    required this.id,
    required this.device,
    required this.eventType,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  LogModel copyWith({
    String? id,
    String? device,
    String? eventType,
    String? message,
    String? status,
    DateTime? timestamp,
  }) {
    return LogModel(
      id: id ?? this.id,
      device: device ?? this.device,
      eventType: eventType ?? this.eventType,
      message: message ?? this.message,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'device': device,
      'eventType': eventType,
      'message': message,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as String,
      device: map['device'] as String,
      eventType: map['eventType'] as String,
      message: map['message'] as String,
      status: map['status'] as String,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LogModel.fromJson(String source) => LogModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LogModel(id: $id, device: $device, eventType: $eventType, message: $message, status: $status, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant LogModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.device == device &&
      other.eventType == eventType &&
      other.message == message &&
      other.status == status &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      device.hashCode ^
      eventType.hashCode ^
      message.hashCode ^
      status.hashCode ^
      timestamp.hashCode;
  }
}
