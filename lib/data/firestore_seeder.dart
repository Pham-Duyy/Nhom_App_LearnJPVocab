import 'package:cloud_firestore/cloud_firestore.dart';

import 'mock/mock_learning_data.dart';

/// Nạp nội dung học mẫu (chủ đề, bài học, từ vựng) lên Firestore khi
/// database còn trống. Document id trùng với id của model.
///
/// Chỉ chạy được khi rules cho phép ghi vào các collection nội dung — tức là
/// trước khi publish bản cuối của `firestore.rules`, vốn chặn mọi thao tác
/// ghi từ app.
class FirestoreSeeder {
  FirestoreSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Trả về true nếu vừa nạp dữ liệu, false nếu database đã có sẵn.
  Future<bool> seedIfEmpty() async {
    final categories = _firestore.collection('categories');
    final existing = await categories.limit(1).get();
    if (existing.docs.isNotEmpty) return false;

    final lessons = _firestore.collection('lessons');
    final vocabularies = _firestore.collection('vocabularies');
    final batch = _firestore.batch();

    for (final category in MockLearningData.categories) {
      batch.set(categories.doc(category.id), category.toMap());
    }
    for (final lesson in MockLearningData.lessons) {
      batch.set(lessons.doc(lesson.id), lesson.toMap());
    }
    for (final word in MockLearningData.vocabulary) {
      batch.set(vocabularies.doc(word.id), word.toMap());
    }

    await batch.commit();
    return true;
  }
}
