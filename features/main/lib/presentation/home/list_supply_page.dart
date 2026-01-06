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

class ListSupply extends ConsumerStatefulWidget {
  @override
  ConsumerState<ListSupply> createState() => _ListSupplyState();
}

class _ListSupplyState extends ConsumerState<ListSupply> {
  // Map to track checked state of supplies by ID
  final Map<String, bool> _checkedState = {};

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

            return _buildSupplyList(context, items, checkedSupplies, totalSupplies, packTime);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildEmptyState(packTime),
        );
      },
    );
  }

  Widget _buildEmptyState(TimeOfDay packTime) {
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
                    'Aucun cours demain',
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
              _buildBagReadyBanner(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item is CourseTitleItem) {
                    // Check if all supplies for this course are checked
                    final allChecked = item.supplyIds.isNotEmpty &&
                      item.supplyIds.every((id) => _checkedState[id] ?? false);

                    return CheckboxListTile(
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide(
                          width: 4.5,
                          color: AppColors.accent,
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
                            color: AppColors.accent,
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
                      },
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

  Widget _buildBagReadyBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.accent,
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
            const SizedBox(height: 16),
            Text(
              "$checked/$total fournitures",
              style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Heure de préparation du sac : ${packTime.hour.toString().padLeft(2, '0')}:${packTime.minute.toString().padLeft(2, '0')}",
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
