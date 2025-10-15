import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ScenarioInfoCard extends StatelessWidget {
  final String name;
  final String description;

  const ScenarioInfoCard({
    super.key,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ShadCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.inverseSurface,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Scenario Information',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.label_outline,
              'Scenario Name',
              name,
              theme.colorScheme.inverseSurface,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.description_outlined,
              'Description',
              '$description',
              theme.colorScheme.inverseSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
