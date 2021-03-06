import 'package:get_it/get_it.dart';

const Di di = Di._();

class Di {
  const Di._();
  static const Di instance = di;

  set allowReassignment(bool value) => GetIt.I.allowReassignment = value;

  /// Singleton.
  void put<T>(T dependency) => GetIt.I.registerSingleton<T>(dependency);

  /// Factory.
  void builder<T>(T Function() builder) => GetIt.I.registerFactory(builder);

  /// Lazy singleton.
  void lazy<T>(T Function() builder) => GetIt.I.registerLazySingleton<T>(builder);

  /// Async singleton.
  void putAsync<T>(Future<T> Function() builder) =>
      GetIt.I.registerSingletonAsync(builder);

  T call<T>() => find<T>();
  T find<T>() => GetIt.I<T>();
}
