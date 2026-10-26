import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/main_navigation_provider.dart';
import '../theme/app_colors.dart';
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
    BottomNavigationBarItem(
      icon: Icon(Icons.alarm_outlined),
      activeIcon: Icon(Icons.alarm),
      label: 'Ôn tập',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.import_contacts_outlined),
      activeIcon: Icon(Icons.import_contacts),
      label: 'Học mới',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_border_rounded),
      activeIcon: Icon(Icons.bookmark_rounded),
      label: 'Sổ từ',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Cá nhân',
    ),
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
