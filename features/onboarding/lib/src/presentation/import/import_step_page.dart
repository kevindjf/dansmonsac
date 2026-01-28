import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    Key? key,
    this.showBackArrow = false,
    this.onImportComplete,
  }) : super(key: key);

  @override
  ConsumerState<OnboardingImportStepPage> createState() =>
      _OnboardingImportStepPageState();
}

class _OnboardingImportStepPageState
    extends ConsumerState<OnboardingImportStepPage> {
  final GlobalKey<CodeInputWidgetState> _codeInputKey = GlobalKey<CodeInputWidgetState>();
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isFromSettings => widget.showBackArrow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.secondary;

    return Scaffold(
      appBar: _isFromSettings
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        top: !_isFromSettings,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_isFromSettings) const SizedBox(height: 48),

                // Icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people,
                    size: 80,
                    color: accentColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  "Un ami a deja DansMonSac ?",
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  "Tu peux importer son emploi du temps avec son code de partage",
                  style: textTheme.titleLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Code input widget
                CodeInputWidget(
                  key: _codeInputKey,
                  enabled: !_isLoading,
                  onScanQrCode: _isLoading ? null : _openQrScanner,
                  onCodeComplete: (code) {
                    _handleImport(code);
                  },
                  onCodeChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // Import button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _onImportPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Importer l'emploi du temps",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                if (!_isFromSettings) ...[
                  const SizedBox(height: 16),

                  // Skip button (onboarding only)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isLoading ? null : _skipImport,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Je n'ai pas de code",
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 48),

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

  void _onImportPressed() {
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

    // Navigate to import preview page as a full screen page
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
                    // Onboarding flow: go to week explanation page
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
    ref.read(routerDelegateProvider).setRoute(OnboardingWeekExplanationPage.routeName);
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
                          final code = _extractCodeFromBarcode(barcode.rawValue);
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
    final deepLinkMatch = RegExp(r'dansmonsac://share/([A-Za-z0-9]{6})', caseSensitive: false).firstMatch(rawValue);
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
