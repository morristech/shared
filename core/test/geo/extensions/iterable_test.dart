import 'package:test/test.dart';

import 'package:core/core.dart';

void main() {
  group('getExtremas', () {
    const nums = [-1, 0, 1, 2, 3];
    final dates = [DateTime(1970), DateTime(1990), DateTime(2010)];

    test('Should return the min and max values from the given Iterable', () async {
      // act
      final numExtremas = nums.getExtremas((item) => item);
      final dateExtremas = dates.getExtremas((item) => item);
      // assert
      expect(numExtremas.first, equals(-1));
      expect(numExtremas.second, equals(3));
      expect(dateExtremas.first, equals(DateTime(1970)));
      expect(dateExtremas.second, equals(DateTime(2010)));
    });

    test('Should return the min value from the given iterable', () async {
      // assert
      expect(nums.getMin((item) => item), equals(-1));
      expect(dates.getMin((item) => item), equals(DateTime(1970)));
    });

    test('Should return the max value from the given Iterable', () async {
      // assert
      expect(nums.getMax((item) => item), equals(3));
      expect(dates.getMax((item) => item), equals(DateTime(2010)));
    });
  });

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
