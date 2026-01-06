import 'package:common/src/ui/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/navigation/routes.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dansmonsac/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RepositoryHelper.initialize();
  await NotificationService.initialize();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Dans mon sac',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
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
      routeInformationParser: _routeInformationParser,
    );
  }
}
