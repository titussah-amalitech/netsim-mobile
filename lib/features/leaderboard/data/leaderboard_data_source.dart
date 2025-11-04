import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netsim_mobile/features/leaderboard/data/models/leaderboard_entry.dart';

class LeaderboardDataSource {
  static const String _leaderboardKey = 'leaderboard';

  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    try {
      // Load default entries from asset
      final jsonStr = await rootBundle.loadString('assets/data/leaderboard.json');
      final List<dynamic> defaultData = json.decode(jsonStr);
      final defaultEntries = defaultData.map((e) => LeaderboardEntry.fromJson(e)).toList();
      debugPrint('📊 Loaded ${defaultEntries.length} default entries from assets');

      // Load saved entries from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_leaderboardKey);
      
      if (savedJson != null) {
        final List<dynamic> savedData = json.decode(savedJson);
        final savedEntries = savedData.map((e) => LeaderboardEntry.fromJson(e)).toList();
        debugPrint('📊 Loaded ${savedEntries.length} saved entries from SharedPreferences');
        
        // Use saved entries if available, otherwise use defaults
        return savedEntries;
      }

      // No saved entries yet, use defaults
      return defaultEntries;
    } catch (e) {
      debugPrint('❌ Error loading leaderboard: $e');
      return [];
    }
  }

  Future<void> saveLeaderboard(List<LeaderboardEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_leaderboardKey, jsonStr);
      debugPrint('📊 Saved ${entries.length} entries to SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error saving leaderboard: $e');
    }
  }
}
