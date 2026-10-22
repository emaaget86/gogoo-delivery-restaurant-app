import 'package:flutter/material.dart';
import 'package:stackfood_multivendor_restaurant/theme/light_theme.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: primaryTeal,
  secondaryHeaderColor: primaryYellow,
  disabledColor: const Color(0xFF6f7275),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF5E6472),
  cardColor: Colors.black,
  shadowColor: Colors.white.withValues(alpha: 0.03),
  scaffoldBackgroundColor: const Color(0xFF161617),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primaryTeal)),
  colorScheme: const ColorScheme.dark(primary: primaryTeal, secondary: primaryYellow).copyWith(error: const Color(0xFFdd3135)),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryTeal,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: primaryTeal,
    indicatorColor: primaryTeal,
    unselectedLabelColor: Color(0xFF5E6472),
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
    surfaceTintColor: Colors.black, height: 68,
    padding: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
);
