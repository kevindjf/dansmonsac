import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/ui/ui.dart';
import 'package:common/src/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule/presentation/supply_list/controller/tomorrow_supply_controller.dart';

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
  final List<String> supplyIds; // IDs of supplies for this course

  CourseTitleItem({required this.title, required this.supplyIds});
}

/// Item pour une fourniture avec checkbox
class SupplyItem implements ListItem {
  final String id;
  final String name;
  bool isChecked;

  SupplyItem({required this.id, required this.name, this.isChecked = false});
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
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _loadCheckedState();
    _loadStandaloneSupplies();
    _scrollController.addListener(_onScroll);
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

    // Load saved state for this date
    final savedState = await PreferencesService.loadSupplyCheckedState(targetDate);

    if (mounted) {
      setState(() {
        _checkedState.addAll(savedState);
        _isLoaded = true;
      });
    }

    // Clean old states
    PreferencesService.clearOldSupplyStates();
  }

  Future<void> _loadStandaloneSupplies() async {
    final supplies = await PreferencesService.getStandaloneSupplies();
    if (mounted) {
      setState(() {
        _standaloneSupplies = supplies;
      });
    }
  }

  Future<void> _saveCheckedState() async {
    if (_targetDate != null) {
      await PreferencesService.saveSupplyCheckedState(_targetDate!, _checkedState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tomorrowSuppliesState = ref.watch(tomorrowSupplyControllerProvider);

    return FutureBuilder<TimeOfDay>(
      future: PreferencesService.getPackTime(),
      builder: (context, packTimeSnapshot) {
        final packTime = packTimeSnapshot.data ?? const TimeOfDay(hour: 19, minute: 0);

        return tomorrowSuppliesState.when(
          data: (coursesWithSupplies) {
            // Build list items from courses and supplies
            final List<ListItem> items = [];
            int totalSupplies = 0;
            int checkedSupplies = 0;

            for (final course in coursesWithSupplies) {
              // Collect supply IDs for this course
              final supplyIds = course.supplies.map((s) => s.id).toList();
              items.add(CourseTitleItem(title: course.courseName, supplyIds: supplyIds));

              for (final supply in course.supplies) {
                totalSupplies++;
                final isChecked = _checkedState[supply.id] ?? false;
                if (isChecked) checkedSupplies++;

                items.add(SupplyItem(
                  id: supply.id,
                  name: supply.name,
                  isChecked: isChecked,
                ));
              }
            }

            // Add standalone supplies section if there are any
            if (_standaloneSupplies.isNotEmpty) {
              // Add section title
              final standaloneIds = _standaloneSupplies.map((name) => 'standalone_$name').toList();
              items.add(CourseTitleItem(title: "Autres fournitures", supplyIds: standaloneIds));

              // Add standalone supplies
              for (final supplyName in _standaloneSupplies) {
                final id = 'standalone_$supplyName';
                totalSupplies++;
                final isChecked = _checkedState[id] ?? false;
                if (isChecked) checkedSupplies++;

                items.add(SupplyItem(
                  id: id,
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

            return _buildSupplyList(context, items, checkedSupplies, totalSupplies, packTime);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildEmptyState(packTime, _EmptyReason.noCourses),
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
        subtitle = 'Aucune seance n\'est programmee dans votre emploi du temps pour cette date.\nAjoutez des cours dans l\'onglet Calendrier.';
        icon = Icons.event_busy;
      case _EmptyReason.noSupplies:
        title = 'Aucune fourniture renseignee';
        subtitle = 'Vos seances n\'ont pas de fournitures associees.\nAjoutez des fournitures a vos cours dans l\'onglet Cours.';
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
    // Check if bag is ready (all supplies checked)
    final bool isBagReady = total > 0 && checked == total;

    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(checked, total, packTime),
            // Show banner when bag is ready
            if (isBagReady)
              _buildBagReadyBanner(context),
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
                    // Check if all supplies for this course are checked
                    final allChecked = item.supplyIds.isNotEmpty &&
                      item.supplyIds.every((id) => _checkedState[id] ?? false);

                    return CheckboxListTile(
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide(
                          width: 4.5,
                          color: accentColor,
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      dense: false,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        item.title.toUpperCase(),
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 16,
                            color: accentColor,
                            fontWeight: FontWeight.bold),
                      ),
                      value: allChecked,
                      onChanged: item.supplyIds.isEmpty ? null : (value) {
                        setState(() {
                          // Check or uncheck all supplies for this course
                          for (final supplyId in item.supplyIds) {
                            _checkedState[supplyId] = value ?? false;
                          }
                        });
                        _saveCheckedState();
                      },
                    );
                  } else if (item is SupplyItem) {
                    // Check if this is a standalone supply
                    final isStandalone = item.id.startsWith('standalone_');

                    return CheckboxListTile(
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide(
                          width: 4.5,
                          color: Colors.grey,
                        ),
                      ),
                      secondary: isStandalone
                          ? IconButton(
                              icon: Icon(Icons.delete, color: accentColor),
                              onPressed: () => _deleteStandaloneSupply(item.name),
                            )
                          : SizedBox(width: 10),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      dense: false,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        item.name,
                        style: GoogleFonts.roboto(color: Colors.white70),
                      ),
                      value: item.isChecked,
                      onChanged: (value) {
                        setState(() {
                          _checkedState[item.id] = value ?? false;
                        });
                        _saveCheckedState();
                      },
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

  Widget _buildBagReadyBanner(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: accentColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Votre sac est prêt !",
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Toutes vos fournitures sont cochées",
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTargetDate(DateTime? date) {
    if (date == null) return '';

    const days = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
    const months = [
      'janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'aout', 'septembre', 'octobre', 'novembre', 'decembre'
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDay = DateTime(date.year, date.month, date.day);

    String prefix;
    if (targetDay == today) {
      prefix = "aujourd'hui";
    } else if (targetDay == tomorrow) {
      prefix = "demain";
    } else {
      prefix = days[date.weekday - 1];
    }

    return "pour $prefix ${date.day} ${months[date.month - 1]}";
  }

  Widget _buildHeader(int checked, int total, TimeOfDay packTime) {
    return Container(
      width: double.infinity,
      color: Color(0xFF303030),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "A mettre dans votre sac",
              style: GoogleFonts.robotoCondensed(
                  color: Colors.white38, fontSize: 14),
            ),
            if (_targetDate != null)
              Text(
                _formatTargetDate(_targetDate),
                style: GoogleFonts.robotoCondensed(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 16),
            Text(
              "$checked/$total fournitures",
              style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Heure de preparation du sac : ${packTime.hour.toString().padLeft(2, '0')}:${packTime.minute.toString().padLeft(2, '0')}",
              style: GoogleFonts.roboto(
                  color: Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w300),
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
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + bottomSafeArea + 16,
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
                    borderSide: BorderSide(color: Theme.of(sheetContext).colorScheme.primary),
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
