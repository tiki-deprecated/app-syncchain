/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 's3_model_list_ver.dart';

class S3ModelList {
  String? name;
  String? prefix;
  String? keyMarker;
  String? versionIdMarker;
  int? maxKeys;
  bool? isTruncated;
  String? nextKeyMarker;
  String? nextVersionIdMarker;
  List<S3ModelListVer>? versions;

  S3ModelList(
      {this.name,
      this.prefix,
      this.keyMarker,
      this.versionIdMarker,
      this.maxKeys,
      this.isTruncated,
      this.nextKeyMarker,
      this.nextVersionIdMarker,
      this.versions});

  S3ModelList.fromXml(XmlElement? xml) {
    if (xml != null) {
      name = xml.getElement('Name')?.text;
      prefix = xml.getElement('Prefix')?.text;
      keyMarker = xml.getElement('KeyMarker')?.text;
      versionIdMarker = xml.getElement('VersionIdMarker')?.text;
      maxKeys = int.tryParse(xml.getElement('MaxKeys')?.text ?? '');
      isTruncated =
          xml.getElement('IsTruncated')?.text == "true" ? true : false;
      nextKeyMarker = xml.getElement('NextKeyMarker')?.text;
      nextVersionIdMarker = xml.getElement('NextVersionIdMarker')?.text;
      if (xml.getElement('Version') != null) {
        versions = List.empty(growable: true);
        xml.findAllElements('Version').forEach(
            (element) => versions!.add(S3ModelListVer.fromXml(element)));
      }
    }
  }

  @override
  String toString() {
    return 'S3ModelList{name: $name, prefix: $prefix, keyMarker: $keyMarker, versionIdMarker: $versionIdMarker, maxKeys: $maxKeys, isTruncated: $isTruncated, nextKeyMarker: $nextKeyMarker, nextVersionIdMarker: $nextVersionIdMarker, versions: $versions}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is S3ModelList &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          prefix == other.prefix &&
          keyMarker == other.keyMarker &&
          versionIdMarker == other.versionIdMarker &&
          maxKeys == other.maxKeys &&
          isTruncated == other.isTruncated &&
          nextKeyMarker == other.nextKeyMarker &&
          nextVersionIdMarker == other.nextVersionIdMarker &&
          ListEquality().equals(versions, other.versions);

  @override
  int get hashCode =>
      name.hashCode ^
      prefix.hashCode ^
      keyMarker.hashCode ^
      versionIdMarker.hashCode ^
      maxKeys.hashCode ^
      isTruncated.hashCode ^
      nextKeyMarker.hashCode ^
      nextVersionIdMarker.hashCode ^
      versions.hashCode;
}
