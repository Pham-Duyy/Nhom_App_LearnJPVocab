import 'dart:math';

import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/data/quiz_generator.dart';
import 'package:chibakanji/models/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

Vocabulary _word(String id, String kana, String meaning, {String kanji = ''}) {
  return Vocabulary(
    id: id,
    lessonId: 'l1',
    kanji: kanji,
    kana: kana,
    romaji: id,
    meaning: meaning,
    exampleJapanese: '',
    exampleVietnamese: '',
    jlptLevel: 'N5',
    order: 1,
  );
}

void main() {
  final words = MockLearningData.vocabulary;

  group('các dạng câu hỏi (kế thừa QuestionBuilder)', () {
    final word = _word('kazoku', 'かぞく', 'Gia đình', kanji: '家族');

    test('mỗi lớp con hỏi và đáp theo cách riêng', () {
      expect(const KanaToMeaning().promptOf(word), 'かぞく');
      expect(const KanaToMeaning().answerOf(word), 'Gia đình');
      expect(const MeaningToKana().promptOf(word), 'Gia đình');
      expect(const MeaningToKana().answerOf(word), 'かぞく');
      expect(const KanjiToMeaning().promptOf(word), '家族');
    });

    test('Kanji → Nghĩa chỉ hỏi được từ có chữ Hán', () {
      expect(const KanjiToMeaning().canAsk(word), isTrue);
      expect(const KanjiToMeaning().canAsk(_word('a', 'あ', 'A')), isFalse);
    });

    test('Nghe → Từ: đề là cách đọc để phát âm, đáp án là chữ kana', () {
      const listen = ListenToWord();

      expect(listen.isListening, isTrue);
      expect(listen.promptOf(word), 'かぞく');
      expect(listen.answerOf(word), 'かぞく');
      expect(const KanaToMeaning().isListening, isFalse);
    });
  });

  group('chọn dạng câu hỏi qua tham số builders', () {
    test('chỉ dùng dạng nghe thì mọi câu đều là câu nghe, đọc đúng đáp án', () {
      final questions =
          QuizGenerator(random: Random(4), builders: const [ListenToWord()])
              .generate(words, quizId: 'q');

      expect(questions, isNotEmpty);
      for (final question in questions) {
        expect(question.isListening, isTrue);
        expect(question.pronunciation, question.correctAnswer);
      }
    });

    test('từ không hỏi được bằng dạng nào thì bị bỏ qua', () {
      final noKanji = [
        for (final kana in ['あ', 'い', 'う', 'え']) _word(kana, kana, kana),
      ];

      final questions = QuizGenerator(builders: const [KanjiToMeaning()])
          .generate(noKanji, quizId: 'q');

      expect(questions, isEmpty);
    });
  });

  group('US16: tạo bộ câu hỏi', () {
    test('ít hơn 4 từ thì không tạo được quiz', () {
      final few = words.take(QuizGenerator.minWords - 1).toList();

      expect(QuizGenerator().generate(few, quizId: 'q'), isEmpty);
    });

    test('tạo tối đa maxQuestions câu, mỗi câu kiểm tra một từ khác nhau', () {
      final questions = QuizGenerator(random: Random(1))
          .generate(words, quizId: 'q', maxQuestions: 10);

      expect(questions, hasLength(10));
      expect(questions.map((q) => q.vocabularyId).toSet(), hasLength(10));
      expect(questions.map((q) => q.order), List.generate(10, (i) => i));
    });

    test('mỗi câu có 4 đáp án khác nhau và đáp án đúng nằm đúng vị trí', () {
      final questions =
          QuizGenerator(random: Random(2)).generate(words, quizId: 'q');

      for (final question in questions) {
        expect(question.options, hasLength(QuizGenerator.optionCount));
        expect(question.options.toSet(), hasLength(question.options.length));
        expect(question.isValid, isTrue);

        final word = words.firstWhere((w) => w.id == question.vocabularyId);
        expect(
          [word.meaning, word.kana],
          contains(question.correctAnswer),
          reason: question.prompt,
        );
      }
    });

    test('cùng seed thì ra cùng bộ câu hỏi (kết quả lặp lại được)', () {
      List<String> run() => QuizGenerator(random: Random(42))
          .generate(words, quizId: 'q')
          .map((q) => '${q.prompt}|${q.options.join(',')}')
          .toList();

      expect(run(), run());
    });

    test('từ trùng nghĩa không tạo ra câu có hai đáp án đúng', () {
      final sameMeaning = [
        _word('a', 'あ', 'Xin chào'),
        _word('b', 'い', 'Xin chào'),
        _word('c', 'う', 'Cảm ơn'),
        _word('d', 'え', 'Tạm biệt'),
        _word('e', 'お', 'Xin lỗi'),
      ];

      for (var seed = 0; seed < 20; seed++) {
        final questions = QuizGenerator(random: Random(seed))
            .generate(sameMeaning, quizId: 'q');
        for (final question in questions) {
          final answer = question.correctAnswer;
          expect(
            question.options.where((option) => option == answer),
            hasLength(1),
          );
        }
      }
    });
  });
}
