import 'package:common/src/ui/theme/colors.dart';
import 'package:common/src/services/log_service.dart';
import 'package:common/src/services/preferences_service.dart';
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
/// - Fire icon (48-64px) with optional scale animation
/// - Streak counter with optional count-up animation
/// - Weekly progress row with optional delayed appearance
/// - Motivational message based on streak state
///
/// Navigation:
/// - Accessed via StreakCounterWidget tap or bag completion
/// - Back button returns to home screen
class StreakDetailPage extends ConsumerStatefulWidget {
  final bool showCelebration;

  const StreakDetailPage({super.key, this.showCelebration = false});

  @override
  ConsumerState<StreakDetailPage> createState() => _StreakDetailPageState();
}

class _StreakDetailPageState extends ConsumerState<StreakDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late AnimationController _weeklyRowController;
  late Animation<double> _flameScale;
  late Animation<double> _weeklyRowOpacity;

  @override
  void initState() {
    super.initState();

    _flameController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _weeklyRowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flameScale = Tween<double>(
      begin: widget.showCelebration ? 0.5 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flameController,
      curve: Curves.elasticOut,
    ));

    _weeklyRowOpacity = Tween<double>(
      begin: widget.showCelebration ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _weeklyRowController,
      curve: Curves.easeIn,
    ));

    if (widget.showCelebration) {
      // Start flame animation immediately
      _flameController.forward();
      // Delay weekly row appearance
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _weeklyRowController.forward();
      });
    } else {
      _flameController.value = 1.0;
      _weeklyRowController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _flameController.dispose();
    _weeklyRowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  ref,
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
    WidgetRef ref,
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

          // Animated flame with scale animation
          ScaleTransition(
            scale: _flameScale,
            child: _buildFlameAnimation(context, colorScheme),
          ),

          const SizedBox(height: 16),

          // Streak counter with count-up animation
          widget.showCelebration
              ? TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: currentStreak),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    );
                  },
                )
              : Text(
                  '$currentStreak',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),

          const SizedBox(height: 16),

          // Weekly streak row with fade-in
          FadeTransition(
            opacity: _weeklyRowOpacity,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: WeeklyStreakRow(statuses: weeklyData),
            ),
          ),

          const SizedBox(height: 32),

          // Motivational message
          _buildMotivationalMessage(
            context,
            currentStreak,
            previousStreak,
          ),

          const SizedBox(height: 48),

          // Vacation mode hint
          _buildVacationModeHint(context, ref),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVacationModeHint(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: PreferencesService.isVacationModeActive(),
      builder: (context, snapshot) {
        final isVacationMode = snapshot.data ?? false;

        // Only show hint if vacation mode is NOT active
        if (isVacationMode) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.vacation.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.vacation.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.beach_access,
                color: AppColors.vacation,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tu es en vacances ? N\'oublie pas de l\'activer dans les paramètres pour ne pas perdre ta streak',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
      title = 'On repart à zéro ?';
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
      title = 'Active ton premier feu !';
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
          style: textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
