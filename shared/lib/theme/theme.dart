import 'package:flutter/material.dart';

export 'schema.dart';
export 'theme_builder.dart';
export 'theme_factory.dart';

extension ThemeDataExtension on ThemeData {
  bool get isLight => brightness == Brightness.light;
  bool get isDark => brightness == Brightness.dark;
}