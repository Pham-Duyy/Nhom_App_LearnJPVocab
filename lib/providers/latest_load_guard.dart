import 'package:flutter/foundation.dart';

/// Chỉ nhận kết quả của lần tải mới nhất. Khi đăng xuất rồi đăng nhập tài
/// khoản khác lúc lần tải trước chưa xong, kết quả cũ (của người trước) về
/// muộn sẽ bị bỏ qua thay vì ghi đè dữ liệu của người mới.
mixin LatestLoadGuard on ChangeNotifier {
  int _loadGeneration = 0;

  /// Gọi ở đầu mỗi lần tải; hàm trả về cho biết lần tải này còn là mới nhất
  /// hay không (gọi sau mỗi `await`).
  bool Function() startLoad() {
    final generation = ++_loadGeneration;
    return () => generation == _loadGeneration;
  }
}
