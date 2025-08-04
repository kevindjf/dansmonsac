import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/utils/hours_util.dart';

class EventUI {
  final Event event;
  double start;
  double height;
  double width;

  EventUI(this.event, this.start, this.height, this.width);
}

class Event {
  final String title;
  final String room;
  final String hour;
  final DateTime startTime;
  final DateTime endTime;

  Event(
      {required this.title,
      required this.room,
      required this.hour,
      required this.startTime,
      required this.endTime});

  @override
  String toString() {
    return 'Event{title: $title - : $startTime / $endTime}';
  }
}

class CalendarBodyWidget extends StatelessWidget {
  List<Event> events = [
    // 🌅 Matin
    Event(
        title: 'Physique',
        room: "Salle 101",
        hour: "8h30-9h30",
        startTime: DateTime(2025, 1, 15, 8, 30),
        endTime: DateTime(2025, 1, 15, 9, 30)),
    Event(
        title: 'Math',
        room: "Salle 205",
        hour: "9h15-12h",
        startTime: DateTime(2025, 1, 15, 9, 15),
        endTime: DateTime(2025, 1, 15, 12, 00)),
    // Se chevauche avec EPS et Français
    Event(
        title: 'EPS',
        room: "Salle 205",
        hour: "9h30-10h",
        startTime: DateTime(2025, 1, 15, 9, 30),
        endTime: DateTime(2025, 1, 15, 10, 30)),
    // Se chevauche avec Math
    Event(
        title: 'Français',
        room: "Salle 301",
        hour: "10h-11h",
        startTime: DateTime(2025, 1, 15, 10, 00),
        endTime: DateTime(2025, 1, 15, 11, 00)),
    // Se chevauche avec Math
    Event(
        title: 'Histoire',
        room: "Salle 102",
        hour: "11h-12h30",
        startTime: DateTime(2025, 1, 15, 10, 30),
        endTime: DateTime(2025, 1, 15, 12, 30)),
    // Ne chevauche que la fin de Math

    // ☕ Pause déjeuner (12h30 - 13h30)

    // 🌇 Après-midi
    Event(
        title: 'Anglais',
        room: "Salle 235",
        hour: "14h-16h",
        startTime: DateTime(2025, 1, 15, 14, 00),
        endTime: DateTime(2025, 1, 15, 16, 00)),
    // Se chevauche avec Techno
    Event(
        title: 'Technologie',
        room: "Salle 220",
        hour: "15h-17h",
        startTime: DateTime(2025, 1, 15, 15, 00),
        endTime: DateTime(2025, 1, 15, 17, 00)),
    // Se chevauche avec Anglais
    Event(
        title: 'SVT',
        room: "Salle 215",
        hour: "16h-17h30",
        startTime: DateTime(2025, 1, 15, 16, 00),
        endTime: DateTime(2025, 1, 15, 17, 30)),
    // Se chevauche avec Techno
    Event(
        title: 'Musique',
        room: "Salle 108",
        hour: "17h-17h30",
        startTime: DateTime(2025, 1, 15, 16, 00),
        endTime: DateTime(2025, 1, 15, 17, 30)),
    // Se chevauche avec la fin de SVT
  ];

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
  Widget build(BuildContext context) {
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black12,
                  borderRadius: BorderRadius.circular(8)
            ),
            margin: EdgeInsets.symmetric(vertical: 4,horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(FormatterDate.formatHours(event.startTime, event.endTime),
                      style: GoogleFonts.robotoCondensed(
                          color: Colors.white38, fontSize: 12)
                  ),
                  Text(event.title,
                      style: GoogleFonts.roboto(
                          color: Colors.white, fontSize: 14)
                  ),
                  Text(event.room,style: GoogleFonts.roboto(
                      color: Colors.white38, fontSize: 12,fontWeight: FontWeight.w300)),
                ],
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

    /* return Column(
      children: () {
        List<Widget> widgets = [];

        // Tri des événements par heure de début


        // J'ai les evenent qui se chevauchent pas date de début
        var groupedEvent = groupOverlappingEvents(events);

        /*for (int i = 0; i < groupedEvent.length; i++) {
          // Je parcours les colonnes
          // je calcule où je me place
          List<Event> eventsSameTime = groupedEvent[i];

          for(int j = 0; j < eventsSameTime.length; j++){
            var event = eventsSameTime[j];
            var marginWithStart = getQuarterHourIntervals(startDay.startTime, event.startTime);
            var height = getQuarterHourIntervals(event.startTime, event.endTime);
            widgets.add(Container(
              color: Colors.blue,
              margin: Edge,
            ))
          }
        }*/

        return widgets;
      }(),
    );*/
  }
}

int getQuarterHourIntervals(DateTime start, DateTime end) {
  return (end.difference(start).inMinutes / 15).ceil();
}

// Trier par ordre alphabetique
// Faire un boucle pour savoir la colonne dans lequel te placer
// taille maximum c'est le nombre de colonne
// pour chaque event ensuite tu regardes les colonnes adjacentes si pas d'event alors ta taille fait +1 sinon stop
