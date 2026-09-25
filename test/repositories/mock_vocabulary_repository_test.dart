import 'package:chibakanji/repositories/mock/mock_vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getByIds giữ đúng thứ tự yêu cầu, không theo thứ tự khai báo',
      () async {
    final repository = MockVocabularyRepository();

    final result = await repository.getByIds(['v_school_1', 'v_greet_1']);

    expect(result.map((w) => w.id).toList(), ['v_school_1', 'v_greet_1']);
  });

  test('getByIds bỏ qua ID không tồn tại mà không crash', () async {
    final repository = MockVocabularyRepository();

    final result = await repository.getByIds([
      'v_greet_1',
      'khong_ton_tai',
      'v_greet_2',
    ]);

    expect(result.map((w) => w.id).toList(), ['v_greet_1', 'v_greet_2']);
  });

  test('getByIds với danh sách rỗng trả về danh sách rỗng', () async {
    final repository = MockVocabularyRepository();

    final result = await repository.getByIds([]);

    expect(result, isEmpty);
  });
}
