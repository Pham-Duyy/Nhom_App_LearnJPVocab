/// Người dùng đã xác thực, ở dạng độc lập với Firebase. UI và Provider chỉ
/// dùng model này, không bao giờ nhận `firebase_auth.User` trực tiếp.
///
/// Khác với `models/user.dart` cũ (có passwordHash, chưa được dùng ở đâu):
/// model đó sẽ được refactor ở giai đoạn hồ sơ người dùng sau này.
class AppAuthUser {
  const AppAuthUser({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  final String uid;
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  @override
  String toString() => 'AppAuthUser($uid, anonymous: $isAnonymous)';
}
