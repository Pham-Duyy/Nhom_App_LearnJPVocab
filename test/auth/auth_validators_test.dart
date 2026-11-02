import 'package:chibakanji/auth/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('US03, US04: email', () {
    test('email hợp lệ, kể cả có khoảng trắng thừa', () {
      expect(AuthValidators.email('duy@gmail.com'), isNull);
      expect(AuthValidators.email('  duy.pham@phenikaa-uni.edu.vn  '), isNull);
    });

    test('để trống thì báo cần nhập', () {
      expect(AuthValidators.email(''), 'Vui lòng nhập email.');
      expect(AuthValidators.email(null), 'Vui lòng nhập email.');
      expect(AuthValidators.email('   '), 'Vui lòng nhập email.');
    });

    test('sai định dạng thì báo lỗi', () {
      for (final value in [
        'duy',
        'duy@',
        '@gmail.com',
        'duy@gmail',
        'd uy@a.b'
      ]) {
        expect(AuthValidators.email(value), 'Email không đúng định dạng.',
            reason: value);
      }
    });
  });

  group('US03, US04: mật khẩu', () {
    test('đủ 6 ký tự thì hợp lệ, 5 ký tự thì không', () {
      expect(AuthValidators.password('123456'), isNull);
      expect(AuthValidators.password('12345'), isNotNull);
      expect(AuthValidators.password(null), isNotNull);
    });

    test('mật khẩu xác nhận phải khớp chính xác', () {
      expect(AuthValidators.confirmPassword('abc123', 'abc123'), isNull);
      expect(AuthValidators.confirmPassword('abc124', 'abc123'), isNotNull);
      expect(AuthValidators.confirmPassword(null, 'abc123'), isNotNull);
    });
  });
}
