import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'app_auth_user.dart';
import 'auth_service.dart';

/// Implementation của [AuthService] sử dụng Firebase Authentication.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  AppAuthUser? _mapUser(fb.User? user) {
    if (user == null) return null;
    return AppAuthUser(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }

  @override
  AppAuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Stream<AppAuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  Future<AppAuthUser> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw const AuthException('user-not-found', 'Không tìm thấy người dùng');
      }
      return _mapUser(user)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    } catch (e) {
      throw AuthException('unknown-error', e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    } catch (e) {
      throw AuthException('unknown-error', e.toString());
    }
  }
}
