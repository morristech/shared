import 'package:flutter/services.dart';

class OverlayChrome {
  OverlayChrome._();

  static SystemUiOverlayStyle defaultStyle;
  static List<SystemUiOverlayStyle> history = [];
  static SystemUiOverlayStyle get latestStyle => history.isNotEmpty ? history.last : defaultStyle;

  static void setDefaultUiOverlayStyle(SystemUiOverlayStyle style) {
    defaultStyle = style.copyWith();
    setSystemUiOverlayStyle(defaultStyle);
  }

  static void setSystemUiOverlayStyle(SystemUiOverlayStyle style) {
    final newStyle = defaultStyle?.copyWith(
      statusBarColor: style.statusBarColor,
      statusBarBrightness: style.statusBarBrightness,
      statusBarIconBrightness: style.statusBarIconBrightness,
      systemNavigationBarColor: style.systemNavigationBarColor,
      systemNavigationBarDividerColor: style.systemNavigationBarDividerColor,
      systemNavigationBarIconBrightness: style.systemNavigationBarIconBrightness,
    ) ?? style;

    if (history.isEmpty || newStyle != latestStyle) {
      history.add(newStyle);
      SystemChrome.setSystemUIOverlayStyle(newStyle);
    }
  }

  static void setPreviousUiOverlayStyle() {
    if (history.length > 1) {
      history.removeLast();
      setSystemUiOverlayStyle(history.last);
    }
  }
}
