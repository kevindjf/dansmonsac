import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/services.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:common/src/providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sharing/sharing.dart';
import 'package:onboarding/onboarding.dart';
import 'package:schedule/di/riverpod_di.dart';
import 'package:streak/di/riverpod_di.dart';
import 'help_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  TimeOfDay _packTime = TimeOfDay(hour: 19, minute: 0);
  DateTime _schoolYearStart = DateTime(2024, 9, 2);
  bool _notificationsEnabled = false;
  Color _accentColor = const Color.fromARGB(255, 212, 53, 240);
  bool _showWeekend = true;
  bool _isLoading = true;
  bool _vacationModeEnabled = false;
  DateTime? _vacationEndDate;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final packTime = await PreferencesService.getPackTime();
    final schoolYearStart = await PreferencesService.getSchoolYearStart();
    final notificationsEnabled =
        await PreferencesService.getNotificationsEnabled();
    final accentColor = await PreferencesService.getAccentColor();
    final showWeekend = await PreferencesService.getShowWeekend();
    final vacationModeEnabled = await PreferencesService.isVacationModeActive();
    final vacationEndDate = await PreferencesService.getVacationModeEndDate();

    setState(() {
      _packTime = packTime;
      _schoolYearStart = schoolYearStart;
      _notificationsEnabled = notificationsEnabled;
      _accentColor = accentColor;
      _showWeekend = showWeekend;
      _vacationModeEnabled = vacationModeEnabled;
      _vacationEndDate = vacationEndDate;
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

                  _buildVacationModeCard(context),

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

                  _buildSwitchCard(
                    icon: Icons.weekend_outlined,
                    title: 'Afficher le weekend',
                    subtitle: 'Samedi et dimanche dans le calendrier',
                    value: _showWeekend,
                    onChanged: _toggleShowWeekend,
                  ),

                  _buildBackgroundImageCard(context),

                  const SizedBox(height: 24),

                  // Section: Année scolaire
                  _buildSectionTitle('Année scolaire', context),
                  const SizedBox(height: 8),

                  _buildSchoolYearCard(context),

                  const SizedBox(height: 24),

                  // Section: Partage
                  _buildSectionTitle('Partage', context),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.share,
                    title: 'Partager mon emploi du temps',
                    subtitle: 'Générer un code pour un ami',
                    value: '',
                    onTap: () => _showShareModal(context),
                  ),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.download,
                    title: 'Importer un emploi du temps',
                    subtitle: 'Utiliser le code d\'un ami',
                    value: '',
                    onTap: () => _navigateToImportPage(),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const HelpPage()),
                      );
                    },
                  ),

                  _buildSettingCard(
                    context: context,
                    icon: Icons.school_outlined,
                    title: 'Revoir le tutoriel',
                    subtitle: 'Revoir le guide de l\'application',
                    value: '',
                    onTap: () => _replayTutorial(),
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
                  color: accentColor.withValues(alpha: 0.2),
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
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
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

      // Update notification with contextual content (Story 2.9)
      final repository = ref.read(calendarCourseRepositoryProvider);
      final database = ref.read(databaseProvider);
      int currentStreak = 0;
      try {
        currentStreak = await ref.read(currentStreakProvider.future);
      } catch (_) {}
      await NotificationService.updateNotificationIfEnabled(
        repository: repository,
        database: database,
        currentStreak: currentStreak,
      );

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
                color: accentColor.withValues(alpha: 0.2),
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
              activeThumbColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolYearCard(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Card(
      color: Color(0xFF303030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _selectSchoolYearStart(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Debut d\'annee scolaire',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Subtitle
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Text(
                  'Date de la premiere semaine A',
                  style: GoogleFonts.roboto(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Date aligned right
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDate(_schoolYearStart),
                    style: GoogleFonts.roboto(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        // Schedule with contextual content (checks vacation mode + tomorrow's courses)
        final repository = ref.read(calendarCourseRepositoryProvider);
        final database = ref.read(databaseProvider);
        int currentStreak = 0;
        try {
          currentStreak = await ref.read(currentStreakProvider.future);
        } catch (_) {}
        await NotificationService.updateNotificationIfEnabled(
          repository: repository,
          database: database,
          currentStreak: currentStreak,
        );
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

  Future<void> _toggleShowWeekend(bool show) async {
    setState(() {
      _showWeekend = show;
    });
    await PreferencesService.setShowWeekend(show);
    _showSnackBar(show
        ? 'Weekend affiché dans le calendrier'
        : 'Weekend masqué du calendrier');
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

  void _replayTutorial() {
    // Navigate to Courses tab with tutorial enabled
    ref.read(routerDelegateProvider).goToHome(
          initialTabIndex: 2,
          showTutorial: true,
        );
  }

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SharePage(),
    );
  }

  void _navigateToImportPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OnboardingImportStepPage(
          showBackArrow: true,
          onImportComplete: () {
            Navigator.of(context).pop();
            _showSnackBar('Emploi du temps importe avec succes !');
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundImageCard(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final bgState = ref.watch(backgroundImageProvider);

    return Card(
      color: const Color(0xFF303030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.wallpaper,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image de fond',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Calendrier et Mon Sac',
                        style: GoogleFonts.roboto(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Image preview or pick button
            if (bgState.hasImage) ...[
              // Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.file(
                      File(bgState.imagePath!),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.white10,
                          child: const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.white38),
                          ),
                        );
                      },
                    ),
                    // Dark overlay preview
                    Container(
                      height: 120,
                      color: Colors.black.withValues(alpha: bgState.opacity),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Opacity slider
              Row(
                children: [
                  Icon(Icons.opacity, color: Colors.white54, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Opacité',
                    style: GoogleFonts.roboto(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: bgState.opacity,
                      min: 0.1,
                      max: 0.9,
                      activeColor: accentColor,
                      inactiveColor: Colors.white12,
                      onChanged: (value) {
                        ref
                            .read(backgroundImageProvider.notifier)
                            .setOpacity(value);
                      },
                    ),
                  ),
                  Text(
                    '${(bgState.opacity * 100).round()}%',
                    style: GoogleFonts.roboto(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickBackgroundImage(),
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('Changer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: BorderSide(
                            color: accentColor.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _removeBackgroundImage(),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[300],
                        side: BorderSide(
                            color: Colors.red[300]!.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Pick image button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickBackgroundImage(),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Choisir une image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;

    // Copy to app documents directory for persistence
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'background_image.jpg';
    final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

    await ref
        .read(backgroundImageProvider.notifier)
        .setImagePath(savedFile.path);
    _showSnackBar('Image de fond mise à jour !');
  }

  Future<void> _removeBackgroundImage() async {
    await ref.read(backgroundImageProvider.notifier).removeImage();
    _showSnackBar('Image de fond supprimée');
  }

  Widget _buildVacationModeCard(BuildContext context) {
    return Card(
      color: const Color(0xFF303030),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showVacationModeBottomSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _vacationModeEnabled
                      ? const Color(0xFFFF9800).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _vacationModeEnabled
                      ? Icons.beach_access
                      : Icons.school_outlined,
                  color: _vacationModeEnabled
                      ? const Color(0xFFFF9800)
                      : Colors.white70,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode vacances',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _vacationModeEnabled && _vacationEndDate != null
                          ? 'Actif jusqu\'au ${_formatDateShort(_vacationEndDate!)}'
                          : 'Protège ta streak pendant les congés',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (_vacationModeEnabled)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🏖️ ACTIF',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVacationModeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VacationModeBottomSheet(
        isEnabled: _vacationModeEnabled,
        endDate: _vacationEndDate,
        onConfirm: (bool enabled, DateTime? endDate) async {
          // 1. Sauvegarde préférences (critique)
          await PreferencesService.setVacationMode(enabled, endDate);

          // 2. UI feedback immédiat (avant les opérations risquées)
          setState(() {
            _vacationModeEnabled = enabled;
            _vacationEndDate = endDate;
          });

          if (!context.mounted) return;
          Navigator.pop(context);

          _showSnackBar(enabled
              ? '🏖️ Mode vacances activé - Ta streak est protégée !'
              : '🎒 Bon retour ! Les rappels sont réactivés.');

          // 3. Notifications + streak refresh (secondaire, isolé)
          try {
            if (enabled) {
              await NotificationService.cancelNotification();
            } else if (_notificationsEnabled) {
              int currentStreak = 0;
              try {
                currentStreak = await ref.read(currentStreakProvider.future);
              } catch (_) {}
              await NotificationService.updateNotificationIfEnabled(
                repository: ref.read(calendarCourseRepositoryProvider),
                database: ref.read(databaseProvider),
                currentStreak: currentStreak,
              );
            }
            ref.invalidate(streakRepositoryProvider);
          } catch (e, st) {
            LogService.e(
              'Erreur mise à jour notifications/streak après vacation mode',
              e,
              st,
            );
          }
        },
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Bottom sheet widget for vacation mode
class _VacationModeBottomSheet extends StatefulWidget {
  final bool isEnabled;
  final DateTime? endDate;
  final Function(bool enabled, DateTime? endDate) onConfirm;

  const _VacationModeBottomSheet({
    required this.isEnabled,
    required this.endDate,
    required this.onConfirm,
  });

  @override
  State<_VacationModeBottomSheet> createState() =>
      _VacationModeBottomSheetState();
}

class _VacationModeBottomSheetState extends State<_VacationModeBottomSheet> {
  late bool _enabled;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _enabled = widget.isEnabled;
    _selectedEndDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF303030),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.beach_access,
                    color: Color(0xFFFF9800),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Mode vacances',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Active ce mode pour protéger ta streak pendant les vacances. Les jours de vacances ne seront pas comptés.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _enabled
                        ? 'Mode vacances activé'
                        : 'Mode vacances désactivé',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch(
                  value: _enabled,
                  onChanged: (value) {
                    setState(() {
                      _enabled = value;
                      if (!value) {
                        _selectedEndDate = null;
                      }
                    });
                  },
                  activeThumbColor: const Color(0xFFFF9800),
                ),
              ],
            ),
          ),

          // Date picker (only shown when enabled)
          if (_enabled) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Date de fin des vacances',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFFFF9800)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedEndDate != null
                              ? _formatDate(_selectedEndDate!)
                              : 'Choisir une date',
                          style: TextStyle(
                            color: _selectedEndDate != null
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Le mode vacances se désactivera automatiquement après cette date',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (_enabled && _selectedEndDate == null)
                        ? null
                        : () => widget.onConfirm(_enabled, _selectedEndDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.white12,
                    ),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final maxDate = now.add(const Duration(days: 90)); // Max 3 months

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF9800),
              onPrimary: Colors.white,
              surface: Color(0xFF303030),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
