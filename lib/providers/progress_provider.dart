import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import '../repositories/progress_repository.dart';

/// Quản lý tiến độ ghi nhớ của toàn bộ từ vựng: tổng số từ đã học, số từ
/// đến hạn ôn tập và phân bố theo từng mức ghi nhớ (1-5).
class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._repository);

  final ProgressRepository _repository;

  List<Progress> _progressList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Progress> get progressList => _progressList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalLearned => _progressList.where((p) => p.isLearned).length;

  List<Progress> getDueForReview([DateTime? now]) {
    final reference = now ?? DateTime.now();
    return _progressList.where((p) => p.isDueForReview(reference)).toList();
  }

  int getCountForLevel(int level) =>
      _progressList.where((p) => p.memoryLevel == level).length;

  Future<void> loadProgress() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _progressList = await _repository.getAll();
    } catch (e) {
      _errorMessage = 'Không thể tải tiến độ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markCorrect(String vocabularyId) async {
    final updated = await _updateAndSave(vocabularyId, (p) => p.markCorrect());
    _replaceInList(updated);
    notifyListeners();
  }

  Future<void> markWrong(String vocabularyId) async {
    final updated = await _updateAndSave(vocabularyId, (p) => p.markWrong());
    _replaceInList(updated);
    notifyListeners();
  }

  Future<void> toggleFavorite(String vocabularyId) async {
    final updated = await _updateAndSave(
      vocabularyId,
      (p) => p.copyWith(isFavorite: !p.isFavorite),
    );
    _replaceInList(updated);
    notifyListeners();
  }

  Future<Progress> _updateAndSave(
    String vocabularyId,
    Progress Function(Progress current) update,
  ) async {
    final current = _findOrCreate(vocabularyId);
    final updated = update(current);
    await _repository.save(updated);
    return updated;
  }

  Progress _findOrCreate(String vocabularyId) {
    for (final progress in _progressList) {
      if (progress.vocabularyId == vocabularyId) return progress;
    }
    return Progress(vocabularyId: vocabularyId);
  }

  void _replaceInList(Progress updated) {
    final index =
        _progressList.indexWhere((p) => p.vocabularyId == updated.vocabularyId);
    if (index == -1) {
      _progressList = [..._progressList, updated];
    } else {
      final newList = [..._progressList];
      newList[index] = updated;
      _progressList = newList;
    }
  }
}
