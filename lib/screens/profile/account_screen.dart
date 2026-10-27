import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_validators.dart';
import '../../repositories/user_data_cleaner.dart';
import '../../services/welcome_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../auth/auth_screen.dart';
import '../auth/welcome_screen.dart';
import '../common/generic_screen.dart';

/// Thông tin tài khoản. Tài khoản khách được gợi ý liên kết email hoặc
/// Google để giữ tiến độ; tài khoản email đổi hoặc đặt lại được mật khẩu.
/// Mọi tài khoản đều xóa được, kèm toàn bộ dữ liệu học.
class AccountScreen extends GenericScreen {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Tài khoản';

  void _linkWithEmail(BuildContext context) {
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
        ] else if (user.hasPassword && email != null) ...[
          ElevatedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const _ChangePasswordDialog(),
            ),
            icon: const Icon(Icons.password_rounded),
            label: const Text('Đổi mật khẩu'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _resetPassword(context, email),
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Quên mật khẩu? Gửi email đặt lại'),
          ),
        ],
        const SizedBox(height: 40),
        Text('VÙNG NGUY HIỂM', style: palette.sectionLabel),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _deleteAccount(context, user.hasPassword),
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text('Xóa tài khoản và dữ liệu'),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.danger,
            side: BorderSide(color: palette.dangerBorder),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteAccount(BuildContext context, bool needsPassword) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteAccountDialog(needsPassword: needsPassword),
    );
    if (deleted != true || !context.mounted) return;
    WelcomeStore.setSeen(false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }
}

/// Đổi mật khẩu: nhập mật khẩu hiện tại để xác nhận, mật khẩu mới hai lần.
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await context.read<AuthController>().changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Đã đổi mật khẩu.')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
              validator: (value) => (value ?? '').isEmpty
                  ? 'Vui lòng nhập mật khẩu hiện tại.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
              validator: (value) =>
                  AuthValidators.confirmPassword(value, _next.text),
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: context.palette.danger)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _saving ? null : _submit,
          child: const Text('Đổi mật khẩu'),
        ),
      ],
    );
  }
}

/// Xác nhận xóa tài khoản; trả về true nếu đã xóa xong.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.needsPassword});

  /// Tài khoản email phải nhập lại mật khẩu để xác nhận.
  final bool needsPassword;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _deleting = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (widget.needsPassword && _password.text.isEmpty) {
      setState(() => _error = 'Vui lòng nhập mật khẩu để xác nhận.');
      return;
    }
    setState(() {
      _deleting = true;
      _error = null;
    });
    final error = await context.read<AuthController>().deleteAccount(
          password: widget.needsPassword ? _password.text : null,
          deleteData: context.read<UserDataCleaner>().deleteAll,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _deleting = false;
        _error = error;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AlertDialog(
      title: const Text('Xóa tài khoản?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Toàn bộ hồ sơ, tiến độ học, lịch sử quiz và kho từ của bạn sẽ '
            'bị xóa vĩnh viễn và không thể khôi phục.',
          ),
          if (widget.needsPassword) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              onSubmitted: (_) => _delete(),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: palette.danger)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.pop(context, false),
          child: const Text('Giữ tài khoản'),
        ),
        TextButton(
          onPressed: _deleting ? null : _delete,
          style: TextButton.styleFrom(foregroundColor: palette.danger),
          child: _deleting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Xóa vĩnh viễn'),
        ),
      ],
    );
  }
}
