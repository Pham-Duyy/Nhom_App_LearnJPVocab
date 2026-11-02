import '../models/vocabulary.dart';
import 'repository.dart';
import 'vocabulary_repository.dart';

/// Gộp hai kho cùng kiểu [T] thành một: [isSecondary] cho biết id nào thuộc
/// kho phụ, mọi id khác thuộc kho chính. Phía dùng chỉ thấy một Repository
/// nên không cần biết dữ liệu nằm ở đâu.
class CombinedRepository<T> implements Repository<T, String> {
  CombinedRepository({
    required Repository<T, String> primary,
    required Repository<T, String> secondary,
    required bool Function(String id) isSecondary,
    required String Function(T item) idOf,
  })  : _primary = primary,
        _secondary = secondary,
        _isSecondary = isSecondary,
        _idOf = idOf;

  final Repository<T, String> _primary;
  final Repository<T, String> _secondary;
  final bool Function(String id) _isSecondary;
  final String Function(T item) _idOf;

  Repository<T, String> _storeOf(String id) =>
      _isSecondary(id) ? _secondary : _primary;

  @override
  Future<List<T>> getAll() async {
    final results = await Future.wait([_primary.getAll(), _secondary.getAll()]);
    return [...results[0], ...results[1]];
  }

  @override
  Future<T?> getById(String id) => _storeOf(id).getById(id);

  /// Giữ đúng thứ tự của [ids] dù các id nằm ở hai kho khác nhau.
  @override
  Future<List<T>> getByIds(List<String> ids) async {
    final results = await Future.wait([
      _primary.getByIds(ids.where((id) => !_isSecondary(id)).toList()),
      _secondary.getByIds(ids.where(_isSecondary).toList()),
    ]);
    final byId = {
      for (final item in [...results[0], ...results[1]]) _idOf(item): item,
    };
    return [
      for (final id in ids)
        if (byId.containsKey(id)) byId[id] as T,
    ];
  }

  @override
  Future<void> save(T item) => _storeOf(_idOf(item)).save(item);

  @override
  Future<void> delete(String id) => _storeOf(id).delete(id);
}

/// Từ vựng của app (kho chung) cộng từ người học tự thêm (kho riêng). Nhờ
/// đó flashcard, quiz, ôn tập và Sổ từ dùng được cả từ tự thêm.
class CombinedVocabularyRepository extends CombinedRepository<Vocabulary>
    implements VocabularyRepository {
  CombinedVocabularyRepository({
    required VocabularyRepository shared,
    required Repository<Vocabulary, String> personal,
  })  : _shared = shared,
        super(
          primary: shared,
          secondary: personal,
          isSecondary: (id) => id.startsWith(Vocabulary.personalIdPrefix),
          idOf: (word) => word.id,
        );

  final VocabularyRepository _shared;

  /// Từ tự thêm không thuộc bài học nào nên chỉ tìm trong kho chung.
  @override
  Future<List<Vocabulary>> getByLesson(String lessonId) =>
      _shared.getByLesson(lessonId);

  @override
  Future<List<Vocabulary>> search(String keyword) async =>
      (await getAll()).where((word) => word.matches(keyword)).toList();
}
