import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_restaurant/theme/light_theme.dart';

class ColorResources {
  /// Brand primary (GOGO Partner cyan).
  static const Color primary = primaryTeal;
  static const Color accent = primaryYellow;

  static Color getRightBubbleColor() {
    return Theme.of(Get.context!).primaryColor;
  }

  static Color getLeftBubbleColor() {
    return Get.isDarkMode ? const Color(0xA2B7B7BB): Theme.of(Get.context!).disabledColor.withValues(alpha: 0.2);
  }
}