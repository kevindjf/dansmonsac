import 'package:common/src/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:streak/di/riverpod_di.dart';
import 'package:streak/models/week_day_status.dart';
import 'package:streak/presentation/widgets/animated_flame.dart';
import 'package:streak/presentation/widgets/weekly_streak_row.dart';

/// Streak detail page showing weekly progress and motivational messages
///
/// Displays:
/// - Fire icon (48-64px)
/// - Weekly progress row (Task 2 will add this widget)
/// - Motivational message based on streak state
///
/// Navigation:
/// - Accessed via StreakCounterWidget tap
/// - Back button returns to home screen
class StreakDetailPage extends ConsumerWidget {
  const StreakDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStreakAsync = ref.watch(currentStreakProvider);
    final previousStreakAsync = ref.watch(previousStreakProvider);
    final weeklyDataAsync = ref.watch(weeklyStreakDataProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: currentStreakAsync.when(
        data: (currentStreak) {
          return previousStreakAsync.when(
            data: (previousStreak) {
              return weeklyDataAsync.when(
                data: (weeklyData) => _buildContent(
                  context,
                  currentStreak,
                  previousStreak,
                  weeklyData,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildError(context),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError(context),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    int currentStreak,
    int previousStreak,
    List<WeekDayStatus> weeklyData,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Animated flame with error handling
          _buildFlameAnimation(context, colorScheme),

          const SizedBox(height: 32),

          // Weekly streak row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: WeeklyStreakRow(statuses: weeklyData),
          ),

          const SizedBox(height: 32),

          // Motivational message
          _buildMotivationalMessage(
            context,
            currentStreak,
            previousStreak,
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage(
    BuildContext context,
    int currentStreak,
    int previousStreak,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String title;
    String subtitle;

    Widget titleWidget;

    if (currentStreak > 0) {
      // Active streak
      final nextStreak = currentStreak + 1;
      title = 'Tu as une streak de $currentStreak jours';
      subtitle = 'Tu gères ! Prépare ton sac pour passer à $nextStreak demain.';

      // Custom styling for active streak
      titleWidget = RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          children: [
            TextSpan(
              text: 'Tu as une streak de ',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: '$currentStreak jours',
              style: TextStyle(color: colorScheme.secondary),
            ),
          ],
        ),
      );
    } else if (previousStreak > 0) {
      // Streak brisé
      final daysText = previousStreak == 1 ? 'jour' : 'jours';
      title = 'On repart à zéro ? 🔄';
      subtitle =
          'Ton record est de $previousStreak $daysText. Relève le défi !';

      titleWidget = Text(
        title,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      // Jamais commencé
      title = 'Active ton premier feu ! ⚡';
      subtitle = 'Organise ton sac chaque jour pour monter en niveau.';

      titleWidget = Text(
        title,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: [
        // Title
        titleWidget,

        const SizedBox(height: 18),

        // Subtitle
        Text(
          subtitle,
          style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFlameAnimation(BuildContext context, ColorScheme colorScheme) {
    try {
      LogService.d('StreakDetailPage: Attempting to load Lottie animation');

      return Lottie.asset(
        'packages/streak/assets/animations/fire_flame.json',
        width: 120,
        height: 120,
        fit: BoxFit.fill,
        repeat: true,
        animate: true,
        errorBuilder: (context, error, stackTrace) {
          LogService.e(
            'StreakDetailPage: Lottie animation failed to load',
            error,
            stackTrace,
          );

          // Fallback to custom Flutter animation
          return AnimatedFlame(
            size: 96,
            color: colorScheme.secondary,
          );
        },
      );
    } catch (e, stackTrace) {
      LogService.e(
        'StreakDetailPage: Exception loading Lottie animation',
        e,
        stackTrace,
      );

      // Fallback to custom Flutter animation
      return AnimatedFlame(
        size: 64,
        color: colorScheme.secondary,
      );
    }
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
