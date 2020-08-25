import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'rotated_text.dart';

class KineticText extends StatefulWidget {
  final String text;
  final int count;
  final TextStyle style;
  final Duration duration;
  final Duration entranceDuration;
  final bool gestureAware;
  const KineticText({
    Key key,
    @required this.text,
    this.count = 20,
    this.style,
    this.duration = const Duration(seconds: 2),
    this.entranceDuration = const Duration(seconds: 5),
    this.gestureAware = true,
  })  : assert(text != null),
        assert(count != null),
        super(key: key);

  @override
  _KineticTextState createState() => _KineticTextState();
}

class _KineticTextState extends State<KineticText> with TickerProviderStateMixin {
  AnimationController _rotationController;

  AnimationController _entranceController;
  CurvedAnimation _entranceAnimation;

  int get numberOfTexts => widget.count;

  double initialDx = 0;
  double currentDx = 0;
  double initialValue = 0.0;

  bool get isForward => currentDx <= initialDx;
  double get width => (context.findRenderObject() as RenderBox).size.width;
  double get rotationValue => isForward ? _rotationController.value : 1 - _rotationController.value;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: widget.entranceDuration,
    )..forward();

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
  }

  void _addDelta(double delta) {
    final v = initialValue + delta;
    _rotationController.value = v > 1.0 ? v - v.floor() : v;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gestureAware) {
      return withGestureDetector();
    }

    return _buildCarousel();
  }

  Widget _buildCarousel() {
    final texts = List<Widget>.generate(
      numberOfTexts,
      _buildText,
    );

    return Stack(
      alignment: Alignment.center,
      children: texts,
    );
  }

  Widget _buildText(int index) {
    final rotatedText = RotatedText(
      word: widget.text,
      style: widget.style,
      entranceAnimation: _entranceAnimation,
    );

    return AnimatedBuilder(
      animation: _rotationController,
      child: rotatedText,
      builder: (context, child) {
        final t = _entranceAnimation.value;
        const pi = math.pi; // lerpDouble(math.pi / 2, math.pi, t);

        final animationRotationValue = rotationValue * 2 * pi / numberOfTexts;
        double rotation = 2 * pi * index / numberOfTexts + (pi / 2) + animationRotationValue;

        final isOnLeft = math.cos(rotation) > 0;

        if (isOnLeft) {
          rotation = -rotation + 2 * animationRotationValue - pi * 2 / numberOfTexts;
        }

        final pivot = lerpDouble(-(math.pi / 4), 0, t);
        final translation = lerpDouble(-240, -120, t);

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(pivot)
            ..rotateY(rotation)
            ..translate(translation),
          child: child,
        );
      },
    );
  }

  Widget withGestureDetector() {
    return GestureDetector(
      onTap: () {
        if (_entranceController.isCompleted) {
          _entranceController.reverse();
        } else if (_entranceController.isDismissed) {
          _entranceController.forward();
        }
      },
      onPanStart: (details) {
        initialDx = details.globalPosition.dx;
        initialValue = _rotationController.value;
        _rotationController.stop();
      },
      onPanUpdate: (details) {
        currentDx = details.globalPosition.dx;
        final delta = ((currentDx - initialDx).abs() / width) * 6;
        _addDelta(delta);
      },
      onPanEnd: (details) async {
        final velocity = details.velocity.pixelsPerSecond.dx;

        final upperBound = velocity.abs() / 200;
        final controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: velocity.abs() ~/ 2),
        );

        final animation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
        animation.addListener(() {
          _addDelta(animation.value * upperBound);
        });

        await controller.forward();
        controller.dispose();
        _rotationController.repeat();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: _buildCarousel(),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
}
