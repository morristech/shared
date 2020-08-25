part of 'translater_page.dart';

class _LanguageChooserPage extends StatelessWidget {
  final List<Language> languages;
  _LanguageChooserPage({
    Key key,
    @required this.languages,
  }) : super(key: key);

  final ValueNotifier<String> query = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Translated languages',
              style: textTheme.headline6,
            ),
          ),
          const SizedBox(height: 8),
          buildTranslatedLanguagesList(context),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add a new language',
              style: textTheme.headline6,
            ),
          ),
          const SizedBox(height: 8),
          buildLanguageInputField(context),
        ],
      ),
    );
  }

  Widget buildTranslatedLanguagesList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final language = languages[index];

        return ListTile(
          title: Text(language.name),
          subtitle: Text(language.englishName),
          onTap: () => context.bloc<TranslaterCubit>().onLanguageChoosen(language),
        );
      },
    );
  }

  Widget buildLanguageInputField(BuildContext context) {
    final cubit = context.bloc<TranslaterCubit>();

    return ValueListenableBuilder<String>(
      valueListenable: query,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                autocorrect: false,
                onSubmitted: cubit.onAddLanguage,
                onChanged: (query) => this.query.value = query,
                decoration: const InputDecoration(
                  hintText: 'You language (e.g. Spanish, German, French)',
                ),
              ),
              const SizedBox(height: 8),
              RaisedButton(
                onPressed: query.value.isNotEmpty
                    ? () => cubit.onAddLanguage(query.value)
                    : null,
                child: const Text('Continue'),
              )
            ],
          ),
        );
      },
    );
  }
}
