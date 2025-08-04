import 'dart:math';

import 'package:common/src/repository/preference_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository extends PreferenceRepository {
  static final String PREF_KEY_DEVICE = "device_id";
  static final String PREF_KEY_SHOWING_ONBOARDING = "showing_onboarding";

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(PREF_KEY_DEVICE);

    if (deviceId == null) {
      deviceId = _generateRandomId(); // Génère un ID unique
      await prefs.setString(PREF_KEY_DEVICE, deviceId);
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
    bool? showing = prefs.getBool(PREF_KEY_SHOWING_ONBOARDING);
    return showing ?? true;
  }

  @override
  Future<void> storeFinishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PREF_KEY_SHOWING_ONBOARDING, false);
  }
}
