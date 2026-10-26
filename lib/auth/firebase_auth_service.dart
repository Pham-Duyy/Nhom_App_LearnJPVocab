import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;

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
      providers: [for (final info in user.providerData) info.providerId],
    );
  }

  @override
  AppAuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Stream<AppAuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  Future<AppAuthUser> signInAnonymously() {
    return _guard(() async => _userOf(await _auth.signInAnonymously()));
  }

  @override
  Future<AppAuthUser> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        final credential = fb.EmailAuthProvider.credential(
          email: email.trim(),
          password: password,
        );
        return _userOf(await current.linkWithCredential(credential));
      }
      return _userOf(await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ));
    });
  }

  @override
  Future<AppAuthUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(() async => _userOf(await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        )));
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  @override
  Future<AppAuthUser> signInWithGoogle() {
    return _guard(() async {
      final provider = fb.GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});

      final current = _auth.currentUser;
      if (current == null || !current.isAnonymous) {
        return _userOf(kIsWeb
            ? await _auth.signInWithPopup(provider)
            : await _auth.signInWithProvider(provider));
      }

      try {
        return _userOf(kIsWeb
            ? await current.linkWithPopup(provider)
            : await current.linkWithProvider(provider));
      } on fb.FirebaseAuthException catch (e) {
        final credential = e.credential;
        if (e.code != 'credential-already-in-use' || credential == null) {
          rethrow;
        }
        return _userOf(await _auth.signInWithCredential(credential));
      }
    });
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  AppAuthUser _userOf(fb.UserCredential credential) {
    final user = _mapUser(credential.user);
    if (user == null) {
      throw const AuthException('user-not-found', 'Không tìm thấy người dùng');
    }
    return user;
  }

  /// Đổi mọi lỗi của Firebase sang [AuthException], giữ nguyên mã lỗi để
  /// AuthController chọn thông báo phù hợp.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('unknown-error', e.toString());
    }
  }
}
