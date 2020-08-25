import 'dart:async';

import 'package:flutter/material.dart';

class Animator extends StatefulWidget {
  final bool toEnd;
  final Widget child;
  final Duration duration;
  final Duration period;
  final bool reverseRepeat;
  final bool animateInitial;
  final Curve curve;
  final Widget Function(BuildContext context, Animation<double> animation, Widget child) builder;
  const Animator({
    Key key,
    this.toEnd = true,
    this.child,
    @required this.duration,
    this.period,
    this.reverseRepeat = false,
    this.animateInitial = false,
    this.curve = Curves.linear,
    @required this.builder,
  }) : super(key: key);

  @override
  _AnimatorState createState() => _AnimatorState();
}

class _AnimatorState extends State<Animator> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (widget.period != null) {
      _animate();
    } else if (widget.toEnd) {
      if (widget.animateInitial) {
        _controller.forward();
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void didUpdateWidget(Animator oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller.duration = widget.duration;

    if (widget.curve != oldWidget.curve) {
      _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    }

    final didChangePeriod = widget.period != oldWidget.period;
    final didChangeRepeat = widget.reverseRepeat != oldWidget.reverseRepeat;
    final didChangeToEnd = widget.toEnd != oldWidget.toEnd;

    if (didChangeToEnd || didChangePeriod || didChangeRepeat) {
      _animate();
    }
  }

  void _animate() {
    if (widget.period != null) {
      void animate() async {
        if (widget.reverseRepeat) {
          await _controller.forward();
          _controller.reverse();
        } else {
          _controller
            ..reset()
            ..forward();
        }
      }

      animate();
      _timer?.cancel();
      _timer = Timer.periodic(
        widget.period + (widget.reverseRepeat ? widget.duration * 2 : widget.duration),
        (_) => animate(),
      );
    } else if (widget.toEnd) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _animation, widget.child);

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
