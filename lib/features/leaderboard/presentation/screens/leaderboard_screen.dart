import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh leaderboard when screen is opened so UI always shows current data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(leaderboardProvider.notifier).reload();
        debugPrint('📲 LeaderboardScreen: requested reload on enter');
      } catch (e) {
        debugPrint('📲 LeaderboardScreen: reload failed: $e');
      }
      // Log current user for debugging
      SharedPreferences.getInstance().then((prefs) {
        final userName = prefs.getString('userName');
        debugPrint('📊 LeaderboardScreen: Current user=$userName');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: leaderboardAsync.when(
        data: (leaderboard) {
          debugPrint('📊 LeaderboardScreen: loaded ${leaderboard.length} entries');
          if (leaderboard.isEmpty) {
            return const Center(
              child: Text(
                'No scores yet!\nComplete a game to see your ranking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final entry = leaderboard[index];
              final isTopThree = index < 3;

              return Card(
                elevation: isTopThree ? 4 : 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getLeaderColor(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Text(
                    '${entry.score}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading leaderboard: $error'),
        ),
      ),
    );
  }

  Color _getLeaderColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.blue.shade300;
    }
  }
}