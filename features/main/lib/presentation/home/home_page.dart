import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/ui/ui.dart';
import 'package:main/presentation/home/calendar_page.dart';
import 'package:main/presentation/home/controller/home_controller.dart';
import 'package:main/presentation/home/controller/home_state_ui.dart';
import 'package:course/presentation/list/courses_page.dart';
import 'package:main/presentation/home/list_supply_page.dart';
import 'package:main/presentation/home/settings_page.dart';

class HomePage extends ConsumerWidget {
  static const String routeName = "/home";

  HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(homeControllerProvider);
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Color(0xFF212121),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF161616),
        currentIndex: state.currentIndex,
        onTap: (index) {
          HomeViewPage page = HomeViewPage.supplies;

          if (index == 1) {
            page = HomeViewPage.calendar;
          }

          if (index == 2) {
            page = HomeViewPage.courses;
          }

          if (index == 3) {
            page = HomeViewPage.settings;
          }
          ref.read(homeControllerProvider.notifier).changePage(index, page);
        },
        selectedItemColor: accentColor,
        unselectedItemColor: Color(0xFF616161),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        // Couleur des éléments non sélectionnés
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: 'Mon sac',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendrier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
      body: SafeArea(child: _getBody(state)),
    );
  }

  Widget getItem(String letter, {bool isSelected = false, required Color accentColor}) {
    return Container(
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.black,
          // Couleur du fond
          borderRadius:
              BorderRadius.circular(8.0), // Rayon appliqué aux 4 coins
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(letter),
        ));
  }

  _getBody(HomeStateUi state) {
    switch (state.currentPage) {
      case HomeViewPage.supplies:
        return ListSupplyPage();
      case HomeViewPage.calendar:
        return CalendarPage();
      case HomeViewPage.courses:
        return CoursesPage();
      case HomeViewPage.settings:
        return SettingsPage();
    }
  }
}
