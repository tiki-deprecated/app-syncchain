/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../authorize/authorize_model_rsp_policy.dart';
import 's3_model_list.dart';
import 's3_model_list_ver.dart';
import 's3_model_ver.dart';
import 's3_repository.dart';

class S3Service {
  final Logger _log = Logger('S3Service');

  final HttppClient _client;
  final S3Repository _repository;
  final String bucket;

  S3Service({required this.bucket, Httpp? httpp})
      : _repository = S3Repository(),
        _client = httpp == null ? Httpp().client() : httpp.client();

  Future<void> get(
          {required String key,
          String? version,
          void Function(Map<String, dynamic>?)? onSuccess,
          void Function(Object)? onError}) =>
      _repository.getObject(
          client: _client,
          bucket: bucket,
          key: key,
          version: version,
          onSuccess: onSuccess,
          onError: (err) {
            _log.severe(err);
            if (onError != null) onError(err);
          });

  Future<void> write(
          {required String key,
          required AuthorizeModelRspPolicy policy,
          required List<int> object,
          void Function(S3ModelVer)? onSuccess,
          void Function(Object)? onError}) =>
      _repository.writeObject(
          bucket: bucket,
          key: key,
          policy: policy,
          object: object,
          onSuccess: (String? versionId) {
            if (onSuccess != null)
              onSuccess(S3ModelVer(versionId: versionId, object: object));
          },
          onError: (err) {
            _log.severe(err);
            if (onError != null) onError(err);
          });

  Future<void> list(
          {String? prefix,
          String? keyMarker,
          String? versionIdMarker,
          void Function(S3ModelList)? onSuccess,
          void Function(Object)? onError}) =>
      _repository.listVersions(
          client: _client,
          bucket: bucket,
          prefix: prefix,
          keyMarker: keyMarker,
          versionIdMarker: versionIdMarker,
          onSuccess: (list) {
            if (onSuccess != null) {
              Map<String, S3ModelListVer> first = Map();
              list.versions?.forEach((e) {
                if (e.key != null && e.lastModified != null) {
                  String key = e.key!;
                  if (first.containsKey(key) &&
                      first[key]!.lastModified!.isAfter(e.lastModified!))
                    first[key] = e;
                  else
                    first[key] = e;
                }
              });
              list.versions = List.of(first.values);
              onSuccess(list);
            }
          },
          onError: (err) {
            _log.severe(err);
            if (onError != null) onError(err);
          });
}
