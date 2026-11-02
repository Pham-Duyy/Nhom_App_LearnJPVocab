import '../../models/user_profile.dart';
import '../user_profile_repository.dart';

/// Giữ hồ sơ trong bộ nhớ, dùng cho test và chạy không cần Firebase.
class MockUserProfileRepository implements UserProfileRepository {
  MockUserProfileRepository({UserProfile? initialProfile})
      : _profile = initialProfile;

  UserProfile? _profile;

  /// Số lần [save] được gọi, để test kiểm tra không ghi thừa.
  int saveCount = 0;

  @override
  Future<UserProfile?> load() async => _profile;

  @override
  Future<void> save(UserProfile profile) async {
    saveCount++;
    _profile = profile;
  }
}
