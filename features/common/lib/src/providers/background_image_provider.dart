import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/services.dart';

class BackgroundImageState {
  final String? imagePath;
  final double opacity;

  const BackgroundImageState({this.imagePath, this.opacity = 0.5});

  bool get hasImage => imagePath != null && File(imagePath!).existsSync();

  BackgroundImageState copyWith({String? imagePath, double? opacity, bool clearImage = false}) {
    return BackgroundImageState(
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      opacity: opacity ?? this.opacity,
    );
  }
}

final backgroundImageProvider =
    StateNotifierProvider<BackgroundImageNotifier, BackgroundImageState>((ref) {
  return BackgroundImageNotifier();
});

class BackgroundImageNotifier extends StateNotifier<BackgroundImageState> {
  BackgroundImageNotifier() : super(const BackgroundImageState()) {
    _load();
  }

  Future<void> _load() async {
    final path = await PreferencesService.getBackgroundImagePath();
    final opacity = await PreferencesService.getBackgroundImageOpacity();
    state = BackgroundImageState(imagePath: path, opacity: opacity);
  }

  Future<void> setImagePath(String? path) async {
    await PreferencesService.setBackgroundImagePath(path);
    if (path == null) {
      state = state.copyWith(clearImage: true);
    } else {
      state = state.copyWith(imagePath: path);
    }
  }

  Future<void> setOpacity(double opacity) async {
    await PreferencesService.setBackgroundImageOpacity(opacity);
    state = state.copyWith(opacity: opacity);
  }

  Future<void> removeImage() async {
    final currentPath = state.imagePath;
    if (currentPath != null) {
      final file = File(currentPath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    await PreferencesService.setBackgroundImagePath(null);
    state = state.copyWith(clearImage: true);
  }
}
