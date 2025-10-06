import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DifficultyTag extends StatelessWidget {
  final String difficulty;

  const DifficultyTag({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    Color tagColor;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        tagColor = Colors.green;
        break;
      case 'medium':
        tagColor = Colors.orange;
        break;
      case 'hard':
        tagColor = Colors.red;
        break;
      default:
        tagColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.2),
        border: Border.all(color: tagColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_cellular_alt, size: 16, color: tagColor),
          const SizedBox(width: 6),
          Text(
            difficulty.toUpperCase(),
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.bold,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }
}
