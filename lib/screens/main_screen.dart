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
      body: SafeArea(bottom: false, child: _buildBody(selectedIndex)),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.palette.divider)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              context.read<MainNavigationProvider>().selectTab(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.alarm_outlined),
              label: 'Ôn tập',
            ),
            NavigationDestination(
              icon: Icon(Icons.import_contacts_outlined),
              label: 'Học mới',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              label: 'Sổ từ',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Cá nhân',
            ),
          ],
        ),
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
}
