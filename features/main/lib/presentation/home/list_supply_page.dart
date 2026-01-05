import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/ui/ui.dart';
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

  CourseTitleItem({required this.title});
}

/// Item pour une fourniture avec checkbox
class SupplyItem implements ListItem {
  final String id;
  final String name;
  bool isChecked;

  SupplyItem({required this.id, required this.name, this.isChecked = false});
}

class ListSupply extends ConsumerStatefulWidget {
  @override
  ConsumerState<ListSupply> createState() => _ListSupplyState();
}

class _ListSupplyState extends ConsumerState<ListSupply> {
  // Map to track checked state of supplies by ID
  final Map<String, bool> _checkedState = {};

  // Toggle between today and tomorrow
  bool _showTomorrow = true; // true = tomorrow (default), false = today

  @override
  Widget build(BuildContext context) {
    final tomorrowSuppliesState = ref.watch(tomorrowSupplyControllerProvider);
    final packTime = ref.read(tomorrowSupplyControllerProvider.notifier).getPackTime();

    return tomorrowSuppliesState.when(
      data: (coursesWithSupplies) {
        // Build list items from courses and supplies
        final List<ListItem> items = [];
        int totalSupplies = 0;
        int checkedSupplies = 0;

        for (final course in coursesWithSupplies) {
          items.add(CourseTitleItem(title: course.courseName));

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

        return _buildSupplyList(context, items, checkedSupplies, totalSupplies, packTime);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildEmptyState(packTime),
    );
  }

  Widget _buildEmptyState(PackTimeInfo packTime) {
    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(0, 0, packTime),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    _showTomorrow ? 'Aucun cours demain' : 'Aucun cours aujourd\'hui',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
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

  Widget _buildSupplyList(BuildContext context, List<ListItem> items, int checked, int total, PackTimeInfo packTime) {
    // Check if bag is ready (all supplies checked)
    final bool isBagReady = total > 0 && checked == total;

    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(checked, total, packTime),
            Expanded(
              child: isBagReady
                  ? _buildBagReadyPlaceholder()
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        if (item is CourseTitleItem) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              item.title.toUpperCase(),
                              style: GoogleFonts.robotoCondensed(
                                  fontSize: 16,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        } else if (item is SupplyItem) {
                          return CheckboxListTile(
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              side: BorderSide(
                                width: 4.5,
                                color: Colors.grey,
                              ),
                            ),
                            secondary: SizedBox(width: 10),
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

  Widget _buildBagReadyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Votre sac est prêt !",
              style: GoogleFonts.robotoCondensed(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Toutes vos fournitures sont cochées",
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int checked, int total, PackTimeInfo packTime) {
    return Container(
      width: double.infinity,
      color: Color(0xFF303030),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "A mettre dans votre sac",
                  style: GoogleFonts.robotoCondensed(
                      color: Colors.white38, fontSize: 14),
                ),
                // Day toggle buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDayButton("Aujourd'hui", !_showTomorrow),
                      _buildDayButton("Demain", _showTomorrow),
                    ],
                  ),
                ),
              ],
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
              "Heure de préparation du sac : ${packTime.toFormattedString()}",
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

  Widget _buildDayButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showTomorrow = label == "Demain";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.robotoCondensed(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => print("là"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Ajouter une fourniture",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
