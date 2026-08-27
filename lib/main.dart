import 'package:flutter/material.dart';

void main() => runApp(const CalmDayApp());

class CalmDayApp extends StatelessWidget {
  const CalmDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ngày nhẹ nhàng',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B7C6C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF7),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<_Task> _tasks = [
    _Task('Uống một ly nước', 'Bắt đầu ngày mới thật chậm rãi', true),
    _Task('Hoàn thành một việc quan trọng', 'Chỉ cần một bước nhỏ', false),
    _Task(
      'Dành 10 phút cho bản thân',
      'Đi bộ, đọc sách hoặc hít thở sâu',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((task) => task.done).length;
    final progress = done / _tasks.length;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDECE3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Color(0xFF35614C),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày nhẹ nhàng',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text('Chậm lại một chút, bạn nhé.'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF35614C),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tiến độ hôm nay',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$done/${_tasks.length} việc đã hoàn thành',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          color: const Color(0xFFD7F1D7),
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Việc nhỏ cho hôm nay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...List.generate(_tasks.length, (index) {
                  final task = _tasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      child: CheckboxListTile(
                        value: task.done,
                        onChanged: (value) =>
                            setState(() => task.done = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: task.done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(task.subtitle),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Text(
                  done == _tasks.length
                      ? 'Tuyệt vời! Hôm nay bạn đã làm đủ rồi.'
                      : 'Không cần vội. Một việc hoàn thành cũng là tiến bộ.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF617069)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Task {
  _Task(this.title, this.subtitle, this.done);

  final String title;
  final String subtitle;
  bool done;
}
