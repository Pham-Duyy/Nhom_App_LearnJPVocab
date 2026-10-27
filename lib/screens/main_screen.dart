import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/main_navigation_provider.dart';
import '../providers/sound_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/japan_scenery.dart';
import 'exam/exam_setup_screen.dart';
import 'home/review_home_page.dart';
import 'lesson/category_screen.dart';
import 'profile/profile_screen.dart';
import 'vocabulary/vocabulary_book_screen.dart';

/// Khung chính của ứng dụng: 5 tab chuyển bằng BottomNavigationBar. Mở ra
/// (ngay sau đăng nhập) thì chào bằng tiếng Nhật và bật nhạc nền.
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  /// Trang của từng tab, cùng thứ tự với [_items].
  static const _pages = <Widget>[
    ReviewHomePage(),
    CategoryScreen(),
    ExamSetupScreen(),
    VocabularyBookScreen(),
    ProfileScreen(),
  ];

  static const _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.auto_stories_outlined),
      activeIcon: _ActiveIcon(Icon(Icons.auto_stories)),
      label: 'Ôn tập',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.eco_outlined),
      activeIcon: _ActiveIcon(Icon(Icons.eco)),
      label: 'Học mới',
    ),
    BottomNavigationBarItem(
      icon: ToriiIcon(),
      activeIcon: _ActiveIcon(ToriiIcon()),
      label: 'Thi thử',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      activeIcon: _ActiveIcon(Icon(Icons.book)),
      label: 'Sổ từ',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: _ActiveIcon(Icon(Icons.person_rounded)),
      label: 'Cá nhân',
    ),
  ];

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final SoundProvider _sound;

  @override
  void initState() {
    super.initState();
    _sound = context.read<SoundProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sound.welcome());
  }

  @override
  void dispose() {
    _sound.leaveApp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<MainNavigationProvider>();
    final palette = context.palette;

    return WashiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: MainScreen._pages[navigation.selectedIndex],
        ),
        bottomNavigationBar: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            currentIndex: navigation.selectedIndex,
            onTap: navigation.selectTab,
            items: MainScreen._items,
          ),
        ),
      ),
    );
  }
}

/// Icon của tab đang chọn: nằm trên nền viên thuốc màu chàm nhạt.
class _ActiveIcon extends StatelessWidget {
  const _ActiveIcon(this.icon);

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: context.palette.accentSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: icon,
    );
  }
}
