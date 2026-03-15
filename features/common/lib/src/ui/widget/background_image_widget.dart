import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/providers/background_image_provider.dart';

/// A widget that displays a background image with an adaptive overlay.
/// Wraps its child content with the user-selected background image.
class BackgroundImageWidget extends ConsumerWidget {
  final Widget child;
  final BackgroundPageType pageType;

  const BackgroundImageWidget({
    super.key,
    required this.child,
    required this.pageType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgState = ref.watch(backgroundImageProvider);

    if (!bgState.hasImageFor(pageType)) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark ? Colors.black : Colors.white;
    final opacity = bgState.opacityFor(pageType);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.file(
          File(bgState.imagePathFor(pageType)!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
        // Adaptive overlay for readability
        Container(
          color: overlayColor.withValues(alpha: opacity),
        ),
        // Content
        child,
      ],
    );
  }
}
