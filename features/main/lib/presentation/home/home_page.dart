import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:common/src/services/preferences_service.dart';
import 'package:main/presentation/home/calendar_page.dart';
import 'package:main/presentation/home/controller/home_controller.dart';
import 'package:main/presentation/home/controller/home_state_ui.dart';
import 'package:course/presentation/list/courses_page.dart';
import 'package:main/presentation/home/list_supply_page.dart';
import 'package:main/presentation/home/settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  static const String routeName = "/home";

  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // GlobalKeys for tutorial targets
  final GlobalKey _suppliesNavKey = GlobalKey();
  final GlobalKey _calendarNavKey = GlobalKey();
  final GlobalKey _coursesNavKey = GlobalKey();
  final GlobalKey _settingsNavKey = GlobalKey();

  TutorialCoachMark? _tutorialCoachMark;

  @override
  void initState() {
    super.initState();
  }

  void _checkAndShowTutorial() {
    final routerDelegate = ref.read(routerDelegateProvider);
    final shouldShowTutorial = routerDelegate.consumeShowTutorial();

    if (shouldShowTutorial) {
      // Wait for the widget tree to be built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNavigationTutorial();
      });
    }
  }

  void _showNavigationTutorial() {
    final accentColor = Theme.of(context).colorScheme.secondary;

    final targets = [
      TargetFocus(
        identify: "courses_tab",
        keyTarget: _coursesNavKey,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.35,
            ),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Onglet Cours",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Nous avons ajouté des cours par défaut pour toi. Tu peux les modifier ou en ajouter d'autres ici.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "supplies_tab",
        keyTarget: _suppliesNavKey,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.35,
            ),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Mon Sac",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Ici tu verras les fournitures à mettre dans ton sac pour demain.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "calendar_tab",
        keyTarget: _calendarNavKey,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.35,
            ),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Calendrier",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Configure ton emploi du temps ici pour voir les bonnes fournitures chaque jour.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "settings_tab",
        keyTarget: _settingsNavKey,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.35,
            ),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Paramètres",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Personnalise l'application et gère tes notifications ici.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      textSkip: "PASSER",
      alignSkip: Alignment.topRight,
      paddingFocus: 10,
      onFinish: () async {
        await PreferencesService.setTutorialSeen(true);
      },
      onSkip: () {
        PreferencesService.setTutorialSeen(true);
        return true;
      },
    );

    _tutorialCoachMark!.show(context: context);
  }

  /// Public method to show tutorial (called from Settings)
  void showTutorial() {
    _showNavigationTutorial();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(homeControllerProvider);
    final accentColor = Theme.of(context).colorScheme.secondary;

    // Check and show tutorial after first build
    _checkAndShowTutorial();

    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF161616),
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
        unselectedItemColor: const Color(0xFF616161),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            key: _suppliesNavKey,
            icon: const Icon(Icons.backpack),
            label: 'Mon sac',
          ),
          BottomNavigationBarItem(
            key: _calendarNavKey,
            icon: const Icon(Icons.calendar_month),
            label: 'Calendrier',
          ),
          BottomNavigationBarItem(
            key: _coursesNavKey,
            icon: const Icon(Icons.book),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            key: _settingsNavKey,
            icon: const Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
      body: SafeArea(child: _getBody(state)),
    );
  }

  Widget _getBody(HomeStateUi state) {
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
