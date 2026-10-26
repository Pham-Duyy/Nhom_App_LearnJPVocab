import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../auth/auth_screen.dart';
import '../common/generic_screen.dart';

/// Thông tin tài khoản. Tài khoản khách được gợi ý liên kết email hoặc
/// Google để giữ tiến độ; tài khoản email có thể đặt lại mật khẩu.
class AccountScreen extends GenericScreen {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Tài khoản';

  void _linkWithEmail(BuildContext context) {
    // Đăng ký khi đang là khách sẽ gắn email vào chính tài khoản này.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AuthScreen(startWithRegister: true),
      ),
    );
  }

  Future<void> _linkWithGoogle(BuildContext context) async {
    final error = await context.read<AuthController>().signInWithGoogle();
    if (!context.mounted) return;
    showErrorSnackBar(context, error ?? 'Đã liên kết tài khoản Google.');
  }

  Future<void> _resetPassword(BuildContext context, String email) async {
    final error =
        await context.read<AuthController>().sendPasswordResetEmail(email);
    if (!context.mounted) return;
    showErrorSnackBar(
      context,
      error ?? 'Đã gửi hướng dẫn đặt lại mật khẩu tới $email.',
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink();
    final email = user.email;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Card(
          elevation: 0,
          color: palette.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: palette.cardBorder),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.login_rounded),
                title: const Text('Cách đăng nhập'),
                trailing: Text(user.signInMethodLabel),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.alternate_email_rounded),
                title: const Text('Email'),
                trailing: Text(email ?? 'Chưa có'),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Mã tài khoản'),
                trailing: Text(user.uid.length > 8
                    ? '${user.uid.substring(0, 8)}…'
                    : user.uid),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (user.isAnonymous) ...[
          Text(
            'Bạn đang dùng tài khoản khách. Nếu đăng xuất hoặc đổi máy, tiến '
            'độ học sẽ mất. Hãy liên kết email hoặc Google để giữ lại.',
            style: palette.body,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _linkWithEmail(context),
            icon: const Icon(Icons.mail_outline_rounded),
            label: const Text('Liên kết bằng email'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _linkWithGoogle(context),
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
            label: const Text('Liên kết Google'),
          ),
        ] else if (user.hasPassword && email != null)
          OutlinedButton.icon(
            onPressed: () => _resetPassword(context, email),
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Đặt lại mật khẩu'),
          ),
      ],
    );
  }
}
