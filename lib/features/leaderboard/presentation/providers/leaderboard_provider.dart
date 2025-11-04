import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:netsim_mobile/features/leaderboard/data/models/leaderboard_entry.dart';
import 'package:netsim_mobile/features/leaderboard/data/services/leaderboard_service.dart';

// Provider for the LeaderboardService
final leaderboardServiceProvider = Provider((ref) => LeaderboardService());

// StateNotifier that holds the leaderboard list and supports reloads
class LeaderboardNotifier extends StateNotifier<AsyncValue<List<LeaderboardEntry>>> {
  final LeaderboardService _service;

  LeaderboardNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _service.getLeaderboard();
      state = AsyncValue.data(entries);
      debugPrint('LeaderboardNotifier.load: loaded ${entries.length} entries');
    } catch (e, st) {
      debugPrint('LeaderboardNotifier.load: error $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Alias for load()
  Future<void> reload() async => load();
}

// Provider that exposes leaderboard state via a StateNotifier
final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, AsyncValue<List<LeaderboardEntry>>>((ref) {
  final service = ref.read(leaderboardServiceProvider);
  return LeaderboardNotifier(service);
});

// Provider that exposes methods to update the leaderboard
final leaderboardControllerProvider = Provider((ref) {
  final leaderboardService = ref.read(leaderboardServiceProvider);

  return LeaderboardController(
    updateLeaderboard: (String playerName, int score) async {
      debugPrint('🔁 leaderboardController: updating for $playerName, score=$score');
      await leaderboardService.updateLeaderboard(playerName, score);
      debugPrint('🔁 leaderboardController: update complete, triggering reload');
      // Tell the notifier to reload so UI consumers update immediately
      try {
        await ref.read(leaderboardProvider.notifier).reload();
        debugPrint('🔁 leaderboardController: reload completed');
      } catch (e) {
        debugPrint('🔁 leaderboardController: reload failed: $e');
      }
    },
  );
});

// Controller class that holds the leaderboard update method
class LeaderboardController {
  final Future<void> Function(String playerName, int score) updateLeaderboard;

  LeaderboardController({required this.updateLeaderboard});
}