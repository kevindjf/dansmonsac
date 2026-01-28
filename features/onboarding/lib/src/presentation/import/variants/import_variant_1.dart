import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharing/sharing.dart';

/// Variante 1: Design fidele au screenshot
/// - Carte cliquable pour scanner QR
/// - Separateur "OU"
/// - Boites de code individuelles avec label
/// - Bouton "VERIFIER LE CODE"
/// - Info card en bas
class ImportVariant1 extends StatefulWidget {
  final bool showBackArrow;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onScanQrCode;
  final ValueChanged<String> onCodeComplete;
  final VoidCallback? onSkip;

  const ImportVariant1({
    super.key,
    this.showBackArrow = false,
    this.isLoading = false,
    this.errorMessage,
    this.onScanQrCode,
    required this.onCodeComplete,
    this.onSkip,
  });

  @override
  State<ImportVariant1> createState() => _ImportVariant1State();
}

class _ImportVariant1State extends State<ImportVariant1> {
  final GlobalKey<CodeInputWidgetState> _codeInputKey = GlobalKey<CodeInputWidgetState>();

  void _onVerifyPressed() {
    final code = _codeInputKey.currentState?.getCode() ?? '';
    if (code.length == 6 && CodeGenerator.isValid(code)) {
      widget.onCodeComplete(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: widget.showBackArrow
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        top: !widget.showBackArrow,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!widget.showBackArrow) const SizedBox(height: 48),

                // Title
                Text(
                  "UN AMI A DEJA DANS MON SAC ?",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "TU PEUX IMPORTER SON EMPLOI DU TEMPS AVEC SON CODE DE PARTAGE",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white60,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // QR Scanner Card
                _buildQrScannerCard(accentColor),

                const SizedBox(height: 24),

                // "OU" Separator
                _buildSeparator(),

                const SizedBox(height: 24),

                // Code entry section
                Text(
                  "ENTRER LE CODE DE PARTAGE",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 16),

                // Code boxes (without QR button, we have the card above)
                _buildCodeBoxes(accentColor),

                if (widget.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // Verify button
                _buildVerifyButton(accentColor),

                if (widget.onSkip != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.isLoading ? null : widget.onSkip,
                    child: Text(
                      "Je n'ai pas de code",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Info card
                _buildInfoCard(accentColor),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrScannerCard(Color accentColor) {
    return InkWell(
      onTap: widget.isLoading ? null : widget.onScanQrCode,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            // QR Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_2,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SCANNER QR CODE",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "AUTOMATIQUE",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward,
              color: accentColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white24, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OU",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white24, thickness: 1)),
      ],
    );
  }

  Widget _buildCodeBoxes(Color accentColor) {
    return CodeInputWidget(
      key: _codeInputKey,
      enabled: !widget.isLoading,
      onScanQrCode: null, // No QR button here, we have the card
      onCodeComplete: widget.onCodeComplete,
    );
  }

  Widget _buildVerifyButton(Color accentColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _onVerifyPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A3A3A),
          foregroundColor: Colors.white54,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              )
            : Text(
                "VERIFIER LE CODE",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: "DEMANDE A TON AMI D'OUVRIR L'APP ET D'ALLER DANS "),
                  TextSpan(
                    text: "PARAMETRES > PARTAGER",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " POUR OBTENIR UN CODE,"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
