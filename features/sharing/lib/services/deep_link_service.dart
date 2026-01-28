import 'dart:async';
import 'package:app_links/app_links.dart';
import 'code_generator.dart';

/// Service to handle deep links for schedule sharing
class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static String? _pendingCode;
  static StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link listener
  static Future<void> initialize(Function(String code) onCodeReceived) async {
    // Handle initial deep link (app launched via link - cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        final code = _extractCode(initialUri);
        if (code != null) {
          _pendingCode = code;
          onCodeReceived(code);
        }
      }
    } catch (e) {
      // No initial link or error - ignore
    }

    // Handle incoming links while app is running (warm start)
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      final code = _extractCode(uri);
      if (code != null) {
        onCodeReceived(code);
      }
    });
  }

  /// Extract share code from URI
  /// Expected format: dansmonsac://share/ABC123
  static String? _extractCode(Uri uri) {
    // Check scheme
    if (uri.scheme != 'dansmonsac') return null;

    // Check host
    if (uri.host != 'share') return null;

    // Get code from path
    if (uri.pathSegments.isEmpty) return null;

    final code = CodeGenerator.normalize(uri.pathSegments.first);
    return CodeGenerator.isValid(code) ? code : null;
  }

  /// Consume pending code (one-time use, for onboarding flow)
  static String? consumePendingCode() {
    final code = _pendingCode;
    _pendingCode = null;
    return code;
  }

  /// Check if there's a pending code
  static bool get hasPendingCode => _pendingCode != null;

  /// Set a pending code manually (e.g., from manual entry)
  static void setPendingCode(String code) {
    if (CodeGenerator.isValid(code)) {
      _pendingCode = CodeGenerator.normalize(code);
    }
  }

  /// Build a share link for a code
  static String buildShareLink(String code) {
    return 'dansmonsac://share/${CodeGenerator.normalize(code)}';
  }

  /// Dispose resources
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
