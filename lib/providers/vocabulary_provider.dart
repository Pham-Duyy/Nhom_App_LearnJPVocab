import 'package:flutter/foundation.dart';

import '../models/vocabulary.dart';
import '../repositories/vocabulary_repository.dart';

/// Trạng thái của một phiên học flashcard: chưa bắt đầu, đang học, đã học hết.
enum LearningSessionStatus { idle, inProgress, completed }

/// Quản lý danh sách từ vựng của bài học đang chọn và vị trí flashcard
/// hiện tại. Không xử lý thuật toán ghi nhớ — việc đó thuộc về [ProgressProvider].
class VocabularyProvider extends ChangeNotifier {
  VocabularyProvider(this._repository);

  final VocabularyRepository _repository;

  List<Vocabulary> _words = [];
  int _currentIndex = 0;
  LearningSessionStatus _sessionStatus = LearningSessionStatus.idle;
  bool _isLoading = false;
  String? _errorMessage;

  List<Vocabulary> get words => _words;
  int get currentIndex => _currentIndex;
  Vocabulary? get currentWord => _words.isEmpty ? null : _words[_currentIndex];
  LearningSessionStatus get sessionStatus => _sessionStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadByLesson(String lessonId) =>
      _loadWords(() => _repository.getByLesson(lessonId));

  /// Tải một phiên ôn tập gồm các từ thuộc [vocabularyIds] — có thể đến từ
  /// nhiều bài học khác nhau. Danh sách id đến hạn do ProgressProvider (hoặc
  /// tầng điều phối phía trên) cung cấp; provider này không tự quyết định
  /// từ nào cần ôn.
  Future<void> loadReviewWords(List<String> vocabularyIds) =>
      _loadWords(() => _repository.getByIds(vocabularyIds));

  Future<void> _loadWords(Future<List<Vocabulary>> Function() fetch) async {
    _words = [];
    _currentIndex = 0;
    _sessionStatus = LearningSessionStatus.idle;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _words = await fetch();
      _sessionStatus = _words.isEmpty
          ? LearningSessionStatus.idle
          : LearningSessionStatus.inProgress;
    } catch (e) {
      _errorMessage = 'Không thể tải từ vựng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextCard() {
    if (_words.isEmpty) return;
    if (_currentIndex < _words.length - 1) {
      _currentIndex++;
    } else {
      _sessionStatus = LearningSessionStatus.completed;
    }
    notifyListeners();
  }

  void previousCard() {
    if (_words.isEmpty || _currentIndex == 0) return;
    _currentIndex--;
    notifyListeners();
  }

  void resetSession() {
    _currentIndex = 0;
    _sessionStatus = _words.isEmpty
        ? LearningSessionStatus.idle
        : LearningSessionStatus.inProgress;
    notifyListeners();
  }
}
