export 'iterable.dart';
export 'map.dart';
export 'num.dart';
export 'string.dart';
export 'time.dart';

extension AnyExtensions<T> on T {
  R let<R>(R Function(T it) lambda) => lambda(this);
  T also(void Function(T it) lambda) {
    lambda(this);
    return this;
  }
}
