import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';
import '../leaderboard_data_source.dart';

class LeaderboardService {
  static const String _leaderboardKey = 'leaderboard';

  // Get the leaderboard data
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_leaderboardKey);
    debugPrint('LeaderboardService.getLeaderboard: raw json = $jsonString');
    
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((item) => LeaderboardEntry.fromJson(item))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score)); // Sort by score descending
    } catch (e) {
      print('Error loading leaderboard: $e');
      return [];
    }
  }

  // Update the leaderboard with a new score
  Future<void> updateLeaderboard(String playerName, int score) async {
    final dataSource = LeaderboardDataSource();
    final currentLeaderboard = await dataSource.loadLeaderboard();
    debugPrint('LeaderboardService.updateLeaderboard: currentLeaderboard = ${currentLeaderboard.map((e) => e.toJson())}');

    // Find if player already exists
    final playerIndex = currentLeaderboard.indexWhere((entry) => entry.name == playerName);

    if (playerIndex != -1) {
      // Player exists - update only if new score is higher
      if (score > currentLeaderboard[playerIndex].score) {
        currentLeaderboard.removeAt(playerIndex);
        currentLeaderboard.add(LeaderboardEntry(name: playerName, score: score));
      }
    } else {
      // New player - add to leaderboard
      currentLeaderboard.add(LeaderboardEntry(name: playerName, score: score));
    }

    // Sort by score descending
    currentLeaderboard.sort((a, b) => b.score.compareTo(a.score));

    // Save the updated leaderboard using the data source
    await dataSource.saveLeaderboard(currentLeaderboard);
    debugPrint('LeaderboardService.updateLeaderboard: saved ${currentLeaderboard.length} entries');
  }

  // Clear the leaderboard (useful for testing)
  Future<void> clearLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_leaderboardKey);
  }
}