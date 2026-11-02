import 'dart:async';

import 'package:chibakanji/utils/app_error.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

FirebaseException _firestore(String code) => FirebaseException(
      plugin: 'cloud_firestore',
      code: code,
      message: 'chi tiết kỹ thuật token=abc123',
    );

void main() {
  group('8a: đổi lỗi kỹ thuật thành câu dễ hiểu', () {
    test('mất mạng, máy chủ không phản hồi, chờ quá lâu đều báo mất mạng', () {
      for (final error in [
        _firestore('unavailable'),
        _firestore('network-request-failed'),
        _firestore('deadline-exceeded'),
        TimeoutException('quá 10 giây'),
      ]) {
        expect(AppError.isNetworkError(error), isTrue, reason: '$error');
        expect(
          AppError.message(error, action: 'tải từ vựng'),
          startsWith('Không có kết nối mạng nên chưa thể tải từ vựng.'),
        );
      }
    });

    test('bị từ chối quyền thì nhắc đăng nhập lại', () {
      expect(
        AppError.message(_firestore('permission-denied'), action: 'tải hồ sơ'),
        contains('đăng nhập lại'),
      );
    });

    test('lỗi lạ thì nói rõ việc gì chưa làm được', () {
      expect(
        AppError.message(StateError('???'), action: 'lưu kết quả quiz'),
        'Không thể lưu kết quả quiz. Vui lòng thử lại.',
      );
      expect(AppError.isNetworkError(StateError('???')), isFalse);
    });

    test('không bao giờ đưa chi tiết kỹ thuật lên giao diện', () {
      for (final code in ['unavailable', 'permission-denied', 'internal']) {
        final message = AppError.message(_firestore(code), action: 'tải');
        expect(message, isNot(contains('abc123')));
        expect(message, isNot(contains('cloud_firestore')));
      }
    });
  });
}
