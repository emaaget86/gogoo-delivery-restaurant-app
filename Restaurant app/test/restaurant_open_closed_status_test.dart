import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor_restaurant/features/restaurant/domain/models/restaurant_availability_status.dart';

void main() {
  test('open status is green and closed status is red', () {
    expect(restaurantAvailabilityColor(true), const Color(0xFF22C55E));
    expect(restaurantAvailabilityColor(false), const Color(0xFFEF4444));
    expect(restaurantOpenColor, const Color(0xFF22C55E));
    expect(restaurantClosedColor, const Color(0xFFEF4444));
  });

  test('status labels use the open and closed translation keys', () {
    expect(restaurantAvailabilityLabelKey(true), 'restaurant_status_open');
    expect(restaurantAvailabilityLabelKey(false), 'restaurant_status_closed');
  });

  test('english copy shows OPEN and CLOSED beside the restaurant status', () {
    final Map<String, dynamic> english = jsonDecode(File('assets/language/en.json').readAsStringSync()) as Map<String, dynamic>;
    expect(english['restaurant_status_open'], 'OPEN');
    expect(english['restaurant_status_closed'], 'CLOSED');
  });

  test('every language file includes the restaurant status labels', () {
    for (final String code in ['en', 'es', 'ar', 'bn']) {
      final Map<String, dynamic> language = jsonDecode(File('assets/language/$code.json').readAsStringSync()) as Map<String, dynamic>;
      expect(language['restaurant_status_open'], isA<String>());
      expect((language['restaurant_status_open'] as String).trim(), isNotEmpty);
      expect(language['restaurant_status_closed'], isA<String>());
      expect((language['restaurant_status_closed'] as String).trim(), isNotEmpty);
    }
  });
}
