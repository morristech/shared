import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:core/core.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';


import 'dao.dart';

abstract class RawSembastDao<T extends DBModel> implements Dao<T> {
  final String name;
  RawSembastDao(this.name);

  DatabaseClient _trx;

  StoreRef<int, Map<String, dynamic>> _store;
  StoreRef<int, Map<String, dynamic>> get store {
    return _store ??= intMapStoreFactory.store(name);
  }

  Completer<Database> _dbOpenCompleter;
  Future<Database> get _db async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDatabase();
    }

    return _dbOpenCompleter.future;
  }

  Future _openDatabase() async {
    final path = join((await directory).path, name);
    final db = await databaseFactoryIo.openDatabase(path);
    _dbOpenCompleter.complete(db);
  }

  Future<Directory> get directory;

  Pair<String, dynamic> putFinder(T item) => null;
  Finder getFinder() => null;

  Map<String, dynamic> toMap(T item);
  T fromMap(Map<String, dynamic> map);

  Finder _getFinder(T item) {
    final finder = putFinder(item);
    if (finder == null) {
      return Finder(
        filter: Filter.byKey(item.key),
      );
    } else {
      return Finder(
        filter: Filter.equals(finder.first, finder.second),
      );
    }
  }

  @override
  Future<void> add(T item) async {
    return store.add(
      _trx ?? await _db,
      toMap(item),
    );
  }

  @override
  Future<void> addAll(List<T> items) {
    return transaction(items, (trx, item) async {
      await add(item);
    });
  }

  @override
  Future<void> insert(int index, T item) async {
    final values = await this.values;
    final newItems = List<T>.from(
      values,
    )..insert(
        min(index, values.length),
        item,
      );

    await nuke();
    await addAll(newItems);
  }

  Future<void> insertAll(int index, List<T> items) async {
    final values = await this.values;
    final newItems = List<T>.from(
      values,
    )..insertAll(
        min(index, values.length),
        items,
      );

    await nuke();
    await addAll(newItems);
  }

  @override
  Future<int> update(T item) async {
    return store.update(
      _trx ?? await _db,
      toMap(item),
      finder: _getFinder(item),
    );
  }

  @override
  Future<void> updateAll(List<T> items) {
    return transaction(items, (trx, item) async {
      await update(item);
    });
  }

  @override
  Future<void> delete(T item) async {
    return store.delete(
      _trx ?? await _db,
      finder: _getFinder(item),
    );
  }

  @override
  Future<void> deleteAll(List<T> items) {
    return transaction(items, (trx, item) async {
      await delete(item);
    });
  }

  @override
  Future<List<T>> get values async =>
      mapSnapshots(await store.find(await _db, finder: getFinder()));

  @override
  Stream<List<T>> get stream async* {
    yield* store
        .query(finder: getFinder())
        .onSnapshots(await _db)
        .map((snapshots) => mapSnapshots(snapshots));
  }

  Future<List<T>> find(Finder finder) async =>
      mapSnapshots(await store.find(await _db, finder: finder));

  @override
  Future<void> nuke() async => deleteAll(await values);

  Future<void> transaction(List<T> items, Future Function(Transaction, T) action) async {
    if (items == null || items.isEmpty) return;

    (await _db).transaction((trx) async {
      _trx = trx;
      for (final item in items) {
        await action(trx, item);
      }
    });

    _trx = null;
  }

  List<T> mapSnapshots(List<RecordSnapshot<int, Map<String, dynamic>>> snapshots) {
    final items = snapshots.map((s) => fromMap(s.value)..key = s.key);
    return List<T>.from(items);
  }

  @override
  Future<int> get length async => store.count(await _db);
}
