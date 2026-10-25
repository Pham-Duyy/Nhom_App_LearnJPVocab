import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_controller.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/tab_header.dart';
import '../auth/welcome_screen.dart';
import '../common/generic_screen.dart';

class ProfileScreen extends GenericScreen {
  const ProfileScreen({Key? key}) : super(key: key);

  static const _themeLabels = {
    ThemeMode.system: 'Theo máy',
    ThemeMode.light: 'Sáng',
    ThemeMode.dark: 'Tối',
  };

  static const _themeIcons = {
    ThemeMode.system: Icons.brightness_auto_outlined,
    ThemeMode.light: Icons.light_mode_outlined,
    ThemeMode.dark: Icons.dark_mode_outlined,
  };

  @override
  String getTitle(BuildContext context) => 'Cá nhân';

  @override
  bool get showAppBar => false;

  Future<void> _confirmSignOut(BuildContext context) async {
    final palette = context.palette;
    final auth = context.read<AuthController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: Text(
          auth.isAnonymous
              ? 'Bạn đang học bằng tài khoản khách. Sau khi đăng xuất, '
                  'tiến độ hiện tại sẽ không lấy lại được.'
              : 'Bạn có thể đăng nhập lại bất cứ lúc nào để tiếp tục học.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: palette.danger),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
    await auth.signOut();
  }

  void _pickTheme(BuildContext context) {
    final settings = context.read<AppSettingsProvider>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final palette = sheetContext.palette;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text('GIAO DIỆN', style: palette.sectionLabel),
                ),
                for (final mode in ThemeMode.values)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    leading: Icon(_themeIcons[mode], color: palette.label),
                    title: Text(_themeLabels[mode]!),
                    trailing: settings.themeMode == mode
                        ? Icon(Icons.check_rounded, color: palette.primary)
                        : null,
                    selected: settings.themeMode == mode,
                    selectedTileColor: palette.lavenderSurface,
                    onTap: () {
                      settings.setThemeMode(mode);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final progress = context.watch<ProgressProvider>();
    final profile = context.watch<UserProfileProvider>();
    final themeMode = context.watch<AppSettingsProvider>().themeMode;
    final reviewedToday = progress.getReviewedTodayCount();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        16,
        AppSpacing.page,
        28,
      ),
      children: [
        TabHeader(
          label: 'TÀI KHOẢN',
          title: 'Cá nhân',
          trailing: TextButton.icon(
            onPressed: () => _showComingSoon(context, 'Chỉnh sửa hồ sơ'),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text(
              'Chỉnh sửa',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ProfileHeader(name: profile.displayName, initial: profile.initial),
        const SizedBox(height: 24),
        _StatisticsRow(
          learned: progress.totalLearned,
          streakDays: 7,
          favorites: progress.favoriteCount,
        ),
        const SizedBox(height: 18),
        _DailyGoalCard(
          learned: reviewedToday,
          goal: ProgressProvider.dailyGoal,
        ),
        const SizedBox(height: 32),
        Text('HỌC TẬP', style: palette.sectionLabel),
        const SizedBox(height: 6),
        const _ProfileMenuItem(
          icon: Icons.workspace_premium_outlined,
          title: 'Thành tích',
          value: '7 ngày đều đặn',
        ),
        const _ProfileMenuItem(
          icon: Icons.history_rounded,
          title: 'Lịch sử ôn tập',
          value: 'Chưa có phiên',
        ),
        const _ProfileMenuItem(
          icon: Icons.notifications_none_rounded,
          title: 'Nhắc học mỗi ngày',
          value: '20:00',
        ),
        const _ProfileMenuItem(
          icon: Icons.tune_rounded,
          title: 'Tùy chọn học',
          value: 'Thẻ & cách đọc',
          showDivider: false,
        ),
        const SizedBox(height: 28),
        Text('TÀI KHOẢN & HỖ TRỢ', style: palette.sectionLabel),
        const SizedBox(height: 6),
        _ProfileMenuItem(
          icon: _themeIcons[themeMode]!,
          title: 'Giao diện',
          value: _themeLabels[themeMode],
          onTap: () => _pickTheme(context),
        ),
        const _ProfileMenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Thông tin tài khoản',
        ),
        const _ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Hướng dẫn sử dụng',
          showDivider: false,
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text('Đăng xuất'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            foregroundColor: palette.danger,
            backgroundColor: palette.dangerSurface,
            side: BorderSide(color: palette.dangerBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'ChibaKanji · Phiên bản 1.0.0',
            style: TextStyle(fontSize: 12, color: palette.textMuted),
          ),
        ),
      ],
    );
  }
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$feature sẽ được hoàn thiện ở giai đoạn sau.')),
    );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.initial});

  final String name;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.secondary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.card, width: 4),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: Text('Người học tiếng Nhật', style: palette.body),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.lavenderSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'N5',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatisticsRow extends StatelessWidget {
  const _StatisticsRow({
    required this.learned,
    required this.streakDays,
    required this.favorites,
  });

  final int learned;
  final int streakDays;
  final int favorites;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: palette.mutedSurface,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _Statistic(value: '$learned', label: 'Từ đã học')),
            VerticalDivider(color: palette.lavenderBorder),
            Expanded(
              child: _Statistic(value: '$streakDays', label: 'Ngày liên tiếp'),
            ),
            VerticalDivider(color: palette.lavenderBorder),
            Expanded(
              child: _Statistic(value: '$favorites', label: 'Từ yêu thích'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Statistic extends StatelessWidget {
  const _Statistic({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: context.palette.textSecondary),
        ),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.learned, required this.goal});

  final int learned;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final remaining = goal - learned;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: palette.lavenderSurface,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: palette.lavenderBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mục tiêu hôm nay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remaining > 0
                          ? 'Còn $remaining từ để hoàn thành.'
                          : 'Bạn đã hoàn thành mục tiêu hôm nay!',
                      style: palette.body.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$learned',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: palette.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' / $goal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedProgressBar(
            value: learned / goal,
            color: palette.primarySoft,
            backgroundColor: palette.card,
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        InkWell(
          onTap: onTap ?? () => _showComingSoon(context, title),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.mutedSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: palette.label),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.textSecondary,
                    ),
                  ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: palette.textMuted),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(indent: 60),
      ],
    );
  }
}
