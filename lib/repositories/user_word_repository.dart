import '../models/vocabulary.dart';
import 'repository.dart';

/// Từ vựng người học tự thêm, của riêng người dùng đang đăng nhập.
abstract class UserWordRepository implements Repository<Vocabulary, String> {}
