import 'package:flutter/material.dart';

/// Dialog displayed when a streak break is detected.
///
/// Shows an encouraging message with the previous streak count
/// and a dismiss button to acknowledge the break and start fresh.
///
/// The tone is positive and motivational, never guilt-inducing.
class StreakBreakDialog extends StatelessWidget {
  /// The previous streak count before the break.
  final int previousStreak;

  const StreakBreakDialog({
    super.key,
    required this.previousStreak,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Semantics(
        label: 'Ton streak de $previousStreak ${previousStreak == 1 ? 'jour' : 'jours'} est terminé. Recommence aujourd\'hui !',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ExcludeSemantics(
              child: Text(
                '\u{1F4AA}',
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tu avais un streak de $previousStreak ${previousStreak == 1 ? 'jour' : 'jours'} !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Pas grave ! Recommence aujourd\'hui et bat ton record !',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'C\'est reparti !',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
