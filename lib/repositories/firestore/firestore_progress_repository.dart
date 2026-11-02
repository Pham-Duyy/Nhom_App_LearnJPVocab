import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/progress.dart';
import '../progress_repository.dart';
import 'firestore_repository.dart';

/// Tiến độ học của người dùng đang đăng nhập, tại `users/{uid}/progress`.
class FirestoreProgressRepository extends FirestoreRepository<Progress>
    implements ProgressRepository {
  FirestoreProgressRepository(
      {FirebaseFirestore? firestore, FirebaseAuth? auth})
      : super(
          path: FirestoreRepository.userCollection('progress', auth: auth),
          fromMap: Progress.fromMap,
          toMap: (progress) => progress.toMap(),
          idOf: (progress) => progress.vocabularyId,
          firestore: firestore,
        );
}
