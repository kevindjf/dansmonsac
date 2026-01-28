import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:sharing/sharing.dart';
import 'package:onboarding/src/presentation/week_explanation/week_explanation_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'variants/import_variant_1.dart';
import 'variants/import_variant_2.dart';
import 'variants/import_variant_3.dart';

/// Page wrapper permettant de switcher entre les variantes de design
/// Utilise un FAB pour changer de variante en temps reel
///
/// TODO: Supprimer ce fichier une fois la variante choisie
class ImportPageWithVariants extends ConsumerStatefulWidget {
  static const String routeName = "/onboarding-import";

  final bool showBackArrow;
  final VoidCallback? onImportComplete;

  const ImportPageWithVariants({
    super.key,
    this.showBackArrow = false,
    this.onImportComplete,
  });

  @override
  ConsumerState<ImportPageWithVariants> createState() => _ImportPageWithVariantsState();
}

class _ImportPageWithVariantsState extends ConsumerState<ImportPageWithVariants> {
  int _currentVariant = 0;
  bool _isLoading = false;
  String? _errorMessage;

  static const _variantNames = [
    "V1: Screenshot",
    "V2: Minimal",
    "V3: Tabs",
  ];

  bool get _isFromSettings => widget.showBackArrow;

  void _nextVariant() {
    setState(() {
      _currentVariant = (_currentVariant + 1) % 3;
    });
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
                    ref.read(routerDelegateProvider).setRoute(OnboardingWeekExplanationPage.routeName);
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      onDetect: (capture) {
                        for (final barcode in capture.barcodes) {
                          final code = _extractCodeFromBarcode(barcode.rawValue);
                          if (code != null) {
                            Navigator.of(scannerContext).pop();
                            _handleImport(code);
                            return;
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
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

    final deepLinkMatch = RegExp(r'dansmonsac://share/([A-Za-z0-9]{6})', caseSensitive: false).firstMatch(rawValue);
    if (deepLinkMatch != null) {
      return deepLinkMatch.group(1)!.toUpperCase();
    }

    final normalized = rawValue.toUpperCase().trim();
    if (CodeGenerator.isValid(normalized)) {
      return normalized;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Stack(
      children: [
        // Current variant
        _buildCurrentVariant(),

        // FAB to switch variants
        Positioned(
          bottom: 100,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Variant name badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _variantNames[_currentVariant],
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // FAB
              FloatingActionButton(
                onPressed: _nextVariant,
                backgroundColor: accentColor,
                child: const Icon(Icons.swap_horiz, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentVariant() {
    switch (_currentVariant) {
      case 0:
        return ImportVariant1(
          showBackArrow: _isFromSettings,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onScanQrCode: _openQrScanner,
          onCodeComplete: _handleImport,
          onSkip: _isFromSettings ? null : _skipImport,
        );
      case 1:
        return ImportVariant2(
          showBackArrow: _isFromSettings,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onScanQrCode: _openQrScanner,
          onCodeComplete: _handleImport,
          onSkip: _isFromSettings ? null : _skipImport,
        );
      case 2:
        return ImportVariant3(
          showBackArrow: _isFromSettings,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onCodeComplete: _handleImport,
          onSkip: _isFromSettings ? null : _skipImport,
        );
      default:
        return ImportVariant1(
          showBackArrow: _isFromSettings,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onScanQrCode: _openQrScanner,
          onCodeComplete: _handleImport,
          onSkip: _isFromSettings ? null : _skipImport,
        );
    }
  }
}
