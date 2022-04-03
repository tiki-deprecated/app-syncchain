/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:xml/xml.dart';

import 's3_model_list_ver_owner.dart';

class S3ModelListVer {
  String? key;
  String? versionId;
  bool? isLatest;
  DateTime? lastModified;
  String? eTag;
  int? size;
  S3ModelListVerOwner? owner;
  String? storageClass;

  S3ModelListVer(
      {this.key,
      this.versionId,
      this.isLatest,
      this.lastModified,
      this.eTag,
      this.size,
      this.owner,
      this.storageClass});

  S3ModelListVer.fromXml(XmlElement? xml) {
    if (xml != null) {
      key = xml.getElement('Key')?.text;
      versionId = xml.getElement('VersionId')?.text;
      isLatest = xml.getElement('IsLatest')?.text == "true" ? true : false;

      if (xml.getElement('LastModified') != null)
        lastModified =
            DateTime.tryParse(xml.getElement('LastModified')?.text ?? '');

      eTag = xml.getElement('ETag')?.text;
      size = int.tryParse(xml.getElement('Size')?.text ?? '');
      owner = S3ModelListVerOwner.fromXml(xml.getElement('Owner'));
      storageClass = xml.getElement('StorageClass')?.text;
    }
  }

  @override
  String toString() {
    return 'S3ModelListVer{key: $key, versionId: $versionId, isLatest: $isLatest, lastModified: $lastModified, eTag: $eTag, size: $size, owner: $owner, storageClass: $storageClass}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is S3ModelListVer &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          versionId == other.versionId &&
          isLatest == other.isLatest &&
          lastModified == other.lastModified &&
          eTag == other.eTag &&
          size == other.size &&
          owner == other.owner &&
          storageClass == other.storageClass;

  @override
  int get hashCode =>
      key.hashCode ^
      versionId.hashCode ^
      isLatest.hashCode ^
      lastModified.hashCode ^
      eTag.hashCode ^
      size.hashCode ^
      owner.hashCode ^
      storageClass.hashCode;
}
