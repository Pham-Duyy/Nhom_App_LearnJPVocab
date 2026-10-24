import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/vocabulary.dart';
import '../vocabulary_repository.dart';

/// Đọc từ vựng trực tiếp từ Cloud Firestore.
class FirestoreVocabularyRepository implements VocabularyRepository {
  FirestoreVocabularyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _vocabulariesRef =>
      _firestore.collection('vocabularies');

  @override
  Future<List<Vocabulary>> getByLesson(String lessonId) async {
    final snapshot = await _vocabulariesRef
        .where('lessonId', isEqualTo: lessonId)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => Vocabulary.fromMap(doc.data())).toList();
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
    final result = <Vocabulary>[];
    for (final id in vocabularyIds) {
      final doc = await _vocabulariesRef.doc(id).get();
      if (doc.exists && doc.data() != null) {
        result.add(Vocabulary.fromMap(doc.data()!));
      }
    }
    return result;
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
