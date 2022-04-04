/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:httpp/httpp.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_kv/tiki_kv.dart';

import 'authorize/authorize_model_policy_rsp.dart';
import 'authorize/authorize_service.dart';
import 'db/db_model.dart';
import 'db/db_service.dart';
import 's3/s3_service.dart';
import 'sync_chain_block.dart';

export 'sync_chain_block.dart';

class SyncChain {
  static const String _isRegistered = 'SyncChain.isRegistered';

  late final TikiKv? _kv;
  final AuthorizeService _authorizeService;
  late final DBService _dbService;
  final Database _database;
  final S3Service _s3service;

  AuthorizeModelPolicyRsp? _policy;
  String? _address;

  SyncChain(
      {Httpp? httpp,
      required Database database,
      TikiKv? kv,
      String s3Bucket = 'tiki-sync-chain',
      Future<void> Function(void Function(String?)? onSuccess)? refresh,
      required Future<Uint8List> Function(Uint8List message) sign})
      : _kv = kv,
        _database = database,
        _authorizeService =
            AuthorizeService(sign: sign, httpp: httpp, refresh: refresh),
        _s3service = S3Service(bucket: s3Bucket);

  Future<SyncChain> init(
      {String? address, String? accessToken, String? publicKey}) async {
    if (_kv == null) _kv = await TikiKv(database: _database).init();
    _dbService = await DBService().open(_database);
    bool? isRegistered =
        await _kv!.read(_isRegistered) == 'true' ? true : false;
    if (!isRegistered) {
      await _authorizeService.register(
          accessToken: accessToken,
          address: address,
          publicKeyB64: publicKey,
          onSuccess: () async {
            await _kv!.upsert(_isRegistered, 'true');
            await _authorizeService.policy(
                accessToken: accessToken,
                address: address,
                onSuccess: (rsp) => _policy = rsp);
          },
          onError: (err) =>
              throw StateError('Failed to init. Cannot register public key'));
    } else
      await _authorizeService.policy(
          accessToken: accessToken,
          address: address,
          onSuccess: (rsp) => _policy = rsp);
    _address = address;
    return this;
  }

  Future<void> syncBlock(
      {String? accessToken,
      required Uint8List hash,
      required SyncChainBlock block,
      void Function(SyncChainBlock)? onSuccess}) async {
    if (_policy == null) {
      await _authorizeService.policy(
          accessToken: accessToken,
          address: _address,
          onSuccess: (rsp) {
            _policy = rsp;
            syncBlock(
                accessToken: accessToken,
                block: block,
                hash: hash,
                onSuccess: onSuccess);
          });
    } else {
      await _s3service.write(
          key:
              '${_hexFromBase64(_address)}/chain/${_hexFromBase64(base64.encode(hash ?? List.empty()))}',
          policy: _policy!,
          object: utf8.encode(json.encode(block.toJson())),
          onSuccess: (ver) async {
            await _dbService.write([
              DBModel(
                  hash: hash, versionId: ver.versionId, synced: block.synced)
            ]);
            if (onSuccess != null) onSuccess(block);
          });
    }
  }

  String _hexFromBase64(String? b64) {
    String hex = "";
    if (b64 != null) {
      base64
          .decode(b64)
          .forEach((e) => hex += e.toRadixString(16).padLeft(2, "0"));
    }
    return hex;
  }
}
