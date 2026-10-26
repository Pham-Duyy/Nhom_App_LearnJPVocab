/// Người dùng đã xác thực, ở dạng độc lập với Firebase. UI và Provider chỉ
/// dùng model này, không bao giờ nhận `firebase_auth.User` trực tiếp.
class AppAuthUser {
  /// Mã nhà cung cấp của Firebase cho đăng nhập bằng email và Google.
  static const passwordProvider = 'password';
  static const googleProvider = 'google.com';

  const AppAuthUser({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.photoUrl,
    this.providers = const [],
  });

  final String uid;
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  /// Các cách đăng nhập đã gắn với tài khoản, vd. `['password']`.
  final List<String> providers;

  bool get hasGoogle => providers.contains(googleProvider);
  bool get hasPassword => providers.contains(passwordProvider);

  /// Cách đăng nhập để hiển thị cho người dùng.
  String get signInMethodLabel {
    if (isAnonymous) return 'Khách';
    if (hasGoogle && hasPassword) return 'Google và email';
    if (hasGoogle) return 'Google';
    if (hasPassword) return 'Email và mật khẩu';
    return 'Tài khoản';
  }

  @override
  String toString() => 'AppAuthUser($uid, anonymous: $isAnonymous)';
}
