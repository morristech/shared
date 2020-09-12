import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class LayoutPreferences {
  final double tabletThreshold;
  final double desktopThreshold;
  const LayoutPreferences({
    this.tabletThreshold = 600.0,
    this.desktopThreshold = 1200.0,
  })  : assert(tabletThreshold != null),
        assert(desktopThreshold != null),
        assert(tabletThreshold < desktopThreshold);

  @override
  String toString() => 'LayoutPreferences(tabletThreshold: $tabletThreshold, desktopThreshold: $desktopThreshold)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is LayoutPreferences && o.tabletThreshold == tabletThreshold && o.desktopThreshold == desktopThreshold;
  }

  @override
  int get hashCode => tabletThreshold.hashCode ^ desktopThreshold.hashCode;
}

class LayoutConfiguration extends StatelessWidget {
  final Widget child;
  final LayoutPreferences preferences;
  const LayoutConfiguration({
    Key key,
    @required this.child,
    this.preferences = const LayoutPreferences(),
  })  : assert(preferences != null),
        super(key: key);

  static LayoutConfiguration of(BuildContext context) => context.findAncestorWidgetOfExactType<LayoutConfiguration>();

  @override
  Widget build(BuildContext context) => child;
}

typedef _Builder = Widget Function(BuildContext _);

class ConfigurationBuilder extends StatelessWidget {
  final LayoutPreferences preferences;
  final _Builder mobile;
  final _Builder mobileLandscape;
  final _Builder tablet;
  final _Builder tabletLandscape;
  final _Builder desktop;
  final _Builder desktopLandscape;
  final Widget Function(BuildContext context, bool isPortrait, DeviceType type, Size screenSize, Size size) builder;
  const ConfigurationBuilder({
    Key key,
    this.preferences,
    this.mobile,
    this.mobileLandscape,
    this.tablet,
    this.tabletLandscape,
    this.desktop,
    this.desktopLandscape,
    this.builder,
  })  : assert(builder != null || mobile != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final preferences = this.preferences ?? LayoutConfiguration.of(context)?.preferences;
    assert(preferences != null, 'No LayoutPreferences found in the widget tree!');

    final mq = MediaQuery.of(context);
    final orientation = mq.orientation;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width;
        if (orientation == Orientation.landscape) {
          width = mq.size.height;
        } else {
          width = mq.size.width;
        }

        final isLandscape = orientation == Orientation.landscape;

        final type = getDeviceType(preferences, width, orientation);
        if (builder != null) {
          return builder(context, !isLandscape, type, mq.size, constraints.biggest);
        }

        if (type == DeviceType.desktop) {
          if (isLandscape && desktopLandscape != null) {
            return desktopLandscape(context);
          }

          if (desktop != null) {
            return desktop(context);
          }
        }

        if (type == DeviceType.tablet || type == DeviceType.desktop) {
          if (isLandscape && tabletLandscape != null) {
            return tabletLandscape(context);
          }

          if (tablet != null) {
            return tablet(context);
          }
        }

        if (isLandscape && mobileLandscape != null) {
          return mobileLandscape(context);
        } else {
          return mobile(context);
        }
      },
    );
  }

  DeviceType getDeviceType(LayoutPreferences preferences, double width, Orientation orientation) {
    if (width >= preferences.desktopThreshold) {
      return DeviceType.desktop;
    } else if (width >= preferences.tabletThreshold) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}
