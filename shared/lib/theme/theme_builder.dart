import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class AppTheme {
  final String key;
  final ThemeData themeData;
  final Schema schema;
  final SystemUiOverlayStyle uiOverlayStyle;
  const AppTheme({
    @required this.key,
    @required this.themeData,
    @required this.schema,
    @required this.uiOverlayStyle,
  })  : assert(key != null),
        assert(themeData != null),
        assert(uiOverlayStyle != null);

  static AppTheme of(BuildContext context) => ThemeBuilder.theme(context);

  bool get isDark => themeData.isDark;
  bool get isLight => themeData.isLight;

  ThemeMode get mode => isLight ? ThemeMode.light : ThemeMode.dark;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AppTheme && o.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

class ThemeBuilder extends StatefulWidget {
  final Widget Function(BuildContext, AppTheme lightTheme, AppTheme darkTheme, ThemeMode)
      builder;
  final List<AppTheme> themes;
  final bool setUiOverlayStyle;
  ThemeBuilder({
    Key key,
    @required this.builder,
    @required this.themes,
    this.setUiOverlayStyle = true,
  })  : assert(themes != null),
        assert(themes.isNotEmpty, 'At least one theme data has to be provided.'),
        super(key: key);

  @override
  ThemeBuilderState createState() => ThemeBuilderState();

  static AppTheme theme(BuildContext context) => of(context)?.getTheme(context);

  static List<AppTheme> getThemes(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ThemeBuilder>().themes;
  }

  static ThemeBuilderState of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeBuilderState>();
  }
}

class ThemeBuilderState extends State<ThemeBuilder> {
  AppPreferences _prefs;

  ThemeMode themeMode;
  AppTheme lightTheme;
  AppTheme darkTheme;

  List<AppTheme> get themes => widget.themes;

  StreamSubscription _lightThemeSubscription;
  StreamSubscription _darkThemeSubscription;
  StreamSubscription _themeModeSubscription;

  @override
  void initState() {
    super.initState();
    didUpdateWidget(widget);
    _observeThemeChanges();
  }

  @override
  void didUpdateWidget(ThemeBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assignDefaultThemes();
    _prefs?.themes = themes;
  }

  void _assignDefaultThemes() {
    for (final theme in widget.themes) {
      if (theme.isLight && (lightTheme == null || theme.key == lightTheme.key)) {
        lightTheme = theme;
      } else if (theme.isDark && (darkTheme == null || theme.key == darkTheme.key)) {
        darkTheme = theme;
      }
    }
  }

  void _observeThemeChanges() async {
    if (Platform.isWindows || Platform.isLinux) return;

    _prefs ??= AppPreferences(await StreamingSharedPreferences.instance);
    _prefs.themes = themes;

    _lightThemeSubscription = _prefs.watchString(AppPreferences.lightThemeKey, (theme) {
      if (_prefs.lightTheme != lightTheme) {
        lightTheme = _prefs.lightTheme;
        _themeChanged();
      }
    });

    _darkThemeSubscription = _prefs.watchString(AppPreferences.darkThemeKey, (theme) {
      if (_prefs.darkTheme != darkTheme) {
        darkTheme = _prefs.darkTheme;
        _themeChanged();
      }
    });

    _themeModeSubscription = _prefs.watchInt(AppPreferences.themeModeKey, (mode) {
      if (mode != -1 && themeMode?.index != mode) {
        themeMode = _prefs.themeMode;
        _themeChanged();
      }
    });
  }

  AppTheme getTheme(BuildContext context) {
    switch (themeMode ?? ThemeMode.system) {
      case ThemeMode.system:
        return Theme.of(context).isLight ? lightTheme : darkTheme;
      case ThemeMode.dark:
        return darkTheme;
      default:
        return lightTheme;
    }
  }

  void _themeChanged() {
    if (widget.setUiOverlayStyle) {
      OverlayChrome.setDefaultUiOverlayStyle(
        getTheme(context).uiOverlayStyle,
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      lightTheme,
      darkTheme,
      themeMode ?? ThemeMode.system,
    );
  }

  @override
  void dispose() {
    _lightThemeSubscription?.cancel();
    _darkThemeSubscription?.cancel();
    _themeModeSubscription?.cancel();
    super.dispose();
  }
}
