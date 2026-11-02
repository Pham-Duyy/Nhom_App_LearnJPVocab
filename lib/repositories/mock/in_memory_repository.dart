import '../repository.dart';

/// Repository tổng quát lưu trong bộ nhớ, cùng interface với
/// FirestoreRepository nên dùng thay thế được khi test hoặc chạy không mạng.
class InMemoryRepository<T> implements Repository<T, String> {
  InMemoryRepository({
    required String Function(T item) idOf,
    Iterable<T> initialItems = const [],
  }) : _idOf = idOf {
    for (final item in initialItems) {
      _store[idOf(item)] = item;
    }
  }

  final String Function(T item) _idOf;

  /// Map giữ thứ tự thêm vào, nên getAll trả về theo thứ tự đã lưu.
  final Map<String, T> _store = {};

  @override
  Future<List<T>> getAll() async => _store.values.toList();

  @override
  Future<T?> getById(String id) async => _store[id];

  @override
  Future<List<T>> getByIds(List<String> ids) async => [
        for (final id in ids)
          if (_store.containsKey(id)) _store[id] as T,
      ];

  @override
  Future<void> save(T item) async {
    _store[_idOf(item)] = item;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}
