import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/services.dart';

/// Which page the background image applies to.
enum BackgroundPageType { calendar, supply }

class BackgroundImageState {
  final String? calendarImagePath;
  final String? supplyImagePath;
  final double calendarOpacity;
  final double supplyOpacity;
  final bool useSameImage;

  const BackgroundImageState({
    this.calendarImagePath,
    this.supplyImagePath,
    this.calendarOpacity = 0.3,
    this.supplyOpacity = 0.3,
    this.useSameImage = true,
  });

  /// Get image path for a specific page.
  String? imagePathFor(BackgroundPageType page) {
    if (useSameImage) return calendarImagePath;
    return page == BackgroundPageType.calendar
        ? calendarImagePath
        : supplyImagePath;
  }

  /// Get opacity for a specific page.
  double opacityFor(BackgroundPageType page) {
    if (useSameImage) return calendarOpacity;
    return page == BackgroundPageType.calendar
        ? calendarOpacity
        : supplyOpacity;
  }

  /// Check if a specific page has an image set.
  bool hasImageFor(BackgroundPageType page) {
    final path = imagePathFor(page);
    return path != null && File(path).existsSync();
  }

  BackgroundImageState copyWith({
    String? calendarImagePath,
    String? supplyImagePath,
    double? calendarOpacity,
    double? supplyOpacity,
    bool? useSameImage,
    bool clearCalendarImage = false,
    bool clearSupplyImage = false,
  }) {
    return BackgroundImageState(
      calendarImagePath: clearCalendarImage
          ? null
          : (calendarImagePath ?? this.calendarImagePath),
      supplyImagePath:
          clearSupplyImage ? null : (supplyImagePath ?? this.supplyImagePath),
      calendarOpacity: calendarOpacity ?? this.calendarOpacity,
      supplyOpacity: supplyOpacity ?? this.supplyOpacity,
      useSameImage: useSameImage ?? this.useSameImage,
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
    final calendarPath = await PreferencesService.getBackgroundImagePath(
        BackgroundPageType.calendar);
    final supplyPath = await PreferencesService.getBackgroundImagePath(
        BackgroundPageType.supply);
    final calendarOpacity = await PreferencesService.getBackgroundImageOpacity(
        BackgroundPageType.calendar);
    final supplyOpacity = await PreferencesService.getBackgroundImageOpacity(
        BackgroundPageType.supply);
    final useSameImage = await PreferencesService.getBackgroundImageUseSame();
    state = BackgroundImageState(
      calendarImagePath: calendarPath,
      supplyImagePath: supplyPath,
      calendarOpacity: calendarOpacity,
      supplyOpacity: supplyOpacity,
      useSameImage: useSameImage,
    );
  }

  Future<void> setImagePath(BackgroundPageType page, String? path) async {
    await PreferencesService.setBackgroundImagePath(page, path);
    if (page == BackgroundPageType.calendar) {
      if (path == null) {
        state = state.copyWith(clearCalendarImage: true);
      } else {
        state = state.copyWith(calendarImagePath: path);
      }
    } else {
      if (path == null) {
        state = state.copyWith(clearSupplyImage: true);
      } else {
        state = state.copyWith(supplyImagePath: path);
      }
    }
  }

  Future<void> setOpacity(BackgroundPageType page, double opacity) async {
    await PreferencesService.setBackgroundImageOpacity(page, opacity);
    if (page == BackgroundPageType.calendar) {
      state = state.copyWith(calendarOpacity: opacity);
    } else {
      state = state.copyWith(supplyOpacity: opacity);
    }
  }

  Future<void> setUseSameImage(bool useSame) async {
    await PreferencesService.setBackgroundImageUseSame(useSame);
    state = state.copyWith(useSameImage: useSame);
  }

  Future<void> removeImage(BackgroundPageType page) async {
    final currentPath = page == BackgroundPageType.calendar
        ? state.calendarImagePath
        : state.supplyImagePath;
    if (currentPath != null) {
      final file = File(currentPath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    await PreferencesService.setBackgroundImagePath(page, null);
    if (page == BackgroundPageType.calendar) {
      state = state.copyWith(clearCalendarImage: true);
    } else {
      state = state.copyWith(clearSupplyImage: true);
    }
  }
}
