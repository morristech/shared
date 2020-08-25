import 'dart:async';

import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'package:shared/shared.dart';

const String THEME = 'THEME';
const String THEME_MODE = 'THEME_MODE';
const String DARK_THEME_KEY = 'DARK_THEME';
const String LIGHT_THEME_KEY = 'LIGHT_THEME';

/// A simple wrapper class around [StreamingSharedPreferences].
class Preferences {
  final StreamingSharedPreferences instance;
  const Preferences(this.instance) : assert(instance != null);

  int getInt(String key, [int defaultValue = 0]) {
    return instance.getInt(key, defaultValue: defaultValue).getValue();
  }

  bool getBool(String key, [bool defaultValue = false]) {
    return instance.getBool(key, defaultValue: defaultValue).getValue();
  }

  String getString(String key, [String defaultValue = '']) {
    return instance.getString(key, defaultValue: defaultValue).getValue();
  }

  double getDouble(String key, [double defaultValue = 0.0]) {
    return instance.getDouble(key, defaultValue: defaultValue).getValue();
  }

  StreamSubscription<int> watchInt(String key, Function(int) onData,
      {int defaultValue = 0}) {
    return instance.getInt(key, defaultValue: defaultValue).listen(onData);
  }

  StreamSubscription<bool> watchBool(String key, Function(bool) onData,
      {bool defaultValue = false}) {
    return instance.getBool(key, defaultValue: defaultValue).listen(onData);
  }

  StreamSubscription<String> watchString(String key, Function(String) onData,
      {String defaultValue = ''}) {
    return instance.getString(key, defaultValue: defaultValue).listen(onData);
  }

  StreamSubscription<double> watchDouble(String key, Function(double) onData,
      {double defaultValue = 0.0}) {
    return instance.getDouble(key, defaultValue: defaultValue).listen(onData);
  }

  Future<bool> setInt(String key, int value) {
    return instance.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) {
    return instance.setBool(key, value);
  }

  Future<bool> setString(String key, String value) {
    return instance.setString(key, value);
  }

  Future<bool> setDouble(String key, double value) {
    return instance.setDouble(key, value);
  }

  Future<bool> remove(String key) {
    return instance.remove(key);
  }
}

/// The base class for all normal Prefs classes in an app with out of the box support
/// for themes and languages.
class AppPreferences extends Preferences {
  AppPreferences(
    StreamingSharedPreferences instance,
  ) : super(instance);

  AppTheme _defaultLight;
  AppTheme _defaultDark;
  Map<String, AppTheme> _themeMap;
  set themes(List<AppTheme> themes) {
    assert(themes != null && themes.isNotEmpty);

    // Apply default light and dark themes.
    _defaultLight = null;
    _defaultDark = null;

    for (final theme in themes) {
      if (theme.isLight && _defaultLight == null) {
        _defaultLight = theme;
      } else if (theme.isDark && _defaultDark == null) {
        _defaultDark = theme;
      }
    }

    _themeMap = {
      for (final theme in themes) theme.key: theme,
    };
  }

  set theme(AppTheme theme) {
    if (theme.isLight) {
      setString(LIGHT_THEME_KEY, theme.key);
    } else {
      setString(DARK_THEME_KEY, theme.key);
    }

    if (themeMode != ThemeMode.system) {
      themeMode = theme.isLight ? ThemeMode.light : ThemeMode.dark;
    }
  }

  AppTheme get lightTheme {
    final key = getString(LIGHT_THEME_KEY);
    return key != '' && _themeMap?.containsKey(key) == true
        ? _themeMap[key]
        : _defaultLight;
  }

  AppTheme get darkTheme {
    final key = getString(DARK_THEME_KEY);
    return key != '' && _themeMap?.containsKey(key) == true
        ? _themeMap[key]
        : _defaultDark;
  }

  set themeMode(ThemeMode mode) {
    if (mode != null) {
      setInt(THEME_MODE, mode.index);
    }
  }

  ThemeMode get themeMode {
    final index = getInt(THEME_MODE, -1);
    return ThemeMode.values.getOrElse(index, ThemeMode.system);
  }
}
