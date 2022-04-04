/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class AuthorizeModelPolicyReq {
  String? address;
  String? stringToSign;
  String? signature;

  AuthorizeModelPolicyReq({this.address, this.stringToSign, this.signature});

  AuthorizeModelPolicyReq.fromJson(Map<String, dynamic>? map) {
    if (map != null) {
      this.address = map['address'];
      this.signature = map['signature'];
      this.stringToSign = map['stringToSign'];
    }
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'signature': signature,
        'stringToSign': stringToSign,
      };

  @override
  String toString() {
    return 'AuthorizeModelPolicyReq{address: $address, stringToSign: $stringToSign, signature: $signature}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizeModelPolicyReq &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          stringToSign == other.stringToSign &&
          signature == other.signature;

  @override
  int get hashCode =>
      address.hashCode ^ stringToSign.hashCode ^ signature.hashCode;
}
