import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

List<String> readChars(String source) {
  final List<String> chars = [];
  for (final rune in source.runes) {
    final char = String.fromCharCode(rune);
    chars.add(char);
  }

  return chars.reversed.toList();
}

class RotatedText extends StatelessWidget {
  final String word;
  final TextStyle style;
  final Animation<double> entranceAnimation;
  const RotatedText({
    Key key,
    @required this.word,
    this.style,
    this.entranceAnimation,
  })  : assert(word != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final chars = readChars(word);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: chars.map((c) => _buildChar(side, c)).toList(),
        );
      },
    );
  }

  Widget _buildChar(double side, String char) {
    final text = RotatedBox(
      quarterTurns: 3,
      child: Container(
        child: Text(
          char,
          style: style ??
              TextStyle(
                color: Colors.white,
                fontSize: side / 5,
                fontWeight: FontWeight.w900,
              ),
        ),
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.9), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.0, 0.2, 0.8],
          ),
        ),
      ),
    );

    if (entranceAnimation == null) return text;

    return AnimatedBuilder(
      child: text,
      animation: entranceAnimation,
      builder: (context, child) {
        final t = entranceAnimation.value;
        final rotation = lerpDouble(math.pi / 4, 0.0, t);
        final scale = t;
        final skew = lerpDouble(1.0, 0.0, const Interval(0.33, 1.0).transform(t));

        return Transform(
          transform: Matrix4.skewX(skew)
            ..rotateZ(-rotation)
            ..scale(scale),
          child: child,
        );
      },
    );
  }
}
