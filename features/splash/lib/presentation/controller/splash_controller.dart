import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splash/presentation/controller/splash_state.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:common/src/repository/preference_repository.dart';

part 'splash_controller.g.dart';

@riverpod
class SplashController extends _$SplashController {
  late PreferenceRepository preferenceRepository;

  @override
  SplashState build() {
    preferenceRepository = ref.watch(preferenceRepositoryProvider);
    getData();
    return LoadingSplashState();
  }

  getData() async {
    var responses =
        await Future.wait([_checkShowOnboarding(), waitTimeToNext()]);

    var routerProvider = ref.watch(routerDelegateProvider);
    if (responses[0]) {
      routerProvider.goToOnboarding();
    } else {
      routerProvider.goToHome();
    }
  }

  Future<bool> _checkShowOnboarding() async {
    return preferenceRepository.showingOnboarding();
  }

  Future waitTimeToNext() async {
    return Future.delayed(const Duration(milliseconds: 1500));
  }
}
