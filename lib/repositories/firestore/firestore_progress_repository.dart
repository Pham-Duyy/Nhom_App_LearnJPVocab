import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/progress.dart';
import '../progress_repository.dart';

/// Lưu và đọc tiến độ học của người dùng trên Cloud Firestore theo UID.
class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _userProgressRef {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('progress');
  }

  @override
  Future<List<Progress>> getAll() async {
    final ref = _userProgressRef;
    if (ref == null) return [];
    final snapshot = await ref.get();
    return snapshot.docs.map((doc) => Progress.fromMap(doc.data())).toList();
  }

  @override
  Future<Progress?> getByVocabularyId(String vocabularyId) async {
    final ref = _userProgressRef;
    if (ref == null) return null;
    final doc = await ref.doc(vocabularyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Progress.fromMap(doc.data()!);
  }

  @override
  Future<List<Progress>> getDueForReview(DateTime now) async {
    final all = await getAll();
    return all.where((progress) => progress.isDueForReview(now)).toList();
  }

  @override
  Future<void> save(Progress progress) async {
    final ref = _userProgressRef;
    if (ref == null) return;
    await ref.doc(progress.vocabularyId).set(
          progress.toMap(),
          SetOptions(merge: true),
        );
  }
}
