import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'stat_card.dart';

class StatsCarousel extends StatelessWidget {
  final int timeLimit;
  final int deviceCount;
  final DateTime createdAt;
  final String createdBy;

  const StatsCarousel({
    super.key,
    required this.timeLimit,
    required this.deviceCount,
    required this.createdAt,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatCard(
        icon: Icons.timer_outlined,
        label: 'Time Limit',
        value: '${timeLimit}s',
        color: Colors.blue,
      ),
      StatCard(
        icon: Icons.devices,
        label: 'Total Devices',
        value: '$deviceCount',
        color: Colors.purple,
      ),
      StatCard(
        icon: Icons.calendar_today,
        label: 'Created',
        value: _formatDate(createdAt),
        color: Colors.orange,
      ),
      StatCard(
        icon: Icons.person_outline,
        label: 'Created By',
        value: createdBy,
        color: Colors.green,
      ),
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 140,
        viewportFraction: 0.45,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
      ),
      items: stats,
    );
  }

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
}
