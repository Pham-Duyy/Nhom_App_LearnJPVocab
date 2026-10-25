import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/models/vocabulary.dart';
import 'package:chibakanji/providers/library_provider.dart';
import 'package:chibakanji/repositories/mock/mock_category_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/flaky_repositories.dart';

/// Trả từ vựng theo thứ tự ngược, giống Firestore trả theo id document
/// chứ không theo thứ tự học.
class _ReversedVocabularyRepository extends MockVocabularyRepository {
  @override
  Future<List<Vocabulary>> getAll() async =>
      (await super.getAll()).reversed.toList();
}

void main() {
  test('xếp từ theo đúng thứ tự học dù CSDL trả về lộn xộn', () async {
    final library = LibraryProvider(
      MockCategoryRepository(),
      _ReversedVocabularyRepository(),
    );

    await library.load();

    expect(
      library.words.map((w) => w.id),
      MockLearningData.vocabulary.map((w) => w.id),
    );
  });

  test('wordIdsOf trả về đúng các từ của một chủ đề', () async {
    final library =
        LibraryProvider(MockCategoryRepository(), MockVocabularyRepository());
    await library.load();

    final greetings = library.wordIdsOf('cat_greetings');

    expect(greetings, hasLength(10));
    expect(greetings.every((id) => id.startsWith('v_greet_')), isTrue);
    expect(library.wordIdsOf('khong-co'), isEmpty);
  });

  test('8a: mất mạng thì báo lỗi, có mạng lại thì tải được', () async {
    final categories = FlakyCategoryRepository()..failure = offlineError;
    final library = LibraryProvider(categories, MockVocabularyRepository());

    await library.load();
    expect(library.errorMessage, startsWith('Không có kết nối mạng'));
    expect(library.words, isEmpty);

    categories.failure = null;
    await library.load();
    expect(library.errorMessage, isNull);
    expect(library.words, hasLength(MockLearningData.vocabulary.length));
  });
}
