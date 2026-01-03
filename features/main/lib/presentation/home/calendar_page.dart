import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/ui/ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main/presentation/home/calendar_body_widget.dart';
import 'package:schedule/presentation/add/add_calendar_course_page.dart';


class CalendarPage extends ConsumerWidget {

  CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return  Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12.0,
                        children: [
                          getItem("L"),
                          getItem("M"),
                          getItem("M", isSelected: true),
                          getItem("J"),
                          getItem("V"),
                          getItem("S"),
                          getItem("D"),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Vos cours de la journée",
                    style: GoogleFonts.robotoCondensed(
                        color: Colors.white38, fontSize: 14),
                  ),
                ),
                Expanded(child: CalendarBodyWidget())
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        _showAddCalendarCourseModal(context);
                      },
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
                            "Ajouter un cours",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
  }

  void _showAddCalendarCourseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddCalendarCoursePage(
        onAddCalendarCourse: (calendarCourse) {
          if (calendarCourse != null) {
            // Mettre à jour votre UI ou état avec le nouveau cours
            print("Cours ajouté au calendrier: ${calendarCourse.roomName}");
          }
        },
      ),
    );
  }

  Widget getItem(String letter, {bool isSelected = false}) {
    return Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.black,
          // Couleur du fond
          borderRadius:
          BorderRadius.circular(8.0), // Rayon appliqué aux 4 coins
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(letter),
        ));
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
  final String name;
  bool isChecked;

  SupplyItem({required this.name, this.isChecked = false});
}

class ListSupply extends StatefulWidget {
  @override
  State<ListSupply> createState() => _ListSupplyState();
}

class _ListSupplyState extends State<ListSupply> {
  final List<ListItem> items = [
    CourseTitleItem(title: 'Math'),
    SupplyItem(name: 'Cahier'),
    SupplyItem(name: 'Classeur'),
    CourseTitleItem(title: 'Français'),
    SupplyItem(name: 'Feuille'),
    SupplyItem(name: 'Stylo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
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
                      "4/22 fournitures",
                      style: GoogleFonts.robotoCondensed(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Heure de prépartion du sac : 19:00",
                      style: GoogleFonts.roboto(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Vérification du type d'item pour afficher le widget approprié
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
                        // Coins légèrement arrondis
                        side: BorderSide(
                          width: 4.5, // Bordure plus large
                          color: Colors.grey,
                        ),
                      ),
                      // Pour rendre la checkbox plus grande
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
                          item.isChecked = value ?? false;
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
        Column(
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
        )
      ],
    );
  }
}
