import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/main_navigation_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'home/review_home_page.dart';
import 'lesson/category_screen.dart';
import 'profile/profile_screen.dart';
import 'vocabulary/vocabulary_book_screen.dart';

/// Khung chính của ứng dụng: 4 tab chuyển bằng BottomNavigationBar.
class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  /// Trang của từng tab, cùng thứ tự với [_items].
  static const _pages = <Widget>[
    ReviewHomePage(),
    CategoryScreen(),
    VocabularyBookScreen(),
    ProfileScreen(),
  ];

  static const _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: _KanjiIcon('復'), label: 'Ôn tập'),
    BottomNavigationBarItem(icon: _KanjiIcon('学'), label: 'Học mới'),
    BottomNavigationBarItem(icon: _KanjiIcon('辞'), label: 'Sổ từ'),
    BottomNavigationBarItem(icon: _KanjiIcon('私'), label: 'Cá nhân'),
  ];

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<MainNavigationProvider>();

    return Scaffold(
      body: SafeArea(bottom: false, child: _pages[navigation.selectedIndex]),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.palette.divider)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navigation.selectedIndex,
          onTap: navigation.selectTab,
          items: _items,
        ),
      ),
    );
  }
}

/// Biểu tượng tab là một chữ Hán; lấy màu từ IconTheme nên tự đổi màu theo
/// tab đang chọn như Icon thường.
class _KanjiIcon extends StatelessWidget {
  const _KanjiIcon(this.kanji);

  final String kanji;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return SizedBox.square(
      dimension: 26,
      child: Center(
        child: Text(
          kanji,
          style: AppTextStyles.japaneseDisplay.copyWith(
            fontSize: iconTheme.size,
            color: iconTheme.color,
            height: 1,
          ),
        ),
      ),
    );
  }
}
