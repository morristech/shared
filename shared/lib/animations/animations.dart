export 'curves.dart';
export 'implicit/implicit.dart';
export 'transitions/transitions.dart';
export 'translate.dart';

double interval(num begin, num end, num value) {
  return ((value - begin) / (end - begin)).clamp(0.0, 1.0);
}
