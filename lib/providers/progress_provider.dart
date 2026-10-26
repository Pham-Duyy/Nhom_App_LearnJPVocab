import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import '../repositories/progress_repository.dart';
import '../utils/app_error.dart';

/// Quản lý tiến độ ghi nhớ của toàn bộ từ vựng: tổng số từ đã học, số từ
/// đến hạn ôn tập và phân bố theo từng mức ghi nhớ (1-5).
class ProgressProvider extends ChangeNotifier {
  /// [onStudyActivity] được gọi sau mỗi lần trả lời một thẻ (đúng hoặc sai),
  /// để ghi nhận chuỗi ngày học mà provider này không cần biết đến hồ sơ.
  ProgressProvider(this._repository, {this.onStudyActivity});

  final ProgressRepository _repository;
  final Future<void> Function()? onStudyActivity;

  List<Progress> _progressList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Progress> get progressList => _progressList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalLearned => _progressList.where((p) => p.isLearned).length;

  int get favoriteCount => _progressList.where((p) => p.isFavorite).length;

  int getReviewedTodayCount([DateTime? now]) {
    final reference = now ?? DateTime.now();
    return _progressList.where((p) {
      final reviewedAt = p.lastReviewedAt;
      return reviewedAt != null &&
          reviewedAt.year == reference.year &&
          reviewedAt.month == reference.month &&
          reviewedAt.day == reference.day;
    }).length;
  }

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
    } catch (e, stack) {
      AppError.log('ProgressProvider.loadProgress', e, stack);
      _errorMessage = AppError.message(e, action: 'tải tiến độ học');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ném lỗi nếu lưu thất bại, để màn hình flashcard giữ nguyên thẻ hiện tại
  /// cho người học thử lại (xem FlashcardScreen).
  Future<void> markCorrect(String vocabularyId) =>
      _answer(vocabularyId, (p) => p.markCorrect());

  /// Ném lỗi nếu lưu thất bại, như [markCorrect].
  Future<void> markWrong(String vocabularyId) =>
      _answer(vocabularyId, (p) => p.markWrong());

  Future<void> _answer(
    String vocabularyId,
    Progress Function(Progress current) update,
  ) async {
    final updated = await _updateAndSave(vocabularyId, update);
    _replaceInList(updated);
    notifyListeners();
    final record = onStudyActivity;
    if (record != null) unawaited(record());
  }

  /// Trả về thông báo lỗi nếu lưu thất bại (dấu yêu thích giữ nguyên như cũ),
  /// hoặc null nếu thành công.
  Future<String?> toggleFavorite(String vocabularyId) async {
    try {
      final updated = await _updateAndSave(
        vocabularyId,
        (p) => p.copyWith(isFavorite: !p.isFavorite),
      );
      _replaceInList(updated);
      notifyListeners();
      return null;
    } catch (e, stack) {
      AppError.log('ProgressProvider.toggleFavorite', e, stack);
      return AppError.message(e, action: 'lưu từ yêu thích');
    }
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
