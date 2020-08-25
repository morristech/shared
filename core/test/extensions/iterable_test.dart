import 'package:test/test.dart';

import 'package:core/core.dart';

void main() {
  test('Should sort the list by multiple fields', () async {
    // arrange
    final list = [Dummy('Ben', 88), Dummy('Ben', 12), Dummy('Anna', 18)];
    // act
    list.sortBy([(d) => d.name, (d) => d.age]);
    // assert
    expect(list, equals([Dummy('Anna', 18), Dummy('Ben', 12), Dummy('Ben', 88)]));
  });

  // * Maps

  test('Should return the value from the map', () async {
    expect({'key': 0}.get('key'), equals(0));
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
