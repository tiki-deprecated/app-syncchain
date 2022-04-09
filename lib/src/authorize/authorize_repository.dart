/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import 'authorize_model_policy_req.dart';
import 'authorize_model_policy_rsp.dart';
import 'authorize_model_register_req.dart';
import 'authorize_model_rsp.dart';

class AuthorizeRepository {
  final Logger _log = Logger('AuthorizeRepository');

  static const String _path =
      'https://bouncer.mytiki.com/api/latest/sync-chain';
  static const String _pathRegister = _path + '/register';
  static const String _pathPolicy = _path + '/policy';

  Future<void> register(
      {required HttppClient client,
      String? accessToken,
      AuthorizeModelRegisterReq? body,
      void Function()? onSuccess,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri.parse(_pathRegister),
        verb: HttppVerb.POST,
        headers: HttppHeaders.typical(bearerToken: accessToken),
        body: HttppBody.fromJson(body?.toJson()),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) onSuccess();
        },
        onResult: (rsp) {
          if (onError != null)
            onError(AuthorizeModelRsp.fromJson(rsp.body?.jsonBody, (json) {}));
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }

  Future<void> policy(
      {required HttppClient client,
      String? accessToken,
      AuthorizeModelPolicyReq? body,
      void Function(AuthorizeModelPolicyRsp)? onSuccess,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri.parse(_pathPolicy),
        verb: HttppVerb.POST,
        headers: HttppHeaders.typical(bearerToken: accessToken),
        body: HttppBody.fromJson(body?.toJson()),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) {
            AuthorizeModelRsp apiRsp = AuthorizeModelRsp.fromJson(
                rsp.body?.jsonBody,
                (json) => AuthorizeModelPolicyRsp.fromJson(json));
            onSuccess(apiRsp.data);
          }
        },
        onResult: (rsp) {
          if (onError != null)
            onError(AuthorizeModelRsp.fromJson(rsp.body?.jsonBody, (json) {}));
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }
}
