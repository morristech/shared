import 'dart:ui';

import 'package:flutter/material.dart';

class Blur extends StatelessWidget {
  final double sigma;
  final Color color;
  final Widget child;
  const Blur({
    Key key,
    @required this.sigma,
    this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blur = ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(color: color ?? Colors.black.withOpacity(0.01)),
      ),
    );

    if (child == null) {
      return blur;
    } else {
      return Stack(
        children: [child, blur],
      );
    }
  }
}
