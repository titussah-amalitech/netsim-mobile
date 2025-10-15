import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final int timeLimit;
  final int deviceCount;
  final DateTime createdAt;
  final String createdBy;

  const StatsGrid({
    super.key,
    required this.timeLimit,
    required this.deviceCount,
    required this.createdAt,
    required this.createdBy,
  });

  String _formatDate(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}mo ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}y ago';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: [
        StatGridCard(
          icon: Icons.timer_outlined,
          label: 'Time Limit',
          value: '${timeLimit}s',
        ),
        StatGridCard(
          icon: Icons.devices,
          label: 'Total Devices',
          value: '$deviceCount',
        ),
        StatGridCard(
          icon: Icons.calendar_today,
          label: 'Created',
          value: _formatDate(createdAt),
        ),
        StatGridCard(
          icon: Icons.person_outline,
          label: 'Created By',
          value: createdBy,
        ),
      ],
    );
  }
}

class StatGridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatGridCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isLongValue = value.length > 8;

    return Card(
      color: colorScheme.surface,
      elevation: 0.3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.inverseSurface, width: 1),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: colorScheme.inverseSurface, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLongValue) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: colorScheme.inverseSurface,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
