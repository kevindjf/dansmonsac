import 'package:common/src/ui/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/src/repository/repository_helper.dart';
import 'package:common/src/navigation/routes.dart';
import 'package:common/src/di/riverpod_di.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:common/src/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RepositoryHelper.initialize();
  await NotificationService.initialize();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();

  Color _accentColor = const Color(0xFF9C27B0); // Default color

  @override
  void initState() {
    super.initState();
    _loadAccentColor();
  }

  Future<void> _loadAccentColor() async {
    final color = await PreferencesService.getAccentColor();
    setState(() {
      _accentColor = color;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dans mon sac',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkThemeWithColor(_accentColor),
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
