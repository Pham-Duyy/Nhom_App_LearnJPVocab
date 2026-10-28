import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/sound_provider.dart';
import 'providers/user_profile_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/main_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_styles.dart';

class ChibaKanjiApp extends StatelessWidget {
  const ChibaKanjiApp({
    Key? key,
    this.showWelcome = true,
    this.signedIn = false,
  }) : super(key: key);

  /// Hiện màn khởi động trước (app thật luôn hiện; test có thể bỏ qua).
  final bool showWelcome;

  /// Đã đăng nhập từ lần trước: màn khởi động xong thì vào thẳng trang chủ.
  final bool signedIn;

  /// Mức phóng chữ lớn nhất theo cài đặt cỡ chữ của máy.
  static const maxTextScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChibaKanji',
      theme: _buildTheme(AppPalette.light, Brightness.light),
      darkTheme: _buildTheme(AppPalette.dark, Brightness.dark),
      themeMode: context.select<UserProfileProvider, ThemeMode>(
        (profile) => profile.themeMode,
      ),
      // Trình duyệt chỉ cho phát tiếng sau lần chạm đầu tiên vào trang.
      // Giao diện được canh theo đúng cỡ chữ thiết kế: máy để chữ hệ thống
      // lớn (vd. 145%) thì chữ trong app không phóng thêm để bố cục không vỡ
      // dòng; để chữ nhỏ hơn mặc định thì vẫn thu nhỏ theo.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => context.read<SoundProvider>().userInteracted(),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: maxTextScale,
          child: child!,
        ),
      ),
      home: showWelcome
          ? WelcomeScreen(signedIn: signedIn)
          : const AuthGate(child: MainScreen()),
    );
  }

  ThemeData _buildTheme(AppPalette palette, Brightness brightness) {
    const font = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFamilyFallback,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
      borderSide: BorderSide(color: palette.cardBorder),
    );

    return ThemeData(
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFamilyFallback,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        secondary: palette.secondary,
        onSecondary: palette.primary,
        error: palette.danger,
        onError: palette.onPrimary,
        surface: palette.background,
        onSurface: palette.textPrimary,
        onSurfaceVariant: palette.textSecondary,
        surfaceContainerHighest: palette.mutedSurface,
        outline: palette.cardBorder,
        outlineVariant: palette.divider,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: font.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.accentBorder,
          disabledForegroundColor: palette.textMuted,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: buttonShape,
          textStyle: font.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: palette.accentBorder),
          shape: buttonShape,
          textStyle: font.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        hintStyle: TextStyle(color: palette.textMuted),
        prefixIconColor: palette.textMuted,
        suffixIconColor: palette.textMuted,
        errorMaxLines: 2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.primary, width: 1.4),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.progressTrack,
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: font.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        contentTextStyle: font.copyWith(
          fontSize: 15,
          height: 1.5,
          color: palette.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: palette.accentBorder,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.background,
        elevation: 0,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textSecondary,
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        selectedLabelStyle:
            font.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            font.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textPrimary,
        contentTextStyle: font.copyWith(color: palette.background),
      ),
    );
  }
}
