import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Configures where to anchor the label.
enum AnnotationLabelAnchor {
  /// Anchor to the starting side of the annotation range.
  start,

  /// Anchor to the middle of the annotation range.
  middle,

  /// Anchor to the ending side of the annotation range.
  end,
}

/// How the label should be orientated relative to the chart.
enum AnnotationLabelOrientation {
  horizontal,
  vertical,
  auto,
}

class Annotation extends ChartLifecycleObject {
  final Color color;
  final String startLabel;
  final String middleLabel;
  final String endLabel;
  final TextStyle labelStyle;
  final AnnotationLabelAnchor anchor;
  final AnnotationLabelOrientation orientation;
  final ChartAxis axis;
  Annotation(
    dynamic start,
    dynamic end, {
    @required dynamic id,
    @required this.axis,
    @required this.color,
    this.startLabel,
    this.middleLabel,
    this.endLabel,
    this.labelStyle,
    this.orientation = AnnotationLabelOrientation.auto,
    this.anchor = AnnotationLabelAnchor.start,
  })  : assert(id != null),
        assert(axis != null),
        assert(color != null) {
    if (startLabel != null || middleLabel != null || endLabel != null) {
      assert(
        labelStyle != null,
        'When providing a label, a label style must also be provided.',
      );
    }

    if (xAxis) {
      from = ChartValue(start, 0).x;
      to = ChartValue(end, 0).x;
    } else {
      from = ChartValue(0, start).y;
      to = ChartValue(0, end).y;
    }
  }

  bool get xAxis => axis == ChartAxis.x;
  bool get yAxis => axis == ChartAxis.y;

  double from;
  double to;

  void applyOnPaint(Paint paint, double v) {
    paint
      ..color = color.withOpacity(lerpDouble(0, color.opacity, v))
      ..style = PaintingStyle.fill;
  }

  static List<Annotation> lerpAll(List<Annotation> a, List<Annotation> b, double v) {
    final List<Annotation> incoming = [];
    final List<Annotation> staying = [];
    final List<Annotation> outgoing = [];
    for (final annotation in b) {
      final old = a.find((anno) => anno == annotation);
      if (old != null) {
        staying.add(Annotation.lerp(
          old,
          annotation..state = AnimState.staying,
          v,
        ));
      } else {
        incoming.add(annotation..state = AnimState.incoming);
      }
    }

    for (final annotation in a) {
      if (!b.contains(annotation)) {
        outgoing.add(annotation..state = AnimState.outgoing);
      }
    }

    return incoming + staying + outgoing;
  }

  static Annotation lerp(Annotation a, Annotation b, double v) {
    return Annotation(
      b.from,
      b.to,
      anchor: b.anchor,
      id: b.id,
      color: Color.lerp(a.color, b.color, v),
      axis: b.axis,
      startLabel: b.startLabel,
      middleLabel: b.middleLabel,
      endLabel: b.endLabel,
      orientation: b.orientation,
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, v),
    )
      ..from = lerpDouble(a.from, b.from, v)
      ..to = lerpDouble(a.to, b.to, v);
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Annotation && o.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
