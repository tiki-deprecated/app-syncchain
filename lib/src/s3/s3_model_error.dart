/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:xml/xml.dart';

class S3ModelError {
  String? code;
  String? message;
  String? requestId;
  String? resource;

  S3ModelError({this.code, this.message, this.requestId, this.resource});

  S3ModelError.fromXml(XmlElement? xml) {
    if (xml != null) {
      code = xml.getElement('Code')?.text;
      message = xml.getElement('Message')?.text;
      requestId = xml.getElement('RequestId')?.text;
      resource = xml.getElement('Resource')?.text;
    }
  }

  @override
  String toString() {
    return 'S3ModelError{code: $code, message: $message, requestId: $requestId, resource: $resource}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is S3ModelError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          requestId == other.requestId &&
          resource == other.resource;

  @override
  int get hashCode =>
      code.hashCode ^ message.hashCode ^ requestId.hashCode ^ resource.hashCode;
}
