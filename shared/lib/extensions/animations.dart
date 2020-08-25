import 'package:flutter/material.dart';

extension ListTweenExtensions<T> on List<Tween<T>> {
  TweenSequence<T> chain() {
    return TweenSequence<T>(
      map((tween) => TweenSequenceItem(tween: tween, weight: 1)).toList(),
    );
  }
}
