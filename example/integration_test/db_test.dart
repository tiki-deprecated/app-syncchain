/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_syncchain/src/db/db_model.dart';
import 'package:tiki_syncchain/src/db/db_repository.dart';
import 'package:tiki_syncchain/src/db/db_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DB Tests', () {
    test('open — success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      await DBService().open(database);
    });

    test('write one — success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      await DBService().open(database);
      DBRepository repository = DBRepository(database);

      Uint8List hash = Uint8List.fromList(utf8.encode(Uuid().v4()));

      DBModel inserted = await repository
          .insert(DBModel(hash: hash, versionId: '1', synced: DateTime.now()));

      expect(ListEquality().equals(hash, inserted.hash), true);
      expect(inserted.versionId, '1');
      expect(inserted.synced != null, true);
    });

    test('get — success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      await DBService().open(database);
      DBRepository repository = DBRepository(database);

      Uint8List hash = Uint8List.fromList(utf8.encode(Uuid().v4()));

      await repository
          .insert(DBModel(hash: hash, versionId: '1', synced: DateTime.now()));

      DBModel? found = await repository.get(hash);

      expect(found != null, true);
      expect(ListEquality().equals(hash, found?.hash), true);
      expect(found?.versionId, '1');
      expect(found?.synced != null, true);
    });

    test('write many — success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      DBService service = await DBService().open(database);
      DBRepository repository = DBRepository(database);

      Uint8List h1 = Uint8List.fromList(utf8.encode(Uuid().v4()));
      Uint8List h2 = Uint8List.fromList(utf8.encode(Uuid().v4()));

      await service.write([
        DBModel(hash: h1, versionId: '1', synced: DateTime.now()),
        DBModel(hash: h2, versionId: '1', synced: DateTime.now())
      ]);

      DBModel? f1 = await repository.get(h1);
      DBModel? f2 = await repository.get(h2);

      expect(f1 != null, true);
      expect(f2 != null, true);
    });

    test('getAll — success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      DBService service = await DBService().open(database);

      Uint8List h1 = Uint8List.fromList(utf8.encode(Uuid().v4()));
      Uint8List h2 = Uint8List.fromList(utf8.encode(Uuid().v4()));

      await service.write([
        DBModel(hash: h1, versionId: '1', synced: DateTime.now()),
        DBModel(hash: h2, versionId: '1', synced: DateTime.now())
      ]);

      List<DBModel> found = await service
          .get([h1, h2, Uint8List.fromList(utf8.encode(Uuid().v4()))]);

      expect(found.length, 2);
      expect(found.any((e) => ListEquality().equals(e.hash, h1)), true);
      expect(found.any((e) => ListEquality().equals(e.hash, h2)), true);
    });
  });
}
