import 'dart:math';

import '../models/question.dart';
import '../models/vocabulary.dart';

/// Một dạng câu hỏi trắc nghiệm: hỏi gì ([promptOf]) và đáp án là gì
/// ([answerOf]). Mỗi dạng là một lớp con, nên thêm dạng mới chỉ cần viết
/// thêm một lớp, không phải sửa QuizGenerator.
abstract class QuestionBuilder {
  const QuestionBuilder();

  String get instruction;

  /// Đề bài là tiếng Nhật thì cho nghe phát âm; đề tiếng Việt thì không, vì
  /// đọc to lên sẽ lộ đáp án.
  bool get promptIsJapanese;

  /// Đề bài chỉ được nghe, không hiện chữ.
  bool get isListening => false;

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
  bool get promptIsJapanese => true;

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
  bool get promptIsJapanese => false;

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
  bool get promptIsJapanese => true;

  @override
  bool canAsk(Vocabulary word) => word.kanji.isNotEmpty;

  @override
  String promptOf(Vocabulary word) => word.kanji;

  @override
  String answerOf(Vocabulary word) => word.meaning;
}

/// Nghe phát âm rồi chọn cách viết đúng. Đề bài không hiện chữ (xem
/// [Question.isListening]), nên phải có giọng đọc mới làm được.
class ListenToWord extends QuestionBuilder {
  const ListenToWord();

  @override
  String get instruction => 'Nghe và chọn từ đúng';

  @override
  bool get promptIsJapanese => true;

  @override
  bool get isListening => true;

  @override
  String promptOf(Vocabulary word) => word.kana;

  @override
  String answerOf(Vocabulary word) => word.kana;
}

/// Tạo bộ câu hỏi trắc nghiệm 4 đáp án từ một danh sách từ vựng.
class QuizGenerator {
  QuizGenerator({Random? random, this.builders = defaultBuilders})
      : assert(builders.isNotEmpty),
        _random = random ?? Random();

  static const optionCount = 4;

  /// Cần ít nhất chừng này từ để có đủ 3 đáp án sai cho mỗi câu.
  static const minWords = optionCount;

  static const defaultBuilders = <QuestionBuilder>[
    KanaToMeaning(),
    MeaningToKana(),
    KanjiToMeaning(),
    ListenToWord(),
  ];

  /// Các dạng câu hỏi được dùng; mỗi câu chọn ngẫu nhiên một dạng hợp lệ.
  final List<QuestionBuilder> builders;
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
    if (usable.isEmpty) return null;
    final builder = usable[_random.nextInt(usable.length)];
    final answer = builder.answerOf(word);

    // Bỏ trùng: hai từ cùng nghĩa sẽ thành hai đáp án đúng.
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
      pronunciation: builder.promptIsJapanese ? word.kana : null,
      isListening: builder.isListening,
    );
  }

  /// Vd. "家族 (かぞく) · kazoku: Gia đình".
  static String _explain(Vocabulary word) {
    final writing =
        word.kanji.isEmpty ? word.kana : '${word.kanji} (${word.kana})';
    return '$writing · ${word.romaji}: ${word.meaning}';
  }
}
