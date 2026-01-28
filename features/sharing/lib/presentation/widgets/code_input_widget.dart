import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/code_generator.dart';

/// Widget for entering a 6-character share code with individual boxes (like Epic Games)
/// Only allows valid characters (A-Z, 2-9 excluding 0, 1, I, O)
class CodeInputWidget extends StatefulWidget {
  /// Callback when the complete code is entered (6 characters)
  final ValueChanged<String>? onCodeComplete;

  /// Callback when the code changes
  final ValueChanged<String>? onCodeChanged;

  /// Callback to open QR scanner
  final VoidCallback? onScanQrCode;

  /// Initial code value
  final String? initialCode;

  /// Whether the widget is enabled
  final bool enabled;

  const CodeInputWidget({
    super.key,
    this.onCodeComplete,
    this.onCodeChanged,
    this.onScanQrCode,
    this.initialCode,
    this.enabled = true,
  });

  @override
  State<CodeInputWidget> createState() => CodeInputWidgetState();
}

class CodeInputWidgetState extends State<CodeInputWidget> {
  static const int _codeLength = 6;
  // Valid characters (same as CodeGenerator)
  static const String _validChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes
    for (int i = 0; i < _codeLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    // Set initial code if provided
    if (widget.initialCode != null) {
      setCode(widget.initialCode!);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Get the current code
  String getCode() {
    return _controllers.map((c) => c.text).join();
  }

  /// Set the code programmatically
  void setCode(String code) {
    final normalized = code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    for (int i = 0; i < _codeLength; i++) {
      if (i < normalized.length) {
        final char = normalized[i];
        // Convert invalid characters to closest valid ones
        _controllers[i].text = _normalizeChar(char);
      } else {
        _controllers[i].text = '';
      }
    }
    _notifyCodeChanged();
  }

  /// Clear the code
  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _notifyCodeChanged();
  }

  /// Normalize a character to a valid one
  String _normalizeChar(String char) {
    final upper = char.toUpperCase();
    // Map common mistakes
    if (upper == '0') return 'Q'; // 0 looks like O, map to Q
    if (upper == '1') return 'L'; // 1 looks like I/L
    if (upper == 'I') return 'J'; // I looks like 1
    if (upper == 'O') return 'Q'; // O looks like 0

    if (_validChars.contains(upper)) {
      return upper;
    }
    return ''; // Invalid character
  }

  void _onCharacterEntered(int index, String value) {
    if (value.isEmpty) {
      // Handle backspace - move to previous field
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      _notifyCodeChanged();
      return;
    }

    // Take only the last character if multiple were entered (paste)
    String char = value.length > 1 ? value[value.length - 1] : value;
    char = _normalizeChar(char);

    if (char.isEmpty) {
      // Invalid character, clear this field
      _controllers[index].clear();
      return;
    }

    // Set the character
    _controllers[index].text = char;

    // Move to next field
    if (index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      // Last field, unfocus
      _focusNodes[index].unfocus();
    }

    _notifyCodeChanged();
  }

  void _notifyCodeChanged() {
    final code = getCode();
    widget.onCodeChanged?.call(code);

    if (code.length == _codeLength && CodeGenerator.isValid(code)) {
      widget.onCodeComplete?.call(code);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // Move to previous field on backspace when current is empty
          _controllers[index - 1].clear();
          _focusNodes[index - 1].requestFocus();
          _notifyCodeChanged();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Code input boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Scanner button
            if (widget.onScanQrCode != null) ...[
              IconButton(
                onPressed: widget.enabled ? widget.onScanQrCode : null,
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: widget.enabled ? accentColor : Colors.white24,
                  size: 28,
                ),
                tooltip: 'Scanner un QR code',
              ),
              const SizedBox(width: 8),
            ],
            // Code boxes
            for (int i = 0; i < _codeLength; i++) ...[
              _buildCodeBox(i, accentColor),
              if (i < _codeLength - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCodeBox(int index, Color accentColor) {
    return SizedBox(
      width: 44,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          maxLength: 1,
          style: GoogleFonts.robotoMono(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: _focusNodes[index].hasFocus
                ? accentColor.withValues(alpha: 0.2)
                : Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _controllers[index].text.isNotEmpty
                    ? accentColor.withValues(alpha: 0.5)
                    : Colors.white24,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white12,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            UpperCaseTextFormatter(),
          ],
          onChanged: (value) => _onCharacterEntered(index, value),
          onTap: () {
            // Select all text when tapping
            _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index].text.length,
            );
          },
        ),
      ),
    );
  }
}

/// Text formatter that converts input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
