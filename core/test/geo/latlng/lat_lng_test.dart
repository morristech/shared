import 'package:test/test.dart';

import 'package:core/core.dart';

void main() {
  group('Parse', () {
    test('Should parse a correct latitude longitude string', () async {
      // arrange
      const src = '59.333, 34.88';
      // act
      final result = LatLng.tryParse(src);
      // assert
      expect(result, equals(const LatLng(59.333, 34.88)));
    });

    test('Should return null for an invalid string', () async {
      // arrange
      const src1 = 'akjc, dksjk, hakdkl, dksdjf.';
      const src2 = '-300.0, 499.0';
      // act
      final result1 = LatLng.tryParse(src1);
      final result2 = LatLng.tryParse(src2);
      // assert
      expect(result1, isNull);
      expect(result2, isNull);
    });
  });
}
