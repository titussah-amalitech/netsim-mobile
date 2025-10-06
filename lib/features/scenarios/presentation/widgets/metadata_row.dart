import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const MetadataRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.p)),
      ],
    );
  }
}
