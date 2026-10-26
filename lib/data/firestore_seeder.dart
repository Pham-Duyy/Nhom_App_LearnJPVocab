import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/learning_content.dart';
import 'mock/mock_learning_data.dart';

/// Nạp nội dung học mẫu (chủ đề, bài học, từ vựng) lên Firestore. Chỉ thêm
/// những document còn thiếu, nên khi bổ sung từ mới vào [MockLearningData]
/// thì chạy lại là đủ. Document id trùng với id của model.
///
/// Chỉ chạy khi app được mở với `--dart-define=SEED_CONTENT=true` và Rules
/// tạm cho phép ghi vào các collection nội dung (xem README, mục "Nạp nội
/// dung lên Firestore").
class FirestoreSeeder {
  FirestoreSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Trả về số document vừa nạp (0 nếu Firestore đã có đủ).
  Future<int> seedMissing() async {
    final batch = _firestore.batch();
    final added = await _addMissing(
          batch,
          'categories',
          MockLearningData.categories,
          (category) => category.toMap(),
        ) +
        await _addMissing(
          batch,
          'lessons',
          MockLearningData.lessons,
          (lesson) => lesson.toMap(),
        ) +
        await _addMissing(
          batch,
          'vocabularies',
          MockLearningData.vocabulary,
          (word) => word.toMap(),
        );
    if (added > 0) await batch.commit();
    return added;
  }

  /// Đưa vào [batch] những phần tử của [items] chưa có trên [collectionPath].
  /// Dùng chung cho mọi loại nội dung nhờ ràng buộc `T extends
  /// LearningContent` (đều có id).
  Future<int> _addMissing<T extends LearningContent>(
    WriteBatch batch,
    String collectionPath,
    List<T> items,
    Map<String, dynamic> Function(T item) toMap,
  ) async {
    final collection = _firestore.collection(collectionPath);
    final snapshot = await collection.get();
    final existingIds = snapshot.docs.map((doc) => doc.id).toSet();
    final missing = items.where((item) => !existingIds.contains(item.id));
    for (final item in missing) {
      batch.set(collection.doc(item.id), toMap(item));
    }
    return missing.length;
  }
}
