import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/rating_service.dart';

class RatingPopup extends StatelessWidget {
  const RatingPopup({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final shouldShow = await RatingService.shouldShowRatingPopup();
    if (shouldShow && context.mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => const RatingPopup(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 16.0 + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.star_rounded,
              size: 36,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Vous aimez DansMonSac ?',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Votre avis nous aide a ameliorer l\'application et a la faire connaitre !',
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Rate button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _onRate(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Noter l\'application',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Later button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _onLater(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Plus tard',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRate(BuildContext context) async {
    await RatingService.onRate();

    // Try native in-app review first
    final success = await RatingService.openInAppReview();

    // If not available, open store listing
    if (!success) {
      await RatingService.openStoreListing();
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _onLater(BuildContext context) async {
    await RatingService.onDismiss();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
