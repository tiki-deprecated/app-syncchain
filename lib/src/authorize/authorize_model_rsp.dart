/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'authorize_model_rsp_message.dart';
import 'authorize_model_rsp_page.dart';

class AuthorizeModelRsp<T> {
  String? status;
  int? code;
  dynamic data;
  AuthorizeModelRspPage? page;
  List<AuthorizeModelRspMessage>? messages;

  AuthorizeModelRsp(
      {this.status, this.code, this.data, this.page, this.messages});

  AuthorizeModelRsp.fromJson(
      Map<String, dynamic>? json, T fromJson(Map<String, dynamic>? json)) {
    if (json != null) {
      status = json['status'];
      code = json['code'];

      if (json['data'] != null) {
        data = json['data'] is List
            ? json['data'].map((e) => fromJson(e)).toList()
            : fromJson(json['data']);
      }

      if (json['page'] != null)
        page = AuthorizeModelRspPage.fromJson(json['page']);

      if (json['messages'] != null)
        this.messages = (json['messages'] as List)
            .map((e) => AuthorizeModelRspMessage.fromJson(e))
            .toList();
    }
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'code': code,
        'data': data?.toJson(),
        'page': page?.toJson(),
        'messages': messages?.map((e) => e.toJson()).toList()
      };

  @override
  String toString() =>
      '''AuthorizeModelRsp<${T.runtimeType}>
status: $status,
code: $code,
data: ${data?.toJson()},
page: ${page?.toJson()},
messages: ${messages?.map((e) => e.toJson())}
''';

}
