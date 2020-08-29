import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum ShadowDirection {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
  center,
}

class SimpleGradient {
  final List<Color> colors;
  final Axis axis;
  final List<double> stops;
  SimpleGradient({
    @required List<Color> colors,
    this.axis = Axis.vertical,
    List<double> stops,
  })  : colors = dynamicToColors(colors, true),
        stops = stops ?? calculateColorStops(dynamicToColors(colors, true));
}

class Box extends StatelessWidget {
  final bool clip;
  final dynamic borderRadius;
  final double elevation;
  final num height;
  final num width;
  final num radius;
  final Border border;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;
  final dynamic color;
  final Color shadowColor;
  final List<BoxShadow> boxShadows;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;
  final BoxShape boxShape;
  final AlignmentGeometry alignment;
  final ShadowDirection shadowDirection;
  final Color splashColor;
  final Duration duration;
  final Curve curve;
  final BoxConstraints constraints;
  final bool showInkWell;
  const Box({
    Key key,
    this.clip = true,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.height,
    this.width,
    this.radius,
    this.border,
    this.margin,
    this.padding = const EdgeInsets.all(0),
    this.child,
    this.color = Colors.transparent,
    this.shadowColor = Colors.black12,
    this.boxShadows,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.boxShape = BoxShape.rectangle,
    this.alignment,
    this.shadowDirection = ShadowDirection.bottomRight,
    this.splashColor,
    this.duration,
    this.curve = Curves.linear,
    this.constraints,
    this.showInkWell = true,
  })  : assert(color == null ||
            color is Color ||
            color is SimpleGradient ||
            color is Gradient),
        assert(borderRadius != null),
        super(key: key);

  static const WRAP = -1;

  bool get circle => radius != null || boxShape == BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final r = radius != null ? radius * 2 : null;
    final h = (r ?? height)?.toDouble();
    final w = (r ?? (h != null && width != WRAP ? double.infinity : width))?.toDouble();

    final BorderRadius br = borderRadius is BorderRadius
        ? borderRadius
        : BorderRadius.circular(
            !circle
                ? borderRadius?.toDouble() ?? 0.0
                : w != null ? w / 2.0 : h != null ? h / 2.0 : 0.0,
          );

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (circle || (clip && br != BorderRadius.zero)) {
      content = circle
          ? ClipOval(child: content)
          : ClipRRect(
              borderRadius: br,
              child: content,
            );
    }

    if (onTap != null || onLongPress != null || onDoubleTap != null) {
      content = Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        shape: circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: br),
        child: InkWell(
          splashColor:
              showInkWell ? splashColor ?? theme.splashColor : Colors.transparent,
          highlightColor: showInkWell ? theme.highlightColor : Colors.transparent,
          hoverColor: showInkWell ? theme.hoverColor : Colors.transparent,
          focusColor: showInkWell ? theme.focusColor : Colors.transparent,
          customBorder:
              circle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: br),
          onTap: onTap,
          onLongPress: onLongPress,
          onDoubleTap: onDoubleTap,
          child: content,
        ),
      );
    }

    final List<BoxShadow> boxShadow =
        boxShadows ?? (elevation > 0 && (shadowColor?.opacity ?? 0) > 0)
            ? [
                BoxShadow(
                  color: shadowColor ?? Colors.black12,
                  offset: _getShadowOffset(min(elevation / 5.0, 1.0)),
                  blurRadius: elevation,
                  spreadRadius: 0,
                ),
              ]
            : null;

    LinearGradient gradient;
    if (color is SimpleGradient) {
      final gr = color as SimpleGradient;
      final vertical = gr.axis == Axis.vertical;
      gradient = LinearGradient(
        colors: gr.colors,
        begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
        end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
        stops: gr.stops,
      );
    } else if (color is LinearGradient) {
      gradient = color;
    }

    final boxDecoration = BoxDecoration(
      color: color is Color ? color : null,
      gradient: gradient,
      borderRadius: !circle && (border == null || border.isUniform) ? br : null,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      boxShadow: boxShadow,
      border: border,
    );

    return duration != null && duration > Duration.zero
        ? AnimatedContainer(
            height: h,
            width: w,
            margin: margin,
            alignment: alignment,
            duration: duration,
            curve: curve,
            decoration: boxDecoration,
            constraints: constraints,
            child: content,
          )
        : Container(
            height: h,
            width: w,
            margin: margin,
            alignment: alignment,
            decoration: boxDecoration,
            constraints: constraints,
            child: content,
          );
  }

  Offset _getShadowOffset(double elevation) {
    final ym = 5 * elevation;
    final xm = 2 * elevation;

    switch (shadowDirection) {
      case ShadowDirection.topLeft:
        return Offset(-1 * xm, -1 * ym);
        break;
      case ShadowDirection.top:
        return Offset(0, -1 * ym);
        break;
      case ShadowDirection.topRight:
        return Offset(xm, -1 * ym);
        break;
      case ShadowDirection.right:
        return Offset(xm, 0);
        break;
      case ShadowDirection.bottomRight:
        return Offset(xm, ym);
        break;
      case ShadowDirection.bottom:
        return Offset(0, ym);
        break;
      case ShadowDirection.bottomLeft:
        return Offset(-1 * xm, ym);
        break;
      case ShadowDirection.left:
        return Offset(-1 * xm, 0);
        break;
      default:
        return Offset.zero;
        break;
    }
  }
}
