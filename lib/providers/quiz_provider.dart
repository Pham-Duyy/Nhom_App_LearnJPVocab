import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/quiz_generator.dart';
import '../models/question.dart';
import '../models/quiz_attempt.dart';
import '../models/study_preferences.dart';
import '../models/vocabulary.dart';
import '../repositories/quiz_attempt_repository.dart';
import '../repositories/vocabulary_repository.dart';
import '../utils/app_error.dart';
import 'latest_load_guard.dart';

/// Báo kết quả của một câu ra ngoài (vd. đưa từ trả lời sai về lịch ôn).
typedef QuizAnswerCallback = Future<void> Function(
  String vocabularyId,
  bool isCorrect,
);

/// Quản lý một lượt làm quiz (câu hiện tại, đáp án đã chọn, điểm) và lịch sử
/// các lượt đã làm.
class QuizProvider extends ChangeNotifier with LatestLoadGuard {
  QuizProvider(
    this._attempts,
    this._vocabulary, {
    QuizGenerator? generator,
    this.onAnswer,
    DateTime Function()? clock,
  })  : _generator = generator ?? QuizGenerator(),
        _clock = clock ?? DateTime.now;

  final QuizAttemptRepository _attempts;
  final VocabularyRepository _vocabulary;
  final QuizGenerator _generator;
  final QuizAnswerCallback? onAnswer;
  final DateTime Function() _clock;

  String _quizId = '';
  String _title = '';
  List<Vocabulary> _words = [];
  int _maxQuestions = StudyPreferences.defaultQuizLength;
  List<Question> _questions = [];
  int _index = 0;

  /// Đáp án đã chọn: key là Question.id, value là vị trí đáp án.
  final Map<String, int> _answers = {};
  DateTime _startedAt = DateTime.now();
  QuizAttempt? _result;
  String? _errorMessage;

  List<QuizAttempt> _history = [];
  bool _isLoadingHistory = false;

  String get title => _title;
  List<Question> get questions => _questions;
  int get currentIndex => _index;
  QuizAttempt? get result => _result;
  bool get isFinished => _result != null;
  String? get errorMessage => _errorMessage;
  List<QuizAttempt> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;

  Question? get currentQuestion =>
      _questions.isEmpty || isFinished ? null : _questions[_index];

  /// Vị trí đáp án đã chọn ở câu hiện tại, null nếu chưa chọn.
  int? get selectedIndex {
    final question = currentQuestion;
    return question == null ? null : _answers[question.id];
  }

  bool get isAnswered => selectedIndex != null;
  bool get isLastQuestion => _index == _questions.length - 1;

  /// Kết quả câu thứ [index]: true là đúng, false là sai, null là chưa trả
  /// lời. Dùng để tô màu thanh tiến độ theo từng câu.
  bool? resultAt(int index) {
    final question = _questions[index];
    final selected = _answers[question.id];
    return selected == null ? null : question.isCorrect(selected);
  }

  int get correctCount => _questions.where(_isAnsweredCorrectly).length;

  /// Các câu đã trả lời sai, để xem lại ở màn hình kết quả.
  List<Question> get wrongQuestions => _questions
      .where((q) => _answers.containsKey(q.id) && !_isAnsweredCorrectly(q))
      .toList();

  bool _isAnsweredCorrectly(Question question) {
    final selected = _answers[question.id];
    return selected != null && question.isCorrect(selected);
  }

  /// Bắt đầu quiz từ [words], tối đa [maxQuestions] câu. Trả về false nếu
  /// không đủ từ để ra đề.
  bool start({
    required String quizId,
    required String title,
    required List<Vocabulary> words,
    int maxQuestions = StudyPreferences.defaultQuizLength,
  }) {
    final questions = _generator.generate(
      words,
      quizId: quizId,
      maxQuestions: maxQuestions,
    );
    if (questions.isEmpty) return false;

    _quizId = quizId;
    _title = title;
    _words = words;
    _maxQuestions = maxQuestions;
    _questions = questions;
    _index = 0;
    _answers.clear();
    _startedAt = _clock();
    _result = null;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Quiz nhanh từ các từ có id trong [vocabularyIds]. Trả về thông báo lỗi,
  /// hoặc null nếu đã bắt đầu được.
  Future<String?> startWithWordIds({
    required String quizId,
    required String title,
    required List<String> vocabularyIds,
    int maxQuestions = StudyPreferences.defaultQuizLength,
  }) async {
    try {
      final words = await _vocabulary.getByIds(vocabularyIds);
      final started = start(
        quizId: quizId,
        title: title,
        words: words,
        maxQuestions: maxQuestions,
      );
      return started
          ? null
          : 'Hãy học ít nhất ${QuizGenerator.minWords} từ để làm quiz.';
    } catch (e, stack) {
      AppError.log('QuizProvider.startWithWordIds', e, stack);
      return AppError.message(e, action: 'tải từ vựng cho quiz');
    }
  }

  /// Làm lại với cùng bộ từ và số câu, câu hỏi được tạo mới.
  bool restart() => start(
        quizId: _quizId,
        title: _title,
        words: _words,
        maxQuestions: _maxQuestions,
      );

  /// Chọn đáp án cho câu hiện tại. Mỗi câu chỉ được chọn một lần.
  void answer(int optionIndex) {
    final question = currentQuestion;
    if (question == null || isAnswered) return;

    _answers[question.id] = optionIndex;
    notifyListeners();

    final vocabularyId = question.vocabularyId;
    final callback = onAnswer;
    if (vocabularyId != null && callback != null) {
      unawaited(
        callback(vocabularyId, question.isCorrect(optionIndex)).catchError(
          (Object e, StackTrace stack) =>
              AppError.log('QuizProvider.onAnswer', e, stack),
        ),
      );
    }
  }

  /// Sang câu tiếp theo, hoặc kết thúc và lưu kết quả nếu là câu cuối.
  Future<void> next() async {
    if (!isAnswered) return;
    if (!isLastQuestion) {
      _index++;
      notifyListeners();
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final attempt = QuizAttempt(
      id: '$_quizId-${_startedAt.millisecondsSinceEpoch}',
      quizId: _quizId,
      title: _title,
      totalQuestions: _questions.length,
      correctCount: correctCount,
      selectedAnswers: Map.of(_answers),
      startedAt: _startedAt,
      completedAt: _clock(),
    );
    _result = attempt;
    _history = [attempt, ..._history];
    notifyListeners();

    try {
      await _attempts.save(attempt);
    } catch (e, stack) {
      AppError.log('QuizProvider.finish', e, stack);
      _errorMessage = AppError.message(e, action: 'lưu kết quả quiz');
      notifyListeners();
    }
  }

  /// Tải lịch sử, lần làm mới nhất đứng đầu.
  Future<void> loadHistory() async {
    final isLatest = startLoad();
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _attempts.getAll();
      if (!isLatest()) return;
      _history = loaded..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (e, stack) {
      if (!isLatest()) return;
      AppError.log('QuizProvider.loadHistory', e, stack);
      _errorMessage = AppError.message(e, action: 'tải lịch sử quiz');
    } finally {
      if (isLatest()) {
        _isLoadingHistory = false;
        notifyListeners();
      }
    }
  }
}
