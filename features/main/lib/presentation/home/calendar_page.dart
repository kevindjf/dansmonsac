import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/ui/ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main/presentation/home/calendar_body_widget.dart';
import 'package:schedule/presentation/add/add_calendar_course_page.dart';
import 'package:schedule/presentation/calendar/controller/calendar_controller.dart';


class CalendarPage extends ConsumerStatefulWidget {

  CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  WeekFilter _weekFilter = WeekFilter.all; // Default to show all courses

  @override
  Widget build(BuildContext context) {
    final selectedWeekday = _selectedDate.weekday; // 1=Monday, 7=Sunday

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
                          _buildDayButton("L", 1, selectedWeekday == 1),
                          _buildDayButton("M", 2, selectedWeekday == 2),
                          _buildDayButton("M", 3, selectedWeekday == 3),
                          _buildDayButton("J", 4, selectedWeekday == 4),
                          _buildDayButton("V", 5, selectedWeekday == 5),
                          _buildDayButton("S", 6, selectedWeekday == 6),
                          _buildDayButton("D", 7, selectedWeekday == 7),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Vos cours de la journée",
                        style: GoogleFonts.robotoCondensed(
                            color: Colors.white38, fontSize: 14),
                      ),
                      // Week filter buttons
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildWeekFilterButton("Complet", WeekFilter.all),
                            _buildWeekFilterButton("Sem. A", WeekFilter.weekA),
                            _buildWeekFilterButton("Sem. B", WeekFilter.weekB),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: CalendarBodyWidget(
                  selectedDate: _selectedDate,
                  weekFilter: _weekFilter,
                ))
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
        selectedDate: _selectedDate, // Pass selected date
        onAddCalendarCourse: (calendarCourse) {
          if (calendarCourse != null) {
            // Mettre à jour votre UI ou état avec le nouveau cours
            print("Cours ajouté au calendrier: ${calendarCourse.roomName}");
          }
        },
      ),
    );
  }

  Widget _buildWeekFilterButton(String label, WeekFilter filter) {
    final isSelected = _weekFilter == filter;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _weekFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.robotoCondensed(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDayButton(String letter, int weekday, bool isSelected) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Calculate the date for the selected weekday in current week
          final now = DateTime.now();
          final currentWeekday = now.weekday;
          final difference = weekday - currentWeekday;
          _selectedDate = now.add(Duration(days: difference));
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.black,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
