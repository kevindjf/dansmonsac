import 'package:flutter/material.dart';
import 'package:onboarding/src/presentation/welcome/welcome_page.dart';
import 'package:onboarding/src/presentation/hour/setup_time_page.dart';
import 'package:onboarding/src/presentation/course/course_page.dart';
import 'package:splash/presentation/splash_page.dart';
import 'package:main/presentation/home/home_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = HomePage.routeName;
  static const String welcome = OnboardingWelcomePage.routeName;
  static const String setupTime = OnboardingSetupTimePage.routeName;
  static const String onboardingCourse = OnboardingCoursePage.routeName;

  static final Map<String, Widget Function()> routes = {
    home: () => HomePage(),
    welcome: () => OnboardingWelcomePage(),
    setupTime: () => OnboardingSetupTimePage(),
    onboardingCourse: () => OnboardingCoursePage(),
    splash: () => SplashPage(),
  };
}

class AppRouterDelegate extends RouterDelegate<String>
    with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  String? _currentRoute;

  AppRouterDelegate();

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

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

  void goToHome() {
    _currentRoute = AppRoutes.home;
    notifyListeners();
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
