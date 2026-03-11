import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streak/di/riverpod_di.dart';
import 'package:streak/presentation/pages/streak_detail_page.dart';

/// Streak counter widget that displays the user's current streak
///
/// Displays:
/// - "🔥 X jours de suite!" when streak > 0
/// - Dynamic message based on bag completion when streak = 0
///
/// Automatically refreshes when the streak changes via Riverpod.
/// Tappable to navigate to detailed streak view (minimum 44x44pt).
class StreakCounterWidget extends ConsumerWidget {
  final int? checkedCount;
  final int? totalCount;

  const StreakCounterWidget({
    super.key,
    this.checkedCount,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(currentStreakProvider);

    return GestureDetector(
      onTap: () {
        // Navigate to detailed streak view (Story 2.11)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StreakDetailPage(),
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
            width: 1.5,
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
      // Show fire icon + streak count
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 24,
            color: accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            '$streak ${_getDaysText(streak)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      );
    } else {
      // Show encouraging message based on bag completion
      final message = _getEncouragingMessage();
      return Text(
        message,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  String _getEncouragingMessage() {
    // If no bag data, show default message
    if (checkedCount == null || totalCount == null || totalCount == 0) {
      return 'Prêt pour ta série ? 💪';
    }

    final percentage = (checkedCount! / totalCount!) * 100;

    if (percentage == 0) {
      return 'Lance-toi ! 🚀';
    } else if (percentage < 50) {
      return 'C\'est parti ! 💪';
    } else if (percentage < 100) {
      return 'Continue comme ça ! 🔥';
    } else {
      return 'GG ! Sac prêt 🎉';
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
      return 'Jour';
    } else {
      return 'Jours';
    }
  }
}
