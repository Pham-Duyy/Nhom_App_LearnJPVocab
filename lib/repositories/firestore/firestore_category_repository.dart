import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/category.dart';
import '../../models/lesson.dart';
import '../category_repository.dart';

/// Đọc category/lesson trực tiếp từ Cloud Firestore.
class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get _lessonsRef =>
      _firestore.collection('lessons');

  @override
  Future<List<Category>> getCategories() async {
    final snapshot = await _categoriesRef.orderBy('order').get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  @override
  Future<List<Lesson>> getLessonsByCategory(String categoryId) async {
    // Sắp xếp phía client: where + orderBy trên hai trường khác nhau cần
    // composite index trên Firestore, thiếu index thì truy vấn lỗi.
    final snapshot =
        await _lessonsRef.where('categoryId', isEqualTo: categoryId).get();
    return snapshot.docs.map((doc) => Lesson.fromMap(doc.data())).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    final doc = await _lessonsRef.doc(lessonId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Lesson.fromMap(doc.data()!);
  }
}
