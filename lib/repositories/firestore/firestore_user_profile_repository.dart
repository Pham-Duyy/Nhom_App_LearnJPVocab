import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_profile.dart';
import '../user_profile_repository.dart';

/// Lưu hồ sơ người học tại document `users/{uid}` trên Cloud Firestore.
class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>>? get _profileRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  @override
  Future<UserProfile?> load() async {
    final ref = _profileRef;
    if (ref == null) return null;
    final data = (await ref.get()).data();
    return data == null ? null : UserProfile.fromMap(data);
  }

  @override
  Future<void> save(UserProfile profile) async {
    final ref = _profileRef;
    if (ref == null) return;
    // merge: giữ nguyên các trường khác có thể được thêm vào document sau này.
    await ref.set(profile.toMap(), SetOptions(merge: true));
  }
}
