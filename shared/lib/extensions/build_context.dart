import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension BuildContextExtension on BuildContext {
  T get<T>() => Provider.of<T>(this, listen: false);
}