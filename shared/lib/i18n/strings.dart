import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'package:intl/intl.dart';

import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language.dart';

enum Gender { male, female, other }

class Strings {
  const Strings._();

  static const String LANGUAGE_KEY = 'language';

  static void Function(Language) _onLanguageChanged;
  static set onLanguageChangedCallback(void Function(Language) callback) =>
      _onLanguageChanged = callback;

  static List<Language> _supportedLanguages;
  static List<Language> get supportedLanguages => _supportedLanguages;
  static Language get defaultLanguage => _supportedLanguages[0];

  static Language _language;
  static Language get language => _language;
  static Locale get locale => language?.locale;
  static String get languageCode => language?.code;
  static bool _useSystemLocale = false;
  static bool get usesSystemLocale => _useSystemLocale;

  static Map<String, String> _currentMapping;
  static Map<String, String> _defaultMapping;
  static bool get isInitalized => _currentMapping != null;

  static String dir = 'i18n';
  static String placeholder = '%s';
  static bool initializeDateFormatting = false;

  static bool isTest = false;
  static bool throwAssertionErrorWhenMissing = true;

  static Future<SharedPreferences> get _preferences =>
      !isTest ? SharedPreferences.getInstance() : null;

  static Future<void> init(
    List<Language> languages, {
    String placeholder,
    bool initializeDateFormatting,
  }) async {
    assert(languages.isNotEmpty);

    Strings.initializeDateFormatting = initializeDateFormatting == true;
    Strings.placeholder = placeholder ?? Strings.placeholder;

    _supportedLanguages = languages;
    await _loadLanguage();

    _subscribeToLocaleChanges();
  }

  static void _subscribeToLocaleChanges() {
    ui.window.onLocaleChanged = () {
      if (_useSystemLocale) {
        setLanguage();
      }
    };
  }

  static Future<void> test(
    Language language, {
    String placeholder,
    bool initializeDateFormatting,
  }) async {
    isTest = true;

    return init(
      [language],
      placeholder: placeholder,
      initializeDateFormatting: initializeDateFormatting,
    );
  }

  /// Loads the [key] from the previously loaded language file and returns the value.
  ///
  /// The [placeholders] parameter can be used to replace any placeholders (the default is '%s' which can
  /// be changed during [init()]).
  ///
  /// The [capitalize] parameter can be used to capitalize the first character of the string.
  static String of(
    String key, {
    dynamic placeholders,
    bool capitalize = false,
  }) {
    if (_currentMapping == null) {
      assert(
        _currentMapping != null,
        'Strings are not yet initalized. Make sure init() is called before calling Strings.of().',
      );

      return key;
    }

    String string = _read(key);

    if (placeholders != null) {
      string =
          _placeholders(string, placeholders is List ? placeholders : [placeholders]);
    }

    return string;
  }

  static String _placeholders(String src, List placeholders) {
    final regex = RegExp(r'{(.*?)}');
    final pluralRegex = RegExp(r'([0-9]:)+');
    final genderRegex = RegExp(r'([male, female, other]:)+');

    for (final p in placeholders) {
      final placeholder = regex.stringMatch(src);
      if (placeholder == null) continue;

      final isPluralPlaceholder = p is num && pluralRegex.hasMatch(placeholder);
      final isGenderPlaceholder = p is Gender && genderRegex.hasMatch(placeholder);
      if (isGenderPlaceholder) {
        src = _gender(src, p);
      } else if (isPluralPlaceholder) {
        src = _plural(src, p);
      } else {
        src = src.replaceFirst(regex, '$p');
      }
    }

    return src;
  }

  static String _getPlaceholderGroup(String src) {
    final group = RegExp(r'{(.*?)}').stringMatch(src);
    if (group == null) return null;
    return group.removePrefix('{').removeSuffix('}');
  }

  static String _gender(String src, Gender gender) {
    final group = _getPlaceholderGroup(src);
    if (group == null) return src;

    bool didFindGender = false;
    for (final match in group.split(',')) {
      if (!match.contains(':')) continue;

      final genderPrefix =
          match.substring(0, match.indexOf(':')).removeSuffix(':').trim();
      final value = match.substring(match.indexOf(':')).removePrefix(':').trim();

      final isMale = genderPrefix == 'male' && gender == Gender.male;
      final isFemale = genderPrefix == 'female' && gender == Gender.female;
      final isOther = genderPrefix == 'other' && gender == Gender.other;
      final isElse = genderPrefix == 'else';

      if (isMale || isFemale || isOther || isElse) {
        didFindGender = true;
        src = src.replaceFirst('{$group}', value);
        break;
      }
    }

    assert(
      didFindGender,
      "No corresponding gender value found for $gender in '$src'",
    );

    return src;
  }

  static String _plural(String src, num count) {
    final group = _getPlaceholderGroup(src);
    if (group == null) return src;

    final groups = group.split(',');
    for (final match in groups) {
      if (!match.contains(':')) continue;

      final plural = match.substring(0, match.indexOf(':')).removeSuffix(':').trim();
      var modifier = match.substring(match.indexOf(':')).removePrefix(':').trim();

      if (plural == 'else' || count == num.tryParse(plural)) {
        final formattedCount =
            NumberFormat.decimalPattern(Strings.locale?.scriptCode).format(count);

        if (groups.first.contains('&i')) {
          modifier = groups.first.replaceFirst('&i', '$formattedCount') + modifier;
        } else if (groups.last.contains('&i')) {
          modifier = modifier + groups.last.replaceFirst('&i', '$formattedCount');
        }

        src = src.replaceFirst('{$group}', modifier);
        break;
      }
    }

    return src;
  }

  /// Retrives the value of the given [key] from the JSON mapping.
  static String _read(String key) {
    String translation = _currentMapping[key];

    if (translation == null && _defaultMapping != null) {
      translation = _defaultMapping[key];
    }

    if (throwAssertionErrorWhenMissing) {
      assert(
        translation != null,
        'JSON key $key not found in the ${language.englishName} translation mapping!',
      );
    }

    return translation ?? key;
  }

  /// Updates the apps language and persists it to device storage.
  ///
  /// When [code] and [language] are null, it will set the devices default
  /// langauge, if your app supports it. Otherwise it will use the default
  /// langauge which is the first language in your `supportedLanguages`.
  static Future<Language> setLanguage({String code, Language language}) async {
    final Language lang = code == null && language == null
        ? null
        : _resolveLanguageForCode(code ?? language?.code);

    await _saveLanguage(lang);
    await _loadLanguage();

    _onLanguageChanged?.call(language);

    return language;
  }

  static Future<void> _saveLanguage(Language lang) async {
    return (await _preferences)?.setString(LANGUAGE_KEY, lang?.code);
  }

  /// Loads the language from the JSON file under the path lang/[language code].json.
  static Future<void> _loadLanguage() async {
    _language = await _getBestLanguage();

    String langId;
    Future<String> loadLanguageFile(String code, [String fileLanguageId = 'json']) async {
      langId = fileLanguageId;

      Future<String> retry() {
        if (fileLanguageId == 'json') {
          return loadLanguageFile(code, 'yaml');
        } else {
          throw ArgumentError.value(
            'The ${language.englishName} language file ($dir/$code) doesn\'t exist!',
          );
        }
      }

      try {
        return await _loadFile('$dir/$code.$fileLanguageId', isTest);
      } on Error {
        return retry();
      } on Exception {
        return retry();
      }
    }

    try {
      Map<String, String> _convertFileToStringMap(String file) {
        Map<String, dynamic> map;
        switch (langId) {
          case 'yaml':
            map = YamlParser.parse(file);
            break;
          default:
            map = json.decode(file);
        }

        return map?.map((key, value) => MapEntry(key, value?.toString()));
      }

      final currentFile = await loadLanguageFile(language.code);
      _currentMapping = _convertFileToStringMap(currentFile);

      if (language.code != defaultLanguage.code) {
        final defaultFile = await loadLanguageFile(defaultLanguage.code);
        _defaultMapping = _convertFileToStringMap(defaultFile);
      }
    } on Error {
      rethrow;
    }

    _initializeDateFormatting();
  }

  static void _initializeDateFormatting() {
    if (initializeDateFormatting) {
      // intl.initializeDateFormatting(language.code);
    }
  }

  /// Retrieves the persisted language from SharedPreferences.
  ///
  /// If the persisted language is null, it will follow the system
  /// language if it is included in your supported languages. Otherwise
  /// it will use the first language in your supported languages list.
  static Future<Language> _getBestLanguage() async {
    final stored = (await _preferences)?.getString(LANGUAGE_KEY);
    _useSystemLocale = stored == null;

    if (_useSystemLocale) {
      return _getNextSupportedSystemLanguage();
    } else {
      return _resolveLanguageForCode(stored) ?? defaultLanguage;
    }
  }

  /// Returns the closes system locale that the app supports.
  static Language _getNextSupportedSystemLanguage() {
    for (final locale in ui.window.locales ?? <Locale>[]) {
      final code = locale.toLanguageTag().replaceAll('-', '_');
      final language = _resolveLanguageForCode(code);
      if (language != null) {
        return language;
      }
    }

    return defaultLanguage;
  }

  /// Returns the corresponding [Language] for the given [code]
  /// when present in [_supportedLanguages].
  static Language _resolveLanguageForCode(String code) {
    if (code == null) {
      return null;
    }

    // Check if there is a language with the exact
    // locale code.
    for (final lang in _supportedLanguages) {
      if (lang.code == code) {
        return lang;
      }
    }

    // Check if there is a language with the same
    // language code. E.g. code == 'en' && lang.code == 'en_US'
    for (final lang in _supportedLanguages) {
      if (lang.code.startsWith(code)) {
        return lang;
      }
    }

    // Check if there is a language with the same
    // language code. E.g. code == 'en_US' && lang.code == 'en'
    for (final lang in _supportedLanguages) {
      if (code.startsWith(lang.code)) {
        return lang;
      }
    }

    return null;
  }
}

Future<String> _loadFile(String path, bool isTest) {
  if (isTest) {
    String dir = Directory.current.path;
    if (Platform.isWindows) {
      dir += '\\${path.replaceAll('/', '\\')}';
    } else {
      dir += '/$path';
    }

    return File(dir).readAsString();
  } else {
    return rootBundle.loadString(path);
  }
}

class YamlParser {
  const YamlParser._();

  static Map<String, String> parse(String file) {
    final Map<String, String> result = {};
    final lines = file.split('\n');

    bool isNewSection(String line) => RegExp(r'\w+:$').hasMatch(line.trimRight());
    bool isLangPair(String line) => RegExp(r'\w+:\s.+').hasMatch(line.trim());

    int sectionIndentation = 0;
    final List<Pair<String, int>> sections = [];
    for (String line in lines) {
      final indentation = _getTabIndentation(line);
      line = line.trimLeft();

      // Ignore comments.
      if (line.trimLeft().startsWith('#')) {
        continue;
      }

      String getPrefixForIndentation() {
        final List<int> alreadyForIndentation = [];

        return sections
            .copy()
            .reversed
            .filter(
              (s) {
                if (s.second < indentation && !alreadyForIndentation.contains(s.second)) {
                  alreadyForIndentation.add(s.second);
                  return true;
                }

                return false;
              },
            )
            .map((s) => s.first)
            .toList()
            .reversed
            .join('_');
      }

      if (isNewSection(line)) {
        final name = line.substring(0, line.indexOf(':'));
        final Pair<String, int> section = Pair(name, indentation);

        if (indentation > sectionIndentation) {
          sections.add(section);
        } else if (indentation == sectionIndentation) {
          if (sections.isNotEmpty) sections.removeLast();
          sections.add(section);
        } else if (indentation < sectionIndentation) {
          for (var i = 0; i < (sectionIndentation - indentation); i++) {
            if (sections.isNotEmpty) sections.removeLast();
          }

          sections.add(section);
        }

        sections.add(section);
        sectionIndentation = indentation;
      } else if (isLangPair(line)) {
        final key = line.substring(0, line.indexOf(':')).trim();
        String value = line.substring(line.indexOf(':') + 1);

        final prefix = getPrefixForIndentation();
        final jsonKey = prefix.isNotEmpty ? '${prefix}_$key' : key;

        // Remove carriage returns
        value = value.replaceAll('\r', '');
        // Add new line charaters
        value = value.replaceAll('\\n', '\n');
        // Remove the first spacing
        value = value.removePrefix(' ');
        // Remove string ticks
        value = value.removePrefix('\"').removeSuffix('\"');
        value = value.removePrefix("'").removeSuffix("'");

        result[jsonKey] = value;
      }
    }

    return result;
  }

  static int _getTabIndentation(String line) {
    int indentation = 0;
    bool wasBlankBefore = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      final isBlank = char == ' ';
      if (isBlank && wasBlankBefore) {
        wasBlankBefore = false;
        indentation++;
        continue;
      } else {
        wasBlankBefore = isBlank;
      }
    }

    return indentation;
  }
}
