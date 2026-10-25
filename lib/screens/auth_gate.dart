import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_status.dart';
import '../providers/lesson_provider.dart';
import '../providers/library_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/error_view.dart';

/// Chỉ hiển thị [child] khi đã có người dùng (ẩn danh). Mỗi khi uid đổi,
/// tải lại chủ đề, hồ sơ và tiến độ của đúng người dùng đó.
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _loadedUid;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.status == AuthStatus.authenticated && auth.uid != null) {
      _loadUserDataFor(auth.uid!);
      return widget.child;
    }

    if (auth.status == AuthStatus.failure ||
        auth.status == AuthStatus.unauthenticated) {
      return Scaffold(
        body: ErrorView(
          message: auth.errorMessage ?? 'Bạn đã đăng xuất.',
          onRetry: auth.isInitializing ? null : auth.retry,
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  void _loadUserDataFor(String uid) {
    if (_loadedUid == uid) return;
    _loadedUid = uid;
    // loadProgress() gọi notifyListeners(), nên phải chờ build hiện tại xong.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LessonProvider>().loadCategories();
      context.read<LibraryProvider>().load();
      context.read<UserProfileProvider>().load();
      context.read<ProgressProvider>().loadProgress();
    });
  }
}
