import 'dart:math';

import '../models/question.dart';
import '../models/vocabulary.dart';

/// Một dạng câu hỏi trắc nghiệm: hỏi gì ([promptOf]) và đáp án là gì
/// ([answerOf]). Mỗi dạng là một lớp con, nên thêm dạng mới chỉ cần viết
/// thêm một lớp, không phải sửa QuizGenerator.
abstract class QuestionBuilder {
  const QuestionBuilder();

  String get instruction;

  /// Dạng câu hỏi này có hỏi được về [word] không (vd. từ không có kanji thì
  /// không hỏi được dạng Kanji → Nghĩa).
  bool canAsk(Vocabulary word) => true;

  String promptOf(Vocabulary word);

  String answerOf(Vocabulary word);
}

class KanaToMeaning extends QuestionBuilder {
  const KanaToMeaning();

  @override
  String get instruction => 'Chọn nghĩa đúng';

  @override
  String promptOf(Vocabulary word) => word.kana;

  @override
  String answerOf(Vocabulary word) => word.meaning;
}

class MeaningToKana extends QuestionBuilder {
  const MeaningToKana();

  @override
  String get instruction => 'Chọn cách viết tiếng Nhật';

  @override
  String promptOf(Vocabulary word) => word.meaning;

  @override
  String answerOf(Vocabulary word) => word.kana;
}

class KanjiToMeaning extends QuestionBuilder {
  const KanjiToMeaning();

  @override
  String get instruction => 'Chữ Hán này nghĩa là gì?';

  @override
  bool canAsk(Vocabulary word) => word.kanji.isNotEmpty;

  @override
  String promptOf(Vocabulary word) => word.kanji;

  @override
  String answerOf(Vocabulary word) => word.meaning;
}

/// Tạo bộ câu hỏi trắc nghiệm 4 đáp án từ một danh sách từ vựng.
class QuizGenerator {
  QuizGenerator({Random? random}) : _random = random ?? Random();

  static const optionCount = 4;

  /// Cần ít nhất chừng này từ để có đủ 3 đáp án sai cho mỗi câu.
  static const minWords = optionCount;

  static const builders = <QuestionBuilder>[
    KanaToMeaning(),
    MeaningToKana(),
    KanjiToMeaning(),
  ];

  final Random _random;

  /// Trả về danh sách rỗng nếu có ít hơn [minWords] từ. Câu nào không tìm
  /// đủ đáp án sai khác nhau (vd. nhiều từ trùng nghĩa) thì bị bỏ qua.
  List<Question> generate(
    List<Vocabulary> words, {
    required String quizId,
    int maxQuestions = 10,
  }) {
    if (words.length < minWords) return [];

    final picked = [...words]..shuffle(_random);
    final questions = <Question>[];
    for (final word in picked) {
      if (questions.length == maxQuestions) break;
      final question = _buildQuestion(word, words, quizId, questions.length);
      if (question != null) questions.add(question);
    }
    return questions;
  }

  Question? _buildQuestion(
    Vocabulary word,
    List<Vocabulary> allWords,
    String quizId,
    int order,
  ) {
    final usable = builders.where((builder) => builder.canAsk(word)).toList();
    final builder = usable[_random.nextInt(usable.length)];
    final answer = builder.answerOf(word);

    // Đáp án sai lấy từ các từ khác, không trùng nhau và không trùng đáp án
    // đúng (hai từ cùng nghĩa sẽ khiến câu hỏi có hai đáp án đúng).
    final wrongAnswers = allWords
        .map(builder.answerOf)
        .where((option) => option != answer)
        .toSet()
        .toList()
      ..shuffle(_random);
    if (wrongAnswers.length < optionCount - 1) return null;

    final options = [answer, ...wrongAnswers.take(optionCount - 1)]
      ..shuffle(_random);
    return Question(
      id: '$quizId-$order',
      quizId: quizId,
      prompt: builder.promptOf(word),
      instruction: builder.instruction,
      options: options,
      correctIndex: options.indexOf(answer),
      explanation: _explain(word),
      order: order,
      vocabularyId: word.id,
    );
  }

  /// Vd. "家族 (かぞく) · kazoku: Gia đình".
  static String _explain(Vocabulary word) {
    final writing =
        word.kanji.isEmpty ? word.kana : '${word.kanji} (${word.kana})';
    return '$writing · ${word.romaji}: ${word.meaning}';
  }
}
