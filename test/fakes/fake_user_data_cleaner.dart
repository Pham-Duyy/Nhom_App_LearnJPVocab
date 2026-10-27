import 'package:chibakanji/repositories/user_data_cleaner.dart';

/// Xóa dữ liệu giả: chỉ đếm số lần được gọi, hoặc ném [failure].
class FakeUserDataCleaner implements UserDataCleaner {
  int deleteCount = 0;
  Object? failure;

  @override
  Future<void> deleteAll() async {
    final error = failure;
    if (error != null) throw error;
    deleteCount++;
  }
}
