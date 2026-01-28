import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/deep_link_service.dart';
import 'controller/share_controller.dart';

class SharePage extends ConsumerStatefulWidget {
  const SharePage({super.key});

  @override
  ConsumerState<SharePage> createState() => _SharePageState();
}

class _SharePageState extends ConsumerState<SharePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _nameInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shareControllerProvider);

    // Initialize name controller with saved name (only once after loading)
    if (!_nameInitialized && !state.isLoading && state.sharerName.isNotEmpty) {
      _nameController.text = state.sharerName;
      _nameInitialized = true;
    }
    final accentColor = Theme.of(context).colorScheme.secondary;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Stack(
      children: [
        Container(
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

            // Title
            Text(
              'Partager ton emploi du temps',
              style: GoogleFonts.robotoCondensed(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Genere un code pour partager ton emploi du temps avec un ami',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (state.isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (state.courseCount == 0) ...[
              // Empty state - no courses to share
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rien a partager pour le moment',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoute d\'abord des matieres dans l\'onglet "Cours", puis renseigne ton emploi du temps dans l\'onglet "Calendrier".',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Compris',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!state.hasCode) ...[
              // Name input
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Ton prenom (optionnel)',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'Ex: Marie',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                ),
                onChanged: (value) {
                  ref.read(shareControllerProvider.notifier).updateSharerName(value);
                },
              ),
              const SizedBox(height: 24),

              // Stats
              _buildStatsRow(state, accentColor),
              const SizedBox(height: 24),

              // Generate button
              FilledButton(
                onPressed: state.isGenerating
                    ? null
                    : () => ref.read(shareControllerProvider.notifier).generateCode(),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Generer un code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ] else ...[
              // Name input (editable even after code is generated)
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Ton prenom (optionnel)',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'Ex: Marie',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                ),
                onChanged: (value) {
                  ref.read(shareControllerProvider.notifier).updateSharerName(value);
                },
              ),
              const SizedBox(height: 24),

              // QR Code
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: DeepLinkService.buildShareLink(state.code!),
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Code display
              GestureDetector(
                onTap: () => _copyCode(state.code!),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        state.code!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Appuie pour copier',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              _buildStatsRow(state, accentColor),
              const SizedBox(height: 24),

              // Sync warning if sync failed
              if (state.syncFailed) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Les donnees ne sont peut-etre pas a jour',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Sync button
                OutlinedButton.icon(
                  onPressed: state.isSyncing
                      ? null
                      : () => ref.read(shareControllerProvider.notifier).syncData(),
                  icon: const Icon(Icons.sync),
                  label: const Text('Synchroniser les donnees'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Share button
              FilledButton.icon(
                onPressed: state.isSyncing ? null : () => _shareLink(state.code!),
                icon: const Icon(Icons.share),
                label: const Text(
                  'Partager le lien',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            if (state.hasError && !state.syncFailed) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
        ),
        // Syncing overlay
        if (state.isSyncing)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF303030),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Synchronisation en cours...',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow(dynamic state, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ce qui sera partage:',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(Icons.book, '${state.courseCount} cours', accentColor),
              const SizedBox(width: 16),
              _buildStatItem(Icons.calendar_today, '${state.calendarCount} seances', accentColor),
              const SizedBox(width: 16),
              _buildStatItem(Icons.backpack, '${state.supplyCount} fournitures', accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color accentColor) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.white54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copie: $code'),
        backgroundColor: const Color(0xFF303030),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareLink(String code) async {
    // Sync data with Supabase before sharing
    final success = await ref.read(shareControllerProvider.notifier).syncAndShare();

    if (!success) {
      // Error is already set in state by the controller
      return;
    }

    final state = ref.read(shareControllerProvider);
    final sharerName = state.sharerName;
    final hasName = sharerName.isNotEmpty;

    final message = '''
${hasName ? '$sharerName partage' : 'Je partage'} mon emploi du temps avec toi !

Code : $code

1. Telecharge DansMonSac :
   iOS : https://apps.apple.com/app/dansmonsac/id123456789
   Android : https://play.google.com/store/apps/details?id=com.dansmonsac

2. Ouvre l'app et entre le code $code dans l'ecran d'import
''';
    Share.share(message);
  }
}
