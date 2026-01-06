import 'package:course/presentation/list/controller/course_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/ui/ui.dart';

class ContentSupplyHolder extends ConsumerWidget {
  final List<SupplyItemUI> supplies;
  final VoidCallback onAddSupply;
  final ValueChanged<SupplyItemUI> onDeleteSupply;
  final VoidCallback onDeleteCourse;

  const ContentSupplyHolder({
    super.key,
    required this.supplies,
    required this.onAddSupply,
    required this.onDeleteSupply,
    required this.onDeleteCourse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Liste des fournitures
        ...supplies.map((supply) => _buildSupplyItem(supply)).toList(),
        const SizedBox(height: 16),

        // Bouton pour ajouter une fourniture
        _buildActionButton(
          icon: Icons.add,
          label: "Ajouter une fourniture",
          onPressed: onAddSupply,
        ),

        const SizedBox(height: 4),

        // Bouton pour supprimer le cours
        _buildActionButton(
          icon: Icons.delete,
          label: "Supprimer cours",
          onPressed: () => _showDeleteConfirmation(context),
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF303030),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Supprimer le cours',
            style: GoogleFonts.robotoCondensed(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ce cours ?\n\nCela supprimera également :\n• Le cours de votre planning\n• Toutes les fournitures associées',
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: GoogleFonts.roboto(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteCourse();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Supprimer',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 📝 Widget pour afficher une fourniture
  Widget _buildSupplyItem(SupplyItemUI supply) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            supply.name,
            style: GoogleFonts.roboto(color: Colors.white70),
          ),
          GestureDetector(
            onTap: () => onDeleteSupply(supply),
            child: Icon(
              Icons.delete,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Widget générique pour un bouton d'action
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
