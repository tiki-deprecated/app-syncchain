/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:xml/xml.dart';

import '../authorize/authorize_model_policy_rsp.dart';
import 's3_model_error.dart';
import 's3_model_list.dart';

class S3Repository {
  final Logger _log = Logger('S3Repository');

  static const _scheme = 'https';
  static const _domain = 's3.amazonaws.com';

  Future<void> getObject(
      {required HttppClient client,
      required String bucket,
      required String key,
      String? version,
      void Function(Map<String, dynamic>?)? onSuccess,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri(
            scheme: _scheme,
            host: '$bucket.$_domain',
            path: '/$key',
            queryParameters: version != null ? {'versionId': version} : null),
        verb: HttppVerb.GET,
        headers: HttppHeaders.typical(),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) onSuccess(rsp.body?.jsonBody);
        },
        onResult: (rsp) {
          if (onError != null && rsp.body?.body != null)
            onError(S3ModelError.fromXml(
                XmlDocument.parse(rsp.body!.body).getElement('Error')));
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }

  Future<void> listVersions(
      {required HttppClient client,
      required String bucket,
      String? prefix,
      String? keyMarker,
      String? versionIdMarker,
      int maxKeys = 1000,
      void Function(S3ModelList)? onSuccess,
      void Function(Object)? onError}) {
    Map<String, dynamic> queryParams = Map();
    queryParams['max-keys'] = '$maxKeys';
    queryParams['versions'] = '';
    if (prefix != null) queryParams['prefix'] = prefix;
    if (keyMarker != null) queryParams['key-marker'] = keyMarker;
    if (versionIdMarker != null)
      queryParams['version-id-marker'] = versionIdMarker;
    HttppRequest request = HttppRequest(
        uri: Uri(
            scheme: _scheme,
            host: '$bucket.$_domain',
            queryParameters: queryParams),
        verb: HttppVerb.GET,
        headers: HttppHeaders.typical(),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null && rsp.body != null)
            onSuccess(S3ModelList.fromXml(XmlDocument.parse(rsp.body!.body)
                .getElement('ListVersionsResult')));
        },
        onResult: (rsp) {
          if (onError != null && rsp.body?.body != null)
            onError(S3ModelError.fromXml(
                XmlDocument.parse(rsp.body!.body).getElement('Error')));
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }

  Future<void> writeObject(
      {required String bucket,
      required String key,
      required AuthorizeModelPolicyRsp policy,
      required List<int> object,
      void Function(String?)? onSuccess,
      void Function(Object)? onError}) async {
    http.MultipartRequest request = new http.MultipartRequest(
        "POST", Uri(scheme: _scheme, host: '$bucket.$_domain'));

    request.fields["key"] = key;
    request.fields["Content-Type"] = "application/json";
    request.fields["X-Amz-Credential"] =
        "${policy.accountId}/${policy.date}/us-east-1/s3/aws4_request";
    request.fields["X-Amz-Algorithm"] = "AWS4-HMAC-SHA256";
    request.fields["X-Amz-Date"] = "${policy.date}T000000Z";
    request.fields["Policy"] = policy.policy ?? "";
    request.fields["Content-MD5"] = base64.encode(md5.convert(object).bytes);
    request.fields["X-Amz-Signature"] = policy.signature ?? "";
    request.fields["x-amz-object-lock-mode"] = "GOVERNANCE";
    request.fields["x-amz-object-lock-retain-until-date"] =
        DateTime.now().add(Duration(days: 1)).toUtc().toIso8601String();

    request.files.add(http.MultipartFile.fromBytes("file", object));
    return request.send().then((res) async {
      if (res.statusCode == 204 && onSuccess != null)
        onSuccess(res.headers['x-amz-version-id']);
      else if (onError != null) {
        String response = await res.stream.bytesToString();
        onError(S3ModelError.fromXml(
            XmlDocument.parse(response).getElement('Error')));
      }
    }, onError: onError);
  }
}
