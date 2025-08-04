abstract class PreferenceRepository {
  Future<String> getUserId();
  Future<bool> showingOnboarding();
  Future<void> storeFinishOnboarding();
}
