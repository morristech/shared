export 'curves.dart';
export 'implicit/implicit.dart';
export 'transitions/transitions.dart';
export 'translate.dart';

double interval(double begin, double end, double t) {
  assert(t != null);

  return ((t - begin) / (end - begin)).clamp(0.0, 1.0);
}
