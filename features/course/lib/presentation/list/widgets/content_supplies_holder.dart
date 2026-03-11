import 'package:common/src/utils/validators.dart';
import 'package:course/presentation/list/controller/course_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentSupplyHolder extends ConsumerWidget {
  final List<SupplyItemUI> supplies;
  final String courseName;
  final VoidCallback onAddSupply;
  final ValueChanged<SupplyItemUI> onDeleteSupply;
  final VoidCallback onDeleteCourse;
  final ValueChanged<String> onRenameCourse;
  final void Function(SupplyItemUI supply, String newName) onRenameSupply;

  const ContentSupplyHolder({
    super.key,
    required this.supplies,
    required this.courseName,
    required this.onAddSupply,
    required this.onDeleteSupply,
    required this.onDeleteCourse,
    required this.onRenameCourse,
    required this.onRenameSupply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Liste des fournitures
        ...supplies.map((supply) => _buildSupplyItem(supply, context)),
        const SizedBox(height: 16),

        // Bouton pour ajouter une fourniture
        _buildActionButton(
          icon: Icons.add,
          label: "Ajouter une fourniture",
          onPressed: onAddSupply,
        ),

        const SizedBox(height: 4),

        // Bouton pour modifier le nom du cours
        _buildActionButton(
          icon: Icons.edit,
          label: "Modifier le nom",
          onPressed: () => _showRenameBottomSheet(context),
          backgroundColor: Colors.transparent,
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
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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

  void _showRenameBottomSheet(BuildContext context) {
    final controller = TextEditingController(text: courseName);

    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final bottomSafeArea = MediaQuery.of(sheetContext).viewPadding.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                bottomSafeArea +
                16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Modifier le nom",
                style: GoogleFonts.robotoCondensed(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(sheetContext).colorScheme.primary),
                  ),
                  labelText: "Nom du cours",
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(sheetContext).pop(value.trim());
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      Navigator.of(sheetContext).pop(newName);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Modifier",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((newName) {
      if (newName != null && newName.isNotEmpty && newName != courseName) {
        onRenameCourse(newName);
      }
    });
  }

  Widget _buildSupplyItem(SupplyItemUI supply, BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showRenameSupplyBottomSheet(context, supply),
              child: Text(
                supply.name,
                style: GoogleFonts.roboto(color: Colors.white70),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showRenameSupplyBottomSheet(context, supply),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.edit, color: accentColor, size: 20),
                ),
              ),
              GestureDetector(
                onTap: () => onDeleteSupply(supply),
                child: Icon(Icons.delete, color: accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRenameSupplyBottomSheet(BuildContext context, SupplyItemUI supply) {
    final controller = TextEditingController(text: supply.name);
    String? errorText;

    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final bottomSafeArea = MediaQuery.of(sheetContext).viewPadding.bottom;
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                    bottomSafeArea +
                    16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Renommer la fourniture",
                    style: GoogleFonts.robotoCondensed(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      labelText: "Nom de la fourniture",
                      labelStyle: const TextStyle(color: Colors.grey),
                      errorText: errorText,
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() => errorText = null);
                      }
                    },
                    onSubmitted: (value) {
                      final validation = Validators.validateSupplyName(value);
                      if (validation != null) {
                        setState(() => errorText = validation);
                        return;
                      }
                      Navigator.of(sheetContext).pop(value.trim());
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final newName = controller.text.trim();
                        final validation =
                            Validators.validateSupplyName(newName);
                        if (validation != null) {
                          setState(() => errorText = validation);
                          return;
                        }
                        Navigator.of(sheetContext).pop(newName);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Renommer",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((newName) {
      if (newName != null && newName.isNotEmpty && newName != supply.name) {
        onRenameSupply(supply, newName);
      }
    });
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
