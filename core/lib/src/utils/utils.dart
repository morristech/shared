import 'dart:math';

export 'di.dart';
export 'durations.dart';
export 'handler.dart';
export 'logger.dart';
export 'lorem_ipsum.dart';
export 'pair.dart';

void unawaited(Future future) {}

double random({double min = 0.0, double max = 1.0}) {
  final r = Random().nextDouble();
  return ((max - min) * r) + min;
}

int randomInt({int min = 0, int max = 100}) {
  final r = Random().nextInt(max);
  return min + (r - 1);
}


