/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'authorize_model_policy_req.dart';
import 'authorize_model_policy_rsp.dart';
import 'authorize_model_register_req.dart';
import 'authorize_model_rsp.dart';
import 'authorize_repository.dart';

class AuthorizeService {
  final Logger _log = Logger('AuthorizeService');

  final HttppClient _client;
  final AuthorizeRepository _repository;
  final Future<Uint8List> Function(Uint8List message) _sign;
  final Future<void> Function(void Function(String?)? onSuccess)? _refresh;

  AuthorizeService(
      {Httpp? httpp,
      required Future<Uint8List> Function(Uint8List message) sign,
      Future<void> Function(void Function(String?)? onSuccess)? refresh})
      : _repository = AuthorizeRepository(),
        _client = httpp == null ? Httpp().client() : httpp.client(),
        _sign = sign,
        _refresh = refresh;

  Future<void> register(
          {String? accessToken,
          String? address,
          String? publicKeyB64,
          void Function()? onSuccess,
          void Function(Object)? onError}) =>
      _repository.register(
          client: _client,
          accessToken: accessToken,
          body: AuthorizeModelRegisterReq(
              address: address, publicKey: publicKeyB64),
          onSuccess: onSuccess,
          onError: (err) {
            _log.severe(err);
            if (onError != null) onError(err);
          });

  Future<void> policy(
      {String? accessToken,
      String? address,
      void Function(AuthorizeModelPolicyRsp)? onSuccess,
      void Function(Object)? onError}) async {
    String stringToSign = Uuid().v4().toString();
    Uint8List signature =
        await _sign(Uint8List.fromList(utf8.encode(stringToSign)));
    return _auth(
        accessToken,
        onError,
        (token, onError) => _repository.policy(
            client: _client,
            body: AuthorizeModelPolicyReq(
                address: address,
                stringToSign: stringToSign,
                signature: base64.encode(signature)),
            accessToken: accessToken,
            onSuccess: onSuccess,
            onError: (err) {
              _log.severe(err);
              onError(err);
            }));
  }

  Future<T> _auth<T>(
      String? accessToken,
      Function(Object)? onError,
      Future<T> Function(String?, Future<void> Function(Object))
          request) async {
    return request(accessToken, (error) async {
      if (error is AuthorizeModelRsp && error.code == 401 && _refresh != null) {
        await _refresh!((token) async {
          if (token != null)
            await request(
                token,
                (error) async =>
                    onError != null ? onError(error) : throw error);
        });
      } else
        onError != null ? onError(error) : throw error;
    });
  }
}
