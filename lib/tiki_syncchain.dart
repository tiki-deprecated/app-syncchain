/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:httpp/httpp.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_kv/tiki_kv.dart';

import 'src/authorize/authorize_model_policy_rsp.dart';
import 'src/authorize/authorize_model_rsp.dart';
import 'src/authorize/authorize_service.dart';
import 'src/db/db_model.dart';
import 'src/db/db_service.dart';
import 'src/s3/s3_model_list_ver.dart';
import 'src/s3/s3_service.dart';
import 'tiki_syncchain_block.dart';

export 'src/db/db_model.dart';

class TikiSyncChain {
  static const String _isRegistered = 'SyncChain.isRegistered';

  late TikiKv? _kv;
  final AuthorizeService _authorizeService;
  late final DBService _dbService;
  final Database _database;
  final S3Service _s3service;
  final Uint8List Function(Uint8List message) _sign;

  AuthorizeModelPolicyRsp? _policy;
  String? _address;
  Amplitude? amplitude;

  TikiSyncChain(
      {Httpp? httpp,
      required Database database,
      TikiKv? kv,
      String s3Bucket = 'tiki-sync-chain',
      Future<void> Function(void Function(String?)? onSuccess)? refresh,
      String? Function()? accessToken,
      required Uint8List Function(Uint8List message) sign,
      this.amplitude})
      : _kv = kv ?? null,
        _database = database,
        _sign = sign,
        _authorizeService = AuthorizeService(
            sign: sign,
            httpp: httpp,
            refresh: refresh,
            accessToken: accessToken),
        _s3service = S3Service(bucket: s3Bucket);

  Future<TikiSyncChain> init(
      {String? address,
      String? publicKey,
      void Function(Object)? onError}) async {
    if (_kv == null) _kv = await TikiKv(database: _database).init();
    _dbService = await DBService().open(_database);
    bool? isRegistered =
        await _kv!.read(_isRegistered) == 'true' ? true : false;
    if (!isRegistered) {
      await _authorizeService.register(
          address: address,
          publicKeyB64: publicKey,
          onSuccess: () async {
            await _kv!.upsert(_isRegistered, 'true');
            await _authorizeService.policy(
                address: address,
                onError: onError,
                onSuccess: (rsp) => _policy = rsp);
          },
          onError: (err) {
            if (err is AuthorizeModelRsp && err.code == 400) {
              err.messages?.forEach((msg) async {
                if (msg.message?.trim().toLowerCase() ==
                    'address already registered') {
                  await _kv!.upsert(_isRegistered, 'true');
                  await _authorizeService.policy(
                      address: address,
                      onError: onError,
                      onSuccess: (rsp) => _policy = rsp);
                }
              });
            } else if (onError != null)
              onError(err);
            else
              throw StateError('Failed to init. Cannot register public key');
          });
    } else
      await _authorizeService.policy(
          address: address,
          onError: onError,
          onSuccess: (rsp) => _policy = rsp);
    _address = address;
    return this;
  }

  void syncBlock(
      {String? accessToken,
      required Uint8List hash,
      required TikiSyncChainBlock block,
      void Function(TikiSyncChainBlock)? onSuccess,
      void Function(Object)? onError}) async {
    if (_policy == null) {
      await _authorizeService.policy(
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
      block.synced = DateTime.now();
      block.signature = await _sign(
          Uint8List.fromList(utf8.encode(json.encode(block.toJson()))));
      await _s3service.write(
          key:
              '${_hexFromBase64(_address)}/chain/${_hexFromBase64(base64.encode(hash))}.json',
          policy: _policy!,
          object: utf8.encode(json.encode(block.toJson())),
          onError: onError,
          onSuccess: (ver) async {
            // TODO bulk write
           await _dbService.write([
              DBModel(
                  hash: hash, versionId: ver.versionId, synced: block.synced)
            ]);
            if (onSuccess != null) onSuccess(block);
          });
    }
  }

  Future<List<DBModel>> getState(List<Uint8List> hashes) =>
      _dbService.get(hashes);

  void getBlocks(
          {void Function(TikiSyncChainBlock)? onSuccess,
          void Function(Object)? onError}) =>
      _getKeys(onComplete: (versions) {
        versions.forEach((ver) {
          _s3service.get(
              key: ver.key!,
              version: ver.versionId,
              onSuccess: (json) {
                if (onSuccess != null)
                  onSuccess(TikiSyncChainBlock.fromJson(json));
              },
              onError: onError);
        });
      });

  void getBlock(
          {required Uint8List hash,
          String? version,
          void Function(TikiSyncChainBlock)? onSuccess,
          void Function(Object)? onError}) =>
      _s3service.get(
          key:
              '${_hexFromBase64(_address)}/chain/${_hexFromBase64(base64.encode(hash))}',
          version: version,
          onSuccess: (json) {
            if (onSuccess != null) onSuccess(TikiSyncChainBlock.fromJson(json));
          },
          onError: onError);

  String _hexFromBase64(String? b64) {
    String hex = "";
    if (b64 != null) {
      base64
          .decode(b64)
          .forEach((e) => hex += e.toRadixString(16).padLeft(2, "0"));
    }
    return hex;
  }

  void _getKeys(
      {List<S3ModelListVer>? list,
      String? keyMarker,
      String? versionIdMarker,
      void Function(List<S3ModelListVer>)? onComplete}) async {
    if (list == null) list = List.empty(growable: true);
    await _s3service.list(
        prefix: '${_hexFromBase64(_address)}/chain/',
        keyMarker: keyMarker,
        versionIdMarker: versionIdMarker,
        onSuccess: (rsp) async {
          if (rsp.versions != null) list!.addAll(rsp.versions!);
          if (rsp.nextKeyMarker != null || rsp.nextVersionIdMarker != null)
            _getKeys(
                list: list,
                keyMarker: rsp.nextKeyMarker ?? rsp.keyMarker,
                versionIdMarker: rsp.nextVersionIdMarker ?? rsp.versionIdMarker,
                onComplete: onComplete);
          else if (onComplete != null) {
            Map<String, S3ModelListVer> first = Map();
            list!.forEach((e) {
              if (e.key != null && e.lastModified != null) {
                String key = e.key!;
                if (first.containsKey(key) &&
                    first[key]!.lastModified!.isAfter(e.lastModified!))
                  first[key] = e;
                else
                  first[key] = e;
              }
            });
            onComplete(List.of(first.values));
          }
        });
  }
}
