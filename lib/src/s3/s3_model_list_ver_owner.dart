/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:xml/xml.dart';

class S3ModelListVerOwner {
  String? id;
  String? displayName;

  S3ModelListVerOwner({this.id, this.displayName});

  S3ModelListVerOwner.fromXml(XmlElement? xml) {
    if (xml != null) {
      id = xml.getElement('ID')?.text;
      displayName = xml.getElement('DisplayName')?.text;
    }
  }

  @override
  String toString() {
    return 'S3ModelListVerOwner{id: $id, displayName: $displayName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is S3ModelListVerOwner &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName;

  @override
  int get hashCode => id.hashCode ^ displayName.hashCode;
}
