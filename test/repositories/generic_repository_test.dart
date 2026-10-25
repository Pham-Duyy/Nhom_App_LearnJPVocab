import 'package:chibakanji/models/category.dart';
import 'package:chibakanji/models/lesson.dart';
import 'package:chibakanji/models/progress.dart';
import 'package:chibakanji/repositories/mock/in_memory_repository.dart';
import 'package:chibakanji/repositories/repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryRepository<T>: một lớp tổng quát cho mọi kiểu dữ liệu', () {
    test('dùng với Progress (khóa là vocabularyId)', () async {
      final Repository<Progress, String> repository =
          InMemoryRepository<Progress>(idOf: (p) => p.vocabularyId);

      await repository.save(const Progress(vocabularyId: 'v1'));

      expect((await repository.getById('v1'))!.vocabularyId, 'v1');
      expect(await repository.getById('khong-co'), isNull);
    });

    test('dùng với Category (khóa là id) và giữ thứ tự đã lưu', () async {
      final repository = InMemoryRepository<Category>(
        idOf: (c) => c.id,
        initialItems: const [
          Category(id: 'b', name: 'B', description: '', order: 2),
          Category(id: 'a', name: 'A', description: '', order: 1),
        ],
      );

      final all = await repository.getAll();

      expect(all.map((c) => c.id), ['b', 'a']);
    });

    test('save cùng khóa thì ghi đè, không thêm bản thứ hai', () async {
      final repository = InMemoryRepository<Progress>(
        idOf: (p) => p.vocabularyId,
      );

      await repository.save(const Progress(vocabularyId: 'v1', memoryLevel: 1));
      await repository.save(const Progress(vocabularyId: 'v1', memoryLevel: 3));

      final all = await repository.getAll();
      expect(all, hasLength(1));
      expect(all.single.memoryLevel, 3);
    });

    test('getByIds giữ thứ tự yêu cầu và bỏ qua id không tồn tại', () async {
      final repository = InMemoryRepository<Progress>(
        idOf: (p) => p.vocabularyId,
        initialItems: const [
          Progress(vocabularyId: 'v1'),
          Progress(vocabularyId: 'v2'),
        ],
      );

      final result = await repository.getByIds(['v2', 'khong-co', 'v1']);

      expect(result.map((p) => p.vocabularyId), ['v2', 'v1']);
    });
  });

  test('sortByOrder<T extends LearningContent> sắp mọi loại nội dung học', () {
    final lessons = sortByOrder([
      const Lesson(
        id: 'l2',
        categoryId: 'c',
        title: 'Bài 2',
        description: '',
        jlptLevel: 'N5',
        order: 2,
      ),
      const Lesson(
        id: 'l1',
        categoryId: 'c',
        title: 'Bài 1',
        description: '',
        jlptLevel: 'N5',
        order: 1,
      ),
    ]);

    expect(lessons.map((l) => l.id), ['l1', 'l2']);
  });
}
