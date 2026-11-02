import 'dart:async';

import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/models/quiz_attempt.dart';
import 'package:chibakanji/providers/progress_provider.dart';
import 'package:chibakanji/providers/quiz_provider.dart';
import 'package:chibakanji/repositories/mock/mock_progress_repository.dart';
import 'package:chibakanji/repositories/mock/mock_quiz_attempt_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository tiến độ mà mỗi lần tải chỉ xong khi test cho phép.
class _SlowProgressRepository extends MockProgressRepository {
  final pending = <Completer<List<Progress>>>[];

  @override
  Future<List<Progress>> getAll() {
    final completer = Completer<List<Progress>>();
    pending.add(completer);
    return completer.future;
  }
}

/// Repository lịch sử quiz mà mỗi lần tải chỉ xong khi test cho phép.
class _SlowAttemptRepository extends MockQuizAttemptRepository {
  final pending = <Completer<List<QuizAttempt>>>[];

  @override
  Future<List<QuizAttempt>> getAll() {
    final completer = Completer<List<QuizAttempt>>();
    pending.add(completer);
    return completer.future;
  }
}

QuizAttempt _attempt(String id) => QuizAttempt(
      id: id,
      quizId: 'q',
      totalQuestions: 5,
      startedAt: DateTime(2026, 10, 1),
    );

void main() {
  // Tình huống: đăng xuất rồi đăng nhập tài khoản khác khi lần tải của người
  // trước chưa xong; lần tải cũ về sau cùng không được ghi đè người mới.
  group('đổi tài khoản nhanh không lẫn dữ liệu', () {
    test('ProgressProvider bỏ qua tiến độ của lần tải cũ', () async {
      final repository = _SlowProgressRepository();
      final provider = ProgressProvider(repository);

      final oldUser = provider.loadProgress();
      final newUser = provider.loadProgress();
      repository.pending[1].complete([]);
      await newUser;
      repository.pending[0].complete(const [
        Progress(vocabularyId: 'cua-nguoi-cu', isLearned: true),
      ]);
      await oldUser;

      expect(provider.totalLearned, 0);
      expect(provider.isLoading, isFalse);
    });

    test('ProgressProvider bỏ qua lỗi của lần tải cũ', () async {
      final repository = _SlowProgressRepository();
      final provider = ProgressProvider(repository);

      final oldUser = provider.loadProgress();
      final newUser = provider.loadProgress();
      repository.pending[1].complete([]);
      await newUser;
      repository.pending[0].completeError(Exception('mất mạng'));
      await oldUser;

      expect(provider.errorMessage, isNull);
    });

    test('QuizProvider bỏ qua lịch sử của lần tải cũ', () async {
      final repository = _SlowAttemptRepository();
      final provider = QuizProvider(repository, MockVocabularyRepository());

      final oldUser = provider.loadHistory();
      final newUser = provider.loadHistory();
      repository.pending[1].complete([_attempt('cua-nguoi-moi')]);
      await newUser;
      repository.pending[0].complete([_attempt('cua-nguoi-cu')]);
      await oldUser;

      expect(provider.history.map((a) => a.id), ['cua-nguoi-moi']);
      expect(provider.isLoadingHistory, isFalse);
    });
  });
}
