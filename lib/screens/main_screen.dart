import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/simple_page.dart';
import 'home/review_home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<String> pageNames = const [
    'Ôn tập',
    'Học mới',
    'Sổ từ',
    'Cá nhân',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: selectedIndex == 0
          ? const ReviewHomePage()
          : SimplePage(title: pageNames[selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
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

  AppBar buildAppBar() {
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
