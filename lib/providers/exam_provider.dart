import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/quiz_generator.dart';
import '../models/question.dart';
import '../models/quiz_attempt.dart';
import '../models/vocabulary.dart';
import '../repositories/quiz_attempt_repository.dart';
import '../utils/app_error.dart';

/// Bài thi thử: làm trong thời gian giới hạn, chưa biết đúng sai cho đến khi
/// nộp, được quay lại sửa đáp án. Hết giờ thì tự nộp. Kết quả lưu như một
/// lượt quiz nên hiện trong Lịch sử và được tính vào Thành tích.
class ExamProvider extends ChangeNotifier {
  ExamProvider(
    this._attempts, {
    QuizGenerator? generator,
    DateTime Function()? clock,
    this.onSaved,
  })  : _generator = generator ?? QuizGenerator(),
        _clock = clock ?? DateTime.now;

  static const questionCountOptions = [10, 20, 30];
  static const defaultQuestionCount = 20;

  /// Mỗi câu có 30 giây, cộng dồn cho cả bài.
  static const timePerQuestion = Duration(seconds: 30);

  /// Đạt từ 60% số câu trở lên.
  static const passPercent = 60;

  final QuizAttemptRepository _attempts;

  /// Gọi sau khi lưu kết quả thành công, vd. để tải lại lịch sử quiz.
  final Future<void> Function()? onSaved;
  final QuizGenerator _generator;
  final DateTime Function() _clock;

  String _level = '';
  List<Vocabulary> _words = [];
  int _questionCount = defaultQuestionCount;
  List<Question> _questions = [];

  /// Đáp án đã chọn: key là Question.id, value là vị trí đáp án.
  final Map<String, int> _answers = {};
  int _index = 0;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  DateTime _startedAt = DateTime(0);
  QuizAttempt? _result;
  String? _errorMessage;

  String get level => _level;
  String get title => 'Thi thử $_level';
  List<Question> get questions => _questions;
  int get currentIndex => _index;
  Question? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_index];
  bool get isFirstQuestion => _index == 0;
  bool get isLastQuestion => _index == _questions.length - 1;
  Duration get remaining => _remaining;
  int get answeredCount => _answers.length;
  int get unansweredCount => _questions.length - _answers.length;
  QuizAttempt? get result => _result;
  bool get isFinished => _result != null;
  bool get passed => (_result?.scorePercent ?? 0) >= passPercent;
  String? get errorMessage => _errorMessage;

  /// Thời gian làm bài của [questionCount] câu.
  static Duration durationFor(int questionCount) =>
      timePerQuestion * questionCount;

  /// Đáp án đã chọn ở câu thứ [index], null nếu chưa làm.
  int? selectedAt(int index) => _answers[_questions[index].id];

  /// Ra đề [questionCount] câu từ [words] và bắt đầu tính giờ. Trả về false
  /// nếu không đủ từ để ra đề.
  bool start({
    required String level,
    required List<Vocabulary> words,
    int questionCount = defaultQuestionCount,
  }) {
    final questions = _generator.generate(
      words,
      quizId: 'exam-$level',
      maxQuestions: questionCount,
    );
    if (questions.isEmpty) return false;

    _stopTimer();
    _level = level;
    _words = words;
    _questionCount = questionCount;
    _questions = questions;
    _answers.clear();
    _index = 0;
    _remaining = durationFor(questions.length);
    _startedAt = _clock();
    _result = null;
    _errorMessage = null;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    notifyListeners();
    return true;
  }

  /// Thi lại cùng phạm vi và số câu, đề được tạo mới.
  bool restart() =>
      start(level: _level, words: _words, questionCount: _questionCount);

  /// Chọn (hoặc đổi) đáp án cho câu hiện tại.
  void select(int optionIndex) {
    final question = currentQuestion;
    if (question == null || isFinished) return;
    _answers[question.id] = optionIndex;
    notifyListeners();
  }

  void goTo(int index) {
    if (index < 0 || index >= _questions.length || index == _index) return;
    _index = index;
    notifyListeners();
  }

  void next() => goTo(_index + 1);

  void previous() => goTo(_index - 1);

  /// Trừ một giây; hết giờ thì tự nộp bài. Timer gọi mỗi giây, test gọi trực
  /// tiếp để không phải chờ giờ thật.
  @visibleForTesting
  void tick() {
    if (isFinished || _questions.isEmpty) return;
    _remaining -= const Duration(seconds: 1);
    if (_remaining > Duration.zero) {
      notifyListeners();
      return;
    }
    _remaining = Duration.zero;
    submit();
  }

  /// Chấm điểm và lưu kết quả. Câu chưa làm tính là sai.
  Future<void> submit() async {
    if (isFinished || _questions.isEmpty) return;
    _stopTimer();

    final correct = _questions
        .where((q) => _answers[q.id] != null && q.isCorrect(_answers[q.id]!))
        .length;
    final attempt = QuizAttempt(
      id: 'exam-$_level-${_startedAt.millisecondsSinceEpoch}',
      quizId: 'exam-$_level',
      title: title,
      totalQuestions: _questions.length,
      correctCount: correct,
      selectedAnswers: Map.of(_answers),
      startedAt: _startedAt,
      completedAt: _clock(),
    );
    _result = attempt;
    notifyListeners();

    try {
      await _attempts.save(attempt);
      final saved = onSaved;
      if (saved != null) unawaited(saved());
    } catch (e, stack) {
      AppError.log('ExamProvider.submit', e, stack);
      _errorMessage = AppError.message(e, action: 'lưu kết quả bài thi');
      notifyListeners();
    }
  }

  /// Bỏ dở bài thi: dừng giờ, không chấm và không lưu.
  void cancel() {
    _stopTimer();
    _questions = [];
    _answers.clear();
    _index = 0;
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
