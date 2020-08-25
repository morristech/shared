import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:shared/shared.dart';

void main() {
  final dir = Directory.current.path;
  final filePath = '$dir\\i18n\\en_parser.yaml';
  final content = File(filePath).readAsStringSync();

  test('Should choose the correct parser based on the file name', () async {
    // act
    final result = I18nParser(filePath);
    // assert
    expect(result, isA<YamlParser>());
  });

  test('Should parse the translation file in a key-value map', () async {
    // act
    final result = const YamlParser().parse(content);
    // assert
    expect(
      result,
      equals({
        'settings': 'Settings',
        'hours': '{1: \$i Hour, else: \$i Hours}',
        'home_body_title': 'title',
        'home_hello': 'hello',
      }),
    );
  });
  print(dir);
}
