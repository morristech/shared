import 'package:test/test.dart';

import 'package:core/core.dart';

void main() {
  group('get', () {
    test('Should return the value from the map if it exists', () async {
      expect({'key': 0}.get('key'), equals(0));
    });
  });
}
