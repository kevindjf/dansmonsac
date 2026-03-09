import 'package:common/src/ui/ui.dart';
import 'package:common/src/utils/hours_util.dart';
import 'package:common/src/services.dart';
import 'package:common/src/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule/di/riverpod_di.dart';
import 'package:schedule/models/calendar_course.dart';
import 'package:schedule/presentation/add/add_calendar_course_page.dart';
import 'package:schedule/presentation/calendar/controller/calendar_controller.dart';
import 'package:streak/di/riverpod_di.dart';

class EventUI {
  final Event event;
  double start;
  double height;
  double width;

  EventUI(this.event, this.start, this.height, this.width);
}

class Event {
  final String id;
  final String courseId;
  final String title;
  final String room;
  final String hour;
  final DateTime startTime;
  final DateTime endTime;
  final String weekType; // 'A', 'B', or 'BOTH'
  final int dayOfWeek; // 1=Monday, 7=Sunday

  Event({
    required this.id,
    required this.courseId,
    required this.title,
    required this.room,
    required this.hour,
    required this.startTime,
    required this.endTime,
    required this.weekType,
    required this.dayOfWeek,
  });

  @override
  String toString() {
    return 'Event{title: $title - : $startTime / $endTime}';
  }

  // Factory to create from CalendarEvent
  factory Event.fromCalendarEvent(CalendarEvent calendarEvent) {
    return Event(
      id: calendarEvent.id,
      courseId: calendarEvent.courseId,
      title: calendarEvent.title,
      room: calendarEvent.room,
      hour: calendarEvent.hour,
      startTime: calendarEvent.startTime,
      endTime: calendarEvent.endTime,
      weekType: calendarEvent.weekType,
      dayOfWeek: calendarEvent.dayOfWeek,
    );
  }
}

class CalendarBodyWidget extends ConsumerWidget {
  final DateTime selectedDate;
  final WeekFilter weekFilter;

  const CalendarBodyWidget({
    Key? key,
    required this.selectedDate,
    required this.weekFilter,
  }) : super(key: key);

  bool hasOverlappingEvent(Event event, List<Event> events) {
    for (var other in events) {
      if (event != other) {
        // Éviter de comparer avec lui-même
        bool overlap = event.startTime.isBefore(other.endTime) &&
            event.endTime.isAfter(other.startTime);

        if (overlap) {
          return true; // Un chevauchement est trouvé, pas besoin de continuer
        }
      }
    }
    return false; // Aucun chevauchement trouvé
  }

  int calculateEventWidth(
      Event event, List<List<Event>> groupedEvents, int currentColIndex) {
    if (currentColIndex >= groupedEvents.length - 1) {
      return 1; // Si on est à la dernière colonne, largeur = 1
    }

    // Vérifier s'il y a un chevauchement dans la colonne suivante
    for (var nextEvent in groupedEvents[currentColIndex + 1]) {
      if (hasOverlappingEvent(event, [nextEvent])) {
        return 1; // Chevauchement trouvé, on ne peut pas s’étendre
      }
    }

    // Sinon, continuer l’exploration récursive dans la colonne suivante
    return 1 + calculateEventWidth(event, groupedEvents, currentColIndex + 1);
  }

  List<List<Event>> groupOverlappingEvents(List<Event> events) {
    events.sort((a, b) =>
        a.startTime.compareTo(b.startTime)); // Trier par heure de début
    List<List<Event>> groupedEvents = [];

    for (var event in events) {
      bool placed = false;

      // Essayer d'ajouter l'événement à une colonne existante
      for (var column in groupedEvents) {
        var lastEventColumn = column.last.endTime;

        if (column.isEmpty ||
            event.startTime.isAfter(column.last.endTime) ||
            (event.startTime.hour == lastEventColumn.hour &&
                event.startTime.minute == lastEventColumn.minute)) {
          column.add(event);
          placed = true;
          break;
        }
      }

      // Sinon, créer une nouvelle colonne
      if (!placed) {
        groupedEvents.add([event]);
      }
    }

    return groupedEvents;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use provider with selected date and week filter
    final calendarState =
        ref.watch(calendarControllerProvider(selectedDate, weekFilter));

    return calendarState.when(
      data: (calendarEvents) {
        // Convert CalendarEvent to Event
        final events =
            calendarEvents.map((e) => Event.fromCalendarEvent(e)).toList();

        // If no events, show empty message
        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Aucun cours aujourd\'hui',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        return _buildCalendar(context, events, ref);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Erreur lors du chargement des cours',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(
      BuildContext context, List<Event> events, WidgetRef ref) {
    var grouped = groupOverlappingEvents(events);

    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    var startDay = events.first;
    var endDay = events.last;

    // Pixels per minute for proportional sizing
    final double pixelsPerMinute = 25.0 / 15.0;

    // Container height based on exact minutes
    final totalMinutes =
        endDay.endTime.difference(startDay.startTime).inMinutes;
    final containerHeight = totalMinutes * pixelsPerMinute + 40;

    List<Widget> widgets = [];

    // Build course widgets with exact minute-based positioning
    for (int i = 0; i < grouped.length; i++) {
      var column = grouped[i];
      for (int j = 0; j < column.length; j++) {
        var event = column[j];

        int width = 1;
        if (i != grouped.length - 1) {
          width = calculateEventWidth(event, groupOverlappingEvents(events), i);
        }

        final minutesFromStart =
            event.startTime.difference(startDay.startTime).inMinutes.toDouble();
        final durationMinutes =
            event.endTime.difference(event.startTime).inMinutes.toDouble();

        widgets.add(Container(
          margin: EdgeInsets.only(
              top: minutesFromStart * pixelsPerMinute,
              left: MediaQuery.of(context).size.width / grouped.length * i),
          width:
              MediaQuery.of(context).size.width / grouped.length * width - 10,
          height: durationMinutes * pixelsPerMinute,
          child: GestureDetector(
            onTap: () => _showCourseOptions(context, ref, event),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        FormatterDate.formatHours(
                            event.startTime, event.endTime),
                        style: GoogleFonts.robotoCondensed(
                            color: Colors.white38, fontSize: 12)),
                    // Title with badge inline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            event.title,
                            style: GoogleFonts.roboto(
                                color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (event.weekType != 'BOTH') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              event.weekType,
                              style: GoogleFonts.robotoCondensed(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(event.room,
                        style: GoogleFonts.roboto(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
        ));
      }
    }

    // Add pause blocks for gaps >= 60 minutes
    // Track the latest end time to detect real gaps (accounting for overlapping events)
    DateTime latestEnd = events.first.endTime;
    for (int i = 0; i < events.length; i++) {
      if (events[i].endTime.isAfter(latestEnd)) {
        latestEnd = events[i].endTime;
      }

      if (i < events.length - 1) {
        final nextStart = events[i + 1].startTime;
        // Only consider it a gap if next event starts after the latest end so far
        if (nextStart.isAfter(latestEnd) ||
            nextStart.isAtSameMomentAs(latestEnd)) {
          final gapMinutes = nextStart.difference(latestEnd).inMinutes;
          if (gapMinutes >= 60) {
            final gapStartFromDay =
                latestEnd.difference(startDay.startTime).inMinutes.toDouble();
            final gapTop = gapStartFromDay * pixelsPerMinute;
            final gapHeight = gapMinutes.toDouble() * pixelsPerMinute;

            // Format pause duration
            final hours = gapMinutes ~/ 60;
            final mins = gapMinutes % 60;
            final pauseLabel = mins > 0
                ? "Pause - ${hours}h${mins.toString().padLeft(2, '0')}"
                : "Pause - ${hours}h";

            widgets.add(Container(
              margin: EdgeInsets.only(top: gapTop),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              width: double.infinity,
              height: gapHeight,
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: 8,
                  dashWidth: 5,
                  dashSpace: 4,
                  strokeWidth: 1,
                ),
                child: Center(
                  child: Text(
                    pauseLabel,
                    style: GoogleFonts.robotoCondensed(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ));
          }
        }
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
              width: double.infinity,
              height: containerHeight,
              child: Stack(
                children: widgets,
              )),
          // Espace pour les boutons en overlay (Ajouter + Partager)
          const SizedBox(height: 150),
        ],
      ),
    );
  }

  void _showCourseOptions(BuildContext context, WidgetRef ref, Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF303030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final bottomPadding = MediaQuery.of(sheetContext).viewPadding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 16.0 + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course info
              Text(
                event.title,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${event.room} • ${event.hour}",
                style: GoogleFonts.roboto(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Edit button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _editCourse(context, ref, event);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.secondary),
                  label: Text(
                    "Modifier ce cours",
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await _deleteCourse(context, ref, event.id);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    "Supprimer ce cours",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editCourse(BuildContext context, WidgetRef ref, Event event) {
    final existingCourse = CalendarCourse(
      id: event.id,
      courseId: event.courseId,
      roomName: event.room,
      startTime:
          TimeOfDay(hour: event.startTime.hour, minute: event.startTime.minute),
      endTime:
          TimeOfDay(hour: event.endTime.hour, minute: event.endTime.minute),
      weekType: WeekType.fromString(event.weekType),
      dayOfWeek: event.dayOfWeek,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF303030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return AddCalendarCoursePage(
          existingCourse: existingCourse,
          selectedDate: selectedDate,
          onAddCalendarCourse: (calendarCourse) {
            ref.invalidate(calendarControllerProvider);
          },
        );
      },
    );
  }

  /// Refresh notifications after calendar changes
  /// Fire-and-forget operation with error protection
  Future<void> _refreshNotifications(WidgetRef ref) async {
    try {
      final repository = ref.read(calendarCourseRepositoryProvider);
      final database = ref.read(databaseProvider);
      int currentStreak = 0;
      try {
        currentStreak = await ref.read(currentStreakProvider.future);
      } catch (_) {
        // Streak read failure is non-critical for notifications
      }
      await NotificationService.updateNotificationIfEnabled(
        repository: repository,
        database: database,
        currentStreak: currentStreak,
      );
    } catch (e, st) {
      LogService.e('Erreur reprogrammation notifications', e, st);
    }
  }

  Future<void> _deleteCourse(
      BuildContext context, WidgetRef ref, String courseId) async {
    final repository = ref.read(calendarCourseRepositoryProvider);
    final result = await repository.deleteCalendarCourse(courseId);

    result.fold(
      (failure) {
        ShowErrorMessage.show(
            context, "Erreur lors de la suppression: ${failure.message}");
      },
      (_) {
        // Refresh calendar and supply list
        ref.invalidate(calendarControllerProvider);
        // Refresh notifications after course deletion
        _refreshNotifications(ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cours supprimé avec succès'),
            backgroundColor: Color(0xFF303030),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    this.borderRadius = 8,
    this.dashWidth = 5,
    this.dashSpace = 4,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
