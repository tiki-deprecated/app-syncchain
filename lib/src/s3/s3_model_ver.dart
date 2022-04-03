/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class S3ModelVer {
  String? versionId;
  List<int>? object;

  S3ModelVer({this.versionId, this.object});

  @override
  String toString() {
    return 'S3ModelVer{versionId: $versionId, object: $object}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is S3ModelVer &&
          runtimeType == other.runtimeType &&
          versionId == other.versionId &&
          object == other.object;

  @override
  int get hashCode => versionId.hashCode ^ object.hashCode;
}
