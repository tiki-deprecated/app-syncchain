/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class DBModel {
  Uint8List? hash;
  String? versionId;
  DateTime? synced;

  DBModel({this.hash, this.versionId, this.synced});

  DBModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      this.hash = map['hash'];
      this.versionId = map['version_id'];
      if (map['synced_epoch'] != null)
        this.synced = DateTime.fromMillisecondsSinceEpoch(map['synced_epoch']);
    }
  }

  Map<String, dynamic> toMap() => {
        'hash': hash,
        'version_id': versionId,
        'synced_epoch': synced?.millisecondsSinceEpoch,
      };

  @override
  String toString() {
    return 'DBModel{hash: $hash, versionId: $versionId, synced: $synced}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DBModel &&
          runtimeType == other.runtimeType &&
          listEquals(hash, other.hash) &&
          versionId == other.versionId &&
          synced == other.synced;

  @override
  int get hashCode => hash.hashCode ^ versionId.hashCode ^ synced.hashCode;
}
