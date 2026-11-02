import '../models/progress.dart';
import 'repository.dart';

/// Tiến độ ghi nhớ của từng từ, khóa là id của từ vựng. Không có hàm riêng:
/// mọi thao tác cần thiết đã có sẵn trong [Repository].
abstract class ProgressRepository implements Repository<Progress, String> {}
