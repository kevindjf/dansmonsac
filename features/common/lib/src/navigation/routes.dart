import 'package:flutter/material.dart';
import 'package:onboarding/src/presentation/welcome/welcome_page.dart';
import 'package:onboarding/src/presentation/week_explanation/week_explanation_page.dart';
import 'package:onboarding/src/presentation/school_year/school_year_page.dart';
import 'package:onboarding/src/presentation/hour/setup_time_page.dart';
import 'package:onboarding/src/presentation/course/course_page.dart';
import 'package:onboarding/src/presentation/notifications/notification_permission_page.dart';
import 'package:onboarding/src/presentation/import/import_step_page.dart';
import 'package:splash/presentation/splash_page.dart';
import 'package:main/presentation/home/home_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = HomePage.routeName;
  static const String welcome = OnboardingWelcomePage.routeName;
  static const String weekExplanation = OnboardingWeekExplanationPage.routeName;
  static const String schoolYear = OnboardingSchoolYearPage.routeName;
  static const String setupTime = OnboardingSetupTimePage.routeName;
  static const String notificationPermission = OnboardingNotificationPermissionPage.routeName;
  static const String onboardingCourse = OnboardingCoursePage.routeName;
  static const String onboardingImport = OnboardingImportStepPage.routeName;

  static final Map<String, Widget Function()> routes = {
    home: () => HomePage(),
    welcome: () => OnboardingWelcomePage(),
    weekExplanation: () => OnboardingWeekExplanationPage(),
    schoolYear: () => OnboardingSchoolYearPage(),
    setupTime: () => OnboardingSetupTimePage(),
    notificationPermission: () => OnboardingNotificationPermissionPage(),
    onboardingCourse: () => OnboardingCoursePage(),
    onboardingImport: () => OnboardingImportStepPage(),
    splash: () => SplashPage(),
  };
}

class AppRouterDelegate extends RouterDelegate<String>
    with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  String? _currentRoute;
  int? _initialTabIndex;
  bool _showTutorial = false;

  AppRouterDelegate();

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String get currentConfiguration => _currentRoute ?? AppRoutes.splash;

  void setRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          child: AppRoutes.routes[_currentRoute]?.call() ?? SplashPage(),
        ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _currentRoute = configuration;
    return;
  }

  void goToOnboarding() {
    _currentRoute = AppRoutes.welcome;
    notifyListeners();
  }

  void goToHome({int? initialTabIndex, bool showTutorial = false}) {
    _currentRoute = AppRoutes.home;
    _initialTabIndex = initialTabIndex;
    _showTutorial = showTutorial;
    notifyListeners();
  }

  /// Returns and clears the initial tab index (one-time use)
  int? consumeInitialTabIndex() {
    final index = _initialTabIndex;
    _initialTabIndex = null;
    return index;
  }

  /// Returns and clears the show tutorial flag (one-time use)
  bool consumeShowTutorial() {
    final show = _showTutorial;
    _showTutorial = false;
    return show;
  }
}

class AppRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
      RouteInformation routeInformation) async {
    return routeInformation.location ?? AppRoutes.splash;
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
