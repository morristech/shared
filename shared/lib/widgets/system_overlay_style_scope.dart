import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

class SystemOverlayStyleScope extends StatelessWidget {
  final SystemUiOverlayStyle style;

  /// The color of the system bottom navigation bar.
  ///
  /// Only honored in Android versions O and greater.
  final Color systemNavigationBarColor;

  /// The color of the divider between the system's bottom navigation bar and the app's content.
  ///
  /// Only honored in Android versions P and greater.
  final Color systemNavigationBarDividerColor;

  /// The brightness of the system navigation bar icons.
  ///
  /// Only honored in Android versions O and greater.
  final Brightness systemNavigationBarIconBrightness;

  /// The color of top status bar.
  ///
  /// Only honored in Android version M and greater.
  final Color statusBarColor;

  /// The brightness of top status bar.
  ///
  /// Only honored in iOS.
  final Brightness statusBarBrightness;

  /// The brightness of the top status bar icons.
  ///
  /// Only honored in Android version M and greater.
  final Brightness statusBarIconBrightness;

  final Widget child;

  const SystemOverlayStyleScope({
    Key key,
    @required this.child,
    this.style,
    this.systemNavigationBarColor,
    this.systemNavigationBarDividerColor,
    this.systemNavigationBarIconBrightness,
    this.statusBarColor,
    this.statusBarBrightness,
    this.statusBarIconBrightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      child: child,
      value: style ??
          (AppTheme.of(context)?.uiOverlayStyle ?? const SystemUiOverlayStyle()).copyWith(
            systemNavigationBarColor: systemNavigationBarColor,
            systemNavigationBarDividerColor: systemNavigationBarDividerColor,
            systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
            statusBarBrightness: statusBarBrightness,
            statusBarColor: statusBarColor,
            statusBarIconBrightness: statusBarIconBrightness,
          ),
    );
  }
}
