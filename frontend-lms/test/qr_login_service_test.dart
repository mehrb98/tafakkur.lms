import 'package:flutter_test/flutter_test.dart';
import 'package:tafakkur_lms/core/services/qr_login_service.dart';

void main() {
  group('QrLoginService.parseToken', () {
    test('reads the token from a Tafakkur sign-in code', () {
      expect(QrLoginService.parseToken('tafakkur://qr-login?token=abc_123-XYZ'), 'abc_123-XYZ');
    });

    test('ignores other QR codes', () {
      expect(QrLoginService.parseToken('https://example.com/?token=abc'), isNull);
      expect(QrLoginService.parseToken('tafakkur://other?token=abc'), isNull);
      expect(QrLoginService.parseToken('tafakkur://qr-login'), isNull);
      expect(QrLoginService.parseToken(null), isNull);
    });
  });
}
