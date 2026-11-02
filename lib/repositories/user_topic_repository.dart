import '../models/user_topic.dart';
import 'repository.dart';

/// Chủ đề người học tự tạo, của riêng người dùng đang đăng nhập.
abstract class UserTopicRepository implements Repository<UserTopic, String> {}
