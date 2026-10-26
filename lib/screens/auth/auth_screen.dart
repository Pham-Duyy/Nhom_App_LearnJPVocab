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
import '../../widgets/chibi_mascot.dart';
import '../../widgets/choice_segments.dart';
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
      backgroundColor: palette.backgroundTinted,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            children: [
              _buildTopBar(palette),
              const SizedBox(height: 20),
              _buildIntro(palette),
              const SizedBox(height: 22),
              ChoiceSegments<bool>(
                options: const [false, true],
                selected: _isRegister,
                labelOf: (register) => register ? 'Đăng ký' : 'Đăng nhập',
                onChanged: _switchMode,
              ),
              const SizedBox(height: 22),
              OutlinedButton(
                onPressed: _isSubmitting ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: palette.card,
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.accentBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'G',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    SizedBox(width: 14),
                    Flexible(
                      child: Text(
                        'Tiếp tục với Google',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _buildDividerLabel(palette),
              const SizedBox(height: 10),
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
                const SizedBox(height: 12),
                _FormErrorBanner(message: _formError!),
              ],
              const SizedBox(height: 24),
              _GradientButton(
                label: _isRegister ? 'Tạo tài khoản' : 'Đăng nhập',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
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
    );
  }

  Widget _buildTopBar(AppPalette palette) {
    return Row(
      children: [
        Material(
          color: palette.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: palette.accentBorder),
          ),
          child: IconButton(
            tooltip: 'Quay lại',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_rounded, color: palette.primarySoft),
          ),
        ),
        const Spacer(),
        const BrandLogo(size: 30),
      ],
    );
  }

  Widget _buildIntro(AppPalette palette) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isRegister ? 'MỘT KHỞI ĐẦU MỚI' : 'CHÀO MỪNG TRỞ LẠI',
              style: palette.sectionLabel,
            ),
            const SizedBox(height: 12),
            Text(
              _isRegister
                  ? 'Bắt đầu\nchuyện học của bạn.'
                  : 'Học tiếp\ncùng Chibi nhé.',
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: 27,
                height: 1.3,
                color: palette.primaryStrong,
              ),
            ),
            const SizedBox(height: 10),
            Text('Từng từ nhỏ, một hành trình lớn.', style: palette.body),
          ],
        ),
        Positioned(
          top: -10,
          right: -6,
          child: ChibiMascot(
            size: 100,
            mood: _isRegister ? ChibiMood.happy : ChibiMood.neutral,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerLabel(AppPalette palette) {
    return Row(
      children: [
        Expanded(child: Divider(color: palette.accentBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'hoặc bằng email',
            style: TextStyle(color: palette.label),
          ),
        ),
        Expanded(child: Divider(color: palette.accentBorder)),
      ],
    );
  }

  List<Widget> _buildFields() {
    return [
      if (_isRegister)
        _LabeledField(
          label: 'Tên hiển thị',
          child: TextFormField(
            controller: _displayNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Chibi nên gọi bạn là gì?',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            maxLength: UserProfile.maxDisplayNameLength,
            validator: (value) => UserProfile.validateDisplayName(value ?? ''),
          ),
        ),
      _LabeledField(
        label: 'Email',
        child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            hintText: 'Ví dụ: duy@gmail.com',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
          validator: AuthValidators.email,
        ),
      ),
      _LabeledField(
        label: 'Mật khẩu',
        child: TextFormField(
          controller: _passwordController,
          obscureText: _hidePassword,
          textInputAction:
              _isRegister ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: _isRegister ? null : (_) => _submit(),
          decoration: InputDecoration(
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
      ),
      if (_isRegister)
        _LabeledField(
          label: 'Xác nhận mật khẩu',
          child: TextFormField(
            controller: _confirmController,
            obscureText: _hideConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
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
        ),
    ];
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
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

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;

  /// Hiện vòng xoay và khóa nút trong lúc chờ.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [palette.primarySoft, palette.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: palette.onPrimary,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: palette.onPrimary,
                  semanticsLabel: 'Đang xử lý',
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}
