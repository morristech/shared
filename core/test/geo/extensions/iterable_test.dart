import 'package:test/test.dart';

import 'package:core/core.dart';

void main() {
  group('sortBy', () {
    test('Should sort the list by multiple fields', () async {
      // arrange
      final list = [Dummy('Ben', 88), Dummy('Ben', 12), Dummy('Anna', 18)];
      // act
      list.sortBy([(d) => d.name, (d) => d.age]);
      // assert
      expect(list, equals([Dummy('Anna', 18), Dummy('Ben', 12), Dummy('Ben', 88)]));
    });
  });

  group('distinct', () {
    test('Should filter all duplicate values from the list', () async {
      expect([1, 1, 2, 3, 4].distinct(), equals([1, 2, 3, 4]));
    });
  });

  group('distinctBy', () {
    test('Should create a new list from a list with only the elements that pass the test',
        () async {
      // arrange
      final list = [Dummy('Newt', 10), Dummy('John', 20), Dummy('Newt', 30)];
      // act
      final result = list.distinctBy(
        (result, item) => item.name != 'Newt' || !result.any((e) => e.name == 'Newt'),
      );
      // assert
      expect(result, equals([Dummy('Newt', 10), Dummy('John', 20)]));
    });
  });
}

class Dummy {
  final String name;
  final int age;
  Dummy(this.name, this.age);

  @override
  String toString() => 'Dummy(name: $name, age: $age)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Dummy && o.name == name && o.age == age;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}
