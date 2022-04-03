/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'db_model.dart';
import 'db_repository.dart';

class DBService {
  late final DBRepository _repository;

  Future<DBService> open(Database database) async {
    if (!database.isOpen)
      throw ArgumentError.value(database, 'database', 'database is not open');
    _repository = DBRepository(database);
    await _repository.createTable();
    return this;
  }

  Future<void> write(List<DBModel> models) async {
    await _repository.transaction((txn) async {
      models.forEach((row) async {
        await _repository.insert(row, txn: txn);
      });
    });
  }

  Future<DBModel?> get(Uint8List hash) => _repository.get(hash);
}
