import 'dart:convert';

import 'package:netsim_mobile/features/logs/data/models/log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LogServices {
  // In-memory cache keyed by playerName to avoid frequent prefs reads
  static final Map<String, List<LogModel>> _playerLogs = {};

  static String _prefsKeyFor(String playerName) => 'logs:$playerName';

  static Future<String?> _getCurrentPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  /// Persist the player's log list into SharedPreferences
  static Future<void> _savePlayerLogs(String playerName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _playerLogs[playerName] ?? [];
      final encoded = json.encode(list.map((l) => l.toMap()).toList());
      await prefs.setString(_prefsKeyFor(playerName), encoded);
      print('LogServices._savePlayerLogs: saved ${list.length} logs for $playerName');
    } catch (e) {
      // ignore write errors for now
    }
  }

  /// Load logs for a given player from SharedPreferences into memory.
  static Future<List<LogModel>> _loadPlayerLogsFromPrefs(String playerName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKeyFor(playerName));
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
      final list = decoded.map((e) => LogModel.fromMap(Map<String, dynamic>.from(e))).toList();
      _playerLogs[playerName] = list;
      print( 'LogServices._loadPlayerLogsFromPrefs: loaded ${list.length} logs for $playerName');
      return list;
    } catch (e) {
      return [];
    }
  }


  static Future<List<LogModel>> fetchLogsForPlayer(String playerName) async {
    try {
      if (_playerLogs.containsKey(playerName)) return List.from(_playerLogs[playerName]!);
      return await _loadPlayerLogsFromPrefs(playerName);
    } catch (_) {
      return [];
    }
  }

  /// Fetch the latest log for a specific player.
  static Future<LogModel?> fetchLatestLogForPlayer(String playerName) async {
    try {
      if (_playerLogs.containsKey(playerName)) {
        final list = _playerLogs[playerName]!;
        if (list.isEmpty) return null;
        return list.first;
      }
      final loaded = await _loadPlayerLogsFromPrefs(playerName);
      if (loaded.isEmpty) return null;
      return loaded.first;
    } catch (_) {
      return null;
    }
  }

  /// Add a log for the given player and persist it.
  static Future<void> addLog(LogModel log) async {
    final playerLogs = _playerLogs.putIfAbsent(log.playerName, () => []);
    playerLogs.insert(0, log);
    await _savePlayerLogs(log.playerName);
  }

  /// Fetch logs for the current player (reads from prefs when missing).
  static Future<List<LogModel>> fetchLogs() async {
    try {
      final currentPlayer = await _getCurrentPlayer();
      if (currentPlayer == null) return [];
      if (_playerLogs.containsKey(currentPlayer)) {
        return List.from(_playerLogs[currentPlayer]!);
      }
      return await _loadPlayerLogsFromPrefs(currentPlayer);
    } catch (_) {
      return [];
    }
  }

  /// Fetch the most recent log for current player.
  static Future<LogModel?> fetchLatestLog() async {
    try {
      final currentPlayer = await _getCurrentPlayer();
      if (currentPlayer == null) return null;
      if (_playerLogs.containsKey(currentPlayer)) {
        final list = _playerLogs[currentPlayer]!;
        if (list.isEmpty) return null;
        return list.first;
      }
      final loaded = await _loadPlayerLogsFromPrefs(currentPlayer);
      if (loaded.isEmpty) return null;
      return loaded.first;
    } catch (_) {
      return null;
    }
  }

  /// Clear persisted logs for the current player
  static Future<void> clearLogsForCurrentPlayer() async {
    final currentPlayer = await _getCurrentPlayer();
    if (currentPlayer != null) {
      _playerLogs.remove(currentPlayer);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeyFor(currentPlayer));
    }
  }
}
