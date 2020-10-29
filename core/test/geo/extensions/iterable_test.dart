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

  group('count', () {
    test('Should count the occurances of the given predicate', () async {
      // arrange
      final list = [Mock('Ben', 88), Mock('Ben', 12), Mock('Anna', 18)];
      // act
      // assert
      expect(list.count((m) => m.name.startsWith('B')), equals(2));
    });
  });

  group('sumBy', () {
    test('Should sum the amounts over the given Iterable', () async {
      // arrange
      final list = [Mock('Ben', 5), Mock('Ben', 10), Mock('Anna', 15)];
      // act
      // assert
      expect(list.sumBy((m) => m.age), equals(30));
    });
  });

  group('sortBy', () {
    test('Should sort the list by multiple fields', () async {
      // arrange
      final list = [Mock('Ben', 88), Mock('Ben', 12), Mock('Anna', 18)];
      // act
      list.sortBy([(d) => d.name, (d) => d.age]);
      // assert
      expect(list, equals([Mock('Anna', 18), Mock('Ben', 12), Mock('Ben', 88)]));
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
      final list = [Mock('Newt', 10), Mock('John', 20), Mock('Newt', 30)];
      // act
      final result = list.distinctBy(
        (result, item) => item.name != 'Newt' || !result.any((e) => e.name == 'Newt'),
      );
      // assert
      expect(result, equals([Mock('Newt', 10), Mock('John', 20)]));
    });
  });
}

class Mock {
  final String name;
  final int age;
  Mock(this.name, this.age);

  @override
  String toString() => 'Dummy(name: $name, age: $age)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Mock && o.name == name && o.age == age;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}
