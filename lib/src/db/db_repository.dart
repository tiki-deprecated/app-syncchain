/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'db_model.dart';

class DBRepository {
  static const String _table = 'sync_chain';
  final _log = Logger('DBRepository');

  final Database _database;

  DBRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'hash BLOB PRIMARY KEY, '
          'version_id TEXT NOT NULL, '
          'synced_epoch INTEGER NOT NULL);');

  Future<DBModel> insert(DBModel model, {Transaction? txn}) async {
    await (txn ?? _database).insert(_table, model.toMap());
    _log.finest('inserted: #${model.hash}');
    return model;
  }

  Future<DBModel?> get(Uint8List hash, {Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).query(_table,
        columns: ['hash', 'version_id', 'synced_epoch'],
        where: 'hash = ?',
        whereArgs: [hash]);
    if (rows.isEmpty) {
      _log.finest('$hash not found');
      return null;
    } else {
      _log.finest('got $hash');
      return DBModel.fromMap(rows[0]);
    }
  }

  Future<List<DBModel>> getAll(List<Uint8List> hashes,
      {Transaction? txn}) async {
    String q = '(' +
        hashes
            .map((hash) =>
                'x\'${hash.map((e) => e.toRadixString(16).padLeft(2, "0")).join()}\'')
            .join(',') +
        ')';
    List<Map<String, Object?>> rows = await (txn ?? _database)
        .rawQuery('SELECT hash, version_id, synced_epoch '
            'FROM $_table WHERE hash IN $q');
    if (rows.isEmpty) {
      _log.finest('no records found');
      return List.empty();
    } else {
      _log.finest('got ${rows.length} blocks');
      return rows.map((row) => DBModel.fromMap(row)).toList();
    }
  }
}
