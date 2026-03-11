import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_styles.dart';

/// Classe qui définit les thèmes de l'application
class AppTheme {
  AppTheme._(); // Constructeur privé

  /// Generate dark theme with custom accent color
  static ThemeData darkThemeWithColor(Color accentColor) {
    return _buildDarkTheme(accentColor);
  }

  /// Generate light theme with custom accent color
  static ThemeData lightThemeWithColor(Color accentColor) {
    return _buildLightTheme(accentColor);
  }

  /// Thème clair de l'application (default accent)
  static ThemeData get lightTheme {
    return ThemeData(
        // ignore: deprecated_member_use
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            error: AppColors.error,
            surface: AppColors.surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onTertiary: AppColors.textSecondary,
            onError: Colors.white,
            onSurface: AppColors.textPrimary,
            onSurfaceVariant: AppColors.textSecondary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headline6,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.cardBackground,
          elevation: 2,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.headline1,
          displayMedium: AppTextStyles.headline2,
          displaySmall: AppTextStyles.headline3,
          headlineMedium: AppTextStyles.headline4,
          headlineSmall: AppTextStyles.headline5,
          titleLarge: AppTextStyles.headline6,
          bodyLarge: AppTextStyles.bodyText1,
          bodyMedium: AppTextStyles.bodyText2,
          labelLarge: AppTextStyles.button,
          bodySmall: AppTextStyles.caption,
          labelSmall: AppTextStyles.overline,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.surface,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            textStyle: AppTextStyles.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // coins arrondis
            side: BorderSide(
              width: 10, // bord plus épais
              color: Colors.grey, // couleur du bord
            ),
          ),
        ));
  }

  /// Thème sombre de l'application
  static ThemeData get darkTheme {
    return _buildDarkTheme(AppColors.accent);
  }

  /// Returns white or black foreground depending on accent luminance
  static Color _foregroundForAccent(Color accent) {
    return accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Build light theme with a specific accent color and blanc cassé palette
  static ThemeData _buildLightTheme(Color accentColor) {
    final onAccent = _foregroundForAccent(accentColor);

    return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: accentColor,
        colorScheme: ColorScheme.light(
          primary: accentColor,
          secondary: accentColor,
          error: AppColors.error,
          surface: AppColors.lightSurface,
          onPrimary: onAccent,
          onSecondary: onAccent,
          onTertiary: AppColors.lightTextSecondary,
          onError: Colors.white,
          onSurface: AppColors.lightTextPrimary,
          onSurfaceVariant: AppColors.lightTextSecondary,
        ),
        scaffoldBackgroundColor: AppColors.lightScaffold,
        appBarTheme: AppBarTheme(
          backgroundColor: accentColor,
          foregroundColor: onAccent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headline6.copyWith(color: onAccent),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.lightCard,
          elevation: 2,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.headline1
              .copyWith(color: AppColors.lightTextPrimary),
          displayMedium: AppTextStyles.headline2
              .copyWith(color: AppColors.lightTextPrimary),
          displaySmall: AppTextStyles.headline3
              .copyWith(color: AppColors.lightTextPrimary),
          headlineMedium: AppTextStyles.headline4
              .copyWith(color: AppColors.lightTextPrimary),
          headlineSmall: AppTextStyles.headline5
              .copyWith(color: AppColors.lightTextPrimary),
          titleLarge: AppTextStyles.headline6
              .copyWith(color: AppColors.lightTextPrimary),
          bodyLarge: AppTextStyles.bodyText1
              .copyWith(color: AppColors.lightTextPrimary),
          bodyMedium: AppTextStyles.bodyText2
              .copyWith(color: AppColors.lightTextPrimary),
          labelLarge: AppTextStyles.button
              .copyWith(color: AppColors.lightTextPrimary),
          bodySmall: AppTextStyles.caption
              .copyWith(color: AppColors.lightTextSecondary),
          labelSmall: AppTextStyles.overline
              .copyWith(color: AppColors.lightTextSecondary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.lightSurface,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightDivider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: onAccent,
            backgroundColor: accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            textStyle: AppTextStyles.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: AppTextStyles.button.copyWith(color: accentColor),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accentColor,
            side: BorderSide(color: accentColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTextStyles.button.copyWith(color: accentColor),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightDivider,
          thickness: 1,
          space: 1,
        ),
        iconTheme: IconThemeData(
          color: accentColor,
          size: 24,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: accentColor,
          unselectedLabelColor: AppColors.lightTextSecondary,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightTextPrimary,
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(
              width: 10,
              color: Colors.grey,
            ),
          ),
        ));
  }

  /// Build dark theme with a specific accent color
  static ThemeData _buildDarkTheme(Color accentColor) {
    return ThemeData.dark().copyWith(
      // ignore: deprecated_member_use
      useMaterial3: true,
      primaryColor: accentColor,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
        error: AppColors.error,
        surface: AppColors.grey800,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
      ),
      scaffoldBackgroundColor: AppColors.grey900,
      // Fond sombre pour tout l'app
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headline6,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.grey800, // Fond des cartes pour mode sombre
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(color: Colors.white),
        displayMedium: AppTextStyles.headline2.copyWith(color: Colors.white),
        displaySmall: AppTextStyles.headline3.copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.headline4.copyWith(color: Colors.white),
        headlineSmall: AppTextStyles.headline5.copyWith(color: Colors.white),
        titleLarge: AppTextStyles.headline6.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.bodyText1.copyWith(color: Colors.white),
        bodyMedium: AppTextStyles.bodyText2.copyWith(color: Colors.white),
        labelLarge: AppTextStyles.button.copyWith(color: Colors.white),
        bodySmall: AppTextStyles.caption.copyWith(color: Colors.white),
        labelSmall: AppTextStyles.overline.copyWith(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.grey800,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.button.copyWith(color: accentColor),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button.copyWith(color: accentColor),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey600, // Lignes de séparation pour le mode sombre
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: accentColor,
        size: 24,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentColor,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF303030),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
