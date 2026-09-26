import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/main_navigation_provider.dart';
import '../theme/app_colors.dart';
import 'home/review_home_page.dart';
import 'lesson/category_screen.dart';
import 'profile/profile_screen.dart';
import 'vocabulary/vocabulary_book_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<MainNavigationProvider>().selectedIndex;

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) =>
            context.read<MainNavigationProvider>().selectTab(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Ôn tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Học mới',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks),
            label: 'Sổ từ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const ReviewHomePage();
      case 1:
        return const CategoryScreen();
      case 2:
        return const VocabularyBookScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const ReviewHomePage();
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.appBarBackground,
      foregroundColor: AppColors.appBarForeground,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ChibaKanji',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          Text(
            'Tiếng Nhật, vui mỗi ngày',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Chip(
            avatar: Icon(
              Icons.local_fire_department,
              size: 18,
              color: Colors.orange,
            ),
            label: Text('7 ngày'),
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
