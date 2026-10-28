import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sound_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/chibi_mascot.dart';
import '../../widgets/japan_scenery.dart';
import '../auth_gate.dart';
import '../main_screen.dart';
import 'auth_screen.dart';

/// Màn khởi động, hiện mỗi lần mở app: Chibi chuyển động ở giữa màn hình,
/// tiếng chuông và Chibi đọc tên app. Sau [duration] (hoặc khi chạm vào màn
/// hình) thì vào trang chủ nếu đã đăng nhập từ trước ([signedIn]), không thì
/// sang màn đăng ký/đăng nhập.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key, this.signedIn = false}) : super(key: key);

  static const duration = Duration(seconds: 7);

  final bool signedIn;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _float = CurvedAnimation(
    parent: _floatController,
    curve: Curves.easeInOut,
  );
  Timer? _timer;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    context.read<SoundProvider>().introduce();
    _timer = Timer(WelcomeScreen.duration, _openAuth);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Máy bật "giảm chuyển động" trong cài đặt trợ năng thì Chibi đứng yên.
    if (MediaQuery.of(context).disableAnimations) {
      _floatController.stop();
    } else if (!_floatController.isAnimating) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  /// Người mới nhiều hơn nên mở sẵn chế độ đăng ký; màn đó có nút chuyển
  /// sang đăng nhập.
  void _openAuth() {
    if (_opened || !mounted) return;
    _opened = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.signedIn
            ? const AuthGate(child: MainScreen())
            : const AuthScreen(startWithRegister: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WashiBackground(
        child: Semantics(
          button: true,
          label: 'ChibaKanji. Chạm để bắt đầu',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openAuth,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _MascotStage(animation: _float),
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
      width: 320,
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
