import 'package:chibakanji/data/mock/mock_learning_data.dart';
import 'package:chibakanji/models/vocabulary.dart';
import 'package:chibakanji/models/word_draft.dart';
import 'package:chibakanji/repositories/combined_repository.dart';
import 'package:chibakanji/repositories/mock/mock_user_word_repository.dart';
import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Vocabulary _myWord(String id) =>
    const WordDraft(kana: 'こうじょう', meaning: 'Nhà máy')
        .toVocabulary(id: id, order: 1);

void main() {
  late MockUserWordRepository personal;
  late CombinedVocabularyRepository combined;

  setUp(() {
    personal = MockUserWordRepository(initialWords: [_myWord('my_1')]);
    combined = CombinedVocabularyRepository(
      shared: MockVocabularyRepository(),
      personal: personal,
    );
  });

  test('getAll gộp từ của app và từ tự thêm', () async {
    final all = await combined.getAll();

    expect(all, hasLength(MockLearningData.vocabulary.length + 1));
    expect(all.last.id, 'my_1');
  });

  test('getByIds lấy từ cả hai kho và giữ đúng thứ tự yêu cầu', () async {
    final words = await combined.getByIds(['v_greet_2', 'my_1', 'v_greet_1']);

    expect(words.map((w) => w.id), ['v_greet_2', 'my_1', 'v_greet_1']);
  });

  test('lưu và xóa từ tự thêm chỉ đụng tới kho riêng', () async {
    await combined.save(_myWord('my_2'));
    await combined.delete('my_1');

    expect((await personal.getAll()).map((w) => w.id), ['my_2']);
    expect(await combined.getById('v_greet_1'), isNotNull);
  });

  test('từ tự thêm được đánh dấu isPersonal', () {
    expect(_myWord('my_1').isPersonal, isTrue);
    expect(MockLearningData.vocabulary.first.isPersonal, isFalse);
  });
}
