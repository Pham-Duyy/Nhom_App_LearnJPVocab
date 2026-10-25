import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/vocabulary.dart';
import '../vocabulary_repository.dart';

/// Đọc từ vựng trực tiếp từ Cloud Firestore. Document id trùng với
/// [Vocabulary.id].
class FirestoreVocabularyRepository implements VocabularyRepository {
  FirestoreVocabularyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Giới hạn số phần tử của một truy vấn `whereIn` trên Firestore.
  static const _whereInLimit = 30;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _vocabulariesRef =>
      _firestore.collection('vocabularies');

  @override
  Future<List<Vocabulary>> getByLesson(String lessonId) async {
    // Sắp xếp phía client để không cần composite index (lessonId + order).
    final snapshot =
        await _vocabulariesRef.where('lessonId', isEqualTo: lessonId).get();
    return snapshot.docs.map((doc) => Vocabulary.fromMap(doc.data())).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<Vocabulary?> getById(String vocabularyId) async {
    final doc = await _vocabulariesRef.doc(vocabularyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Vocabulary.fromMap(doc.data()!);
  }

  @override
  Future<List<Vocabulary>> getByIds(List<String> vocabularyIds) async {
    if (vocabularyIds.isEmpty) return [];

    final ids = vocabularyIds.toSet().toList();
    final chunks = [
      for (var i = 0; i < ids.length; i += _whereInLimit)
        ids.sublist(i, (i + _whereInLimit).clamp(0, ids.length)),
    ];
    final snapshots = await Future.wait(chunks.map(
      (chunk) =>
          _vocabulariesRef.where(FieldPath.documentId, whereIn: chunk).get(),
    ));

    final byId = {
      for (final snapshot in snapshots)
        for (final doc in snapshot.docs) doc.id: Vocabulary.fromMap(doc.data()),
    };
    return [
      for (final id in vocabularyIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  @override
  Future<List<Vocabulary>> search(String keyword) async {
    final snapshot = await _vocabulariesRef.get();
    return snapshot.docs
        .map((doc) => Vocabulary.fromMap(doc.data()))
        .where((word) => word.matches(keyword))
        .toList();
  }
}
