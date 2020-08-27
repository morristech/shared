import '../constants/constants.dart';
import '../utils/utils.dart';
import 'num.dart';

typedef Predicate<T> = bool Function(T item);

extension IterableExtension<T> on Iterable<T> {
  T get firstOrNull {
    try {
      return first;
    } catch (_) {
      return null;
    }
  }

  T get lastOrNull {
    try {
      return last;
    } catch (_) {
      return null;
    }
  }

  int get lastIndex => length - 1;

  List<E> mapWithIndex<E>(E Function(T item, int index) mapper) {
    var i = 0;
    return map((e) => mapper(e, i++)).toList();
  }

  /// Counts the occurances of the given [predicate] or adds up
  /// the results returned by [predicate].
  N count<N extends num>(dynamic Function(T item) predicate) {
    num count = 0;
    for (final item in this) {
      final value = predicate.call(item);
      if (value == null) continue;

      assert(value is bool || value is num, value);
      if (value is bool && value == true) {
        count++;
      } else if (value is num) {
        count += value;
      }
    }

    return count as N;
  }

  /// Returns a copy of this list.
  List<T> copy([T Function(T) copier]) => map((t) => copier?.call(t) ?? t).toList();

  /// Returns the first occurance that matches the given [predicate].
  T find(Predicate<T> predicate, {T orElse}) {
    for (final item in this) {
      if (predicate(item)) return item;
    }
    return orElse;
  }

  bool includes(Predicate<T> predicate) => find(predicate) != null;

  /// Returns a new list of items for which [predicate] equals true.
  List<T> filter(Predicate<T> predicate) {
    final List<T> result = [];
    for (final item in this) {
      if (predicate(item)) result.add(item);
    }
    return result;
  }

  /// Returns a new list with a length of <= `count` beggining
  /// at `start`.
  List<T> slice(int count, {int start = 0}) {
    if (start >= length) {
      return <T>[];
    }

    return toList().sublist(start, (start + count).atMost(length));
  }

  T getMax(num Function(T item) lambda) {
    T value;
    num max = minInt;
    for (final item in this) {
      final v = lambda(item);
      if (v > max) {
        value = item;
        max = v;
      }
    }

    return value;
  }

  T getMin(num Function(T item) lambda) {
    T value;
    num min = maxInt;
    for (final item in this) {
      final v = lambda(item);
      if (v < min) {
        value = item;
        min = v;
      }
    }

    return value;
  }

  List<List<T>> groupBy<E>(E Function(T item) value) {
    final List<List<T>> result = [];

    for (final item in this) {
      final v = value(item);
      List<T> groupToAdd;
      for (final group in result) {
        if (value(group.first) == v) {
          groupToAdd = group;
          break;
        }
      }

      if (groupToAdd != null) {
        groupToAdd.add(item);
      } else {
        result.add([item]);
      }
    }

    return result;
  }
}

extension MyListExtension<T> on List<T> {
  T getOrNull(dynamic index) {
    if (this == null) return null;

    try {
      return this[index];
    } catch (_) {
      return null;
    }
  }

  T getOrElse(dynamic index, T other) => getOrNull(index) ?? other;

  void removeAll(List<T> items) {
    for (final item in items) {
      remove(item);
    }
  }

  void forEachIndexed(void Function(T, int) callback, {int skip = 1}) {
    assert(skip != null);
    for (var i = 0; i < length; i += skip) {
      callback(this[i], i);
    }
  }

  T pickRandom() {
    assert(isNotEmpty);
    final index = (length * random()).floor();
    return this[index];
  }

  /// Removes the [item] if already present and inserts the [item] at the specified
  /// [index]. If [index] is null the [item] gets added to the list.
  bool upsert(T item, {int index}) {
    final contains = this.contains(item);
    if (contains) {
      remove(item);
    }

    index == null ? add(item) : insert(index, item);
    return contains;
  }

  void sortBy(List<Comparable Function(T item)> fields) {
    sort((a, b) {
      for (final field in fields) {
        final r = field(a).compareTo(field(b));
        if (r != 0) {
          return r;
        }
      }

      return 0;
    });
  }

  double avgOf(num Function(T item) value) {
    if (length == 0) return 0.0;
    return count(value) / length;
  }
}

extension NumIterableX on Iterable<num> {
  double get avg => count((v) => v) / length;
}

extension MapExtensions<K, V> on Map<K, V> {
  V get(String key) => this[key];
}
