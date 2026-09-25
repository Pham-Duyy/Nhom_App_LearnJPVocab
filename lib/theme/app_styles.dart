import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  /// Lề chung của nội dung trang (danh sách, trang chủ, flashcard).
  static const double page = 20;
}

class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double cardLarge = 20;
}

class AppTextStyles {
  AppTextStyles._();

  /// Tiêu đề trong một card dạng danh sách (chủ đề, bài học).
  static const cardTitle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
}
