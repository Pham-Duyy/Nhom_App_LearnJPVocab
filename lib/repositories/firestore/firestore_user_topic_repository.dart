import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_topic.dart';
import '../user_topic_repository.dart';
import 'firestore_repository.dart';

/// Chủ đề tự tạo tại `users/{uid}/topics`.
class FirestoreUserTopicRepository extends FirestoreRepository<UserTopic>
    implements UserTopicRepository {
  FirestoreUserTopicRepository(
      {FirebaseFirestore? firestore, FirebaseAuth? auth})
      : super(
          path: FirestoreRepository.userCollection('topics', auth: auth),
          fromMap: UserTopic.fromMap,
          toMap: (topic) => topic.toMap(),
          idOf: (topic) => topic.id,
          firestore: firestore,
        );
}
