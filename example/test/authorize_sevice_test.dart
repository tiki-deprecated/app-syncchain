import 'package:flutter_test/flutter_test.dart';
import 'package:tiki_syncchain/src/authorize/authorize_model_rsp.dart';
import 'package:tiki_syncchain/src/authorize/authorize_model_rsp_message.dart';
import 'package:tiki_syncchain/src/authorize/authorize_model_rsp_page.dart';

void main() {
  group('Authorize Service Tests', () {
    test("AuthorizeModelRsp to String test", () async {
      String log = AuthorizeModelRsp(
          status: 'ok',
          code: 200,
          page: AuthorizeModelRspPage(
              size: 10,
              totalElements: 100,
              totalPages: 1000,
              page: 2
          ),
          messages: [
            AuthorizeModelRspMessage.fromJson({
              'size': 100,
              'status': "OK",
              'message': "MESSAGE",
            })
          ]
      ).toString();
      expect(log, 'AuthorizeModelRsp<Type>\n'
          'status: ok,\n'
          'code: 200,\n'
          'data: null,\n'
          'page: {size: 10, totalElements: 100, totalPages: 1000, page: 2},\n'
          'messages: ({size: null, status: OK, message: MESSAGE, properties: null})\n');
    });
  });
}