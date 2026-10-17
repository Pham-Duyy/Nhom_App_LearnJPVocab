import 'package:chibakanji/models/category.dart';
import 'package:chibakanji/models/generic_entity.dart';
import 'package:chibakanji/models/learning_content.dart';
import 'package:chibakanji/models/lesson.dart';
import 'package:chibakanji/models/quiz.dart';
import 'package:chibakanji/models/user.dart';
import 'package:chibakanji/models/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const category = Category(
    id: 'cat_1',
    name: 'Chào hỏi',
    description: 'Các câu chào thường ngày',
    order: 2,
  );

  test('Category kế thừa GenericEntity<String> qua LearningContent', () {
    expect(category, isA<LearningContent>());
    expect(category, isA<GenericEntity<String>>());
  });

  test('các phương thức get chung trả về đúng giá trị', () {
    expect(category.getId(), 'cat_1');
    expect(category.getName(), 'Chào hỏi');
    expect(category.getDescription(), 'Các câu chào thường ngày');
  });

  test('order và isPublished kế thừa từ LearningContent', () {
    expect(category.order, 2);
    expect(category.isPublished, isTrue);
  });

  group('matches() kế thừa từ GenericEntity', () {
    test('tìm được theo tên, không phân biệt hoa thường', () {
      expect(category.matches('CHÀO'), isTrue);
    });

    test('tìm được theo mô tả', () {
      expect(category.matches('thường ngày'), isTrue);
    });

    test('từ khóa không liên quan hoặc rỗng không khớp', () {
      expect(category.matches('kanji'), isFalse);
      expect(category.matches('  '), isFalse);
    });
  });

  test('toString() chung dùng tên lớp con và name', () {
    expect(category.toString(), 'Category(Chào hỏi)');
  });

  test('toMap()/fromMap() giữ nguyên dữ liệu sau khi đổi sang kế thừa', () {
    final restored = Category.fromMap(category.toMap());

    expect(restored.id, category.id);
    expect(restored.name, category.name);
    expect(restored.description, category.description);
    expect(restored.order, category.order);
    expect(restored.isPublished, category.isPublished);
  });

  group('Lesson kế thừa LearningContent', () {
    const lesson = Lesson(
      id: 'les_1',
      categoryId: 'cat_1',
      title: 'Chào hỏi cơ bản',
      description: 'Các câu chào thông dụng',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 5,
    );

    test('là GenericEntity<String>, title được lưu vào name của lớp cha', () {
      expect(lesson, isA<LearningContent>());
      expect(lesson, isA<GenericEntity<String>>());
      expect(lesson.name, 'Chào hỏi cơ bản');
      expect(lesson.getName(), lesson.title);
    });

    test('matches() và toString() kế thừa dùng được với title', () {
      expect(lesson.matches('cơ bản'), isTrue);
      expect(lesson.toString(), 'Lesson(Chào hỏi cơ bản)');
    });

    test('toMap() vẫn dùng key title để dữ liệu cũ đọc được', () {
      final map = lesson.toMap();
      expect(map['title'], 'Chào hỏi cơ bản');
      expect(map.containsKey('name'), isFalse);

      final restored = Lesson.fromMap(map);
      expect(restored.title, lesson.title);
      expect(restored.categoryId, lesson.categoryId);
      expect(restored.vocabularyCount, lesson.vocabularyCount);
    });

    test('copyWith(title:) đổi được tên bài học', () {
      expect(lesson.copyWith(title: 'Bài mới').name, 'Bài mới');
    });
  });

  group('Vocabulary kế thừa LearningContent', () {
    const word = Vocabulary(
      id: 'v1',
      lessonId: 'l1',
      kanji: '学校',
      kana: 'がっこう',
      romaji: 'gakkou',
      meaning: 'trường học',
      exampleJapanese: '毎日学校へ行きます。',
      exampleVietnamese: 'Tôi đến trường mỗi ngày.',
      jlptLevel: 'N5',
      order: 1,
    );
    const kanaOnly = Vocabulary(
      id: 'v2',
      lessonId: 'l1',
      kanji: '',
      kana: 'こんにちは',
      romaji: 'konnichiwa',
      meaning: 'xin chào',
      exampleJapanese: 'こんにちは、田中さん。',
      exampleVietnamese: 'Xin chào anh Tanaka.',
      jlptLevel: 'N5',
      order: 2,
    );

    test(
        'là GenericEntity<String>, kanji thành name, meaning thành description',
        () {
      expect(word, isA<LearningContent>());
      expect(word, isA<GenericEntity<String>>());
      expect(word.name, '学校');
      expect(word.getDescription(), 'trường học');
      expect(word.meaning, word.description);
    });

    test('từ không có kanji thì name lấy kana, kanji vẫn để rỗng', () {
      expect(kanaOnly.name, 'こんにちは');
      expect(kanaOnly.kanji, isEmpty);
    });

    test('toMap() giữ key kanji/meaning, không thêm name/description', () {
      final map = kanaOnly.toMap();
      expect(map['kanji'], '');
      expect(map['meaning'], 'xin chào');
      expect(map.containsKey('name'), isFalse);
      expect(map.containsKey('description'), isFalse);

      final restored = Vocabulary.fromMap(map);
      expect(restored.name, 'こんにちは');
      expect(restored.meaning, 'xin chào');
    });

    test('copyWith(kanji:) cập nhật lại name', () {
      expect(kanaOnly.copyWith(kanji: '今日は').name, '今日は');
    });
  });

  group('Quiz kế thừa LearningContent', () {
    const quiz = Quiz(
      id: 'quiz_1',
      lessonId: 'les_1',
      title: 'Kiểm tra chào hỏi',
      description: '5 câu trắc nghiệm',
      questionCount: 5,
      order: 1,
    );

    test('là GenericEntity<String>, title được lưu vào name của lớp cha', () {
      expect(quiz, isA<LearningContent>());
      expect(quiz, isA<GenericEntity<String>>());
      expect(quiz.getName(), 'Kiểm tra chào hỏi');
      expect(quiz.title, quiz.name);
      expect(quiz.toString(), 'Quiz(Kiểm tra chào hỏi)');
    });

    test('toMap() vẫn dùng key title, fromMap() đọc lại đúng', () {
      final map = quiz.toMap();
      expect(map['title'], 'Kiểm tra chào hỏi');
      expect(map.containsKey('name'), isFalse);

      final restored = Quiz.fromMap(map);
      expect(restored.title, quiz.title);
      expect(restored.lessonId, quiz.lessonId);
      expect(restored.questionCount, 5);
    });
  });

  group('User kế thừa GenericEntity<int>', () {
    final user = User(
      id: 7,
      username: 'duy',
      email: 'duy@example.com',
      passwordHash: 'hash',
    );

    test('id có kiểu int, username thành name, email thành description', () {
      expect(user, isA<GenericEntity<int>>());
      expect(user, isNot(isA<LearningContent>()));

      final int id = user.getId();
      expect(id, 7);
      expect(user.getName(), 'duy');
      expect(user.getDescription(), 'duy@example.com');
    });

    test('các phương thức riêng của User vẫn hoạt động', () {
      expect(user.isValidEmail(), isTrue);
      expect(user.getDisplayName(), 'Duy');
      expect(user.matches('example'), isTrue);
      expect(user.toString(), 'User(duy, duy@example.com)');
    });

    test('toMap() giữ key username/email, fromMap() đọc lại đúng', () {
      final map = user.toMap();
      expect(map['username'], 'duy');
      expect(map['email'], 'duy@example.com');
      expect(map.containsKey('name'), isFalse);

      final restored = User.fromMap(map);
      expect(restored.id, 7);
      expect(restored.username, 'duy');
      expect(restored.passwordHash, 'hash');
    });
  });
}
