import 'dart:ui';

import 'package:flutter/material.dart';

double lpToPx(BuildContext context, double px) {
  return MediaQuery.of(context).devicePixelRatio * px;
}

void postFrame(VoidCallback callback) {
  assert(callback != null);
  WidgetsBinding.instance.addPostFrameCallback((_) => callback());
}

Future<T> openDialog<T>(BuildContext context, Widget dialog,
    {bool dismissable = true}) async {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, anim, secondaryAnim) {
      return dialog;
    },
    barrierColor: Colors.black38,
    barrierDismissible: dismissable,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 200),
  );
}
