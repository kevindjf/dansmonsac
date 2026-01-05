import 'package:common/src/ui/ui.dart';
import 'package:common/src/utils/hours_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule/di/riverpod_di.dart';
import 'package:schedule/presentation/calendar/controller/calendar_controller.dart';

class EventUI {
  final Event event;
  double start;
  double height;
  double width;

  EventUI(this.event, this.start, this.height, this.width);
}

class Event {
  final String id;
  final String title;
  final String room;
  final String hour;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.id,
    required this.title,
    required this.room,
    required this.hour,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() {
    return 'Event{title: $title - : $startTime / $endTime}';
  }

  // Factory to create from CalendarEvent
  factory Event.fromCalendarEvent(CalendarEvent calendarEvent) {
    return Event(
      id: calendarEvent.id,
      title: calendarEvent.title,
      room: calendarEvent.room,
      hour: calendarEvent.hour,
      startTime: calendarEvent.startTime,
      endTime: calendarEvent.endTime,
    );
  }
}

class CalendarBodyWidget extends ConsumerWidget {
  final DateTime selectedDate;

  const CalendarBodyWidget({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  List<Event> _getDefaultEvents() {
    // Return empty list by default
    return [];
  }

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
    // Use provider with selected date
    final calendarState = ref.watch(calendarControllerProvider(selectedDate));

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
    // 2. Définir notre unité temporelle (pixels par minute)
    final double pixelsPerMinute = 100 / 30; // 100 pixels pour 30 minutes

    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    var startDay = events.first;
    var endDay = events.last;
    var heightContainer =
        getQuarterHourIntervals(startDay.startTime, endDay.endTime) + 30;

    double sizeOfQuarter = 25;

    List<Widget> widgets = [];

    for (int i = 0; i < grouped.length; i++) {
      var column = grouped[i];
      for (int j = 0; j < column.length; j++) {
        var event = column[j];

        int width = 1;
        if (i != grouped.length - 1) {
          width = calculateEventWidth(event, groupOverlappingEvents(events), i);
        }
        // POUR LA TAILLE JE DOIS REGARDER SI
        widgets.add(Container(
          margin: EdgeInsets.only(
              top:
                  getQuarterHourIntervals(startDay.startTime, event.startTime) *
                      sizeOfQuarter,
              left: MediaQuery.of(context).size.width / grouped.length * i),
          width:
              MediaQuery.of(context).size.width / grouped.length * width - 10,
          height: getQuarterHourIntervals(event.startTime, event.endTime) *
              sizeOfQuarter,
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
                    Text(event.title,
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 14)),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
              width: double.infinity,
              height: heightContainer * 15,
              child: Stack(
                children: widgets,
              )),
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
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
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

            // Delete button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

int getQuarterHourIntervals(DateTime start, DateTime end) {
  return (end.difference(start).inMinutes / 15).ceil();
}

// Trier par ordre alphabetique
// Faire un boucle pour savoir la colonne dans lequel te placer
// taille maximum c'est le nombre de colonne
// pour chaque event ensuite tu regardes les colonnes adjacentes si pas d'event alors ta taille fait +1 sinon stop
