import '../models/user_profile.dart';

abstract class UserProfileRepository {
  /// Hồ sơ của người dùng hiện tại, hoặc null nếu chưa từng được lưu.
  Future<UserProfile?> load();

  Future<void> save(UserProfile profile);
}
