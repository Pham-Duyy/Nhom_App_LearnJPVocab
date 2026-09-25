import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'theme/app_colors.dart';

class ChibaKanjiApp extends StatelessWidget {
  const ChibaKanjiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChibaKanji',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
