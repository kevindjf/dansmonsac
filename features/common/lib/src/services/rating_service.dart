import 'package:in_app_review/in_app_review.dart';
import 'preferences_service.dart';

class RatingService {
  static const int _daysBeforeFirstPrompt = 5;
  static const int _daysBeforeReprompt = 7;
  static const int _maxDismissCount = 3;

  /// Initialize first launch date if not already set
  static Future<void> initialize() async {
    await PreferencesService.setFirstLaunchDate(DateTime.now());
  }

  /// Check if the rating popup should be shown
  static Future<bool> shouldShowRatingPopup() async {
    // Check if user has already rated
    final hasRated = await PreferencesService.getHasRated();
    if (hasRated) return false;

    // Check dismiss count - stop asking after max dismissals
    final dismissCount = await PreferencesService.getRatingDismissCount();
    if (dismissCount >= _maxDismissCount) return false;

    // Check first launch date
    final firstLaunchDate = await PreferencesService.getFirstLaunchDate();
    if (firstLaunchDate == null) return false;

    final now = DateTime.now();
    final daysSinceFirstLaunch = now.difference(firstLaunchDate).inDays;

    // Not enough days since first launch
    if (daysSinceFirstLaunch < _daysBeforeFirstPrompt) return false;

    // Check if user has dismissed before
    final lastDismissedDate = await PreferencesService.getRatingDismissedDate();
    if (lastDismissedDate != null) {
      final daysSinceDismiss = now.difference(lastDismissedDate).inDays;
      // Not enough days since last dismiss
      if (daysSinceDismiss < _daysBeforeReprompt) return false;
    }

    return true;
  }

  /// Called when user dismisses the popup (clicks "Plus tard")
  static Future<void> onDismiss() async {
    await PreferencesService.setRatingDismissedDate(DateTime.now());
    await PreferencesService.incrementRatingDismissCount();
  }

  /// Called when user chooses to rate (clicks "Noter")
  static Future<void> onRate() async {
    await PreferencesService.setHasRated(true);
  }

  /// Open the native in-app review dialog
  static Future<bool> openInAppReview() async {
    final inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      return true;
    }
    return false;
  }

  /// Open the store listing directly
  static Future<void> openStoreListing() async {
    final inAppReview = InAppReview.instance;
    await inAppReview.openStoreListing(
      appStoreId: '', // Add your App Store ID here if needed
    );
  }
}
