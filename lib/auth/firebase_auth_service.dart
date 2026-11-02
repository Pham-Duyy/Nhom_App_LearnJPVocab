import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

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

  /// Android chọn tài khoản Google bằng màn hình của hệ điều hành. Cách mở
  /// trình duyệt (signInWithProvider) hay mất phiên giữa chừng trên một số
  /// máy ("missing initial state"); web vẫn dùng cửa sổ bật lên.
  bool get _nativeGoogle =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void>? _googleReady;

  /// Mở màn chọn tài khoản Google của Android, trả về credential cho Firebase.
  Future<fb.AuthCredential> _googleCredential() async {
    final google = GoogleSignIn.instance;
    await (_googleReady ??= google.initialize());
    try {
      final account = await google.authenticate();
      return fb.GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
    } on GoogleSignInException catch (e) {
      throw AuthException(
        switch (e.code) {
          GoogleSignInExceptionCode.canceled ||
          GoogleSignInExceptionCode.interrupted =>
            'web-context-canceled',
          GoogleSignInExceptionCode.clientConfigurationError ||
          GoogleSignInExceptionCode.providerConfigurationError =>
            'google-config-error',
          _ => 'unknown-error',
        },
        e.description,
      );
    }
  }

  @override
  Future<AppAuthUser> signInWithGoogle() {
    return _guard(() async {
      final provider = fb.GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      final current = _auth.currentUser;
      final isGuest = current != null && current.isAnonymous;

      if (!_nativeGoogle) {
        if (!isGuest) {
          return _userOf(kIsWeb
              ? await _auth.signInWithPopup(provider)
              : await _auth.signInWithProvider(provider));
        }
        return _linkOrSwitch(() => kIsWeb
            ? current.linkWithPopup(provider)
            : current.linkWithProvider(provider));
      }

      final credential = await _googleCredential();
      if (!isGuest) {
        return _userOf(await _auth.signInWithCredential(credential));
      }
      return _linkOrSwitch(() => current.linkWithCredential(credential));
    });
  }

  /// Gắn Google vào tài khoản khách để giữ tiến độ; nếu tài khoản Google đó
  /// đã dùng trong app trước đây thì đăng nhập vào tài khoản cũ.
  Future<AppAuthUser> _linkOrSwitch(
    Future<fb.UserCredential> Function() link,
  ) async {
    try {
      return _userOf(await link());
    } on fb.FirebaseAuthException catch (e) {
      final credential = e.credential;
      if (e.code != 'credential-already-in-use' || credential == null) {
        rethrow;
      }
      return _userOf(await _auth.signInWithCredential(credential));
    }
  }

  /// Đăng xuất cả Google trên Android để lần sau được chọn lại tài khoản.
  @override
  Future<void> signOut() => _guard(() async {
        if (_nativeGoogle && _googleReady != null) {
          await GoogleSignIn.instance.signOut();
        }
        await _auth.signOut();
      });

  @override
  Future<void> reauthenticate({String? password}) {
    return _guard(() async {
      final user = _signedInUser;
      final providers = {for (final info in user.providerData) info.providerId};
      final email = user.email;
      if (providers.contains(AppAuthUser.passwordProvider) &&
          password != null &&
          email != null) {
        await user.reauthenticateWithCredential(
          fb.EmailAuthProvider.credential(email: email, password: password),
        );
      } else if (providers.contains(AppAuthUser.googleProvider)) {
        final provider = fb.GoogleAuthProvider();
        if (_nativeGoogle) {
          await user.reauthenticateWithCredential(await _googleCredential());
        } else if (kIsWeb) {
          await user.reauthenticateWithPopup(provider);
        } else {
          await user.reauthenticateWithProvider(provider);
        }
      }
    });
  }

  @override
  Future<void> updatePassword(String newPassword) =>
      _guard(() => _signedInUser.updatePassword(newPassword));

  @override
  Future<void> deleteAccount() => _guard(() => _signedInUser.delete());

  fb.User get _signedInUser =>
      _auth.currentUser ??
      (throw const AuthException('user-not-found', 'Chưa đăng nhập'));

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
