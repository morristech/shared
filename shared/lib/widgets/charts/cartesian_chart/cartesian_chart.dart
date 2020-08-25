import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

export 'annotations.dart';
export 'cartesian_chart.dart';
export 'cartesian_chart_data.dart';
export 'cartesian_chart_painter.dart';

/// How and if to animate an object (e.g. a ChartSeries).
enum AnimState {
  /// Object is new and should be animated in.
  incoming,

  /// Object should'nt be animated.
  staying,

  /// Object should be animated out.
  outgoing,
}

abstract class CartesianChart<T, D, S extends CartesianSeries<T>> extends Chart<T, S> {
  final D Function(T, int) x;
  final num Function(T, int) y;
  final num maxY;
  final num minY;
  final D maxX;
  final D minX;
  final double thickness;
  final Axises<D> axises;
  final List<Color> color;
  final List<Color> shadow;
  final double elevation;
  final StrokeCap strokeCap;
  final List<Annotation> annotations;
  const CartesianChart({
    Key key,
    @required List<S> data,
    @required EdgeInsets padding,
    @required double width,
    @required double height,
    @required Legend<T> legend,
    @required this.x,
    @required this.y,
    this.axises,
    this.thickness = 4.0,
    this.color = const [Colors.black, Colors.black],
    this.shadow = const [Colors.black38, Colors.black38],
    this.elevation = 0.0,
    this.maxY,
    this.minY,
    this.maxX,
    this.minX,
    Duration duration = const Millis(500),
    Curve curve = Curves.linear,
    this.strokeCap = StrokeCap.round,
    this.annotations = const [],
  })  : assert(data != null),
        assert(annotations != null),
        assert(color != null),
        assert(color is List<Color>,
            'Make sure to call dynamicToColors(color) when passing to the super constructor.'),
        assert(shadow == null || shadow is List<Color>,
            'Make sure to call dynamicToColors(shadow) when passing to the super constructor.'),
        super(
          key: key,
          data: data,
          duration: duration,
          curve: curve,
          width: width,
          height: height,
          padding: padding,
          legend: legend,
        );
}

abstract class CartesianChartState<
    T,
    D,
    C extends CartesianChart<T, D, CartesianSeries<T>>,
    CCD extends CartesianChartData<T, D>> extends ChartState<T, C, CCD> {
  List<Stop> verticalStops = [];
  List<Stop> prevVerticalStops = [];
  List<Stop> get allVerticalStops => _getStops(prevVerticalStops, verticalStops);
  List<Stop> horizontalStops = [];
  List<Stop> _prevHorizontalStops = [];
  List<Stop> get allHorizontalStops => _getStops(_prevHorizontalStops, horizontalStops);
  List<Stop> verticalGuides = [];
  List<Stop> _prevVerticalGuides = [];
  List<Stop> get allVerticalGuides => _getStops(_prevVerticalGuides, verticalGuides);
  List<Stop> horizontalGuides = [];
  List<Stop> _prevHorizontalGuides = [];
  List<Stop> get allHorizontalGuides =>
      _getStops(_prevHorizontalGuides, horizontalGuides);

  List<Stop> _getStops(List<Stop> a, List<Stop> b) {
    final changes = detectChanges(a, b);
    // ignore: avoid_function_literals_in_foreach_calls
    changes.added.forEach((a) => a.state = AnimState.incoming);
    // ignore: avoid_function_literals_in_foreach_calls
    changes.removed.forEach((r) => r.state = AnimState.outgoing);
    return changes.added + changes.stayed + changes.removed;
  }

  @override
  void initState() {
    super.initState();
    postFrame(() => _updateStops());
  }

  /// Subclasses should make a super call to this function after applying there own values.
  /// This function will assign the other default values of a [CartesianChart].
  ///
  /// Example implementation in [BarChart]:
  ///
  /// @override
  /// BarChartData<T, D> getChartData([BarChartData<T, D> data]) {
  ///  List<BarSeries<T>> s = List.from(widget.data);
  ///  for (final series in s) {
  ///    series
  ///      ..color ??= widget.color
  ///      ..shadow ??= widget.shadow ?? series.color
  ///      ..elevation ??= widget.elevation
  ///      ..barWidth ??= widget.thickness
  ///      ..cornerRadius ??= widget.cornerRadius
  ///      ..border ??= dynamicToColors(widget.border)
  ///      ..borderThickness ??= widget.borderThickness
  ///      ..gradientDirection ??= widget.gradientDirection;
  ///  }
  ///
  ///  final chartData = BarChartData<T, D>(
  ///    series: s,
  ///    targets: s,
  ///    groupSpacing: widget.groupSpacing,
  ///    barGroupingType: widget.barGroupingType,
  ///  );
  ///
  ///  return super.getChartData(chartData);
  /// }
  @override
  CCD getChartData([CCD data]) {
    if (data != null) {
      final List<CartesianSeries<T>> s = List.from(widget.data);

      // Apply values if there are null to be able to interpolate between them
      // and assign the numerical values for the painter.
      for (final series in s) {
        series.values.clear();
        for (var i = 0; i < series.data.length; i++) {
          final value = series.data[i];
          series.values.add(ChartValue(
            widget.x(value, i),
            widget.y(value, i),
          ));
        }
      }

      final extrema = Extrema.ofObjects(s, widget.annotations).copyWith(
        maxX: ChartValue(widget.maxX, 0).x,
        minX: ChartValue(widget.minX, 0).x,
        maxY: ChartValue(0, widget.maxY).y,
        minY: ChartValue(0, widget.minY).y,
      );

      data
        ..extrema ??= extrema
        ..tExtrema ??= extrema
        ..annotations ??= widget.annotations
        ..axises ??= widget?.axises?.clone(strokeCap: widget.strokeCap)
        ..strokeCap ??= widget.strokeCap;

      // Call adjust data on the painter.
      final painter = getPainter(data);
      painter.adjustData(data);
    }

    return data;
  }

  @override
  void didUpdateWidget(C oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateStops();
  }

  void _updateStops() {
    _prevHorizontalStops = List<Stop>.from(horizontalStops);
    prevVerticalStops = List<Stop>.from(verticalStops);

    _prevHorizontalGuides = List<Stop>.from(horizontalGuides);
    _prevVerticalGuides = List<Stop>.from(verticalGuides);
  }
}
