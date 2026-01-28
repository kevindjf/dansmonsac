import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/import_result.dart';

class ImportConflictDialog extends StatelessWidget {
  final ImportConflict conflict;
  final int currentIndex;
  final int totalConflicts;
  final Function(ConflictResolution) onResolution;

  const ImportConflictDialog({
    super.key,
    required this.conflict,
    required this.currentIndex,
    required this.totalConflicts,
    required this.onResolution,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress indicator
        Text(
          'Conflit $currentIndex/$totalConflicts',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.white54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'Le cours "${conflict.courseName}" existe deja',
          style: GoogleFonts.robotoCondensed(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Existing supplies
        _buildSuppliesList(
          'Fournitures actuelles',
          conflict.existingSupplies,
          Colors.blue,
        ),
        const SizedBox(height: 16),

        // Imported supplies
        _buildSuppliesList(
          'Fournitures importees',
          conflict.importedSupplies,
          accentColor,
        ),
        const SizedBox(height: 24),

        // Actions
        FilledButton(
          onPressed: () => onResolution(ConflictResolution.keepExisting),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.grey[700],
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Garder les fournitures actuelles'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => onResolution(ConflictResolution.replace),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Remplacer par les nouvelles'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => onResolution(ConflictResolution.merge),
          style: FilledButton.styleFrom(
            backgroundColor: accentColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Fusionner (${conflict.mergedSupplies.length} fournitures)'),
        ),
      ],
    );
  }

  Widget _buildSuppliesList(String title, List<String> supplies, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: supplies.map((supply) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  supply,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
