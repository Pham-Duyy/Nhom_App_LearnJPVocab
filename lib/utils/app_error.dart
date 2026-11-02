import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Một chỗ duy nhất đổi lỗi kỹ thuật thành câu tiếng Việt cho người dùng.
/// Chi tiết lỗi (mã, stack trace) chỉ ghi vào log, không bao giờ hiện lên UI.
class AppError {
  AppError._();

  /// Câu báo lỗi cho người dùng. [action] là việc đang làm dở, viết thường,
  /// vd. 'tải danh sách chủ đề' -> "Không thể tải danh sách chủ đề...".
  static String message(Object error, {required String action}) {
    if (isNetworkError(error)) {
      return 'Không có kết nối mạng nên chưa thể $action. '
          'Hãy kiểm tra kết nối rồi thử lại.';
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
        case 'unauthenticated':
          return 'Phiên đăng nhập không hợp lệ nên chưa thể $action. '
              'Hãy đăng nhập lại.';
        case 'resource-exhausted':
          return 'Máy chủ đang quá tải. Vui lòng thử lại sau ít phút.';
      }
    }
    return 'Không thể $action. Vui lòng thử lại.';
  }

  /// Mất mạng, máy chủ không phản hồi, hoặc chờ quá lâu.
  static bool isNetworkError(Object error) {
    if (error is TimeoutException) return true;
    return error is FirebaseException &&
        const {'unavailable', 'network-request-failed', 'deadline-exceeded'}
            .contains(error.code);
  }

  /// Ghi lỗi vào log kèm nơi xảy ra. Lỗi xác thực có thể chứa email hay
  /// token nên AuthController tự ghi log riêng, chỉ gồm mã lỗi.
  static void log(String where, Object error, [StackTrace? stack]) {
    debugPrint('[$where] ${error.runtimeType}: $error');
    if (stack != null) debugPrintStack(stackTrace: stack, maxFrames: 8);
  }
}
