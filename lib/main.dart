import 'package:flutter/material.dart';

void main() {
  runApp(const ChibaKanjiApp());
}

class ChibaKanjiApp extends StatelessWidget {
  const ChibaKanjiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChibaKanji',
      theme: ThemeData(
        primaryColor: const Color(0xFF397B32),
        scaffoldBackgroundColor: const Color(0xFFFFFBF0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF397B32),
          secondary: Color(0xFFFFD65A),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

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
        selectedItemColor: const Color(0xFF397B32),
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
      backgroundColor: const Color(0xFFFFDF78),
      foregroundColor: const Color(0xFF413A2B),
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

class ReviewHomePage extends StatelessWidget {
  const ReviewHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const GreetingSection(),
        const SizedBox(height: 24),
        const MemoryCard(),
        const SizedBox(height: 16),
        ReviewCard(
          onReview: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bắt đầu phiên ôn tập 3 từ!'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFFFFF2BD),
          child: Text('•ᴗ•', style: TextStyle(fontSize: 24)),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào Duy!',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Mỗi ngày một chút, nhớ lâu hơn.'),
            ],
          ),
        ),
      ],
    );
  }
}

class MemoryCard extends StatelessWidget {
  const MemoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEBE6D7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BẠN ĐÃ HỌC'),
            const Text(
              '9 từ vựng',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                MemoryBar(level: 1, count: 3, height: 55),
                MemoryBar(level: 2, count: 3, height: 75),
                MemoryBar(level: 3, count: 1, height: 35),
                MemoryBar(level: 4, count: 1, height: 42),
                MemoryBar(level: 5, count: 1, height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryBar extends StatelessWidget {
  const MemoryBar({
    Key? key,
    required this.level,
    required this.count,
    required this.height,
  }) : super(key: key);

  final int level;
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFEDB86D),
      const Color(0xFFE5C957),
      const Color(0xFFBFC979),
      const Color(0xFF8FBC7B),
      const Color(0xFF5C9864),
    ];

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$count'),
          const SizedBox(height: 5),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: colors[level - 1],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text('Mức $level', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({Key? key, required this.onReview}) : super(key: key);

  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0B7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Text(
            'Đến giờ ôn rồi!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text('3 từ đang chờ bạn · khoảng 2 phút'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF397B32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Ôn ngay',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SimplePage extends StatelessWidget {
  const SimplePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Màn hình $title sẽ được hoàn thiện tiếp.',
        style: const TextStyle(fontSize: 17),
      ),
    );
  }
}
