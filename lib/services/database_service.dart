import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/mock/mock_learning_data.dart';
import '../models/category.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../models/vocabulary.dart';

/// Dịch vụ kết nối và thao tác với Cloud Firestore.
class DatabaseService {
  DatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get _lessonsRef =>
      _firestore.collection('lessons');

  CollectionReference<Map<String, dynamic>> get _vocabulariesRef =>
      _firestore.collection('vocabularies');

  CollectionReference<Map<String, dynamic>> _userProgressRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('progress');

  // ================= CATEGORIES =================
  Future<List<Category>> getCategories() async {
    final snapshot = await _categoriesRef.orderBy('order').get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  // ================= LESSONS =================
  Future<List<Lesson>> getLessons(String categoryId) async {
    final snapshot = await _lessonsRef
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => Lesson.fromMap(doc.data())).toList();
  }

  // ================= VOCABULARIES =================
  Future<List<Vocabulary>> getVocabulariesByLesson(String lessonId) async {
    final snapshot = await _vocabulariesRef
        .where('lessonId', isEqualTo: lessonId)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => Vocabulary.fromMap(doc.data())).toList();
  }

  Future<Vocabulary?> getVocabularyById(String id) async {
    final doc = await _vocabulariesRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Vocabulary.fromMap(doc.data()!);
  }

  // ================= PROGRESS =================
  Future<void> saveProgress(String userId, Progress progress) async {
    await _userProgressRef(userId)
        .doc(progress.vocabularyId)
        .set(progress.toMap(), SetOptions(merge: true));
  }

  Future<Progress?> getProgress(String userId, String vocabularyId) async {
    final doc = await _userProgressRef(userId).doc(vocabularyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Progress.fromMap(doc.data()!);
  }

  Future<List<Progress>> getAllProgress(String userId) async {
    final snapshot = await _userProgressRef(userId).get();
    return snapshot.docs.map((doc) => Progress.fromMap(doc.data())).toList();
  }

  /// Nạp dữ liệu mẫu ban đầu lên Firestore nếu database còn trống.
  Future<void> seedInitialData() async {
    final catSnap = await _categoriesRef.limit(1).get();
    if (catSnap.docs.isNotEmpty) return; // Đã có dữ liệu, không nạp đè

    final batch = _firestore.batch();

    for (final cat in MockLearningData.categories) {
      batch.set(_categoriesRef.doc(cat.id), cat.toMap());
    }

    for (final les in MockLearningData.lessons) {
      batch.set(_lessonsRef.doc(les.id), les.toMap());
    }

    for (final voc in MockLearningData.vocabulary) {
      batch.set(_vocabulariesRef.doc(voc.id), voc.toMap());
    }

    await batch.commit();
  }
}
