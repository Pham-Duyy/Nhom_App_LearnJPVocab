import 'package:chibakanji/models/user_topic.dart';
import 'package:chibakanji/models/vocabulary.dart';
import 'package:chibakanji/models/word_draft.dart';
import 'package:chibakanji/providers/my_vocabulary_provider.dart';
import 'package:chibakanji/repositories/combined_repository.dart';
import 'package:chibakanji/repositories/mock/mock_user_topic_repository.dart';
import 'package:chibakanji/repositories/mock/mock_user_word_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/flaky_repositories.dart';

const _factory = WordDraft(kanji: '工場', kana: 'こうじょう', meaning: 'Nhà máy');
const _safety = WordDraft(kanji: '安全', kana: 'あんぜん', meaning: 'An toàn');

class _FlakyWordRepository extends MockUserWordRepository {
  Object? failure;

  @override
  Future<void> save(Vocabulary item) async {
    if (failure != null) throw failure!;
    return super.save(item);
  }
}

Future<MyVocabularyProvider> _provider({
  MockUserWordRepository? words,
  Future<void> Function()? onWordsChanged,
}) async {
  final myWords = words ?? MockUserWordRepository();
  final provider = MyVocabularyProvider(
    MockUserTopicRepository(),
    myWords,
    CombinedVocabularyRepository(
      shared: MockVocabularyRepository(),
      personal: myWords,
    ),
    onWordsChanged: onWordsChanged,
  );
  await provider.load();
  return provider;
}

void main() {
  group('US22: chủ đề của tôi', () {
    test('tạo chủ đề; tên rỗng hoặc trùng thì báo lỗi', () async {
      final provider = await _provider();

      expect(await provider.createTopic('Công việc'), isNull);
      expect(await provider.createTopic('  '), 'Hãy nhập tên chủ đề.');
      expect(await provider.createTopic('công việc'), contains('Đã có'));
      expect(provider.topics.map((t) => t.name), ['Công việc']);
    });

    test('thêm từ có sẵn vào chủ đề không bị lặp', () async {
      final provider = await _provider();
      await provider.createTopic('Chào hỏi');
      final topic = provider.topics.single;

      await provider.addWordsToTopic(topic.id, ['v_greet_1', 'v_greet_2']);
      await provider.addWordsToTopic(topic.id, ['v_greet_2']);

      final updated = provider.topicById(topic.id)!;
      expect(updated.wordIds, ['v_greet_1', 'v_greet_2']);
      expect(provider.wordsOf(updated).first.kana, 'こんにちは');
    });

    test('đổi tên và xóa chủ đề; từ vẫn còn trong kho', () async {
      final provider = await _provider();
      await provider.createTopic('Cũ');
      final topic = provider.topics.single;
      await provider.addWord(_factory, topicId: topic.id);

      await provider.updateTopic(topic, name: 'Mới');
      expect(provider.topics.single.name, 'Mới');

      await provider.deleteTopic(topic.id);
      expect(provider.topics, isEmpty);
      expect(provider.myWords, hasLength(1));
    });
  });

  group('US22: từ vựng của tôi', () {
    test('thêm từ mới vào kho và vào chủ đề đã chọn', () async {
      var changed = 0;
      final provider = await _provider(onWordsChanged: () async => changed++);
      await provider.createTopic('Nhà máy');
      final topicId = provider.topics.single.id;

      expect(await provider.addWord(_factory, topicId: topicId), isNull);

      final word = provider.myWords.single;
      expect(word.isPersonal, isTrue);
      expect(word.jlptLevel, Vocabulary.personalLevel);
      expect(provider.topicById(topicId)!.wordIds, [word.id]);
      expect(changed, 1);
    });

    test('thiếu kana, thiếu nghĩa hoặc trùng từ thì không thêm', () async {
      final provider = await _provider();
      await provider.addWord(_factory);

      expect(
        await provider.addWord(const WordDraft(kana: '', meaning: 'x')),
        contains('cách đọc'),
      );
      expect(
        await provider.addWord(const WordDraft(kana: 'あ', meaning: ' ')),
        contains('nghĩa'),
      );
      expect(await provider.addWord(_factory), contains('đã có'));
      expect(provider.myWords, hasLength(1));
    });

    test('sửa từ giữ nguyên id; xóa từ thì bỏ khỏi mọi chủ đề', () async {
      final provider = await _provider();
      await provider.createTopic('A');
      final topicId = provider.topics.single.id;
      await provider.addWord(_factory, topicId: topicId);
      final word = provider.myWords.single;

      await provider.updateWord(
        word,
        const WordDraft(kanji: '工場', kana: 'こうば', meaning: 'Xưởng'),
      );
      expect(provider.myWords.single.id, word.id);
      expect(provider.myWords.single.kana, 'こうば');

      await provider.deleteWord(word.id);
      expect(provider.myWords, isEmpty);
      expect(provider.topicById(topicId)!.wordIds, isEmpty);
    });

    test('8a: lưu thất bại thì báo lỗi dễ hiểu, kho không đổi', () async {
      final words = _FlakyWordRepository()..failure = offlineError;
      final provider = await _provider(words: words);

      final error = await provider.addWord(_factory);

      expect(error, contains('thêm từ'));
      expect(error, isNot(contains('abc123')));
      expect(provider.myWords, isEmpty);
    });
  });

  group('US23: import từ vựng', () {
    test('thêm các từ mới, bỏ qua từ trùng, gắn vào chủ đề', () async {
      final provider = await _provider();
      await provider.createTopic('Import');
      final topicId = provider.topics.single.id;
      await provider.addWord(_factory);

      final result = await provider.importWords(
        [_factory, _safety, _safety],
        topicId: topicId,
      );

      expect(result.added, 1);
      expect(result.skipped, 2);
      expect(provider.myWords, hasLength(2));
      expect(provider.topicById(topicId)!.wordCount, 1);
    });
  });

  test('UserTopic: toMap/fromMap giữ nguyên dữ liệu', () {
    final topic = UserTopic(
      id: 'topic_1',
      name: 'Công việc',
      description: 'Từ ở xưởng',
      order: 2,
      wordIds: const ['v_greet_1', 'my_1'],
      createdAt: DateTime(2026, 10, 26, 9),
    );

    final restored = UserTopic.fromMap(topic.toMap());

    expect(restored.name, topic.name);
    expect(restored.wordIds, topic.wordIds);
    expect(restored.createdAt, topic.createdAt);
    expect(restored.contains('my_1'), isTrue);
  });
}
