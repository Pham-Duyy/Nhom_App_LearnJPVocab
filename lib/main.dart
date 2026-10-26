import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/firestore_seeder.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'utils/app_error.dart';
import 'widgets/error_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _catchUnexpectedErrors();

  if (!await _initFirebase()) {
    runApp(const _StartupErrorApp());
    return;
  }
  if (kDebugMode) await _seedMissingContent();
  runApp(const AppProviders(child: ChibaKanjiApp()));
}

/// Lưới an toàn cuối cùng: lỗi không được nơi nào bắt (khi dựng giao diện,
/// hoặc trong một Future không ai chờ) được ghi log thay vì âm thầm làm hỏng
/// app. Lỗi dự đoán được đã được từng provider tự xử lý trước đó.
void _catchUnexpectedErrors() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppError.log('FlutterError', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppError.log('Uncaught', error, stack);
    return true;
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (_) => const Center(
          child: Text(
            'Đã có lỗi khi hiển thị phần này.',
            textDirection: TextDirection.ltr,
          ),
        );
  }
}

Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e, stack) {
    AppError.log('Firebase.initializeApp', e, stack);
    return false;
  }
}

/// Chỉ ở bản debug: đẩy nội dung mẫu còn thiếu lên Firestore. Đăng nhập ẩn
/// danh trước vì rules yêu cầu đăng nhập (AuthController sau đó dùng lại
/// đúng người dùng này). Có timeout vì khi mất mạng, Firestore chờ kết nối
/// vô thời hạn.
Future<void> _seedMissingContent() async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) await auth.signInAnonymously();
    final added = await FirestoreSeeder()
        .seedMissing()
        .timeout(const Duration(seconds: 10));
    if (added > 0) debugPrint('Đã nạp $added document mẫu lên Firestore.');
  } catch (e) {
    debugPrint('Không nạp được dữ liệu mẫu: $e');
  }
}

/// Hiện khi Firebase không khởi động được, thay vì để app chạy tiếp rồi lỗi
/// ở lần đầu đọc dữ liệu.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ErrorView(
          message: 'Không thể khởi động ứng dụng. '
              'Hãy kiểm tra kết nối mạng rồi thử lại.',
          onRetry: main,
        ),
      ),
    );
  }
}
