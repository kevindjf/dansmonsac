import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/services.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:main/presentation/home/home_page.dart';

class OnboardingNotificationPermissionPage extends ConsumerStatefulWidget {
  static const String routeName = "/notification-permission-onboarding";

  const OnboardingNotificationPermissionPage({super.key});

  @override
  ConsumerState<OnboardingNotificationPermissionPage> createState() =>
      _OnboardingNotificationPermissionPageState();
}

class _OnboardingNotificationPermissionPageState
    extends ConsumerState<OnboardingNotificationPermissionPage> {
  bool _isRequesting = false;
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    _checkCurrentPermission();
  }

  Future<void> _checkCurrentPermission() async {
    final canSchedule = await NotificationService.canScheduleExactAlarms();
    if (mounted) {
      setState(() {
        _permissionGranted = canSchedule;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      // Request permission to schedule exact alarms
      final canSchedule = await NotificationService.canScheduleExactAlarms();

      if (!canSchedule) {
        // Show dialog explaining that permissions are required
        if (mounted) {
          _showPermissionDialog();
        }
      }

      setState(() {
        _permissionGranted = canSchedule;
      });
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autorisation requise'),
        content: const Text(
          'Pour recevoir tes rappels quotidiens, active les notifications dans les paramètres de ton appareil.\n\n'
          'Paramètres > Applications > DansMonSac > Notifications',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Future<void> _continueToApp() async {
    // Mark onboarding as completed
    await PreferencesService.setOnboardingCompleted(true);

    // Navigate to home using the app's routing system
    if (mounted) {
      ref.read(routerDelegateProvider).goToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 80,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Reçois tes rappels',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Pour ne jamais oublier de préparer ton sac, active les notifications.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Features list
              _buildFeature(
                icon: Icons.alarm,
                title: 'Rappel quotidien',
                description: 'Reçois une notification à l\'heure que tu as choisie',
                accentColor: accentColor,
              ),

              const SizedBox(height: 16),

              _buildFeature(
                icon: Icons.event_note,
                title: 'Liste personnalisée',
                description:
                    'La notification affiche les fournitures pour le lendemain',
                accentColor: accentColor,
              ),

              const SizedBox(height: 16),

              _buildFeature(
                icon: Icons.privacy_tip,
                title: '100% privé',
                description:
                    'Notifications locales uniquement, aucune donnée envoyée',
                accentColor: accentColor,
              ),

              const Spacer(),

              // Permission status
              if (_permissionGranted == true)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications activées !',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_permissionGranted == false)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Active les notifications pour profiter pleinement de l\'app',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Action buttons
              if (_permissionGranted != true)
                FilledButton.icon(
                  onPressed: _isRequesting ? null : _requestPermission,
                  icon: _isRequesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.notifications_active),
                  label: Text(
                    _isRequesting ? 'Vérification...' : 'Activer les notifications',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

              if (_permissionGranted == true)
                FilledButton.icon(
                  onPressed: _continueToApp,
                  icon: const Icon(Icons.check),
                  label: const Text('Commencer'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

              const SizedBox(height: 8),

              // Skip button
              if (_permissionGranted != true)
                TextButton(
                  onPressed: _continueToApp,
                  child: const Text('Passer cette étape'),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
