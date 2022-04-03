/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class AuthorizeModelRegisterReq {
  String? address;
  String? publicKey;

  AuthorizeModelRegisterReq({this.address, this.publicKey});

  AuthorizeModelRegisterReq.fromJson(Map<String, dynamic>? map) {
    if (map != null) {
      this.address = map['address'];
      this.publicKey = map['publicKey'];
    }
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'publicKey': publicKey,
      };

  @override
  String toString() {
    return 'AuthorizeModelRegisterReq{address: $address, publicKey: $publicKey}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizeModelRegisterReq &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          publicKey == other.publicKey;

  @override
  int get hashCode => address.hashCode ^ publicKey.hashCode;
}
