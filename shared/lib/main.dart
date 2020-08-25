import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await I18n.init([Language.english, Language.german], usesIntl: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Center(
          child: Builder(
            builder: (context) => Column(
              children: [
                RaisedButton(
                  child: Text('Settings'.i18n),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TranslaterPage(appName: 'Flux'),
                    ),
                  ),
                  onLongPress: () {
                    I18n.setLanguage(
                      I18n.language == Language.english
                          ? Language.german
                          : Language.english,
                    );
                  },
                ),
                Text(
                  DateTime(2020, 9, 12, 3, 49).yMMMMEEEEd(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
