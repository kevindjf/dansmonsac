import 'package:flutter/material.dart';
import 'package:sharing/sharing.dart';

/// Variante 2: Design minimaliste / epure
/// - Titre simple et elegant
/// - Gros bouton QR central
/// - Code input en dessous
/// - Moins d'elements visuels
class ImportVariant2 extends StatefulWidget {
  final bool showBackArrow;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onScanQrCode;
  final ValueChanged<String> onCodeComplete;
  final VoidCallback? onSkip;

  const ImportVariant2({
    super.key,
    this.showBackArrow = false,
    this.isLoading = false,
    this.errorMessage,
    this.onScanQrCode,
    required this.onCodeComplete,
    this.onSkip,
  });

  @override
  State<ImportVariant2> createState() => _ImportVariant2State();
}

class _ImportVariant2State extends State<ImportVariant2> {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Title - simple and elegant
              Text(
                "Importer un emploi du temps",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "Scanne le QR code ou entre le code",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),

              // Big QR button - center focus
              GestureDetector(
                onTap: widget.isLoading ? null : widget.onScanQrCode,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: accentColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Scanner",
                style: TextStyle(
                  fontSize: 14,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 1),

              // Divider with "ou"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "ou",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white12)),
                ],
              ),

              const SizedBox(height: 32),

              // Code input - clean
              CodeInputWidget(
                key: _codeInputKey,
                enabled: !widget.isLoading,
                onScanQrCode: null,
                onCodeComplete: widget.onCodeComplete,
              ),

              if (widget.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              // Simple verify button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.isLoading ? null : _onVerifyPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Verifier",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const Spacer(flex: 2),

              // Skip option
              if (widget.onSkip != null)
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onSkip,
                  child: Text(
                    "Passer cette etape",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
