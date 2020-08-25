import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import 'progress_bar_data.dart';

part 'circular_progress_bar.dart';
part 'horizontal_progress_bar.dart';

abstract class _ProgressBar extends ImplicitAnimation {
  final double size;
  final double value;
  final double strokeWidth;
  final double backgroundStrokeWidth;
  final double elevation;
  final Color color;
  final Color backgroundColor;
  final Color shadowColor;
  final bool round;
  const _ProgressBar({
    Key key,
    @required Duration duration,
    @required Curve curve,
    @required this.size,
    @required this.value,
    @required this.strokeWidth,
    @required this.backgroundStrokeWidth,
    @required this.elevation,
    @required this.color,
    @required this.backgroundColor,
    @required this.shadowColor,
    @required this.round,
  })  : assert(value == null || (value >= 0.0 && value <= 1.0)),
        assert(strokeWidth != null && strokeWidth >= 0.0),
        assert(backgroundStrokeWidth != null && backgroundStrokeWidth >= 0.0),
        assert(elevation != null && elevation >= 0.0),
        assert(round != null),
        super(
          key,
          duration,
          curve,
        );
}

abstract class _ProgressBarState<W extends _ProgressBar> extends ImplicitAnimationState<ProgressBarData, W>
    with TickerProviderStateMixin {
  AnimationController _controller;

  Duration get indeterminateDuration => const Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: indeterminateDuration,
      vsync: this,
    );

    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  ProgressBarData lerp(ProgressBarData a, ProgressBarData b, double t) => a.scaleTo(b, t);

  @override
  ProgressBarData get newValue {
    return ProgressBarData(
      size: widget.size,
      color: widget.color ?? Theme.of(context).accentColor,
      round: widget.round,
      progress: widget.value?.clamp(0.0, 1.0),
      elevation: widget.elevation,
      shadowColor: widget.shadowColor ?? widget.color ?? Colors.black26,
      strokeWidth: widget.strokeWidth,
      backgroundColor: widget.backgroundColor ?? Theme.of(context).dividerColor,
      backgroundStrokeWidth: widget.backgroundStrokeWidth,
    );
  }

  @nonVirtual
  @override
  Widget builder(BuildContext context, ProgressBarData data) {
    return Semantics(
      value: data.progress != null ? '${(data.progress * 100).round()} %' : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return buildProgressBar(context, data, _controller.value);
        },
      ),
    );
  }

  Widget buildProgressBar(BuildContext context, ProgressBarData data, double animationValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

abstract class _ProgressBarPainter extends BasePainter {
  final ProgressBarData data;
  final double animationValue;
  _ProgressBarPainter(
    this.data,
    this.animationValue,
  );

  double get progress => data.progress;
  double get strokeWidth => data.strokeWidth;
  double get backgroundStrokeWidth => data.backgroundStrokeWidth;
  double get elevation => data.elevation;
  Color get color => data.color;
  Color get backgroundColor => data.backgroundColor;
  Color get shadowColor => data.shadowColor;
  bool get round => data.round;

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.animationValue != animationValue;
  }
}
