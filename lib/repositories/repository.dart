import '../models/learning_content.dart';

/// Interface tổng quát cho mọi kho dữ liệu: [T] là kiểu đối tượng được lưu,
/// [ID] là kiểu khóa của nó. Các repository cụ thể (tiến độ, từ vựng, lịch sử
/// quiz...) kế thừa interface này và chỉ thêm các hàm riêng của mình.
abstract class Repository<T, ID> {
  Future<List<T>> getAll();

  /// Trả về null nếu không có đối tượng nào mang [id].
  Future<T?> getById(ID id);

  /// Các đối tượng có id trong [ids], giữ đúng thứ tự của [ids]; id không tồn
  /// tại bị bỏ qua thay vì gây lỗi.
  Future<List<T>> getByIds(List<ID> ids);

  /// Thêm mới, hoặc ghi đè nếu đã có đối tượng cùng khóa.
  Future<void> save(T item);

  /// Xóa đối tượng mang [id]; không có thì bỏ qua.
  Future<void> delete(ID id);
}

/// Sắp xếp nội dung học (chủ đề, bài học, từ vựng) theo thứ tự hiển thị và
/// trả về chính danh sách đó. Ràng buộc `T extends LearningContent` bảo đảm
/// mọi phần tử đều có [LearningContent.order].
List<T> sortByOrder<T extends LearningContent>(List<T> items) =>
    items..sort((a, b) => a.order.compareTo(b.order));
