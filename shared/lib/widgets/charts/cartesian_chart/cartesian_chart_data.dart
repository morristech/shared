import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

abstract class CartesianSeries<T> extends Series<T> {
  /// The data for this series.
  List<T> data;

  CartesianSeries({
    @required List<T> data,
    @required dynamic id,
    @required String label,
  })  : data = List<T>.from(data),
        assert(data != null),
        super(
          id: id,
          label: label,
        );

  List<ChartValue> values = [];
}

/// The base class for the state of a [CartesianChart].
///
/// Every chart should have its own Data class to hold its state
/// to be able to lerp between them and thus animate the changes.
///
/// The properties will be assigned by the [CartesianChart] when
/// calling the super.getChartData([CartesianChartData subclass]).
abstract class CartesianChartData<T, D> extends ChartData<T> {
  List<Annotation> annotations;
  Axises<D> axises;
  StrokeCap strokeCap;
  Extrema extrema;
  Extrema tExtrema;
  CartesianChartData({
    this.annotations,
    this.axises,
    this.strokeCap,
    this.extrema,
    this.tExtrema,
  }) : super();

  List<Annotation> get xAxisAnnotations => annotations.filter((a) => a.axis == ChartAxis.x);
  List<Annotation> get yAxisAnnotations => annotations.filter((a) => a.axis == ChartAxis.y);
}

class Axises<D> {
  final MainAxis<num> leftAxis;
  final MainAxis<num> rightAxis;
  final MainAxis<D> topAxis;
  final MainAxis<D> bottomAxis;
  final GuideAxis verticalGuides;
  final GuideAxis horizontalGuides;
  const Axises({
    this.leftAxis,
    this.rightAxis,
    this.topAxis,
    this.bottomAxis,
    this.verticalGuides,
    this.horizontalGuides,
  });

  Axises<D> clone({
    DashPattern dashPattern,
    StrokeCap strokeCap,
  }) {
    return Axises(
      topAxis: topAxis?.clone(strokeCap),
      leftAxis: leftAxis?.clone(strokeCap),
      rightAxis: rightAxis?.clone(strokeCap),
      bottomAxis: bottomAxis?.clone(strokeCap),
      verticalGuides: verticalGuides?.clone(
        strokeCap,
        bottomAxis?.labelSpacing ?? topAxis?.labelSpacing,
      ),
      horizontalGuides: horizontalGuides?.clone(
        strokeCap,
        leftAxis?.labelSpacing ?? rightAxis?.labelSpacing,
      ),
    );
  }

  static Axises<D> lerp<D>(Axises<D> a, Axises<D> b, double v) {
    return Axises<D>(
      topAxis: MainAxis.lerp<D>(a?.topAxis, b?.topAxis, v),
      leftAxis: MainAxis.lerp<num>(a?.leftAxis, b?.leftAxis, v),
      rightAxis: MainAxis.lerp<num>(a?.rightAxis, b?.rightAxis, v),
      bottomAxis: MainAxis.lerp<D>(a?.bottomAxis, b?.bottomAxis, v),
      verticalGuides: GuideAxis.lerp(a?.verticalGuides, b?.verticalGuides, v),
      horizontalGuides: GuideAxis.lerp(a?.horizontalGuides, b?.horizontalGuides, v),
    );
  }

  List<MainAxis<num>> get verticalAxises => [leftAxis, rightAxis]..removeWhere((a) => a == null);
  List<MainAxis<D>> get horizontalAxises => [topAxis, bottomAxis]..removeWhere((a) => a == null);
}

typedef AxisLabel<T> = String Function(T value);

class MainAxis<T> {
  final bool show;
  final Color color;
  final double thickness;
  final Ticks ticks;
  final StrokeCap strokeCap;
  final DashPattern dashPattern;
  final TextStyle style;
  final double gap;
  final AxisLabel<T> label;
  final double labelSpacing;
  const MainAxis({
    this.show = true,
    this.color = Colors.grey,
    this.thickness = 3.0,
    this.gap = 8.0,
    this.labelSpacing = 48,
    this.strokeCap,
    this.ticks,
    this.label,
    this.style,
    this.dashPattern,
  })  : assert(gap >= 0.0),
        assert(thickness >= 0.0);

  static MainAxis<T> lerp<T>(MainAxis<T> a, MainAxis<T> b, double v) {
    if (b == null) return null;
    if (a == null) return b;

    return MainAxis<T>(
      show: b.show,
      color: Color.lerp(a.color, b.color, v),
      thickness: lerpDouble(a.thickness, b.thickness, v),
      gap: lerpDouble(a.gap, b.gap, v),
      labelSpacing: b.labelSpacing,
      ticks: Ticks.lerp(a.ticks, b.ticks, v),
      dashPattern: DashPattern.lerp(a.dashPattern, b.dashPattern, v),
      strokeCap: b.strokeCap,
      style: TextStyle.lerp(a.style, b.style, v),
      label: b.label,
    );
  }

  bool get showTicks => show && ticks != null && gap > 0.0;
  bool get showLabels => style != null && label != null;
  double get realThickness => show ? thickness : 0.0;
  double get halfThickness => realThickness / 2;

  void applyOnPaint(Paint paint) {
    paint
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = strokeCap;
  }

  MainAxis<T> clone(
    StrokeCap strokeCap,
  ) {
    return copyWith(
      strokeCap: this.strokeCap == null ? strokeCap : null,
    );
  }

  MainAxis<T> copyWith({
    bool show,
    Color color,
    double thickness,
    double gap,
    Ticks ticks,
    TextStyle style,
    StrokeCap strokeCap,
    DashPattern dashPattern,
    double labelSpacing,
  }) {
    return MainAxis(
      show: show ?? this.show,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      gap: gap ?? this.gap,
      style: style ?? this.style,
      ticks: ticks ?? this.ticks,
      strokeCap: strokeCap ?? this.strokeCap,
      dashPattern: dashPattern ?? this.dashPattern,
      label: label,
      labelSpacing: labelSpacing ?? this.labelSpacing,
    );
  }
}

class Ticks {
  final Color color;
  final double thickness;
  final StrokeCap strokeCap;
  const Ticks({
    this.color,
    this.thickness,
    this.strokeCap,
  });

  static Ticks lerp(Ticks a, Ticks b, double v) {
    if (b == null) return null;

    return Ticks(
      color: Color.lerp(a?.color ?? b?.color?.withOpacity(0), b?.color, v),
      thickness: lerpDouble(a?.thickness, b?.thickness, v),
      strokeCap: b?.strokeCap,
    );
  }

  void applyOnPaint(Paint paint, MainAxis axis) {
    paint
      ..style = PaintingStyle.stroke
      ..color = color ?? axis.color
      ..strokeWidth = thickness ?? axis.thickness
      ..strokeCap = strokeCap ?? axis.strokeCap;
  }

  Ticks copyWith({
    Color color,
    double thickness,
    StrokeCap strokeCap,
  }) {
    return Ticks(
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      strokeCap: strokeCap ?? this.strokeCap,
    );
  }
}

enum GuideStyle {
  line,
  bar,
}

class GuideAxis {
  final bool show;
  final Color color;
  final double thickness;
  final GuideStyle style;
  final StrokeCap strokeCap;
  final DashPattern dashPattern;
  final bool paintLast;
  final double spacing;
  const GuideAxis({
    this.show = true,
    this.color = Colors.grey,
    this.thickness = 1.5,
    this.spacing,
    this.strokeCap,
    this.dashPattern,
    this.style = GuideStyle.line,
    this.paintLast = false,
  });

  static GuideAxis lerp(GuideAxis a, GuideAxis b, double v) {
    if (a == null) return b;
    if (b == null) return null;

    return GuideAxis(
      show: b.show,
      color: Color.lerp(a.color, b.color, v),
      style: b?.style,
      thickness: lerpDouble(a.thickness, b.thickness, v),
      strokeCap: b.strokeCap,
      dashPattern: DashPattern.lerp(a.dashPattern, b.dashPattern, v),
      paintLast: b.paintLast,
      spacing: lerpDouble(a.spacing, b.spacing, v),
    );
  }

  bool get isDashed => dashPattern != null;

  double getThickness() => show ? thickness : 0.0;

  void applyOnPaint(Paint paint) {
    paint
      ..style = style == GuideStyle.line ? PaintingStyle.stroke : PaintingStyle.fill
      ..color = color
      ..strokeCap = strokeCap
      ..strokeWidth = thickness;
  }

  GuideAxis clone(
    StrokeCap strokeCap,
    double spacing,
  ) {
    return copyWith(
      strokeCap: this.strokeCap == null ? strokeCap : null,
      spacing: this.spacing == null ? spacing : null,
    );
  }

  GuideAxis copyWith({
    bool show,
    Color color,
    double thickness,
    GuideStyle style,
    StrokeCap strokeCap,
    DashPattern dashPattern,
    bool paintLast,
    double spacing,
  }) {
    return GuideAxis(
      show: show ?? this.show,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      style: style ?? this.style,
      strokeCap: strokeCap ?? this.strokeCap,
      dashPattern: dashPattern ?? this.dashPattern,
      paintLast: paintLast ?? this.paintLast,
      spacing: spacing ?? this.spacing,
    );
  }
}

class Extrema {
  static const double MIN_DIFFERENCE = 0.000001;
  double maxY;
  double minY;
  double maxX;
  double minX;
  Extrema({
    this.maxY,
    this.minY,
    this.maxX,
    this.minX,
  }) {
    if (maxY == minY) {
      maxY += _factor(maxY);
      minY -= _factor(minY);
    }

    if (maxX == minX) {
      maxX += _factor(maxX);
      minX -= _factor(minX);
    }
  }

  double _factor(double source) {
    source = source.abs();
    if (source < 0.01) {
      return 0.0001;
    } else if (source < 0.1) {
      return 0.001;
    } else if (source < 1.0) {
      return 0.01;
    } else if (source < 10) {
      return 0.1;
    } else {
      return 1;
    }
  }

  static Extrema lerp(Extrema a, Extrema b, double v) {
    return Extrema(
      maxX: lerpDouble(a.maxX, b.maxX, v),
      minX: lerpDouble(a.minX, b.minX, v),
      maxY: lerpDouble(a.maxY, b.maxY, v),
      minY: lerpDouble(a.minY, b.minY, v),
    );
  }

  static Extrema ofObjects(List<CartesianSeries> series, List<Annotation> annotations) {
    double maxY = double.minPositive;
    double minY = double.maxFinite;
    double maxX = double.minPositive;
    double minX = double.maxFinite;
    for (final part in series) {
      for (final value in part.values) {
        final x = value.x;
        final y = value.y;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }

    for (final annotation in annotations) {
      if (annotation.state != AnimState.outgoing) {
        final x = annotation.xAxis ? annotation.to : minX;
        final y = annotation.yAxis ? annotation.to : minY;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }

    return Extrema(maxX: maxX, minX: minX, maxY: maxY, minY: minY);
  }

  @override
  String toString() {
    return '_Extrema maxY: $maxY, minY: $minY, maxX: $maxX, minX: $minX';
  }

  Extrema copyWith({
    double maxY,
    double minY,
    double maxX,
    double minX,
  }) {
    return Extrema(
      maxY: maxY ?? this.maxY,
      minY: minY ?? this.minY,
      maxX: maxX ?? this.maxX,
      minX: minX ?? this.minX,
    );
  }
}
