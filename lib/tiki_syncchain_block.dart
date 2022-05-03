/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

class TikiSyncChainBlock {
  Uint8List? contents;
  DateTime? created;
  Uint8List? previous;
  DateTime? synced;
  Uint8List? signature;

  TikiSyncChainBlock(
      {this.contents,
      this.created,
      this.previous,
      this.synced,
      this.signature});

  TikiSyncChainBlock.fromJson(Map<String, dynamic>? map) {
    if (map != null) {
      if (map['contents'] != null)
        this.contents = base64.decode(map['contents']);
      if (map['previous'] != null)
        this.previous = base64.decode(map['previous']);
      if (map['signature'] != null)
        this.signature = base64.decode(map['signature']);
      if (map['created'] != null)
        this.created = DateTime.fromMillisecondsSinceEpoch(map['created']);
      if (map['synced'] != null)
        this.synced = DateTime.fromMillisecondsSinceEpoch(map['synced']);
    }
  }

  Map<String, dynamic> toJson() => {
        'contents': contents != null ? base64.encode(contents!) : null,
        'previous': previous != null ? base64.encode(previous!) : null,
        'created': created?.millisecondsSinceEpoch,
        'synced': synced?.millisecondsSinceEpoch,
        'signature': signature != null ? base64.encode(signature!) : null,
      };

  @override
  String toString() {
    return 'BlockModel{contents: $contents, created: $created, previous: $previous, synced: $synced, signature: $signature}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TikiSyncChainBlock &&
          runtimeType == other.runtimeType &&
          contents == other.contents &&
          created == other.created &&
          previous == other.previous &&
          synced == other.synced &&
          signature == other.signature;

  @override
  int get hashCode =>
      contents.hashCode ^
      created.hashCode ^
      previous.hashCode ^
      synced.hashCode ^
      signature.hashCode;
}
