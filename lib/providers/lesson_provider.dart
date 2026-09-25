import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/lesson.dart';
import '../repositories/category_repository.dart';

/// Quản lý danh sách chủ đề (category) và bài học (lesson) đang được chọn
/// để hiển thị ở màn hình "Học mới".
class LessonProvider extends ChangeNotifier {
  LessonProvider(this._repository);

  final CategoryRepository _repository;

  List<Category> _categories = [];
  List<Lesson> _lessons = [];
  Category? _selectedCategory;
  Lesson? _selectedLesson;
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
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
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách chủ đề: $e';
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
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách bài học: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
