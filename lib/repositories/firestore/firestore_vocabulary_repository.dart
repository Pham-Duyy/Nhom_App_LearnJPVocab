import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/vocabulary.dart';
import '../repository.dart';
import '../vocabulary_repository.dart';
import 'firestore_repository.dart';

/// Từ vựng tại collection `vocabularies`; document id trùng với
/// [Vocabulary.id].
class FirestoreVocabularyRepository extends FirestoreRepository<Vocabulary>
    implements VocabularyRepository {
  FirestoreVocabularyRepository({FirebaseFirestore? firestore})
      : super(
          path: () => 'vocabularies',
          fromMap: Vocabulary.fromMap,
          toMap: (word) => word.toMap(),
          idOf: (word) => word.id,
          firestore: firestore,
        );

  @override
  Future<List<Vocabulary>> getByLesson(String lessonId) async =>
      sortByOrder(await getWhere('lessonId', lessonId));

  @override
  Future<List<Vocabulary>> search(String keyword) async =>
      (await getAll()).where((word) => word.matches(keyword)).toList();
}
