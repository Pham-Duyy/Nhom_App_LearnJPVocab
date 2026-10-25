import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/category.dart';
import '../../models/lesson.dart';
import '../category_repository.dart';
import '../repository.dart';
import 'firestore_repository.dart';

/// Chủ đề (`categories`) và bài học (`lessons`) trên Cloud Firestore, mỗi
/// collection là một FirestoreRepository tổng quát.
class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository({FirebaseFirestore? firestore})
      : _categories = FirestoreRepository<Category>(
          path: () => 'categories',
          fromMap: Category.fromMap,
          toMap: (category) => category.toMap(),
          idOf: (category) => category.id,
          firestore: firestore,
        ),
        _lessons = FirestoreRepository<Lesson>(
          path: () => 'lessons',
          fromMap: Lesson.fromMap,
          toMap: (lesson) => lesson.toMap(),
          idOf: (lesson) => lesson.id,
          firestore: firestore,
        );

  final FirestoreRepository<Category> _categories;
  final FirestoreRepository<Lesson> _lessons;

  @override
  Future<List<Category>> getCategories() async =>
      sortByOrder(await _categories.getAll());

  @override
  Future<List<Lesson>> getLessonsByCategory(String categoryId) async =>
      sortByOrder(await _lessons.getWhere('categoryId', categoryId));
}
