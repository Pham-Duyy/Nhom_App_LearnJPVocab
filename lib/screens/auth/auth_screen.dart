import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/main_navigation_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/chibi_mascot.dart';
import '../../widgets/segmented_tabs.dart';
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
  static final _usernamePattern = RegExp(r'^[A-Za-z0-9_]{3,24}$');

  var _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late bool _isRegister = widget.startWithRegister;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _switchMode(bool register) {
    if (register == _isRegister) return;
    setState(() {
      _isRegister = register;
      _formKey = GlobalKey<FormState>();
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isRegister) {
      context
          .read<UserProfileProvider>()
          .updateDisplayName(_displayNameController.text);
    }
    context.read<MainNavigationProvider>().goHome();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AuthGate(child: MainScreen()),
      ),
      (_) => false,
    );
  }

  void _signInWithGoogle() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập Google sẽ có khi nối Firebase Auth.'),
        ),
      );
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
              SegmentedTabs(
                labels: const ['Đăng nhập', 'Đăng ký'],
                selectedIndex: _isRegister ? 1 : 0,
                onChanged: (index) => _switchMode(index == 1),
              ),
              const SizedBox(height: 22),
              OutlinedButton(
                onPressed: _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: palette.card,
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.lavenderBorder),
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
                    Text('Tiếp tục với Google'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _buildDividerLabel(palette),
              const SizedBox(height: 10),
              ..._buildFields(),
              const SizedBox(height: 28),
              _GradientButton(
                label: _isRegister ? 'Tạo tài khoản' : 'Đăng nhập',
                onPressed: _submit,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 18,
                    color: palette.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Bản trải nghiệm giao diện',
                    style: TextStyle(color: palette.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
            side: BorderSide(color: palette.lavenderBorder),
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
        Expanded(child: Divider(color: palette.lavenderBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'hoặc bằng tên đăng nhập',
            style: TextStyle(color: palette.label),
          ),
        ),
        Expanded(child: Divider(color: palette.lavenderBorder)),
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
            validator: (value) => (value ?? '').trim().isEmpty
                ? 'Hãy cho Chibi biết tên của bạn.'
                : null,
          ),
        ),
      _LabeledField(
        label: 'Tên đăng nhập',
        child: TextFormField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Ví dụ: duy_hocnhat',
            prefixIcon: const Icon(Icons.alternate_email_rounded),
            helperText:
                _isRegister ? '3–24 ký tự: chữ không dấu, số hoặc dấu _' : null,
          ),
          validator: (value) => _usernamePattern.hasMatch(value ?? '')
              ? null
              : 'Tên đăng nhập gồm 3–24 ký tự: chữ không dấu, số hoặc _.',
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
            hintText: _isRegister ? 'Tạo mật khẩu mẫu' : 'Nhập mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            helperText:
                _isRegister ? 'Dùng ít nhất 6 ký tự cho bản demo.' : null,
            suffixIcon: _VisibilityToggle(
              hidden: _hidePassword,
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),
          validator: (value) =>
              (value ?? '').length < 6 ? 'Mật khẩu cần ít nhất 6 ký tự.' : null,
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
              hintText: 'Nhập lại mật khẩu mẫu',
              prefixIcon: const Icon(Icons.verified_user_outlined),
              suffixIcon: _VisibilityToggle(
                hidden: _hideConfirm,
                onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
              ),
            ),
            validator: (value) => value != _passwordController.text
                ? 'Mật khẩu xác nhận chưa khớp.'
                : null,
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

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
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
