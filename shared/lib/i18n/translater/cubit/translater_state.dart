part of 'translater_cubit.dart';

abstract class TranslaterState extends Equatable {
  const TranslaterState();

  @override
  List<Object> get props => [];
}

class TranslaterLoadingState extends TranslaterState {}

class TranslaterLanguageChooserState extends TranslaterState {
  final List<Language> languages;
  const TranslaterLanguageChooserState(this.languages);

  @override
  List<Object> get props => [languages];
}

class TranslaterEditState extends TranslaterState {
  final bool isSubmittable;
  final String language;
  final List<Translation> translations;
  const TranslaterEditState(
    this.isSubmittable,
    this.language,
    this.translations,
  );

  @override
  List<Object> get props => [translations, language, isSubmittable];

  TranslaterEditState copyWith({
    bool isSubmittable,
    String language,
    List<Translation> translations,
  }) {
    return TranslaterEditState(
      isSubmittable ?? this.isSubmittable,
      language ?? this.language,
      translations ?? this.translations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isSubmittable': isSubmittable,
      'language': language,
      'translations': translations?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory TranslaterEditState.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return TranslaterEditState(
      map['isSubmittable'] ?? false,
      map['language'] ?? '',
      List<Translation>.from(
          map['translations']?.map((x) => Translation.fromMap(x)) ?? const []),
    );
  }

  String toJson() => json.encode(toMap());

  factory TranslaterEditState.fromJson(String source) {
    if (source == null) return null;

    return TranslaterEditState.fromMap(json.decode(source));
  }
}

class TranslaterSubmittedState extends TranslaterState {}
