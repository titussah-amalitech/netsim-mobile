import 'package:flutter/material.dart';

class DifficultyHeaderCard extends StatelessWidget {
  final String difficulty;

  const DifficultyHeaderCard({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getDifficultyGradient(difficulty),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_getDifficultyIcon(difficulty), color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficulty.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Difficulty Level',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getDifficultyGradient(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return [Colors.green[400]!, Colors.green[600]!];
      case 'medium':
        return [Colors.orange[400]!, Colors.orange[600]!];
      case 'hard':
        return [Colors.red[400]!, Colors.red[600]!];
      default:
        return [Colors.grey[400]!, Colors.grey[600]!];
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.trending_down;
      case 'medium':
        return Icons.trending_flat;
      case 'hard':
        return Icons.trending_up;
      default:
        return Icons.help_outline;
    }
  }
}
