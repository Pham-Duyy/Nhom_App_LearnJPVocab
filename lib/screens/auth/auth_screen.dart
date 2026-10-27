import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_validators.dart';
import '../../models/user_profile.dart';
import '../../providers/main_navigation_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../services/welcome_store.dart';
import '../../theme/app_styles.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/japan_scenery.dart';
import '../common/generic_screen.dart';
import '../auth_gate.dart';
import '../main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key, this.startWithRegister = true}) : super(key: key);

  final bool startWithRegister;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends GenericScreenState<AuthScreen> {
  var _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late bool _isRegister = widget.startWithRegister;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  /// Đang chờ Firebase trả lời; khóa nút để không gửi hai lần.
  bool _isSubmitting = false;

  /// Lỗi từ Firebase (sai mật khẩu, email đã dùng...), hiện ngay trên nút.
  String? _formError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _switchMode(bool register) {
    if (register == _isRegister || _isSubmitting) return;
    setState(() {
      _isRegister = register;
      _formError = null;
      _formKey = GlobalKey<FormState>();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthController>();
    final email = _emailController.text;
    final password = _passwordController.text;
    if (_isRegister) {
      await _runSignIn(
        () => auth.registerWithEmail(email: email, password: password),
        onSuccess: () => _applyDisplayName(_displayNameController.text),
      );
    } else {
      await _runSignIn(
        () => auth.signInWithEmail(email: email, password: password),
      );
    }
  }

  Future<void> _signInWithGoogle() {
    final auth = context.read<AuthController>();
    return _runSignIn(
      auth.signInWithGoogle,
      onSuccess: () =>
          _applyDisplayName(auth.user?.displayName, onlyIfUnset: true),
    );
  }

  /// Khóa nút trong lúc chờ [action]; lỗi thì hiện trên form, thành công thì
  /// chạy [onSuccess] rồi vào trang chủ.
  Future<void> _runSignIn(
    Future<String?> Function() action, {
    Future<void> Function()? onSuccess,
  }) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final error = await action();
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSubmitting = false;
        _formError = error;
      });
      return;
    }

    if (onSuccess != null) await onSuccess();
    if (!mounted) return;
    _openHome();
  }

  /// Tải hồ sơ của đúng tài khoản vừa đăng nhập trước khi đặt tên, để tên
  /// mới không bị ghép với hồ sơ (mục tiêu, chuỗi ngày) của người dùng trước.
  /// Tên không hợp lệ (vd. tên Google quá dài) được bỏ qua.
  Future<void> _applyDisplayName(String? name,
      {bool onlyIfUnset = false}) async {
    final profile = context.read<UserProfileProvider>();
    await profile.load();
    if (name == null) return;
    if (onlyIfUnset && profile.displayName != UserProfile.defaultDisplayName) {
      return;
    }
    await profile.updateDisplayName(name);
  }

  void _openHome() {
    WelcomeStore.setSeen(true);
    context.read<MainNavigationProvider>().goHome();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AuthGate(child: MainScreen()),
      ),
      (_) => false,
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    if (AuthValidators.email(email) != null) {
      _showMessage('Hãy nhập đúng email của bạn vào ô Email trước.');
      return;
    }
    final error =
        await context.read<AuthController>().sendPasswordResetEmail(email);
    if (!mounted) return;
    _showMessage(
      error ?? 'Đã gửi hướng dẫn đặt lại mật khẩu tới ${email.trim()}.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  String getTitle(BuildContext context) =>
      _isRegister ? 'Đăng ký' : 'Đăng nhập';

  @override
  bool get showAppBar => false;

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: WashiBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              children: [
                // Mở từ màn khởi động thì không có màn nào phía sau để quay lại.
                SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Navigator.of(context).canPop()
                        ? IconButton(
                            tooltip: 'Quay lại',
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          )
                        : null,
                  ),
                ),
                const Center(child: BrandLogo(size: 34)),
                const SizedBox(height: 36),
                Text(
                  _isRegister ? 'Tạo tài khoản' : 'Đăng nhập',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  _isRegister
                      ? 'Lưu tiến độ học trên mọi thiết bị.'
                      : 'Chào mừng bạn quay lại.',
                  style: palette.body.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 28),
                ..._buildFields(),
                if (!_isRegister)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : _resetPassword,
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                if (_formError != null) ...[
                  const SizedBox(height: 8),
                  _FormErrorBanner(message: _formError!),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: palette.onPrimary,
                            semanticsLabel: 'Đang xử lý',
                          ),
                        )
                      : Text(_isRegister ? 'Tạo tài khoản' : 'Đăng nhập'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child:
                          Text('hoặc', style: TextStyle(color: palette.label)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _isSubmitting ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.cardBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'G',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Tiếp tục với Google',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _switchMode(!_isRegister),
                  child: Text.rich(
                    TextSpan(
                      text: _isRegister
                          ? 'Bạn đã có tài khoản? '
                          : 'Chưa có tài khoản? ',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: _isRegister ? 'Đăng nhập' : 'Đăng ký',
                          style: TextStyle(
                            color: palette.primaryStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Nhãn nằm trong ô và nổi lên khi gõ, thay cho một dòng nhãn riêng ở
  /// trên mỗi ô.
  List<Widget> _buildFields() {
    const gap = SizedBox(height: 14);
    return [
      if (_isRegister) ...[
        TextFormField(
          controller: _displayNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Tên hiển thị',
            hintText: 'Chibi nên gọi bạn là gì?',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          maxLength: UserProfile.maxDisplayNameLength,
          validator: (value) => UserProfile.validateDisplayName(value ?? ''),
        ),
        gap,
      ],
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'Ví dụ: duy@gmail.com',
          prefixIcon: Icon(Icons.alternate_email_rounded),
        ),
        validator: AuthValidators.email,
      ),
      gap,
      TextFormField(
        controller: _passwordController,
        obscureText: _hidePassword,
        textInputAction:
            _isRegister ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: _isRegister ? null : (_) => _submit(),
        decoration: InputDecoration(
          labelText: 'Mật khẩu',
          hintText: _isRegister ? 'Tạo mật khẩu' : 'Nhập mật khẩu',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          helperText: _isRegister
              ? 'Ít nhất ${AuthValidators.minPasswordLength} ký tự.'
              : null,
          suffixIcon: _VisibilityToggle(
            hidden: _hidePassword,
            onPressed: () => setState(() => _hidePassword = !_hidePassword),
          ),
        ),
        validator: AuthValidators.password,
      ),
      if (_isRegister) ...[
        gap,
        TextFormField(
          controller: _confirmController,
          obscureText: _hideConfirm,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            hintText: 'Nhập lại mật khẩu',
            prefixIcon: const Icon(Icons.verified_user_outlined),
            suffixIcon: _VisibilityToggle(
              hidden: _hideConfirm,
              onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
            ),
          ),
          validator: (value) => AuthValidators.confirmPassword(
            value,
            _passwordController.text,
          ),
        ),
      ],
    ];
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.hidden, required this.onPressed});

  final bool hidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: hidden ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
      onPressed: onPressed,
      icon: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }
}

class _FormErrorBanner extends StatelessWidget {
  const _FormErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.dangerSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.dangerBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: palette.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: palette.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
