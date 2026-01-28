import 'dart:math';

/// Generates unique 6-character alphanumeric codes for sharing
class CodeGenerator {
  // Characters that are unambiguous (no 0/O/1/I to avoid confusion)
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int _codeLength = 6;

  /// Generate a random 6-character code
  static String generate() {
    final random = Random.secure();
    return List.generate(
      _codeLength,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
  }

  /// Validate if a code has the correct format
  static bool isValid(String code) {
    if (code.length != _codeLength) return false;
    return code.toUpperCase().split('').every((c) => _chars.contains(c));
  }

  /// Normalize a code (uppercase, trim)
  static String normalize(String code) {
    return code.toUpperCase().trim();
  }
}
