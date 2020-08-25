import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

abstract class CartesianChartPainter<
    T,
    D,
    CS extends CartesianSeries<T>,
    C extends CartesianChart<T, D, CS>,
    CCD extends CartesianChartData<T, D>,
    S extends CartesianChartState<T, D, C, CCD>> extends ChartPainter<T, CCD> {
  final CCD data;
  final S parent;
  CartesianChartPainter({
    @required this.parent,
    @required this.data,
  }) {
    _pt = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade300
      ..strokeCap = strokeCap
      ..isAntiAlias = true;
  }

  List<CS> get series;
  C get chart => parent.widget;
  List<Annotation> get xAxisAnnotations => data.xAxisAnnotations;
  List<Annotation> get yAxisAnnotations => data.yAxisAnnotations;

  Axises<D> get axises => data.axises;
  MainAxis<num> get leftAxis => axises?.leftAxis;
  MainAxis<num> get rightAxis => axises?.rightAxis;
  MainAxis<D> get topAxis => axises?.topAxis;
  MainAxis<D> get bottomAxis => axises?.bottomAxis;
  double get maxX => data.extrema.maxX;
  double get minX => data.extrema.minX;
  double get maxY => data.extrema.maxY;
  double get minY => data.extrema.minY;
  StrokeCap get strokeCap => data.strokeCap;
  List<Stop> get _verticalStops => parent.verticalStops;
  List<Stop> get _horizontalStops => parent.horizontalStops;
  List<Stop> get _allVerticalStops => parent.allVerticalStops;
  List<Stop> get _allHorizontalStops => parent.allHorizontalStops;
  List<Stop> get _verticalGuides => parent.verticalGuides;
  List<Stop> get _horizontalGuides => parent.horizontalGuides;
  List<Stop> get _allVerticalGuides => parent.allVerticalGuides;
  List<Stop> get _allHorizontalGuides => parent.allHorizontalGuides;

  double get w => width - (insets.horizontal + (xChartInset * 2));
  double get h => height - (insets.vertical + (yChartInset * 2));
  Rect get rect => Rect.fromLTWH(
        insets.left + (leftAxis?.halfThickness ?? 0),
        insets.top + (topAxis?.halfThickness ?? 0),
        (w + (xChartInset * 2)) - (rightAxis?.halfThickness ?? 0),
        (h + (yChartInset * 2)) - (bottomAxis?.halfThickness ?? 0),
      );

  double get yChartInset => 0.0;
  double get xChartInset => 0.0;
  int get verticalGuideCount => (w ~/ (axises?.verticalGuides?.spacing ?? 1)) + 1;
  int get horizontalGuideCount => (h ~/ (axises?.horizontalGuides?.spacing ?? 1)) + 1;

  EdgeInsets insets = const EdgeInsets.all(0);
  double yAxisWidth = 0;
  double xAxisHeight = 0;

  Paint _pt;

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    assert(data != null);
    layoutAxises();

    final textPadding =
        max(rightAxis?.style?.fontSize ?? 0, leftAxis?.style?.fontSize ?? 0) / 2;
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(0, textPadding.neg, width, height + textPadding))
      ..restore();
  }

  void layoutAxises() {
    _calcHorizontalAxises();
    _calcVerticalAxises();
    _calcHorizontalAxises();

    // Lerp between the insets; for example when the labels need more space.
    if (parent.oldPainter != null) {
      insets = EdgeInsets.lerp(parent.oldPainter.insets, insets, v);
    }
  }

  void paintAxises() {
    _paintHorizontalAxises();
    _paintVerticalAxises();
    _paintAxisAnnotations();
  }

  int horizontalStopCount(MainAxis<D> axis) => (w ~/ axis.labelSpacing) + 1;

  int verticalStopcount(MainAxis<num> axis) => (h ~/ axis.labelSpacing) + 1;

  String horizontalAxisLabel(MainAxis<D> axis, D value, int i) => axis.label?.call(value);

  String verticalAxisLabel(MainAxis<num> axis, num value, int i) =>
      axis?.label?.call(value);

  void _calcHorizontalAxises() {
    if (axises == null) return;

    _horizontalStops.clear();
    _verticalGuides.clear();

    for (final axis in axises.horizontalAxises) {
      final isTop = axis == axises.topAxis;
      final isBottom = !isTop;
      final count = horizontalStopCount(axis);

      double maxHeight = 0.0;
      for (var i = 0; i <= count; i++) {
        final v = (((data.tExtrema.maxX - data.tExtrema.minX) / count) * i) +
            data.tExtrema.minX;
        final label = horizontalAxisLabel(axis, ChartValue.domainOfX<D>(v), i);

        if (!label.isBlank) {
          _horizontalStops.add(Stop.ofX(v, label, axis, isTop));
          final h = _measure(label, axis).height;
          if (h > maxHeight) maxHeight = h;
        }
      }

      if (axis.show) maxHeight += axis.thickness;
      if (axis.showLabels && maxHeight > 0.0) maxHeight += axis.gap;

      if (isTop) insets = insets.copyWith(top: maxHeight);
      if (isBottom) insets = insets.copyWith(bottom: maxHeight);
    }

    final guide = axises.verticalGuides;
    if (guide != null) {
      final count = verticalGuideCount;
      for (var i = 0; i <= count; i++) {
        final v = (((data.tExtrema.maxX - data.tExtrema.minX) / count) * i) +
            data.tExtrema.minX;
        _verticalGuides.add(Stop.ofX(v));
      }
    }
  }

  void _calcVerticalAxises() {
    if (axises == null) return;

    _verticalStops.clear();
    _horizontalGuides.clear();
    for (final axis in axises.verticalAxises) {
      final isLeft = axis == axises.leftAxis;
      final isRight = !isLeft;
      final count = verticalStopcount(axis);

      double maxWidth = 0.0;
      for (var i = 0; i <= count; i++) {
        final v = (((data.tExtrema.maxY - data.tExtrema.minY) / count) * i) +
            data.tExtrema.minY;
        final label = verticalAxisLabel(axis, v, i);

        if (!label.isBlank) {
          _verticalStops.add(Stop.ofY(v, label, axis, isLeft));
          final w = _measure(label, axis).width;
          if (w > maxWidth) maxWidth = w;
        }
      }

      if (axis.show) maxWidth += axis.thickness;
      if (axis.showLabels && maxWidth > 0.0) maxWidth += axis.gap;

      if (isLeft) insets = insets.copyWith(left: maxWidth);
      if (isRight) insets = insets.copyWith(right: maxWidth);
    }

    final guide = axises.horizontalGuides;
    if (guide != null) {
      final count = horizontalGuideCount;
      for (var i = 0; i <= count; i++) {
        final v = (((data.tExtrema.maxY - data.tExtrema.minY) / count) * i) +
            data.tExtrema.minY;
        _horizontalGuides.add(Stop.ofY(v));
      }
    }
  }

  void _paintHorizontalAxises() {
    if (axises == null) return;

    for (final stop in _allHorizontalStops) {
      final isFirst = stop == _horizontalStops.first;
      final isLast = stop == _horizontalStops.last;
      final isStart = stop.isStart;
      final axis = stop.axis;

      final dx =
          (((stop.value - minX) / (maxX - minX)) * w) + (insets.left + xChartInset);
      final dy = stop.isStart ? insets.top : height - insets.bottom;

      if (axis.showTicks && axis.showLabels) {
        axis.ticks.applyOnPaint(_pt, axis);
        stop.fade(_pt, v);

        drawLine(
          Offset(dx, stop.isStart ? dy - axis.halfThickness : dy + axis.halfThickness),
          Offset(
              dx,
              stop.isStart
                  ? dy + (axis.gap / 2)
                  : dy + (axis.gap / 2) + axis.halfThickness),
          _pt,
        );
      }

      if (axis.showLabels && !stop.text.isBlank) {
        Alignment align;
        if (isFirst && !axis.showTicks) {
          align = stop.isStart ? Alignment.bottomLeft : Alignment.topLeft;
        } else if (isLast && !axis.showTicks) {
          align = stop.isStart ? Alignment.bottomRight : Alignment.topRight;
        } else {
          align = stop.isStart ? Alignment.bottomCenter : Alignment.topCenter;
        }

        drawText(
          TextSpan(
            text: stop.text,
            style: axis.style.copyWith(
              color: axis.style.color.withOpacity(
                lerpDouble(
                  0,
                  axis.style.color.opacity,
                  stop.state == AnimState.incoming
                      ? v
                      : stop.state == AnimState.outgoing ? 1.0 - v : 1.0,
                ),
              ),
            ),
          ),
          Offset(
            dx,
            isStart ? dy - axis.gap : dy + axis.gap + axis.thickness,
          ),
          align: align,
        );
      }
    }

    final guide = axises.verticalGuides;
    if (guide != null) {
      var i = -1;
      for (final stop in _allVerticalGuides) {
        if (_verticalGuides.contains(stop)) i++;
        final isFirst = stop == _verticalGuides.first;
        final isLast = stop == _verticalGuides.last;
        final dx =
            (((stop.value - minX) / (maxX - minX)) * w) + (insets.left + xChartInset);
        final start = Offset(dx, insets.top);
        final end = Offset(dx, height - insets.bottom);

        guide.applyOnPaint(_pt);

        if (guide.style == GuideStyle.line &&
            (!isFirst || xChartInset > 0) &&
            (!isLast || guide.paintLast)) {
          stop.fade(_pt, v);
          drawLine(
            start,
            end,
            _pt,
            dashPattern: guide?.dashPattern,
          );
        } else if (guide.style == GuideStyle.bar && i.isEven && !isLast) {
          final wm = w / verticalGuideCount;
          final x1 = Offset((wm * i) + insets.left, insets.top);
          final x2 = Offset((wm * (i + 1)) + insets.left, h);
          if (x2.dx < rect.right) {
            drawRect(
              Rect.fromPoints(x1, x2),
              _pt,
            );
          }
        }
      }
    }

    for (final axis in axises.horizontalAxises) {
      final dy = axis == axises.topAxis ? insets.top : height - insets.bottom;

      if (axis.show) {
        axis.applyOnPaint(_pt);
        drawLine(
          Offset(insets.left, dy),
          Offset(width - insets.right, dy),
          _pt,
        );
      }
    }
  }

  void _paintVerticalAxises() {
    if (axises == null) return;

    for (final stop in _allVerticalStops) {
      final isFirst = stop == _verticalStops.first;
      final isLast = stop == _verticalStops.last;
      final axis = stop.axis;
      final dx = stop.isStart ? insets.left : width - insets.right;
      final dy =
          h - (((stop.value - minY) / (maxY - minY)) * h) + (insets.top + yChartInset);

      if (axis.showTicks && axis.showLabels) {
        axis.ticks.applyOnPaint(_pt, axis);
        stop.fade(_pt, v);

        drawLine(
          Offset(
            stop.isStart
                ? dx - ((axis.gap / 2) + axis.halfThickness)
                : dx + ((axis.gap / 2) + axis.halfThickness),
            dy,
          ),
          Offset(dx, dy),
          _pt,
        );
      }

      if (axis.showLabels && !stop.text.isBlank) {
        Alignment align;
        if (isFirst && !axis.showTicks) {
          align = stop.isStart ? Alignment.topRight : Alignment.topLeft;
        } else if (isLast && !axis.showTicks) {
          align = stop.isStart ? Alignment.bottomRight : Alignment.bottomLeft;
        } else {
          align = stop.isStart ? Alignment.centerRight : Alignment.centerLeft;
        }

        drawText(
          TextSpan(
            text: stop.text,
            style: axis.style.copyWith(
              color: axis.style.color.withOpacity(
                lerpDouble(
                  0,
                  axis.style.color.opacity,
                  stop.state == AnimState.incoming
                      ? v
                      : stop.state == AnimState.outgoing ? 1.0 - v : 1.0,
                ),
              ),
            ),
          ),
          Offset(
            dx + ((stop.isStart ? -1 : 1) * (axis.gap + axis.halfThickness)),
            dy,
          ),
          align: align,
        );
      }
    }

    final guide = axises.horizontalGuides;
    if (guide != null) {
      var i = -1;
      for (final stop in _allHorizontalGuides) {
        if (_horizontalGuides.contains(stop)) i++;
        final isFirst = stop == _horizontalGuides.first;
        final isLast = stop == _horizontalGuides.last;
        final dy =
            h - (((stop.value - minY) / (maxY - minY)) * h) + (insets.top + yChartInset);
        final start = Offset(insets.left, dy);
        final end = Offset(width - insets.right, dy);

        guide.applyOnPaint(_pt);
        if (guide.style == GuideStyle.line &&
            (!isFirst || yChartInset > 0) &&
            (!isLast || guide.paintLast)) {
          stop.fade(_pt, v);
          drawLine(
            start,
            end,
            _pt,
            dashPattern: guide?.dashPattern,
          );
        } else if (guide.style == GuideStyle.bar && !i.isEven) {
          final hm = h / horizontalGuideCount;
          final y1 = Offset(insets.left, (hm * i) + insets.top);
          final y2 = Offset(w + insets.left, (hm * (i + 1)) + insets.top);
          if (y2.dy < rect.bottom) {
            drawRect(
              Rect.fromPoints(y1, y2),
              _pt,
            );
          }
        }
      }
    }

    for (final axis in axises.verticalAxises) {
      final dx = axis == axises.leftAxis ? insets.left : width - insets.right;

      if (axis.show) {
        axis.applyOnPaint(_pt);
        drawLine(
          Offset(dx, insets.top),
          Offset(dx, height - insets.bottom),
          _pt,
        );
      }
    }
  }

  void _paintAxisAnnotations() {
    canvas.save();
    canvas.clipRect(rect);
    for (final annotation in data.annotations) {
      final af = annotation.isIncoming ? v : annotation.isOutgoing ? 1.0 - v : 1.0;
      double getY(double v) =>
          (height - (((v - minY) / (maxY - minY)) * height)) + insets.top;
      double getX(double v) => (((v - minX) / (maxX - minX)) * width) + insets.left;
      final isX = annotation.xAxis;
      final isY = !isX;
      final start = Offset(isX ? getX(annotation.from) : insets.left,
          isX ? insets.top + (height * (1.0 - af)) : getY(annotation.to));
      final end = Offset(
          isY ? w : getX(annotation.to), isY ? getY(annotation.from) * af : height);

      final rect = Rect.fromPoints(start, end);
      annotation.applyOnPaint(_pt, af);
      canvas.drawRect(rect, _pt);

      // Draw annotation labels.
      final anchor = annotation.anchor;
      double dy = start.dx;
      if (anchor == AnnotationLabelAnchor.start) {
        dy = start.dy;
      } else if (anchor == AnnotationLabelAnchor.middle) {
        dy = ((end.dy - start.dy) / 2) + start.dy;
      } else if (anchor == AnnotationLabelAnchor.end) {
        dy = end.dy;
      }

      final o = annotation.orientation;
      void drawLabel(
        String text,
        Offset offset,
        Alignment align,
      ) =>
          drawText(
            TextSpan(
              text: text,
              style: annotation.labelStyle.copyWith(
                color: annotation.labelStyle.color.withOpacity(
                  lerpDouble(0.0, annotation.labelStyle.color.opacity, af),
                ),
              ),
            ),
            offset,
            align: align,
            angle: (isX && o == AnnotationLabelOrientation.horizontal) ||
                    (isY &&
                        (o == AnnotationLabelOrientation.horizontal ||
                            o == AnnotationLabelOrientation.auto))
                ? 0
                : 270,
          );

      if (annotation.startLabel != null) {
        Alignment align;
        final offset = Offset(start.dx, dy);
        if (anchor == AnnotationLabelAnchor.start) {
          align = Alignment.topLeft;
        } else if (anchor == AnnotationLabelAnchor.middle) {
          align = Alignment.centerLeft;
        } else if (anchor == AnnotationLabelAnchor.end) {
          align = Alignment.bottomLeft;
        }

        drawLabel(annotation.startLabel, offset, align);
      }

      if (annotation.middleLabel != null) {
        Alignment align;
        final offset = Offset(((end.dx - start.dx) / 2) + start.dx, dy);
        if (anchor == AnnotationLabelAnchor.start) {
          align = Alignment.topCenter;
        } else if (anchor == AnnotationLabelAnchor.middle) {
          align = Alignment.center;
        } else if (anchor == AnnotationLabelAnchor.end) {
          align = Alignment.bottomCenter;
        }

        drawLabel(annotation.middleLabel, offset, align);
      }

      if (annotation.endLabel != null) {
        Alignment align;
        final offset = Offset(end.dx, dy);
        if (anchor == AnnotationLabelAnchor.start) {
          align = Alignment.topRight;
        } else if (anchor == AnnotationLabelAnchor.middle) {
          align = Alignment.centerRight;
        } else if (anchor == AnnotationLabelAnchor.end) {
          align = Alignment.bottomRight;
        }

        drawLabel(annotation.endLabel, offset, align);
      }
    }
    canvas.restore();
  }

  Size _measure(String text, MainAxis axis) {
    return measureText(TextSpan(text: text, style: axis.style));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Stop {
  final double value;
  final String text;
  final bool isY;
  final bool isStart;
  final MainAxis axis;
  Stop(
    this.value,
    this.text,
    this.isY,
    this.isStart,
    this.axis,
  );

  AnimState state = AnimState.staying;
  bool get isIncoming => state == AnimState.incoming;
  bool get isOutgoing => state == AnimState.outgoing;
  bool get isStaying => state == AnimState.staying;

  bool get isX => !isY;
  bool get isEnd => !isStart;

  factory Stop.ofY(double v, [String text, MainAxis axis, bool isStart = true]) {
    return Stop(v, text, true, isStart, axis);
  }

  factory Stop.ofX(double v, [String text, MainAxis axis, bool isStart = true]) {
    return Stop(v, text, false, isStart, axis);
  }

  void fade(Paint paint, double v) {
    paint.color = paint.color.withOpacity(
      lerpDouble(
        0,
        paint.color.opacity,
        state == AnimState.incoming ? v : state == AnimState.outgoing ? 1.0 - v : 1.0,
      ).clamp(0.0, 1.0),
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Stop && o.value == value && o.text == text;
  }

  @override
  int get hashCode {
    return value.hashCode ^ text.hashCode ^ isY.hashCode;
  }

  @override
  String toString() {
    return 'AxisGuide state: $state, value: $value, text: $text, _isY: $isY';
  }

  Stop copyWith({
    double value,
    String text,
    MainAxis axis,
    bool isStart,
  }) {
    final guide = Stop(
      value ?? this.value,
      text ?? this.text,
      isY,
      isStart ?? this.isStart,
      axis ?? this.axis,
    );

    return guide;
  }
}
