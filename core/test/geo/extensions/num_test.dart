import 'package:test/test.dart';

import 'package:core/core.dart';

void main() {
  group('Num extensions', () {
    test('Should return the negative of the number when positive', () async {
      expect(1.neg, equals(1));
      expect(-1.neg, equals(-1));
    });

    test('Should coerce the number to be at least the number specified', () async {
      expect(1.atLeast(2), equals(2));
      expect(2.atLeast(1), equals(2));
    });

    test('Should coerce the number to be at most the number specified', () async {
      expect(2.atMost(1), equals(1));
      expect(1.atMost(2), equals(1));
    });

    test('Should return true if a number is in between two numbers', () async {
      expect(2.isBetween(1, 3), isTrue);
      expect(4.isBetween(1, 3), isFalse);
    });

    test('Should swap the sign of the number', () async {
      expect(1.swapSign(), equals(-1));
      expect(-1.swapSign(), equals(1));
    });

    test('Should wrap the number to the specified bounds', () async {
      expect(5.wrapAt(0, 3), equals(2));
      expect((-1).wrapAt(0, 3), equals(2));
      expect(3.wrapAt(0, 3), equals(3));
    });

    test('Should linearly interpolate between the two doubles', () async {
      expect(lerpDouble(0.0, 10.0, 0.5), equals(5.0));
      expect(lerpDouble(5.0, 0.0, 0.5), equals(2.5));
    });

    test(
      'Should linearly interpolate between the two numbers and round to the nearest int',
      () async {
        expect(lerpInt(0, 10, 0.5), equals(5));
        expect(lerpInt(5, 0, 0.5), equals(3));
      },
    );
  });

  group('Int extensions', () {
    test('Should generate a range including the last number', () async {
      expect(0.to(5), equals([0, 1, 2, 3, 4, 5]));
      expect(5.to(0), equals([5, 4, 3, 2, 1, 0]));
    });

    test(
      'Should generate a range exluding the last number on ascending ranges or the first number on descending ranges',
      () async {
        expect(0.until(5), equals([0, 1, 2, 3, 4]));
        expect(5.until(0), equals([4, 3, 2, 1, 0]));
      },
    );
  });

  group('Double extensions', () {
    test('Should round the double to the given precision', () async {
      expect(1.2345.roundToPrecision(2), equals(1.23));
      expect(4.36890.roundToPrecision(3), equals(4.369));
    });
  });
}
