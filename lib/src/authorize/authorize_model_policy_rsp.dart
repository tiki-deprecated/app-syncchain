/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class AuthorizeModelPolicyRsp {
  String? policy;
  String? signature;
  String? date;
  String? accountId;

  AuthorizeModelPolicyRsp(
      {this.policy, this.signature, this.date, this.accountId});

  AuthorizeModelPolicyRsp.fromJson(Map<String, dynamic>? map) {
    if (map != null) {
      this.policy = map['policy'];
      this.signature = map['signature'];
      this.date = map['date'];
      this.accountId = map['accountId'];
    }
  }

  Map<String, dynamic> toJson() => {
        'policy': policy,
        'signature': signature,
        'date': date,
        'accountId': accountId
      };

  @override
  String toString() {
    return 'AuthorizeModelPolicyRsp{policy: $policy, signature: $signature, date: $date, accountId: $accountId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizeModelPolicyRsp &&
          runtimeType == other.runtimeType &&
          policy == other.policy &&
          signature == other.signature &&
          date == other.date &&
          accountId == other.accountId;

  @override
  int get hashCode =>
      policy.hashCode ^ signature.hashCode ^ date.hashCode ^ accountId.hashCode;
}
