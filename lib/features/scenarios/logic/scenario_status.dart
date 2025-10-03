class Status {
  final bool online;
  final int latency;
  final DateTime lastChecked;

  Status({
    required this.online,
    required this.latency,
    required this.lastChecked,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
      final asInt = int.tryParse(value);
      if (asInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          asInt,
          isUtc: true,
        ).toLocal();
      }
    }
    return DateTime.now();
  }

  factory Status.fromJson(Map<String, dynamic> json) => Status(
    online: json['online'] as bool,
    latency: (json['latency'] as num).toInt(),
    lastChecked: _parseDate(json['lastChecked']),
  );

  Map<String, dynamic> toJson() => {
    'online': online,
    'latency': latency,
    'lastChecked': lastChecked.toIso8601String(),
  };

  Status copyWith({bool? online, int? latency, DateTime? lastChecked}) =>
      Status(
        online: online ?? this.online,
        latency: latency ?? this.latency,
        lastChecked: lastChecked ?? this.lastChecked,
      );
}
