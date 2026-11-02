import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/quiz_attempt.dart';
import '../quiz_attempt_repository.dart';
import 'firestore_repository.dart';

/// Lịch sử quiz của người dùng đang đăng nhập, tại `users/{uid}/quizAttempts`.
class FirestoreQuizAttemptRepository extends FirestoreRepository<QuizAttempt>
    implements QuizAttemptRepository {
  FirestoreQuizAttemptRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : super(
          path: FirestoreRepository.userCollection('quizAttempts', auth: auth),
          fromMap: QuizAttempt.fromMap,
          toMap: (attempt) => attempt.toMap(),
          idOf: (attempt) => attempt.id,
          firestore: firestore,
        );
}
