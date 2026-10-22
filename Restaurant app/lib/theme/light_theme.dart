import 'package:flutter/material.dart';

const Color primaryTeal = Color(0xFF3FD9CD);
const Color primaryYellow = Color(0xFFFFD900);
const Color onPrimaryText = Color(0xFF1A1A1A);
const Color authTeal = Color(0xFF00A99D);

const LinearGradient authGradient = LinearGradient(
  colors: [authTeal, primaryYellow],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

ThemeData authPageTheme(ThemeData base) {
  return base.copyWith(
    primaryColor: authTeal,
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: authTeal)),
    colorScheme: base.colorScheme.copyWith(primary: authTeal),
  );
}

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: primaryTeal,
  secondaryHeaderColor: primaryYellow,
  disabledColor: const Color(0xFFBCBDC3),
  brightness: Brightness.light,
  hintColor: const Color(0xFF999999),
  cardColor: Colors.white,
  shadowColor: Colors.black.withValues(alpha: 0.03),
  scaffoldBackgroundColor: const Color(0xFFFCFCFC),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primaryTeal)),
  colorScheme: const ColorScheme.light(
    primary: primaryTeal,
    secondary: primaryYellow).copyWith(error: const Color(0xFFE84D4F),
    tertiary: const Color(0xFFF9F9F9),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryTeal,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: primaryTeal,
    indicatorColor: primaryTeal,
    unselectedLabelColor: Color(0xFF999999),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryTeal),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryTeal;
      }
      return null;
    }),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryTeal;
      }
      return null;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryTeal;
      }
      return null;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primaryTeal.withValues(alpha: 0.45);
      }
      return null;
    }),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white, height: 68,
    padding: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
);