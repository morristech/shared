import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:core/core.dart';

abstract class SembastDao<T extends DBModel> extends BaseSembastDao<T> {
  SembastDao(String name) : super(name);

  bool get useCacheDir => false;

  @override
  Future<Directory> get directory {
    return useCacheDir ? getTemporaryDirectory() : getApplicationDocumentsDirectory();
  }
}
