import 'dart:math';

import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  static HexColor hex(String hexCode) => HexColor(hexCode);

  static Color random() => Color.fromRGBO(
        Random().nextInt(255),
        Random().nextInt(255),
        Random().nextInt(255),
        1.0,
      );

  double get brightness => computeLuminance();

  bool get isBright => brightness > 0.75;
  bool get isDark => brightness < 0.25;

  double differenceTo(Color other) => (brightness - other.brightness).abs();

  Color toContrast({
    Color onBright = Colors.black,
    Color onDark = Colors.white,
  }) =>
      isBright ? onBright : onDark;

  Color blend(Color other) {
    if (this == null || other == null) return this;

    return Color.fromARGB(
      (alpha + other.alpha) ~/ 2,
      (red + other.red) ~/ 2,
      (green + other.green) ~/ 2,
      (blue + other.blue) ~/ 2,
    );
  }

  Color lighten(double fraction) {
    return Color.fromARGB(
      alpha,
      min(255, red + (255 * fraction).round()),
      min(255, green + (255 * fraction).round()),
      min(255, blue + (255 * fraction).round()),
    );
  }

  Color darken(double fraction) {
    return Color.fromARGB(
      alpha,
      max(0, red - (255 * fraction).round()),
      max(0, green - (255 * fraction).round()),
      max(0, blue - (255 * fraction).round()),
    );
  }

  Color scaleOpacity(double factor) => withOpacity(opacity * factor);
}

class HexColor extends Color {
  final String hexCode;

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }

    return int.parse(hexColor, radix: 16);
  }

  HexColor(this.hexCode) : super(_getColorFromHex(hexCode));
}
