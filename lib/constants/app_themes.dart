import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Colors
  static const Color primaryColor = Color(0xFFE53935); // Emergency red
  static const Color secondaryColor = Color(0xFF1E88E5); // Info blue
  static const Color bgLightColor = Color(0xFFF5F5F5);
  static const Color bgDarkColor = Color(0xFF121212);
  static const Color cardLightColor = Colors.white;
  static const Color cardDarkColor = Color(0xFF1E1E1E);
  static const Color textLightColor = Color(0xFF212121);
  static const Color textDarkColor = Color(0xFFEEEEEE);

  // Text Styles
  static final TextStyle headingStyle = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subheadingStyle = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyStyle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle buttonTextStyle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardLightColor,
    ),
    scaffoldBackgroundColor: bgLightColor,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 0,
      titleTextStyle: headingStyle.copyWith(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: cardLightColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle.copyWith(color: textLightColor),
      displayMedium: subheadingStyle.copyWith(color: textLightColor),
      bodyLarge: bodyStyle.copyWith(color: textLightColor),
      bodyMedium: bodyStyle.copyWith(color: textLightColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: buttonTextStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardDarkColor,
    ),
    scaffoldBackgroundColor: bgDarkColor,
    appBarTheme: AppBarTheme(
      color: cardDarkColor,
      elevation: 0,
      titleTextStyle: headingStyle.copyWith(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: cardDarkColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle.copyWith(color: textDarkColor),
      displayMedium: subheadingStyle.copyWith(color: textDarkColor),
      bodyLarge: bodyStyle.copyWith(color: textDarkColor),
      bodyMedium: bodyStyle.copyWith(color: textDarkColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: buttonTextStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
  );
}
