import 'dart:convert';

import 'package:flutter/material.dart';

class Language {
  final String name;
  final String englishName;
  final String code;
  final Locale _locale;
  const Language({
    @required this.name,
    this.englishName,
    @required this.code,
    Locale locale,
  }) : _locale = locale;

  Locale get locale => _locale ?? Locale(code);

  static const Language english = Language(
    name: 'English',
    englishName: 'English',
    code: 'en',
    locale: Locale('en'),
  );

  static const Language german = Language(
    name: 'Deutsch',
    englishName: 'German',
    code: 'de',
    locale: Locale('de'),
  );

  static const Language french = Language(
    name: 'France',
    englishName: 'French',
    code: 'fr',
    locale: Locale('fr'),
  );

  Language copyWith({
    String name,
    String englishName,
    String code,
    Locale locale,
  }) {
    return Language(
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      code: code ?? this.code,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'englishName': englishName,
      'code': code,
    };
  }

  factory Language.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Language(
      name: map['name'] ?? '',
      englishName: map['englishName'] ?? '',
      code: map['code'] ?? '',
      locale: Locale.fromSubtags(languageCode: map['code'] ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory Language.fromJson(String source) => Language.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Language name: $name, englishName: $englishName, code: $code, locale: $locale';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Language &&
        o.name == name &&
        o.englishName == englishName &&
        o.code == code &&
        o._locale == _locale;
  }

  @override
  int get hashCode {
    return name.hashCode ^ englishName.hashCode ^ code.hashCode ^ _locale.hashCode;
  }
}
