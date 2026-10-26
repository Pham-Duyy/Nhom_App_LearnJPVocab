import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_controller.dart';
import '../../models/achievement.dart';
import '../../models/study_preferences.dart';
import '../../models/user_profile.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/tab_header.dart';
import '../auth/welcome_screen.dart';
import '../common/generic_screen.dart';
import '../quiz/quiz_history_screen.dart';
import 'account_screen.dart';
import 'achievements_screen.dart';
import 'help_screen.dart';
import 'study_preferences_screen.dart';

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

  Future<void> _editDisplayName(BuildContext context) async {
    final profile = context.read<UserProfileProvider>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: profile.displayName),
    );
    if (name == null || !context.mounted) return;
    await profile.updateDisplayName(name);
    if (context.mounted) _showSaveError(context);
  }

  Future<void> _pickTheme(BuildContext context) async {
    final profile = context.read<UserProfileProvider>();
    final mode = await _showOptionsSheet<ThemeMode>(
      context,
      title: 'GIAO DIỆN',
      options: ThemeMode.values,
      selected: profile.themeMode,
      labelOf: (mode) => _themeLabels[mode]!,
      iconOf: (mode) => _themeIcons[mode]!,
    );
    if (mode == null || !context.mounted) return;
    await profile.setThemeMode(mode);
    if (context.mounted) _showSaveError(context);
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _toggleReminder(BuildContext context) async {
    final profile = context.read<UserProfileProvider>();
    final preferences = profile.preferences;
    await profile.setPreferences(
      preferences.copyWith(dailyReminder: !preferences.dailyReminder),
    );
    if (context.mounted) _showSaveError(context);
  }

  Future<void> _pickDailyGoal(BuildContext context) async {
    final profile = context.read<UserProfileProvider>();
    final goal = await _showOptionsSheet<int>(
      context,
      title: 'MỤC TIÊU MỖI NGÀY',
      options: UserProfile.dailyGoalOptions,
      selected: profile.dailyGoal,
      labelOf: (goal) => '$goal từ mỗi ngày',
      iconOf: (_) => Icons.flag_outlined,
    );
    if (goal == null || !context.mounted) return;
    await profile.setDailyGoal(goal);
    if (context.mounted) _showSaveError(context);
  }

  void _showSaveError(BuildContext context) {
    final profile = context.read<UserProfileProvider>();
    final error = profile.errorMessage;
    if (error == null) return;
    profile.clearError();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final progress = context.watch<ProgressProvider>();
    final profile = context.watch<UserProfileProvider>();
    final themeMode = profile.themeMode;
    final streak = profile.streak;
    final preferences = profile.preferences;
    final email = context.watch<AuthController>().user?.email;
    final stats = watchLearningStats(context);
    final unlockedCount =
        Achievement.all.where((a) => a.isUnlocked(stats)).length;
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
            onPressed: () => _editDisplayName(context),
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
          streakDays: streak,
          favorites: progress.favoriteCount,
        ),
        const SizedBox(height: 18),
        _DailyGoalCard(learned: reviewedToday, goal: profile.dailyGoal),
        const SizedBox(height: 32),
        Text('HỌC TẬP', style: palette.sectionLabel),
        const SizedBox(height: 6),
        _ProfileMenuItem(
          icon: Icons.flag_outlined,
          title: 'Mục tiêu mỗi ngày',
          value: '${profile.dailyGoal} từ',
          onTap: () => _pickDailyGoal(context),
        ),
        _ProfileMenuItem(
          icon: Icons.workspace_premium_outlined,
          title: 'Thành tích',
          value: '$unlockedCount/${Achievement.all.length} huy hiệu',
          onTap: () => _open(context, const AchievementsScreen()),
        ),
        _ProfileMenuItem(
          icon: Icons.history_rounded,
          title: 'Lịch sử quiz',
          onTap: () => _open(context, const QuizHistoryScreen()),
        ),
        _ProfileMenuItem(
          icon: Icons.notifications_none_rounded,
          title: 'Nhắc học mỗi ngày',
          value: preferences.dailyReminder ? 'Bật' : 'Tắt',
          onTap: () => _toggleReminder(context),
        ),
        _ProfileMenuItem(
          icon: Icons.tune_rounded,
          title: 'Tùy chọn học',
          value: preferences.cardFront == CardFront.japanese
              ? 'Chữ Nhật trước'
              : 'Nghĩa trước',
          onTap: () => _open(context, const StudyPreferencesScreen()),
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
        _ProfileMenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Tài khoản',
          value: email ?? 'Khách',
          onTap: () => _open(context, const AccountScreen()),
        ),
        _ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Hướng dẫn sử dụng',
          onTap: () => _open(context, const HelpScreen()),
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

/// Bottom sheet chọn một giá trị trong [options]; trả về giá trị được chọn,
/// hoặc null nếu người dùng đóng sheet.
Future<T?> _showOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T option) labelOf,
  required IconData Function(T option) iconOf,
}) {
  return showModalBottomSheet<T>(
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
                child: Text(title, style: palette.sectionLabel),
              ),
              for (final option in options)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  leading: Icon(iconOf(option), color: palette.label),
                  title: Text(labelOf(option)),
                  trailing: option == selected
                      ? Icon(Icons.check_rounded, color: palette.primary)
                      : null,
                  selected: option == selected,
                  selectedTileColor: palette.accentSurface,
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Hộp thoại đổi tên hiển thị; trả về tên mới đã hợp lệ, hoặc null nếu hủy.
class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi tên hiển thị'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: UserProfile.maxDisplayNameLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(hintText: 'Tên của bạn'),
          validator: (value) => UserProfile.validateDisplayName(value ?? ''),
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
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
                      color: palette.accentSurface,
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
            VerticalDivider(color: palette.accentBorder),
            Expanded(
              child: _Statistic(value: '$streakDays', label: 'Ngày liên tiếp'),
            ),
            VerticalDivider(color: palette.accentBorder),
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
        color: palette.accentSurface,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: palette.accentBorder),
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
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
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
                  Flexible(
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: palette.textSecondary,
                      ),
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
