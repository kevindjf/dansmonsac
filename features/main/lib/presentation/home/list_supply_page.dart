import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/services.dart';
import 'package:common/src/utils/week_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main/presentation/home/controller/daily_check_controller.dart';
import 'package:schedule/presentation/supply_list/controller/tomorrow_supply_controller.dart';
import 'package:streak/presentation/widgets/streak_counter_widget.dart';
import 'package:streak/presentation/widgets/streak_break_dialog.dart';
import 'package:streak/di/riverpod_di.dart';

class ListSupplyPage extends ConsumerWidget {
  ListSupplyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListSupply();
  }
}

/// Classe abstraite représentant un item dans la liste
abstract class ListItem {}

/// Item pour le titre d'un cours
class CourseTitleItem implements ListItem {
  final String title;
  final String courseId; // Course ID for persistence
  final List<String> supplyIds; // IDs of supplies for this course

  CourseTitleItem({
    required this.title,
    required this.courseId,
    required this.supplyIds,
  });
}

/// Item pour une fourniture avec checkbox
class SupplyItem implements ListItem {
  final String id;
  final String courseId; // Course ID for persistence (empty for standalone)
  final String name;
  bool isChecked;

  SupplyItem({
    required this.id,
    required this.courseId,
    required this.name,
    this.isChecked = false,
  });
}

enum _EmptyReason { noCourses, noSupplies }

class ListSupply extends ConsumerStatefulWidget {
  @override
  ConsumerState<ListSupply> createState() => _ListSupplyState();
}

class _ListSupplyState extends ConsumerState<ListSupply> {
  // Map to track checked state of supplies by ID
  final Map<String, bool> _checkedState = {};
  DateTime? _targetDate;
  bool _isLoaded = false;
  List<String> _standaloneSupplies = [];
  String? _currentWeekType;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _scrollTimer;
  bool _bagCompletionMarked = false; // Track if bag completion was already marked for today

  @override
  void initState() {
    super.initState();
    _loadCheckedState();
    _loadStandaloneSupplies();
    _loadWeekType();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadWeekType() async {
    final schoolYearStart = await PreferencesService.getSchoolYearStart();
    final weekType = WeekUtils.getCurrentWeekType(schoolYearStart);
    if (mounted) {
      setState(() {
        _currentWeekType = weekType;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // User is scrolling
    if (!_isScrolling) {
      setState(() {
        _isScrolling = true;
      });
    }

    // Cancel previous timer
    _scrollTimer?.cancel();

    // Set timer to detect when scrolling stops
    _scrollTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isScrolling = false;
        });
      }
    });
  }

  Future<void> _loadCheckedState() async {
    // Determine target date
    final packTime = await PreferencesService.getPackTime();
    final now = DateTime.now();
    final targetDate = (now.hour < packTime.hour ||
            (now.hour == packTime.hour && now.minute < packTime.minute))
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day + 1);

    _targetDate = targetDate;

    // Load saved state from Drift database via DailyCheckController
    final controller = ref.read(dailyCheckControllerProvider.notifier);
    final savedState = await controller.loadChecksForDate(_targetDate!);

    if (mounted) {
      setState(() {
        _checkedState.addAll(savedState);
        _isLoaded = true;
      });
    }

    // Check for streak break after load completes
    await _checkForStreakBreak();
  }

  Future<void> _checkForStreakBreak() async {
    final streakRepository = ref.read(streakRepositoryProvider);
    final breakResult = await streakRepository.detectBrokenStreak();

    breakResult.fold(
      (failure) => LogService.e('Failed to detect streak break', failure),
      (isBroken) async {
        if (isBroken) {
          final previousResult = await streakRepository.getPreviousStreak();
          final previousStreak = previousResult.fold(
            (failure) => 0,
            (streak) => streak,
          );

          if (previousStreak > 0 && mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => StreakBreakDialog(
                previousStreak: previousStreak,
              ),
            );
            // After dismiss, refresh streak counter
            ref.invalidate(currentStreakProvider);
          }
        }
      },
    );
  }

  Future<void> _loadStandaloneSupplies() async {
    final supplies = await PreferencesService.getStandaloneSupplies();
    if (mounted) {
      setState(() {
        _standaloneSupplies = supplies;
      });
    }
  }

  // Removed: _saveCheckedState() - now handled by DailyCheckController.toggleCheck() inline

  /// Check if all supplies are checked and mark bag as completed
  Future<void> _checkAndMarkBagCompletion(int totalSupplies) async {
    // Count currently checked supplies
    int checkedCount = _checkedState.values.where((checked) => checked).length;

    // If all supplies are checked and we haven't marked completion yet
    if (totalSupplies > 0 && checkedCount == totalSupplies && !_bagCompletionMarked) {
      _bagCompletionMarked = true;

      // Insert into BagCompletions via StreakRepository
      final streakRepository = ref.read(streakRepositoryProvider);
      final result = await streakRepository.markBagComplete(_targetDate ?? DateTime.now());

      result.fold(
        (failure) {
          // Log error but don't show to user (non-critical)
          LogService.e('Failed to mark bag completion', failure);
        },
        (_) async {
          // Success - invalidate streak provider to refresh UI
          ref.invalidate(currentStreakProvider);

          // Log new streak value for debugging
          final newStreak = await ref.read(currentStreakProvider.future);
          LogService.d('BagCompletion: targetDate=$_targetDate, new streak=$newStreak');

          // Show a celebratory snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ton sac est prêt ! Ton streak a été mis à jour 🔥',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tomorrowSuppliesState = ref.watch(tomorrowSupplyControllerProvider);

    return FutureBuilder<TimeOfDay>(
      future: PreferencesService.getPackTime(),
      builder: (context, packTimeSnapshot) {
        final packTime =
            packTimeSnapshot.data ?? const TimeOfDay(hour: 19, minute: 0);

        return tomorrowSuppliesState.when(
          data: (coursesWithSupplies) {
            // Build list items from courses and supplies
            final List<ListItem> items = [];
            int totalSupplies = 0;
            int checkedSupplies = 0;

            for (final course in coursesWithSupplies) {
              // Collect supply IDs for this course
              final supplyIds = course.supplies.map((s) => s.id).toList();
              items.add(CourseTitleItem(
                title: course.courseName,
                courseId: course.courseId,
                supplyIds: supplyIds,
              ));

              for (final supply in course.supplies) {
                totalSupplies++;
                final isChecked = _checkedState[supply.id] ?? false;
                if (isChecked) checkedSupplies++;

                items.add(SupplyItem(
                  id: supply.id,
                  courseId: course.courseId,
                  name: supply.name,
                  isChecked: isChecked,
                ));
              }
            }

            // Add standalone supplies section if there are any
            if (_standaloneSupplies.isNotEmpty) {
              // Add section title
              final standaloneIds = _standaloneSupplies.map((name) => 'standalone_$name').toList();
              items.add(CourseTitleItem(
                title: "Autres fournitures",
                courseId: '', // Empty for standalone supplies
                supplyIds: standaloneIds,
              ));

              // Add standalone supplies
              for (final supplyName in _standaloneSupplies) {
                final id = 'standalone_$supplyName';
                totalSupplies++;
                final isChecked = _checkedState[id] ?? false;
                if (isChecked) checkedSupplies++;

                items.add(SupplyItem(
                  id: id,
                  courseId: '', // Empty for standalone supplies
                  name: supplyName,
                  isChecked: isChecked,
                ));
              }
            }

            // If no courses at all and no standalone supplies, show empty state
            if (coursesWithSupplies.isEmpty && _standaloneSupplies.isEmpty) {
              return _buildEmptyState(packTime, _EmptyReason.noCourses);
            }

            // If courses exist but 0 supplies total (no standalone either)
            if (totalSupplies == 0) {
              return _buildEmptyState(packTime, _EmptyReason.noSupplies);
            }

            return _buildSupplyList(
                context, items, checkedSupplies, totalSupplies, packTime);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              _buildEmptyState(packTime, _EmptyReason.noCourses),
        );
      },
    );
  }

  Widget _buildEmptyState(TimeOfDay packTime, _EmptyReason reason) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    final String title;
    final String subtitle;
    final IconData icon;

    switch (reason) {
      case _EmptyReason.noCourses:
        title = 'Pas de seance prevue';
        subtitle =
            'Aucune seance n\'est programmee dans votre emploi du temps pour cette date.\nAjoutez des cours dans l\'onglet Calendrier.';
        icon = Icons.event_busy;
      case _EmptyReason.noSupplies:
        title = 'Aucune fourniture renseignee';
        subtitle =
            'Vos seances n\'ont pas de fournitures associees.\nAjoutez des fournitures a vos cours dans l\'onglet Cours.';
        icon = Icons.inventory_2_outlined;
    }

    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(0, 0, packTime),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildSupplyList(BuildContext context, List<ListItem> items, int checked, int total, TimeOfDay packTime) {
    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(checked, total, packTime),
            // Show banner always (with progress)
            _buildBagReadyBanner(context, checked, total, packTime),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length + 1, // +1 for footer padding
                itemBuilder: (context, index) {
                  // Footer padding
                  if (index == items.length) {
                    return const SizedBox(height: 100); // Space for the button
                  }

                  final item = items[index];
                  final accentColor = Theme.of(context).colorScheme.secondary;

                  if (item is CourseTitleItem) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Row(
                        children: [
                          // Bullet point
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.title.toUpperCase(),
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 13,
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (item is SupplyItem) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D3A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          item.name,
                          style: GoogleFonts.roboto(
                            color: item.isChecked ? Colors.white38 : Colors.white70,
                            fontSize: 15,
                            decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: Checkbox(
                          value: item.isChecked,
                          onChanged: (value) async {
                            final controller = ref.read(dailyCheckControllerProvider.notifier);
                            setState(() {
                              _checkedState[item.id] = value ?? false;
                            });
                            // Save to Drift via controller
                            await controller.toggleCheck(
                              item.id,
                              item.courseId,
                              _targetDate!,
                              value ?? false,
                            );

                            // Check if bag is now complete
                            final tomorrowSupplies = await ref.read(tomorrowSupplyControllerProvider.future);
                            int totalSupplies = 0;
                            for (final course in tomorrowSupplies) {
                              totalSupplies += course.supplies.length;
                            }
                            totalSupplies += _standaloneSupplies.length;
                            await _checkAndMarkBagCompletion(totalSupplies);
                          },
                          activeColor: accentColor,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onTap: () async {
                          // Toggle checkbox when tapping anywhere on the card
                          final newValue = !item.isChecked;
                          final controller = ref.read(dailyCheckControllerProvider.notifier);
                          setState(() {
                            _checkedState[item.id] = newValue;
                          });
                          // Save to Drift via controller
                          await controller.toggleCheck(
                            item.id,
                            item.courseId,
                            _targetDate!,
                            newValue,
                          );

                          // Check if bag is now complete
                          final tomorrowSupplies = await ref.read(tomorrowSupplyControllerProvider.future);
                          int totalSupplies = 0;
                          for (final course in tomorrowSupplies) {
                            totalSupplies += course.supplies.length;
                          }
                          totalSupplies += _standaloneSupplies.length;
                          await _checkAndMarkBagCompletion(totalSupplies);
                        },
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildBagReadyBanner(BuildContext context, int checked, int total, TimeOfDay packTime) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final progress = total > 0 ? checked / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 2.2,
          colors: [
            accentColor.withValues(alpha: 0.35),
            accentColor.withValues(alpha: 0.2),
            accentColor.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Votre sac est prêt !",
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Prévu à ${packTime.hour.toString().padLeft(2, '0')}:${packTime.minute.toString().padLeft(2, '0')}",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "$checked/$total",
                style: GoogleFonts.robotoCondensed(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "FOURNITURES",
            style: GoogleFonts.robotoCondensed(
              fontSize: 11,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Gradient progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  // Background
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Gradient progress
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            const Color(0xFFFF6B9D), // Pink
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTargetDateShort(DateTime? date) {
    if (date == null) return '';

    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const months = [
      'Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Aout', 'Septembre', 'Octobre', 'Novembre', 'Decembre'
    ];

    return "${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}";
  }

  Widget _buildHeader(int checked, int total, TimeOfDay packTime) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Mon Sac",
                  style: GoogleFonts.robotoCondensed(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Date + Week inline
                Row(
                  children: [
                    if (_targetDate != null)
                      Text(
                        _formatTargetDateShort(_targetDate),
                        style: GoogleFonts.roboto(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (_currentWeekType != null && _targetDate != null)
                      Text(
                        " • Semaine $_currentWeekType",
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Streak badge top-right
            Positioned(
              top: 0,
              right: 0,
              child: StreakCounterWidget(
                checkedCount: checked,
                totalCount: total,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        width: _isScrolling ? 56 : null, // Shrink to FAB size when scrolling
        child: FilledButton(
          onPressed: () => _showAddSupplyDialog(),
          style: FilledButton.styleFrom(
            padding: _isScrolling
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_isScrolling ? 28 : 12),
            ),
            minimumSize: _isScrolling ? const Size(56, 56) : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _isScrolling
                ? const Icon(
                    Icons.add,
                    color: Colors.white,
                    key: ValueKey('icon'),
                  )
                : Row(
                    key: const ValueKey('row'),
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Ajouter une fourniture",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteStandaloneSupply(String supplyName) async {
    await PreferencesService.removeStandaloneSupply(supplyName);
    await _loadStandaloneSupplies();
  }

  Future<void> _showAddSupplyDialog() async {
    final TextEditingController controller = TextEditingController();

    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF303030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final bottomSafeArea = MediaQuery.of(sheetContext).viewPadding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                bottomSafeArea +
                16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ajouter une fourniture',
                style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(sheetContext).colorScheme.primary),
                  ),
                  labelText: "Nom de la fourniture",
                  hintText: "Exemple : Règle",
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(sheetContext).pop(value.trim());
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final supplyName = controller.text.trim();
                    if (supplyName.isNotEmpty) {
                      Navigator.of(sheetContext).pop(supplyName);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Ajouter",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((supplyName) async {
      if (supplyName != null && supplyName.isNotEmpty) {
        await PreferencesService.addStandaloneSupply(supplyName);
        await _loadStandaloneSupplies();
      }
    });
  }
}
