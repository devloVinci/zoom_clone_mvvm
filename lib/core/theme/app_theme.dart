import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.lightBlue;
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color onPrimaryColor = Colors.white;
  static const Color onSecondaryColor = Colors.white;
  static const Color onBackgroundColor = Colors.black;
  static const Color onSurfaceColor = Colors.black;
  static const Color onErrorColor = Colors.white;

  // Text Styles
  static TextStyle ralewayStyle(
    double size, [
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
  ]) {
    return GoogleFonts.raleway(
      fontSize: size,
      color: color ?? onBackgroundColor,
      fontWeight: fontWeight,
    );
  }

  static TextStyle montserratStyle(
    double size, [
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
  ]) {
    return GoogleFonts.montserrat(
      fontSize: size,
      color: color ?? onBackgroundColor,
      fontWeight: fontWeight,
    );
  }

  // Gradients
  static LinearGradient get blueGradient =>
      LinearGradient(colors: GradientColors.blue);

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onSurface: onSurfaceColor,
      onError: onErrorColor,
    ),
    textTheme: TextTheme(
      displayLarge: ralewayStyle(32),
      displayMedium: ralewayStyle(28),
      displaySmall: ralewayStyle(24),
      headlineLarge: montserratStyle(22),
      headlineMedium: montserratStyle(20),
      headlineSmall: montserratStyle(18),
      bodyLarge: ralewayStyle(16, null, FontWeight.w400),
      bodyMedium: ralewayStyle(14, null, FontWeight.w400),
      bodySmall: ralewayStyle(12, null, FontWeight.w400),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      titleTextStyle: ralewayStyle(20, onPrimaryColor),
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        textStyle: ralewayStyle(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      hintStyle: ralewayStyle(16, Colors.grey, FontWeight.w400),
    ),
  );
}
