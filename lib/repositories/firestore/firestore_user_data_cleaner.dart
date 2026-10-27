import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../user_data_cleaner.dart';

/// Xóa document `users/{uid}` cùng mọi collection con của nó. Firestore
/// không tự xóa collection con khi xóa document cha, nên phải xóa từng
/// document; mỗi batch tối đa 500 thao tác.
class FirestoreUserDataCleaner implements UserDataCleaner {
  FirestoreUserDataCleaner({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Các collection con dưới `users/{uid}` (xem các Firestore repository).
  static const collections = ['progress', 'quizAttempts', 'topics', 'words'];
  static const _batchLimit = 500;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> deleteAll() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final user = _firestore.collection('users').doc(uid);

    for (final name in collections) {
      final docs = (await user.collection(name).get()).docs;
      for (var start = 0; start < docs.length; start += _batchLimit) {
        final batch = _firestore.batch();
        for (final doc in docs.skip(start).take(_batchLimit)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    await user.delete();
  }
}
