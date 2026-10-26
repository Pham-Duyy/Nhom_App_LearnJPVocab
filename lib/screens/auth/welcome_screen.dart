import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/chibi_mascot.dart';
import '../common/generic_screen.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends GenericScreenState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _float = CurvedAnimation(
    parent: _floatController,
    curve: Curves.easeInOut,
  );
  bool _motionEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) _motionEnabled = false;
    _syncMotion();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _syncMotion() {
    if (_motionEnabled) {
      if (!_floatController.isAnimating) {
        _floatController.repeat(reverse: true);
      }
    } else {
      _floatController.stop();
    }
  }

  void _toggleMotion() {
    setState(() => _motionEnabled = !_motionEnabled);
    _syncMotion();
  }

  void _openAuth({required bool register}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthScreen(startWithRegister: register),
      ),
    );
  }

  @override
  String getTitle(BuildContext context) => 'Chào mừng';

  @override
  bool get showAppBar => false;

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.backgroundTinted,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'ChibaKanji',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: palette.primaryStrong,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'BẠN NHỎ ĐỒNG HÀNH HỌC TIẾNG NHẬT',
                      textAlign: TextAlign.center,
                      style: palette.sectionLabel.copyWith(letterSpacing: 1.6),
                    ),
                    const SizedBox(height: 20),
                    _MascotStage(animation: _float),
                    TextButton(
                      onPressed: _toggleMotion,
                      style: TextButton.styleFrom(
                        foregroundColor: palette.textMuted,
                      ),
                      child: Text(
                        _motionEnabled
                            ? 'Tạm dừng chuyển động'
                            : 'Bật lại chuyển động',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Mỗi ngày một từ,\ngần Nhật Bản hơn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 31,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Cùng Chibi học từ mới, lật thẻ\n'
                      'và ghi nhớ từng chút mỗi ngày.',
                      textAlign: TextAlign.center,
                      style: palette.body.copyWith(fontSize: 15, height: 1.7),
                    ),
                    const Spacer(),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () => _openAuth(register: true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(62),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Bắt đầu cùng Chibi →'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => _openAuth(register: false),
                      child: Text.rich(
                        TextSpan(
                          text: 'Đã có tài khoản? ',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Đăng nhập',
                              style: TextStyle(
                                color: palette.primaryStrong,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MascotStage extends StatelessWidget {
  const _MascotStage({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 310,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [palette.card, palette.secondary],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -10 * t),
                child: const ChibiMascot(size: 230),
              ),
              Positioned(
                left: 0,
                top: 34 + 8 * t,
                child: Transform.rotate(
                  angle: -0.12,
                  child: _GlyphTile(
                    glyph: 'あ',
                    background: palette.card,
                    foreground: palette.primarySoft,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 170 - 8 * t,
                child: Transform.rotate(
                  angle: 0.1,
                  child: _GlyphTile(
                    glyph: 'か',
                    background: palette.topicBackgrounds[1],
                    foreground: palette.topicForegrounds[1],
                  ),
                ),
              ),
              Positioned(
                right: 34,
                top: 26 + 6 * t,
                child: Icon(
                  Icons.auto_awesome,
                  size: 26,
                  color: palette.accentBorder,
                ),
              ),
              Positioned(
                left: 30,
                bottom: 60 - 6 * t,
                child: Icon(
                  Icons.auto_awesome_outlined,
                  size: 16,
                  color: palette.primarySoft,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlyphTile extends StatelessWidget {
  const _GlyphTile({
    required this.glyph,
    required this.background,
    required this.foreground,
  });

  final String glyph;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.palette.primary.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
