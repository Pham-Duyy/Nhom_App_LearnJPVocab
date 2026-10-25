import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/lesson.dart';
import '../models/vocabulary.dart';
import '../repositories/category_repository.dart';
import '../repositories/vocabulary_repository.dart';
import '../utils/app_error.dart';

/// Toàn bộ nội dung học (chủ đề, bài học, từ vựng) đọc từ CSDL một lần sau
/// khi đăng nhập, cho các màn hình cần xem nhiều bài cùng lúc: Sổ từ và
/// tiến độ từng chủ đề.
class LibraryProvider extends ChangeNotifier {
  LibraryProvider(this._categories, this._vocabulary);

  final CategoryRepository _categories;
  final VocabularyRepository _vocabulary;

  List<Vocabulary> _words = [];

  /// Mã chủ đề của từng bài học: lessonId -> categoryId.
  Map<String, String> _categoryOfLesson = {};
  bool _isLoading = false;
  String? _errorMessage;

  /// Mọi từ vựng, theo thứ tự học: chủ đề -> bài -> từ.
  List<Vocabulary> get words => _words;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Id các từ thuộc một chủ đề, để tính tiến độ của chủ đề đó.
  Set<String> wordIdsOf(String categoryId) => {
        for (final word in _words)
          if (_categoryOfLesson[word.lessonId] == categoryId) word.id,
      };

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Đọc song song; Future.wait ném ra đúng lỗi gốc (vd. mất mạng) để
      // AppError chọn được câu báo phù hợp.
      final results = await Future.wait<List<Object>>([
        _categories.getCategories(),
        _categories.getAllLessons(),
        _vocabulary.getAll(),
      ]);
      final categories = results[0].cast<Category>();
      final lessons = results[1].cast<Lesson>();
      final words = results[2].cast<Vocabulary>().toList();

      _categoryOfLesson = {
        for (final lesson in lessons) lesson.id: lesson.categoryId,
      };

      // Thứ hạng của mỗi bài trong toàn bộ khóa học, để xếp từ theo đúng
      // thứ tự người học gặp chúng.
      final categoryRank = {
        for (var i = 0; i < categories.length; i++) categories[i].id: i,
      };
      final lessonRank = {
        for (final lesson in lessons)
          lesson.id:
              (categoryRank[lesson.categoryId] ?? 0) * 1000 + lesson.order,
      };
      _words = words
        ..sort((a, b) {
          final byLesson = (lessonRank[a.lessonId] ?? 0)
              .compareTo(lessonRank[b.lessonId] ?? 0);
          return byLesson != 0 ? byLesson : a.order.compareTo(b.order);
        });
    } catch (e, stack) {
      AppError.log('LibraryProvider.load', e, stack);
      _errorMessage = AppError.message(e, action: 'tải sổ từ');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
