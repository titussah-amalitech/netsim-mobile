

import 'package:netsim_mobile/app/services/log_services.dart';
import 'dart:async';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../models/log_model.dart';
import '../models/log_state_model.dart';

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
  
  void applyFilters() {
    List<LogModel> filtered = state.logs;

    if (state.statusFilter != null && state.statusFilter!.isNotEmpty) {
      filtered = filtered.where((log) => log.status == state.statusFilter).toList();
    }

    if (state.eventTypeFilter != null && state.eventTypeFilter!.isNotEmpty) {
      filtered = filtered.where((log) => log.eventType == state.eventTypeFilter).toList();
    }

    state = state.copyWith(filteredLogs: filtered);
  }
}
final logsProvider = StateNotifierProvider<LogNotifier, LogState>((ref) {
  return LogNotifier();
});

// Provider to expose the single latest log and poll every 30 seconds
final latestLogProvider = StateNotifierProvider<LatestLogNotifier, LogModel?>((ref) {
  final notifier = LatestLogNotifier(ref);
  // Dispose the notifier when the provider is disposed
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class LatestLogNotifier extends StateNotifier<LogModel?> {
  final Ref ref;
  Timer? _timer;

  LatestLogNotifier(this.ref) : super(null) {
    _loadLatest();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _loadLatest());
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
      // Optionally log the error; don't crash the notifier
      // ignore: avoid_print
      print('Error fetching latest log: $e');
    }
  }


  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider that keeps a list of latest logs (newest first)
final latestLogsProvider = StateNotifierProvider<LatestLogsNotifier, List<LogModel>>((ref) {
  final notifier = LatestLogsNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class LatestLogsNotifier extends StateNotifier<List<LogModel>> {
  final Ref ref;
  Timer? _timer;

  static const int initialSeedCount = 20;

  LatestLogsNotifier(this.ref) : super([]) {
    _seedInitialLogs();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _loadLatest());
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
      // ignore but print for dev
      // ignore: avoid_print
      print('Error seeding initial logs: $e');
    }
  }

  Future<void> _loadLatest() async {
    try {
      final latest = await LogServices.fetchLatestLog();
      if (latest == null) return;

      // If the latest log is different from current top, prepend it
      if (state.isEmpty || latest.id != state.first.id) {
        state = [latest, ...state];
      }
    } catch (e) {
      // ignore errors but print for dev
      // ignore: avoid_print
      print('Error fetching latest for list: $e');
    }
  }

  /// Clear all stored logs
  void clearAll() {
    state = <LogModel>[];
  }

  /// Load more logs (older ones) and append at the end of the list.
  /// This uses `fetchLogs()` and appends logs that are not already present.
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
      print('Error loading more logs: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}