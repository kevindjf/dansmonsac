import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/src/ui/ui.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // TODO: Get from preferences
  TimeOfDay _packTime = TimeOfDay(hour: 19, minute: 0);
  DateTime _schoolYearStart = DateTime(2024, 9, 2);

  @override
  Widget build(BuildContext context) {
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
                  _buildSectionTitle('Préparation du sac'),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    icon: Icons.access_time,
                    title: 'Heure de préparation',
                    subtitle: 'Quand préparez-vous votre sac ?',
                    value: _formatTime(_packTime),
                    onTap: () => _selectPackTime(context),
                  ),

                  const SizedBox(height: 24),

                  // Section: Année scolaire
                  _buildSectionTitle('Année scolaire'),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    icon: Icons.calendar_today,
                    title: 'Début d\'année scolaire',
                    subtitle: 'Date de la première semaine A',
                    value: _formatDate(_schoolYearStart),
                    onTap: () => _selectSchoolYearStart(context),
                  ),

                  const SizedBox(height: 24),

                  // Section: À propos
                  _buildSectionTitle('À propos'),
                  const SizedBox(height: 8),

                  _buildSettingCard(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: 'DansMonSac',
                    value: '1.0.0',
                    onTap: null,
                  ),

                  _buildSettingCard(
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.robotoCondensed(
          fontSize: 14,
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback? onTap,
  }) {
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
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
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

              // Value
              if (value.isNotEmpty)
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    color: AppColors.accent,
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _packTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
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
      // TODO: Save to preferences
      _showSnackBar('Heure de préparation mise à jour: ${_formatTime(picked)}');
    }
  }

  Future<void> _selectSchoolYearStart(BuildContext context) async {
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
              primary: AppColors.accent,
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
      // TODO: Save to preferences
      _showSnackBar('Date de début mise à jour: ${_formatDate(picked)}');
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
