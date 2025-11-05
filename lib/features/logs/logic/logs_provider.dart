import 'package:netsim_mobile/features/logs/data/services/log_services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../data/models/log_model.dart';
import '../data/models/log_state_model.dart';

final logsFutureProvider = FutureProvider<List<LogModel>>((ref) async {
  var logs = await LogServices.fetchLogs();
  ref.read(logsProvider.notifier).setLogs(logs);
  return logs;
});

class LogNotifier extends StateNotifier<LogState> {
  LogNotifier() : super(LogState(logs: [], filteredLogs: [], page: 10));
  void setLogs(List<LogModel> logs) {
    state = state.copyWith(logs: logs);
    applyFilters();
  }

  /// Reload logs for a specific player and apply filters.
  Future<void> reloadForPlayer(String playerName) async {
    final logs = await LogServices.fetchLogsForPlayer(playerName);
    setLogs(logs);
  }

  /// Convenience: read the current persisted player name and reload logs for them.
  Future<void> reloadForCurrentPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerName = prefs.getString('userName');
      if (playerName == null || playerName.isEmpty) {
        setLogs([]);
        return;
      }
      await reloadForPlayer(playerName);
    } catch (e) {
      debugPrint('Error reloading logs for current player: $e');
    }
  }

  void applyFilters() {
    List<LogModel> filtered = state.logs;

    if (state.statusFilter != null && state.statusFilter!.isNotEmpty) {
      filtered = filtered
          .where((log) => log.status == state.statusFilter)
          .toList();
    }

    if (state.eventTypeFilter != null && state.eventTypeFilter!.isNotEmpty) {
      filtered = filtered
          .where((log) => log.eventType == state.eventTypeFilter)
          .toList();
    }

    state = state.copyWith(filteredLogs: filtered);
  }
}

final logsProvider = StateNotifierProvider<LogNotifier, LogState>((ref) {
  return LogNotifier();
});

final latestLogProvider = StateNotifierProvider<LatestLogNotifier, LogModel?>((
  ref,
) {
  final notifier = LatestLogNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class LatestLogNotifier extends StateNotifier<LogModel?> {
  final Ref ref;
  Timer? _timer;

  LatestLogNotifier(this.ref) : super(null) {
    _loadLatest();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _loadLatest());
  }

  Future<void> _loadLatest() async {
    try {
      final latest = await LogServices.fetchLatestLog();
      // Update state only when different to avoid unnecessary rebuilds
      if (latest != null && latest != state) {
        state = latest;
      } else if (latest == null && state != null) {
        state = null;
      }
    } catch (e) {
      debugPrint('Error fetching latest log: $e');
    }
  }

  /// Reload the latest-log state for a specific player.
  Future<void> reloadForPlayer(String playerName) async {
    try {
      final latest = await LogServices.fetchLatestLogForPlayer(playerName);
      state = latest;
    } catch (e) {
      debugPrint('Error reloading latest log for $playerName: $e');
    }
  }

  /// Reload the latest-log state for the currently persisted player.
  Future<void> reloadForCurrentPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerName = prefs.getString('userName');
      if (playerName == null || playerName.isEmpty) {
        state = null;
        return;
      }
      await reloadForPlayer(playerName);
    } catch (e) {
      debugPrint('Error reloading latest log for current player: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final latestLogsProvider =
    StateNotifierProvider<LatestLogsNotifier, List<LogModel>>((ref) {
      final notifier = LatestLogsNotifier(ref);
      ref.onDispose(() => notifier.dispose());
      return notifier;
    });

class LatestLogsNotifier extends StateNotifier<List<LogModel>> {
  final Ref ref;
  Timer? _timer;
  // gameplay mode is represented by the active timer interval; no persistent field needed

  static const int initialSeedCount = 20;
  static const Duration gameplayUpdateInterval = Duration(seconds: 1);
  static const Duration normalUpdateInterval = Duration(seconds: 30);

  LatestLogsNotifier(this.ref) : super([]) {
    _seedInitialLogs();
    _startTimer(normalUpdateInterval);
  }

  void _startTimer(Duration interval) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _loadLatest());
  }

  void setGameplayMode(bool isInGameplay) {
    _startTimer(isInGameplay ? gameplayUpdateInterval : normalUpdateInterval);
  }

  void addGameplayLog({
    required String device,
    required String deviceType,
    required String eventType,
    required String message,
    required String status,
    required String playerName,
  }) {
    final log = LogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      device: device,
      deviceType: deviceType,
      eventType: eventType,
      message: message,
      status: status,
      timestamp: DateTime.now(),
      playerName: playerName,
    );
    LogServices.addLog(log);
    state = [log, ...state];
  }

  Future<void> _seedInitialLogs() async {
    try {
      final all = await LogServices.fetchLogs();
      if (all.isEmpty) return;
      all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      // take the most recent N
      final seed = all.take(initialSeedCount).toList();
      state = seed;
    } catch (e) {
      debugPrint('Error seeding initial logs: $e');
    }
  }

  /// Reload logs for a specific player immediately (used when switching players)
  Future<void> reloadForPlayer(String playerName) async {
    try {
      final all = await LogServices.fetchLogsForPlayer(playerName);
      if (all.isEmpty) {
        state = [];
        return;
      }
      all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = all.take(initialSeedCount).toList();
      print('LatestLogsNotifier.reloadForPlayer: reloaded ${state.length} logs for $playerName');
    } catch (e) {
      debugPrint('Error reloading logs for player $playerName: $e');
    }
  }

  /// Convenience: read the current persisted player name and reload the logs list for them.
  Future<void> reloadForCurrentPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerName = prefs.getString('userName');
      if (playerName == null || playerName.isEmpty) {
        state = [];
        return;
      }
      await reloadForPlayer(playerName);
    } catch (e) {
      debugPrint('Error reloading logs for current player: $e');
    }
  }

  Future<void> _loadLatest() async {
    try {
      final latest = await LogServices.fetchLatestLog();
      if (latest == null) return;

      if (state.isEmpty || latest.id != state.first.id) {
        state = [latest, ...state];
      }
      print('LatestLogsNotifier._loadLatest: added latest log ${latest.id}');
    } catch (e) {
      debugPrint('Error fetching latest for list: $e');
    }
  }

  /// Clear all stored logs
  void clearAll() {
    state = <LogModel>[];
  }

  Future<void> loadMore({int count = 20}) async {
    try {
      final all = await LogServices.fetchLogs();
      if (all.isEmpty) return;
      all.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final existingIds = state.map((e) => e.id).toSet();

      // Collect logs not already present
      final newOnes = <LogModel>[];
      for (final log in all) {
        if (existingIds.contains(log.id)) continue;
        newOnes.add(log);
      }

      if (newOnes.isEmpty) return;

      // Append older logs after the existing newest-first list
      state = [...state, ...newOnes.take(count)];
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Error loading more logs: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
