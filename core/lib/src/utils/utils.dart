import 'dart:math';

export 'di.dart';
export 'handler.dart';
export 'logger.dart';
export 'lorem_ipsum.dart';
export 'pair.dart';
export 'time.dart';

void unawaited(Future future) {}

Future<void> delayed(Duration delay) => Future.delayed(delay);

double random({double min = 0.0, double max = 1.0}) {
  final r = Random().nextDouble();
  return ((max - min) * r) + min;
}

int randomInt({int min = 0, int max = 100}) {
  final r = Random().nextInt(max);
  return min + (r - 1);
}


