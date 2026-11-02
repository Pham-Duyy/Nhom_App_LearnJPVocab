import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/vocabulary.dart';
import '../user_word_repository.dart';
import 'firestore_repository.dart';

/// Từ vựng tự thêm tại `users/{uid}/words`.
class FirestoreUserWordRepository extends FirestoreRepository<Vocabulary>
    implements UserWordRepository {
  FirestoreUserWordRepository(
      {FirebaseFirestore? firestore, FirebaseAuth? auth})
      : super(
          path: FirestoreRepository.userCollection('words', auth: auth),
          fromMap: Vocabulary.fromMap,
          toMap: (word) => word.toMap(),
          idOf: (word) => word.id,
          firestore: firestore,
        );
}
