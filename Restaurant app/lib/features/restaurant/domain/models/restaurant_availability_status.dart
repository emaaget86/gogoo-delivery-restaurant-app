import 'package:flutter/material.dart';

const Color restaurantOpenColor = Color(0xFF22C55E);
const Color restaurantClosedColor = Color(0xFFEF4444);

Color restaurantAvailabilityColor(bool isOpen) => isOpen ? restaurantOpenColor : restaurantClosedColor;

String restaurantAvailabilityLabelKey(bool isOpen) => isOpen ? 'restaurant_status_open' : 'restaurant_status_closed';
