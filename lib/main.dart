import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/firestore_seeder.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase.initializeApp error: $e');
  }
  if (kDebugMode) await _seedContentIfEmpty();
  runApp(const AppProviders(child: ChibaKanjiApp()));
}

/// Chỉ ở bản debug: đẩy dữ liệu mẫu lên Firestore lần đầu chạy. Đăng nhập ẩn
/// danh trước vì rules yêu cầu đăng nhập (AuthController sau đó dùng lại
/// đúng người dùng này). Có timeout vì khi mất mạng, Firestore chờ kết nối
/// vô thời hạn.
Future<void> _seedContentIfEmpty() async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) await auth.signInAnonymously();
    final seeded = await FirestoreSeeder()
        .seedIfEmpty()
        .timeout(const Duration(seconds: 10));
    if (seeded) debugPrint('Đã nạp dữ liệu mẫu lên Firestore.');
  } catch (e) {
    debugPrint('Không nạp được dữ liệu mẫu: $e');
  }
}
