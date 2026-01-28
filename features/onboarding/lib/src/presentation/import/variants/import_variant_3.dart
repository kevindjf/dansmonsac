import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sharing/sharing.dart';

/// Variante 3: Design avec tabs QR/Code
/// - Tabs pour switcher entre scanner et saisie manuelle
/// - Scanner integre dans la page (pas en bottom sheet)
/// - Experience plus fluide
class ImportVariant3 extends StatefulWidget {
  final bool showBackArrow;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onCodeComplete;
  final VoidCallback? onSkip;

  const ImportVariant3({
    super.key,
    this.showBackArrow = false,
    this.isLoading = false,
    this.errorMessage,
    required this.onCodeComplete,
    this.onSkip,
  });

  @override
  State<ImportVariant3> createState() => _ImportVariant3State();
}

class _ImportVariant3State extends State<ImportVariant3> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<CodeInputWidgetState> _codeInputKey = GlobalKey<CodeInputWidgetState>();
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    final code = _codeInputKey.currentState?.getCode() ?? '';
    if (code.length == 6 && CodeGenerator.isValid(code)) {
      widget.onCodeComplete(code);
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackArrow
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          "Importer",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelColor: accentColor,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(
              icon: Icon(Icons.qr_code_scanner),
              text: "Scanner",
            ),
            Tab(
              icon: Icon(Icons.keyboard),
              text: "Code",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Scanner
          _buildScannerTab(accentColor),
          // Tab 2: Manual code entry
          _buildCodeTab(accentColor),
        ],
      ),
    );
  }

  Widget _buildScannerTab(Color accentColor) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),

          Text(
            "Pointe la camera vers le QR code",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Scanner area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    MobileScanner(
                      onDetect: (capture) {
                        if (_scanned || widget.isLoading) return;

                        for (final barcode in capture.barcodes) {
                          final code = _extractCodeFromBarcode(barcode.rawValue);
                          if (code != null) {
                            setState(() => _scanned = true);
                            widget.onCodeComplete(code);
                            return;
                          }
                        }
                      },
                    ),
                    // Overlay with corners
                    CustomPaint(
                      painter: _ScannerOverlayPainter(accentColor),
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: accentColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ton ami peut generer un QR code dans Parametres > Partager",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.onSkip != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                "Passer",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCodeTab(Color accentColor) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.dialpad,
                  size: 48,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Entre le code a 6 caracteres",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "Demande le code a ton ami",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Code input
              CodeInputWidget(
                key: _codeInputKey,
                enabled: !widget.isLoading,
                onScanQrCode: null,
                onCodeComplete: widget.onCodeComplete,
              ),

              if (widget.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.isLoading ? null : _onVerifyPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                          "Importer",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              if (widget.onSkip != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    "Passer cette etape",
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter for scanner overlay with corner markers
class _ScannerOverlayPainter extends CustomPainter {
  final Color color;

  _ScannerOverlayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const padding = 40.0;

    final rect = Rect.fromLTWH(padding, padding, size.width - padding * 2, size.height - padding * 2);

    // Top-left corner
    canvas.drawLine(Offset(rect.left, rect.top + cornerLength), Offset(rect.left, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cornerLength, rect.top), paint);

    // Top-right corner
    canvas.drawLine(Offset(rect.right - cornerLength, rect.top), Offset(rect.right, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + cornerLength), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLength), Offset(rect.left, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cornerLength, rect.bottom), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(rect.right - cornerLength, rect.bottom), Offset(rect.right, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
