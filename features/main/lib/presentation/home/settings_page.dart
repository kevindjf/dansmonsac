import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/ui/ui.dart';
import 'package:common/src/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dansmonsac/providers/accent_color_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  TimeOfDay _packTime = TimeOfDay(hour: 19, minute: 0);
  DateTime _schoolYearStart = DateTime(2024, 9, 2);
  bool _notificationsEnabled = false;
  Color _accentColor = const Color(0xFF9C27B0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final packTime = await PreferencesService.getPackTime();
    final schoolYearStart = await PreferencesService.getSchoolYearStart();
    final notificationsEnabled = await PreferencesService.getNotificationsEnabled();
    final accentColor = await PreferencesService.getAccentColor();

    setState(() {
      _packTime = packTime;
      _schoolYearStart = schoolYearStart;
      _notificationsEnabled = notificationsEnabled;
      _accentColor = accentColor;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF212121),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF212121),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Color(0xFF303030),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Paramètres",
                      style: GoogleFonts.robotoCondensed(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Personnalisez votre expérience",
                      style: GoogleFonts.roboto(
                        color: Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Section: Préparation du sac
                  _buildSectionTitle('Préparation du sac', context),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.access_time,
                    title: 'Heure de préparation',
                    subtitle: 'Quand préparez-vous votre sac ?',
                    value: _formatTime(_packTime),
                    onTap: () => _selectPackTime(context),
                  ),

                  _buildSwitchCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications de rappel',
                    subtitle: 'Recevoir un rappel quotidien',
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),

                  const SizedBox(height: 24),

                  // Section: Apparence
                  _buildSectionTitle('Apparence', context),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.palette_outlined,
                    title: 'Couleur d\'accent',
                    subtitle: 'Personnalisez votre thème',
                    value: '',
                    onTap: () => _selectAccentColor(context),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section: Année scolaire
                  _buildSectionTitle('Année scolaire', context),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.calendar_today,
                    title: 'Début d\'année scolaire',
                    subtitle: 'Date de la première semaine A',
                    value: _formatDate(_schoolYearStart),
                    onTap: () => _selectSchoolYearStart(context),
                  ),

                  const SizedBox(height: 24),

                  // Section: À propos
                  _buildSectionTitle('À propos', context),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: 'DansMonSac',
                    value: '1.0.0',
                    onTap: null,
                  ),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Aide',
                    subtitle: 'Besoin d\'assistance ?',
                    value: '',
                    onTap: () {
                      // TODO: Open help page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.robotoCondensed(
          fontSize: 14,
          color: accentColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Card(
      color: Color(0xFF303030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Custom trailing or default value/arrow
              if (trailing != null)
                trailing
              else ...[
                // Value
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: GoogleFonts.roboto(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                // Arrow icon if tappable
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                    size: 24,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectPackTime(BuildContext context) async {
    final accentColor = Theme.of(context).colorScheme.secondary;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _packTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: Color(0xFF303030),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _packTime) {
      setState(() {
        _packTime = picked;
      });
      await PreferencesService.setPackTime(picked);
      await NotificationService.updateNotificationIfEnabled();
      _showSnackBar('Heure de préparation mise à jour: ${_formatTime(picked)}');
    }
  }

  Future<void> _selectSchoolYearStart(BuildContext context) async {
    final accentColor = Theme.of(context).colorScheme.secondary;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _schoolYearStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: Color(0xFF303030),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _schoolYearStart) {
      setState(() {
        _schoolYearStart = picked;
      });
      await PreferencesService.setSchoolYearStart(picked);
      _showSnackBar('Date de début mise à jour: ${_formatDate(picked)}');
    }
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Card(
      color: Color(0xFF303030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        color: Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() {
      _notificationsEnabled = enabled;
    });

    await PreferencesService.setNotificationsEnabled(enabled);

    if (enabled) {
      // Request permissions
      final granted = await NotificationService.requestPermissions();
      if (granted) {
        await NotificationService.scheduleDailyNotification();
        _showSnackBar('Notifications activées à ${_formatTime(_packTime)}');
      } else {
        // Permission denied, revert the switch
        setState(() {
          _notificationsEnabled = false;
        });
        await PreferencesService.setNotificationsEnabled(false);
        _showSnackBar('Permission de notification refusée');
      }
    } else {
      await NotificationService.cancelNotification();
      _showSnackBar('Notifications désactivées');
    }
  }

  Future<void> _selectAccentColor(BuildContext context) async {
    final accentColor = Theme.of(context).colorScheme.secondary;
    Color? pickedColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF303030),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Choisir une couleur',
            style: GoogleFonts.robotoCondensed(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _accentColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              labelTypes: const [],
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
              },
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Confirmer',
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

    if (pickedColor != null && pickedColor != _accentColor) {
      setState(() {
        _accentColor = pickedColor!;
      });
      // Update color via provider for instant app-wide update
      await ref.read(accentColorProvider.notifier).updateColor(pickedColor!);
      _showSnackBar('Couleur mise à jour !');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF303030),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
