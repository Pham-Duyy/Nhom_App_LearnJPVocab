import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/lesson.dart';
import '../repositories/category_repository.dart';
import '../utils/app_error.dart';

/// Quản lý danh sách chủ đề (category) và bài học (lesson) đang được chọn
/// để hiển thị ở màn hình "Học mới".
class LessonProvider extends ChangeNotifier {
  LessonProvider(this._repository);

  /// Các cấp độ JLPT và mục từ vựng chuyên ngành.
  static const levels = ['N5', 'N4', 'N3', Category.industryLevel];

  final CategoryRepository _repository;

  List<Category> _categories = [];
  List<Lesson> _lessons = [];
  Category? _selectedCategory;
  Lesson? _selectedLesson;
  String _selectedLevel = levels.first;
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  String get selectedLevel => _selectedLevel;
  List<Category> get categoriesForSelectedLevel => _categories
      .where((category) => category.jlptLevel == _selectedLevel)
      .toList();
  List<Lesson> get lessons => _lessons;
  Category? get selectedCategory => _selectedCategory;
  Lesson? get selectedLesson => _selectedLesson;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
    } catch (e, stack) {
      AppError.log('LessonProvider.loadCategories', e, stack);
      _errorMessage = AppError.message(e, action: 'tải danh sách chủ đề');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(Category category) async {
    _selectedCategory = category;
    _selectedLesson = null;
    _lessons = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lessons = await _repository.getLessonsByCategory(category.id);
    } catch (e, stack) {
      AppError.log('LessonProvider.selectCategory', e, stack);
      _errorMessage = AppError.message(e, action: 'tải danh sách bài học');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLevel(String level) {
    if (level == _selectedLevel) return;
    _selectedLevel = level;
    notifyListeners();
  }

  void selectLesson(Lesson lesson) {
    _selectedLesson = lesson;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
