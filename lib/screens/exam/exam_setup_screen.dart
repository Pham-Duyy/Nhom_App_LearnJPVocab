import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/quiz_generator.dart';
import '../../models/vocabulary.dart';
import '../../providers/exam_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../../widgets/pill_choices.dart';
import '../common/generic_screen.dart';
import 'exam_screen.dart';

/// Một phạm vi ra đề: tên hiển thị và các từ thuộc phạm vi đó.
typedef _Scope = ({String label, List<Vocabulary> words});

/// Tab Thi thử: chọn phạm vi (cấp độ, chủ đề, từ đã học...) và số câu rồi
/// bắt đầu làm bài.
class ExamSetupScreen extends StatefulWidget {
  const ExamSetupScreen({Key? key}) : super(key: key);

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends GenericScreenState<ExamSetupScreen> {
  static const _learned = 'Từ đã học';
  static const _all = 'Tất cả';

  String? _level;
  int _topicIndex = 0;
  int _questionCount = ExamProvider.defaultQuestionCount;

  @override
  String getTitle(BuildContext context) => 'Thi thử';

  @override
  bool get showAppBar => false;

  /// Các phạm vi lớn có từ vựng, theo thứ tự hiển thị.
  Map<String, List<Vocabulary>> _levels(BuildContext context) {
    final words = context.watch<LibraryProvider>().words;
    final learnedIds = {
      for (final p in context.watch<ProgressProvider>().progressList)
        if (p.isLearned) p.vocabularyId,
    };
    final byLevel = <String, List<Vocabulary>>{
      for (final level in LessonProvider.levels)
        level: words.where((w) => w.jlptLevel == level).toList(),
      _learned: words.where((w) => learnedIds.contains(w.id)).toList(),
      _all: words,
    };
    byLevel.removeWhere((_, levelWords) => levelWords.isEmpty);
    return byLevel;
  }

  /// "Tất cả chủ đề" cùng từng chủ đề của [level] (chủ đề có sẵn hoặc chủ đề
  /// tự tạo); phạm vi "Từ đã học" và "Tất cả" không chia chủ đề.
  List<_Scope> _topics(String level, List<Vocabulary> levelWords) {
    if (level == _learned || level == _all) return [];
    final scopes = <_Scope>[(label: 'Tất cả chủ đề', words: levelWords)];
    if (level == Vocabulary.personalLevel) {
      final myVocabulary = context.watch<MyVocabularyProvider>();
      for (final topic in myVocabulary.topics) {
        scopes.add((label: topic.name, words: myVocabulary.wordsOf(topic)));
      }
    } else {
      final library = context.watch<LibraryProvider>();
      final categories = context
          .watch<LessonProvider>()
          .categories
          .where((category) => category.jlptLevel == level);
      for (final category in categories) {
        final ids = library.wordIdsOf(category.id);
        scopes.add((
          label: category.name,
          words: levelWords.where((w) => ids.contains(w.id)).toList(),
        ));
      }
    }
    return scopes.where((scope) => scope.words.isNotEmpty).toList();
  }

  void _start(_Scope scope) {
    final started = context.read<ExamProvider>().start(
          level: scope.label,
          words: scope.words,
          questionCount: _questionCount,
        );
    if (!started) {
      showErrorSnackBar(context, 'Phạm vi này chưa đủ từ để ra đề.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExamScreen()),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final library = context.watch<LibraryProvider>();
    if (library.words.isEmpty) {
      if (library.errorMessage != null) {
        return ErrorView(message: library.errorMessage!, onRetry: library.load);
      }
      return const Center(child: CircularProgressIndicator());
    }

    final levels = _levels(context);
    final level = levels.containsKey(_level) ? _level! : levels.keys.first;
    final topics = _topics(level, levels[level]!);
    final topicIndex = _topicIndex < topics.length ? _topicIndex : 0;
    // "Tất cả chủ đề" (vị trí 0) dùng tên phạm vi lớn, vd. "Thi thử N5".
    final _Scope scope = topicIndex == 0
        ? (label: level, words: levels[level]!)
        : topics[topicIndex];
    final questionCount = scope.words.length < _questionCount
        ? scope.words.length
        : _questionCount;
    final minutes = ExamProvider.durationFor(questionCount).inMinutes;
    final enough = scope.words.length >= QuizGenerator.minWords;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        const SizedBox(height: 8),
        const Text('Thi thử', style: AppTextStyles.pageTitle),
        const SizedBox(height: 22),
        Text('PHẠM VI', style: palette.sectionLabel),
        const SizedBox(height: 10),
        PillChoices<String>(
          options: levels.keys.toList(),
          selected: level,
          onChanged: (value) => setState(() {
            _level = value;
            _topicIndex = 0;
          }),
        ),
        if (topics.length > 1) ...[
          const SizedBox(height: 18),
          Text('CHỦ ĐỀ', style: palette.sectionLabel),
          const SizedBox(height: 10),
          PillChoices<int>(
            options: [for (var i = 0; i < topics.length; i++) i],
            selected: topicIndex,
            labelOf: (i) => topics[i].label,
            onChanged: (i) => setState(() => _topicIndex = i),
          ),
        ],
        const SizedBox(height: 18),
        Text('SỐ CÂU', style: palette.sectionLabel),
        const SizedBox(height: 10),
        PillChoices<int>(
          options: ExamProvider.questionCountOptions,
          selected: _questionCount,
          labelOf: (count) => '$count câu',
          onChanged: (count) => setState(() => _questionCount = count),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: palette.accentSurface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$questionCount câu · $minutes phút · '
                'đạt từ ${ExamProvider.passPercent}%',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: palette.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                enough
                    ? 'Lấy ngẫu nhiên từ ${scope.words.length} từ'
                    : 'Cần ít nhất ${QuizGenerator.minWords} từ để ra đề',
                style: palette.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: enough ? () => _start(scope) : null,
          child: const Text('Bắt đầu làm bài'),
        ),
        const SizedBox(height: 10),
        Text(
          'Được đổi đáp án trước khi nộp · hết giờ tự nộp',
          textAlign: TextAlign.center,
          style: palette.body.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}
