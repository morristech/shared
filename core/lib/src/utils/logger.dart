import 'package:logger/logger.dart';

final log = Logger();

DateTime _time;

extension LoggerExtensions on Logger {
  void time([String msg]) {
    _time ??= DateTime.now();
    if (msg == null) return;

    final now = DateTime.now();
    final delta = now.difference(_time).inMilliseconds;

    print('+$delta MS | $msg');
  }

  void startTimer() => _time = DateTime.now();

  void stopTimer([String msg]) {
    time(msg);
    _time = null;
  }
}
