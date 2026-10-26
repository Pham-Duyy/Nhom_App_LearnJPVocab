import '../../models/vocabulary.dart';
import '../user_word_repository.dart';
import 'in_memory_repository.dart';

class MockUserWordRepository extends InMemoryRepository<Vocabulary>
    implements UserWordRepository {
  MockUserWordRepository({List<Vocabulary> initialWords = const []})
      : super(idOf: (word) => word.id, initialItems: initialWords);
}
