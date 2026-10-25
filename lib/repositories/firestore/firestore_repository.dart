import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repository.dart';

/// Repository tổng quát cho một collection trên Cloud Firestore. Toàn bộ thao
/// tác đọc/ghi được viết một lần ở đây; mỗi loại dữ liệu chỉ cần cho biết
/// đường dẫn collection và cách chuyển đổi giữa đối tượng [T] và Map
/// (ORM: Object ↔ Document).
///
/// Dùng trực tiếp: `FirestoreRepository<Category>(path: ..., ...)`, hoặc
/// kế thừa để thêm hàm riêng (xem FirestoreProgressRepository).
class FirestoreRepository<T> implements Repository<T, String> {
  FirestoreRepository({
    required String? Function() path,
    required T Function(Map<String, dynamic> map) fromMap,
    required Map<String, dynamic> Function(T item) toMap,
    required String Function(T item) idOf,
    FirebaseFirestore? firestore,
  })  : _path = path,
        _fromMap = fromMap,
        _toMap = toMap,
        _idOf = idOf,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Giới hạn số phần tử của một truy vấn `whereIn` trên Firestore.
  static const _whereInLimit = 30;

  final String? Function() _path;
  final T Function(Map<String, dynamic> map) _fromMap;
  final Map<String, dynamic> Function(T item) _toMap;
  final String Function(T item) _idOf;
  final FirebaseFirestore _firestore;

  /// Đường dẫn tới collection con của người dùng đang đăng nhập, vd.
  /// `users/{uid}/progress`; null nếu chưa đăng nhập.
  static String? Function() userCollection(String name, {FirebaseAuth? auth}) {
    return () {
      final uid = (auth ?? FirebaseAuth.instance).currentUser?.uid;
      return uid == null ? null : 'users/$uid/$name';
    };
  }

  /// Null khi chưa đăng nhập: đọc thì trả về rỗng, ghi thì bỏ qua.
  CollectionReference<Map<String, dynamic>>? get _collection {
    final path = _path();
    return path == null ? null : _firestore.collection(path);
  }

  List<T> _toItems(QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((doc) => _fromMap(doc.data())).toList();

  @override
  Future<List<T>> getAll() async {
    final collection = _collection;
    if (collection == null) return [];
    return _toItems(await collection.get());
  }

  @override
  Future<T?> getById(String id) async {
    final data = (await _collection?.doc(id).get())?.data();
    return data == null ? null : _fromMap(data);
  }

  /// Các đối tượng có [field] bằng [value]. Sắp xếp để phía gọi tự làm, vì
  /// where + orderBy trên hai trường khác nhau cần tạo composite index.
  Future<List<T>> getWhere(String field, Object value) async {
    final collection = _collection;
    if (collection == null) return [];
    return _toItems(await collection.where(field, isEqualTo: value).get());
  }

  /// Đọc theo lô `whereIn` thay vì từng document một.
  @override
  Future<List<T>> getByIds(List<String> ids) async {
    final collection = _collection;
    if (collection == null || ids.isEmpty) return [];

    final unique = ids.toSet().toList();
    final snapshots = await Future.wait([
      for (var i = 0; i < unique.length; i += _whereInLimit)
        collection
            .where(
              FieldPath.documentId,
              whereIn: unique.skip(i).take(_whereInLimit).toList(),
            )
            .get(),
    ]);

    final byId = {
      for (final snapshot in snapshots)
        for (final doc in snapshot.docs) doc.id: _fromMap(doc.data()),
    };
    return [
      for (final id in ids)
        if (byId.containsKey(id)) byId[id] as T,
    ];
  }

  /// merge: giữ nguyên các trường khác có thể được thêm vào document sau này.
  @override
  Future<void> save(T item) async {
    await _collection
        ?.doc(_idOf(item))
        .set(_toMap(item), SetOptions(merge: true));
  }
}
