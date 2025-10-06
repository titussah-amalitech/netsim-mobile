class Position {
  final int x;
  final int y;

  Position({required this.x, required this.y});

  factory Position.fromJson(Map<String, dynamic> json) =>
      Position(x: (json['x'] as num).toInt(), y: (json['y'] as num).toInt());

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  Position copyWith({int? x, int? y}) =>
      Position(x: x ?? this.x, y: y ?? this.y);
}
