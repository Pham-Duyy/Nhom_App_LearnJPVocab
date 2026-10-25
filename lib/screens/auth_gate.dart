import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_status.dart';
import '../providers/lesson_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_colors.dart';

/// Chỉ hiển thị [child] khi đã có người dùng (ẩn danh). Mỗi khi uid đổi,
/// tải lại chủ đề và tiến độ của đúng người dùng đó.
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
      return _AuthErrorView(
        message: auth.errorMessage ?? 'Bạn đã đăng xuất.',
        onRetry: auth.isInitializing ? null : auth.retry,
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
      context.read<ProgressProvider>().loadProgress();
    });
  }
}

class _AuthErrorView extends StatelessWidget {
  const _AuthErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 56, color: context.palette.primary),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
