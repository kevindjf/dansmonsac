import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controller/import_controller.dart';
import 'import_conflict_dialog.dart';

class ImportPreviewPage extends ConsumerWidget {
  final String code;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const ImportPreviewPage({
    super.key,
    required this.code,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importControllerProvider(code));
    final accentColor = Theme.of(context).colorScheme.secondary;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (state.isLoading) ...[
              const SizedBox(height: 40),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              Text(
                'Chargement...',
                style: GoogleFonts.roboto(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ] else if (state.hasError) ...[
              // Error state
              Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ] else if (state.result != null) ...[
              // Success state
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Import termine !',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildResultStats(state.result!, accentColor),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (onComplete != null) {
                    onComplete!();
                  } else {
                    Navigator.of(context).pop(true);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continuer'),
              ),
            ] else if (state.isResolvingConflicts) ...[
              // Conflict resolution
              ImportConflictDialog(
                conflict: state.currentConflict!,
                currentIndex: state.currentConflictIndex + 1,
                totalConflicts: state.pendingConflicts.length,
                onResolution: (resolution) {
                  ref.read(importControllerProvider(code).notifier).resolveConflict(resolution);
                },
              ),
            ] else if (state.hasSchedule) ...[
              // Preview state
              Icon(
                Icons.download,
                size: 64,
                color: accentColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Importer l\'emploi du temps',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.schedule!.sharerName != null
                    ? 'de ${state.schedule!.sharerName}'
                    : 'd\'un ami',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: accentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Stats
              _buildPreviewStats(state, accentColor),
              const SizedBox(height: 24),

              // Buttons
              FilledButton(
                onPressed: state.isImporting
                    ? null
                    : () => ref.read(importControllerProvider(code).notifier).startImport(),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isImporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Importer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.isImporting
                    ? null
                    : (onCancel ?? () => Navigator.of(context).pop()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Annuler'),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStats(dynamic state, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildStatRow(Icons.book, '${state.courseCount} cours', accentColor),
          const Divider(color: Colors.white12, height: 24),
          _buildStatRow(Icons.calendar_today, '${state.calendarCount} seances', accentColor),
          const Divider(color: Colors.white12, height: 24),
          _buildStatRow(Icons.backpack, '${state.supplyCount} fournitures', accentColor),
        ],
      ),
    );
  }

  Widget _buildResultStats(dynamic result, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.createdCourses.isNotEmpty)
            _buildStatRow(
              Icons.add_circle,
              '${result.createdCourses.length} cours crees',
              Colors.green,
            ),
          if (result.skippedCourses.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildStatRow(
              Icons.skip_next,
              '${result.skippedCourses.length} cours ignores (deja existants)',
              Colors.orange,
            ),
          ],
          if (result.calendarEntriesImported > 0) ...[
            const SizedBox(height: 8),
            _buildStatRow(
              Icons.calendar_today,
              '${result.calendarEntriesImported} seances importees',
              accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
