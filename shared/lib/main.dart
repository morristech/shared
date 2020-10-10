import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await I18n.init([
    Language.english,
    Language.german,
  ]);

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
          child: RRectProgressBar(
            running: false,
            strokeWidth: 6.0,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 200,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
