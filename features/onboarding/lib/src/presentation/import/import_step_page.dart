import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:sharing/sharing.dart';
import 'package:onboarding/src/presentation/week_explanation/week_explanation_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class OnboardingImportStepPage extends ConsumerStatefulWidget {
  static const String routeName = "/onboarding-import";

  /// Whether to show a back arrow (true when coming from settings)
  final bool showBackArrow;

  /// Called after a successful import. If null, uses the onboarding flow.
  final VoidCallback? onImportComplete;

  const OnboardingImportStepPage({
    super.key,
    this.showBackArrow = false,
    this.onImportComplete,
  });

  @override
  ConsumerState<OnboardingImportStepPage> createState() =>
      _OnboardingImportStepPageState();
}

class _OnboardingImportStepPageState
    extends ConsumerState<OnboardingImportStepPage> {
  final GlobalKey<CodeInputWidgetState> _codeInputKey =
      GlobalKey<CodeInputWidgetState>();
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isFromSettings => widget.showBackArrow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: _isFromSettings
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
        top: !_isFromSettings,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_isFromSettings) const SizedBox(height: 48),

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

                // Code boxes
                CodeInputWidget(
                  key: _codeInputKey,
                  enabled: !_isLoading,
                  onScanQrCode:
                      null, // No QR button here, we have the card above
                  onCodeComplete: _handleImport,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // Verify button
                _buildVerifyButton(accentColor),

                if (!_isFromSettings) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : _skipImport,
                    child: const Text(
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Demande a ton ami d'ouvrir l'app et d'aller dans Parametres > Partager pour obtenir un code",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrScannerCard(Color accentColor) {
    return InkWell(
      onTap: _isLoading ? null : _openQrScanner,
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
        const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
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
        const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
      ],
    );
  }

  Widget _buildVerifyButton(Color accentColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onVerifyPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A3A3A),
          foregroundColor: Colors.white54,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                      text:
                          "DEMANDE A TON AMI D'OUVRIR L'APP ET D'ALLER DANS "),
                  TextSpan(
                    text: "PARAMETRES > PARTAGER",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: " POUR OBTENIR UN CODE."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onVerifyPressed() {
    final code = _codeInputKey.currentState?.getCode() ?? '';
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Le code doit contenir 6 caracteres';
      });
      return;
    }

    if (!CodeGenerator.isValid(code)) {
      setState(() {
        _errorMessage = 'Code invalide. Verifie les caracteres.';
      });
      return;
    }

    _handleImport(code);
  }

  Future<void> _handleImport(String code) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: const Color(0xFF212121),
            body: SafeArea(
              child: ImportPreviewPage(
                code: code,
                onComplete: () {
                  Navigator.of(context).pop();
                  if (widget.onImportComplete != null) {
                    widget.onImportComplete!();
                  } else {
                    ref
                        .read(routerDelegateProvider)
                        .setRoute(OnboardingWeekExplanationPage.routeName);
                  }
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _skipImport() {
    ref
        .read(routerDelegateProvider)
        .setRoute(OnboardingWeekExplanationPage.routeName);
  }

  void _openQrScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF303030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (scannerContext) {
        final bottomPadding = MediaQuery.of(scannerContext).viewPadding.bottom;
        return SizedBox(
          height: MediaQuery.of(scannerContext).size.height * 0.7,
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scanner le QR code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Scanner
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      onDetect: (capture) {
                        final barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final code =
                              _extractCodeFromBarcode(barcode.rawValue);
                          if (code != null) {
                            Navigator.of(scannerContext).pop();
                            _codeInputKey.currentState?.setCode(code);
                            _handleImport(code);
                            return;
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              // Cancel button
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + bottomPadding,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(scannerContext).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _extractCodeFromBarcode(String? rawValue) {
    if (rawValue == null) return null;

    // Check if it's a deep link (dansmonsac://share/CODE)
    final deepLinkMatch =
        RegExp(r'dansmonsac://share/([A-Za-z0-9]{6})', caseSensitive: false)
            .firstMatch(rawValue);
    if (deepLinkMatch != null) {
      return deepLinkMatch.group(1)!.toUpperCase();
    }

    // Check if it's a valid 6-character code
    final normalized = rawValue.toUpperCase().trim();
    if (CodeGenerator.isValid(normalized)) {
      return normalized;
    }

    return null;
  }
}

/// Separate StatefulWidget for QR Scanner to properly manage the controller lifecycle
class _QrScannerSheet extends StatefulWidget {
  final void Function(String code) onCodeDetected;
  final String? Function(String? rawValue) extractCode;

  const _QrScannerSheet({
    required this.onCodeDetected,
    required this.extractCode,
  });

  @override
  State<_QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<_QrScannerSheet> {
  late MobileScannerController _controller;
  bool _hasDetected = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;

    for (final barcode in capture.barcodes) {
      final code = widget.extractCode(barcode.rawValue);
      if (code != null) {
        _hasDetected = true;
        widget.onCodeDetected(code);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scanner le QR code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Scanner
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),
          // Cancel button
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + bottomPadding,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Annuler'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
