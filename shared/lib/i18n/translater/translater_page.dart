import 'package:flutter/material.dart' hide Placeholder;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared/shared.dart';

import 'cubit/translater_cubit.dart';
import 'model/translation.dart';

part 'language_chooser_page.dart';
part 'submitted_page.dart';
part 'translation_edit_page.dart';

class TranslaterPage extends StatelessWidget {
  final String appName;
  const TranslaterPage({
    Key key,
    @required this.appName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TranslaterCubit(),
      child: BlocBuilder<TranslaterCubit, TranslaterState>(
        builder: (context, state) {
          final child = state.let((it) {
            if (state is TranslaterLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TranslaterLanguageChooserState) {
              return _LanguageChooserPage(languages: state.languages);
            } else if (state is TranslaterEditState) {
              return _TranslationEditPage(state: state);
            } else if (state is TranslaterSubmittedState) {
              return const _SubmittedPage();
            }
          });

          return Scaffold(
            body: LiftOnScrollAppBar(
              maxElevation: 8,
              title: Text(
                state is TranslaterEditState ? state.language : 'Translate $appName',
              ),
              actions: [buildSubmitButton(context, state), const SizedBox(width: 16),],
              body: child,
            ),
          );
        },
      ),
    );
  }

  Widget buildSubmitButton(BuildContext context, TranslaterState state) {
    return AnimatedOpacity(
      opacity: state is TranslaterEditState && state.isSubmittable ? 1.0 : 0.0,
      duration: const Millis(400),
      child: Center(
        child: OutlineButton(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          highlightedBorderColor: Colors.white.withOpacity(0.7),
          onPressed: context.bloc<TranslaterCubit>().onSubmitAll,
          child: const Text('Submit'),
        ),
      ),
    );
  }
}
