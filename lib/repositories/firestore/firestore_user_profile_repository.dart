import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_profile.dart';
import '../user_profile_repository.dart';
import 'firestore_repository.dart';

/// Hồ sơ người học tại document `users/{uid}`: một FirestoreRepository trên
/// collection `users`, với khóa luôn là uid của người đang đăng nhập.
class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance {
    _users = FirestoreRepository<UserProfile>(
      path: () => 'users',
      fromMap: UserProfile.fromMap,
      toMap: (profile) => profile.toMap(),
      idOf: (_) => _uid!,
      firestore: firestore,
    );
  }

  final FirebaseAuth _auth;
  late final FirestoreRepository<UserProfile> _users;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<UserProfile?> load() async {
    final uid = _uid;
    return uid == null ? null : _users.getById(uid);
  }

  @override
  Future<void> save(UserProfile profile) async {
    if (_uid == null) return;
    await _users.save(profile);
  }
}
