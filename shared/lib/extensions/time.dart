// ignore_for_file: non_constant_identifier_names

import 'package:flutter/widgets.dart';

import 'package:core/core.dart';

extension FlutterDateTimeExtions on DateTime {
  /// HOUR_USER_ADJUSTED
  String h(BuildContext context) {
    final is24HourTime = MediaQuery.of(context).alwaysUse24HourFormat;
    return is24HourTime ? H() : j();
  }

  /// HOUR_MINUTE_USER_ADJUSTED
  String hm(BuildContext context) {
    final is24HourTime = MediaQuery.of(context).alwaysUse24HourFormat;
    return is24HourTime ? Hm() : jm();
  }

  /// HOUR_MINUTE_SECOND_USER_ADJUSTED
  String hms(BuildContext context) {
    final is24HourTime = MediaQuery.of(context).alwaysUse24HourFormat;
    return is24HourTime ? Hms() : jms();
  }
}
