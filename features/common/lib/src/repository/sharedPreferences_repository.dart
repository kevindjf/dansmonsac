// ignore_for_file: file_names
import 'dart:math';

import 'package:common/src/repository/preference_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository extends PreferenceRepository {
  static final String prefKeyDevice = "device_id";
  static final String prefKeyShowingOnboarding = "showing_onboarding";

  @override
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(prefKeyDevice);

    if (deviceId == null) {
      deviceId = _generateRandomId(); // Génère un ID unique
      await prefs.setString(prefKeyDevice, deviceId);
    }

    return deviceId;
  }

  static String _generateRandomId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(999999); // Plage étendue
    return '$timestamp-$randomNumber'; // Ajout d'un séparateur
  }

  @override
  Future<bool> showingOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    bool? showing = prefs.getBool(prefKeyShowingOnboarding);
    return showing ?? true;
  }

  @override
  Future<void> storeFinishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKeyShowingOnboarding, false);
  }
}
