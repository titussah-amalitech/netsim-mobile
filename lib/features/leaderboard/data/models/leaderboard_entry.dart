class LeaderboardEntry {
  final String name;
  final int score;

  const LeaderboardEntry({
    required this.name,
    required this.score,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
      };

  // Create from JSON
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] as String,
      score: json['score'] as int,
    );
  }
}