import 'package:main/presentation/home/controller/home_state_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/di/riverpod_di.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {

  @override
  HomeStateUi build() {
    // Check for initial tab from navigation (e.g., after onboarding)
    final routerDelegate = ref.read(routerDelegateProvider);
    final initialIndex = routerDelegate.consumeInitialTabIndex();

    if (initialIndex != null) {
      final page = _getPageForIndex(initialIndex);
      return HomeStateUi(initialIndex, page);
    }

    return HomeStateUi(0, HomeViewPage.supplies);
  }

  changePage(int index, HomeViewPage page) {
    state = HomeStateUi(index, page);
  }

  HomeViewPage _getPageForIndex(int index) {
    switch (index) {
      case 0: return HomeViewPage.supplies;
      case 1: return HomeViewPage.calendar;
      case 2: return HomeViewPage.courses;
      case 3: return HomeViewPage.settings;
      default: return HomeViewPage.supplies;
    }
  }
}
