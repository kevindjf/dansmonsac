import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/services.dart';

/// Provider for managing the app's accent color
final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier();
});

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(const Color(0xFF9C27B0)) {
    _loadColor();
  }

  Future<void> _loadColor() async {
    final color = await PreferencesService.getAccentColor();
    state = color;
  }

  Future<void> updateColor(Color color) async {
    await PreferencesService.setAccentColor(color);
    state = color;
  }
}
