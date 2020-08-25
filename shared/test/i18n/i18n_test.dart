import 'package:flutter_test/flutter_test.dart';

import 'package:shared/shared.dart';

void main() async {
  await I18n.test([
    Language.english,
    Language.german,
  ]);

  I18n.setLanguage(Language.german);

  test('Should translate a key correctly', () async {
    expect('Settings'.i18n, equals('Einstellungen'));
    expect('You have {10 hours} left.'.i18n, equals('Dir verbleiben 10 Stunden.'));
  });
}
