import 'package:flutter/material.dart';

class DataPointDisplay extends StatelessWidget {
  const DataPointDisplay({
    super.key,
    required this.theme,
    required this.dataPointName,
    required this.dataPoint,
  });

  final ThemeData theme;
  final String dataPointName;
  final String dataPoint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataPointName,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dataPoint,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
