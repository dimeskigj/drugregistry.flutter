import 'package:flutter/material.dart';

class ReviewPromptPanel extends StatelessWidget {
  const ReviewPromptPanel({
    super.key,
    required this.onReview,
    required this.onFeedback,
    required this.onDismiss,
  });

  final VoidCallback onReview;
  final VoidCallback onFeedback;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Фала што ја користиш апликацијата!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Дали би сакал/а да оставиш рецензија или да ни пратиш подетален фидбек?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Затвори',
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onReview,
            icon: const Icon(Icons.star_border_rounded),
            label: const Text('Остави рецензија'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onFeedback,
            icon: const Icon(Icons.mail_outline_rounded),
            label: const Text('Испрати фидбек'),
          ),
        ],
      ),
    );
  }
}
