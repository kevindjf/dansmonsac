import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streak/di/riverpod_di.dart';

/// Streak counter widget that displays the user's current streak
///
/// Displays:
/// - "🔥 X jours de suite!" when streak > 0
/// - "Commence ton streak aujourd'hui!" when streak = 0
///
/// Automatically refreshes when the streak changes via Riverpod.
/// Tappable to navigate to detailed streak view (minimum 44x44pt).
class StreakCounterWidget extends ConsumerWidget {
  const StreakCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(currentStreakProvider);

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to detailed streak view (future story)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Detailed streak view - coming soon!'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 44,
          minWidth: 44,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: streakAsync.when(
          data: (streak) => _buildStreakContent(context, streak),
          loading: () => const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, stack) => _buildErrorContent(context),
        ),
      ),
    );
  }

  Widget _buildStreakContent(BuildContext context, int streak) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    if (streak > 0) {
      // Show fire emoji + streak count
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Text(
            '$streak ${_getDaysText(streak)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      );
    } else {
      // Show encouraging message
      return Text(
        'Commence ton streak aujourd\'hui!',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildErrorContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 20,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 8),
        Text(
          'Erreur de chargement',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  String _getDaysText(int count) {
    if (count == 1) {
      return 'jour de suite!';
    } else {
      return 'jours de suite!';
    }
  }
}
