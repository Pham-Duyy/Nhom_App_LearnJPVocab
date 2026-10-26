import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  /// Lề chung của nội dung trang (danh sách, trang chủ, flashcard).
  static const double page = 20;
}

class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double cardLarge = 22;
  static const double button = 16;
}

class AppTextStyles {
  AppTextStyles._();

  static const fontFamily = 'BeVietnamPro';

  /// Font chữ Nhật kiểu bút lông. Be Vietnam Pro không có kana và kanji nên
  /// mọi chữ Nhật trong app tự động hiện bằng font này.
  static const japaneseFamily = 'ShipporiMincho';

  static const fontFamilyFallback = [japaneseFamily];

  /// Chữ Nhật cỡ lớn: chữ trên thẻ, đề quiz, dấu triện.
  static const japaneseDisplay = TextStyle(
    fontFamily: japaneseFamily,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  /// Tiêu đề trong một card dạng danh sách (chủ đề, bài học).
  static const cardTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  static const pageTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );

  static const sectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static const body = TextStyle(fontSize: 14, height: 1.45);
}
