import 'dart:ui';

import 'package:common/src/ui/theme/theme_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/navigation/routes.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:common/src/services.dart';
import 'package:common/src/providers.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init (first to catch errors from subsequent inits)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Disable Crashlytics in debug to avoid noise
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Flutter framework errors → Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Async Dart errors → Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await dotenv.load(fileName: '.env');
  await RepositoryHelper.initialize();
  await NotificationService.initialize();

  // Mark migration as completed so old users skip the migration screen
  await PreferencesService.setMigrationV3Completed(true);

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppRouteInformationParser routeInformationParser =
        AppRouteInformationParser();

    // Watch accent color and theme mode providers for reactive updates
    final accentColor = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Dans mon sac',
      theme: AppTheme.lightThemeWithColor(accentColor),
      darkTheme: AppTheme.darkThemeWithColor(accentColor),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      routerDelegate: ref.watch(routerDelegateProvider),
      routeInformationParser: routeInformationParser,
    );
  }
}
