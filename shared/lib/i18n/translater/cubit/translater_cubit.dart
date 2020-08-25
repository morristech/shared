import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:shared/shared.dart';

import 'package:shared/i18n/internationalization.dart';
import 'package:shared/i18n/translater/model/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'translater_state.dart';

class TranslaterCubit extends Cubit<TranslaterState> {
  TranslaterCubit() : super(TranslaterLoadingState()) {
    _load();
  }

  bool _didChangeTranslations = false;

  final _dao = _TranslationDao();

  void _load() async {
    final cached = await _dao.getTranslations();
    if (cached != null) {
      _didChangeTranslations = true;
      emit(cached);
    } else {
      emit(TranslaterLanguageChooserState(
        I18n.languages.filter((item) => item != I18n.defaultLanguage),
      ));
    }
  }

  void onLanguageChoosen(Language language) async {
    final map = await I18n.loadTranslations(language);
    emit(TranslaterEditState(
      _didChangeTranslations,
      language.englishName,
      _createTranslations(map),
    ));
  }

  void onAddLanguage(String language) async {
    // ignore: invalid_use_of_visible_for_testing_member
    final emptyMap = I18n.defaultTranslations.map((key, value) => MapEntry(key, ''));
    emit(TranslaterEditState(
      _didChangeTranslations,
      language,
      _createTranslations(emptyMap),
    ));
  }

  void onTranslationSubmitted(Translation translation) {
    final state = this.state as TranslaterEditState;
    final translations = state.translations;

    for (var i = 0; i < translations.length; i++) {
      final tr = translations[i];
      if (tr.key == translation.key) {
        translations
          ..insert(i, translation)
          ..removeAt(i + 1);
        break;
      }
    }

    emit(state.copyWith(
      translations: translations,
      isSubmittable: true,
    ));
  }

  void onSubmitAll() {
    final state = this.state;
    if (state is TranslaterEditState && state.isSubmittable) {
      _dao.reset();
      emit(TranslaterSubmittedState());
    }
  }

  void onSave() {
    if (state is TranslaterEditState) {
      _dao.saveTranslations(state);
    }
  }

  void onReset() {
    if (state is TranslaterEditState) {
      _dao.reset();
      onAddLanguage((state as TranslaterEditState).language);
    }
  }

  List<Translation> _createTranslations(Map<String, String> mapping) {
    // ignore: invalid_use_of_visible_for_testing_member
    final defaultMapping = I18n.defaultTranslations;

    final List<Translation> translations = [];
    mapping.forEach((key, value) {
      translations.add(
        Translation(
          key: key,
          original: defaultMapping[key] ?? '',
          translation: value,
        ),
      );
    });

    return translations;
  }
}

class _TranslationDao {
  final prefs = SharedPreferences.getInstance();

  Future<void> saveTranslations(TranslaterEditState state) async =>
      (await prefs).setString('translations', state.toJson());
  Future<TranslaterEditState> getTranslations() async =>
      TranslaterEditState.fromJson((await prefs).getString('translations'));
  Future<void> reset() => saveTranslations(null);
}
