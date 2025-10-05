// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


class Metadata {
  final String createdBy;
  final DateTime createdAt;
  final String description;

  Metadata({
    required this.createdBy,
    required this.createdAt,
    required this.description,
  });

  Metadata copyWith({
    String? createdBy,
    DateTime? createdAt,
    String? description,
  }) {
    return Metadata(
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory Metadata.fromMap(Map<String, dynamic> map) {
    String toStr(dynamic v) => v == null ? '' : v.toString();

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      final s = v.toString();
      final parsedInt = int.tryParse(s);
      if (parsedInt != null) return DateTime.fromMillisecondsSinceEpoch(parsedInt);
      return DateTime.tryParse(s) ?? DateTime.now();
    }

    return Metadata(
      createdBy: toStr(map['createdBy'] ?? map['created_by'] ?? map['author']),
      createdAt: parseDate(map['createdAt'] ?? map['created_at'] ?? map['created_at_ms'] ?? map['created']),
      description: toStr(map['description'] ?? map['desc'] ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory Metadata.fromJson(String source) => Metadata.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Metadata(createdBy: $createdBy, createdAt: $createdAt, description: $description)';

  @override
  bool operator ==(covariant Metadata other) {
    if (identical(this, other)) return true;
  
    return 
      other.createdBy == createdBy &&
      other.createdAt == createdAt &&
      other.description == description;
  }

  @override
  int get hashCode => createdBy.hashCode ^ createdAt.hashCode ^ description.hashCode;
}
