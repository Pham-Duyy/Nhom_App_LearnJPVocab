import 'package:flutter/material.dart';

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
