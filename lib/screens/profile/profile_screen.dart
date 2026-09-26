import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final learnedToday = progress.totalLearned.clamp(0, 10);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          const Text('Cá nhân',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          _ProfileHeader(totalLearned: progress.totalLearned),
          const SizedBox(height: 16),
          _DailyGoalCard(learned: learnedToday, goal: 10),
          const SizedBox(height: 22),
          const Text('Học tập',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const _MenuCard(
            children: [
              _ProfileMenuItem(
                icon: Icons.emoji_events_outlined,
                iconColor: Color(0xFFE6A52E),
                title: 'Thành tích',
                subtitle: 'Xem những cột mốc đã đạt được',
              ),
              _ProfileMenuItem(
                icon: Icons.track_changes,
                iconColor: AppColors.primary,
                title: 'Mục tiêu học tập',
                subtitle: '10 từ mới mỗi ngày',
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Ứng dụng',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const _MenuCard(
            children: [
              _ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                iconColor: Color(0xFF5F79B8),
                title: 'Nhắc nhở học tập',
                subtitle: 'Mỗi ngày lúc 20:00',
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                iconColor: Colors.blueGrey,
                title: 'Cài đặt',
                subtitle: 'Âm thanh, giao diện và dữ liệu',
              ),
              _ProfileMenuItem(
                icon: Icons.info_outline_rounded,
                iconColor: Color(0xFF8A78B8),
                title: 'Về ChibaKanji',
                subtitle: 'Phiên bản học tập 1.0.0',
                showDivider: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.totalLearned});

  final int totalLearned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE28A), Color(0xFFFFF1BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.person_rounded,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text('Duy',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Người học tiếng Nhật N5',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Statistic(
                  value: '$totalLearned',
                  label: 'Từ đã học',
                  icon: Icons.menu_book_rounded,
                ),
              ),
              Container(width: 1, height: 42, color: Colors.black12),
              const Expanded(
                child: _Statistic(
                  value: '7',
                  label: 'Ngày liên tiếp',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Statistic extends StatelessWidget {
  const _Statistic(
      {required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(value,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
    final ratio = learned / goal;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.primary, size: 23),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mục tiêu hôm nay',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Duy trì thói quen mỗi ngày',
                        style: TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              Text('$learned/$goal từ',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0).toDouble(),
              minHeight: 9,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('$title sẽ được hoàn thiện ở giai đoạn sau.')),
            );
          },
        ),
        if (showDivider) const Divider(height: 1, indent: 70, endIndent: 16),
      ],
    );
  }
}
