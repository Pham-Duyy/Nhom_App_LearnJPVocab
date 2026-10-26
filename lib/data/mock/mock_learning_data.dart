import '../../models/category.dart';
import '../../models/lesson.dart';
import '../../models/progress.dart';
import '../../models/vocabulary.dart';

/// Một từ viết gọn trên một dòng:
/// (kanji, kana, romaji, nghĩa, câu ví dụ, nghĩa câu ví dụ).
typedef _WordRow = (String, String, String, String, String, String);

/// Dữ liệu N5 mẫu: nguồn để nạp lên Firestore (xem FirestoreSeeder) và dữ
/// liệu cho test.
class MockLearningData {
  MockLearningData._();

  static const List<Category> categories = [
    Category(
      id: 'cat_greetings',
      name: 'Chào hỏi và giao tiếp',
      description: 'Các mẫu câu chào hỏi và giao tiếp cơ bản hằng ngày.',
      order: 1,
    ),
    Category(
      id: 'cat_family',
      name: 'Gia đình và con người',
      description: 'Từ vựng về thành viên gia đình và mô tả con người.',
      order: 2,
    ),
    Category(
      id: 'cat_school',
      name: 'Trường học và cuộc sống',
      description: 'Đồ dùng học tập và các hoạt động thường ngày ở trường.',
      order: 3,
    ),
    Category(
      id: 'cat_food',
      name: 'Ăn uống',
      description: 'Đồ ăn, thức uống và bữa ăn hằng ngày.',
      order: 4,
    ),
    Category(
      id: 'cat_time',
      name: 'Thời gian',
      description: 'Ngày, tuần và các thời điểm trong ngày.',
      order: 5,
    ),
    Category(
      id: 'cat_shopping',
      name: 'Số đếm và mua sắm',
      description: 'Đếm số, hỏi giá và mua đồ ở cửa hàng.',
      order: 6,
    ),
    Category(
      id: 'cat_places',
      name: 'Nơi chốn và đi lại',
      description: 'Địa điểm trong thành phố và phương tiện giao thông.',
      order: 7,
    ),
    Category(
      id: 'cat_home',
      name: 'Nhà cửa và đồ dùng',
      description: 'Các phòng trong nhà và đồ dùng cá nhân.',
      order: 8,
    ),
    Category(
      id: 'cat_nature',
      name: 'Thời tiết và thiên nhiên',
      description: 'Thời tiết, cảnh vật thiên nhiên và động vật.',
      order: 9,
    ),
  ];

  static const List<Lesson> lessons = [
    Lesson(
      id: 'les_greetings_1',
      categoryId: 'cat_greetings',
      title: 'Chào hỏi cơ bản',
      description: 'Các câu chào hỏi thông dụng nhất trong ngày.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 5,
    ),
    Lesson(
      id: 'les_greetings_2',
      categoryId: 'cat_greetings',
      title: 'Giao tiếp hằng ngày',
      description: 'Hỏi thăm, giới thiệu tên và nghề nghiệp.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 5,
    ),
    Lesson(
      id: 'les_family_1',
      categoryId: 'cat_family',
      title: 'Thành viên gia đình',
      description: 'Cách gọi các thành viên trong gia đình mình.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 5,
    ),
    Lesson(
      id: 'les_family_2',
      categoryId: 'cat_family',
      title: 'Con người và ngoại hình',
      description: 'Từ vựng mô tả con người và đặc điểm ngoại hình.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 5,
    ),
    Lesson(
      id: 'les_school_1',
      categoryId: 'cat_school',
      title: 'Đồ dùng học tập',
      description: 'Tên gọi các vật dụng thường thấy trong lớp học.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 5,
    ),
    Lesson(
      id: 'les_school_2',
      categoryId: 'cat_school',
      title: 'Cuộc sống hằng ngày',
      description: 'Các hoạt động và cảm xúc thường gặp ở trường.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 5,
    ),
    Lesson(
      id: 'les_food_1',
      categoryId: 'cat_food',
      title: 'Đồ ăn thức uống',
      description: 'Tên các món ăn và đồ uống quen thuộc.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_food_2',
      categoryId: 'cat_food',
      title: 'Bữa ăn',
      description: 'Ăn, uống, các bữa trong ngày và hương vị.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_time_1',
      categoryId: 'cat_time',
      title: 'Ngày và tuần',
      description: 'Hôm nay, ngày mai, các thứ trong tuần.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_time_2',
      categoryId: 'cat_time',
      title: 'Trong một ngày',
      description: 'Sáng, trưa, tối và giờ giấc sinh hoạt.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_shopping_1',
      categoryId: 'cat_shopping',
      title: 'Số đếm',
      description: 'Các con số cơ bản và cách đếm đồ vật.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_shopping_2',
      categoryId: 'cat_shopping',
      title: 'Mua sắm',
      description: 'Hỏi giá, đắt rẻ và các món đồ hay mua.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_places_1',
      categoryId: 'cat_places',
      title: 'Địa điểm',
      description: 'Nhà ga, bệnh viện, ngân hàng và các nơi khác.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_places_2',
      categoryId: 'cat_places',
      title: 'Đi lại',
      description: 'Phương tiện giao thông và động từ đi, đến, về.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_home_1',
      categoryId: 'cat_home',
      title: 'Trong nhà',
      description: 'Các phòng và vật dụng trong nhà.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_home_2',
      categoryId: 'cat_home',
      title: 'Đồ dùng cá nhân',
      description: 'Những thứ mang theo người hằng ngày.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_nature_1',
      categoryId: 'cat_nature',
      title: 'Thời tiết',
      description: 'Mưa, nắng, nóng, lạnh và các mùa.',
      jlptLevel: 'N5',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_nature_2',
      categoryId: 'cat_nature',
      title: 'Thiên nhiên và động vật',
      description: 'Núi, sông, biển, cây cối và con vật.',
      jlptLevel: 'N5',
      order: 2,
      vocabularyCount: 10,
    ),
  ];

  static final List<Vocabulary> _vocabulary = [
    const Vocabulary(
      id: 'v_greet_1',
      lessonId: 'les_greetings_1',
      kanji: '',
      kana: 'こんにちは',
      romaji: 'konnichiwa',
      meaning: 'Xin chào (ban ngày)',
      exampleJapanese: 'こんにちは、元気ですか。',
      exampleVietnamese: 'Xin chào, bạn khỏe không?',
      jlptLevel: 'N5',
      order: 1,
    ),
    const Vocabulary(
      id: 'v_greet_2',
      lessonId: 'les_greetings_1',
      kanji: '',
      kana: 'おはようございます',
      romaji: 'ohayou gozaimasu',
      meaning: 'Chào buổi sáng',
      exampleJapanese: 'おはようございます、先生。',
      exampleVietnamese: 'Chào buổi sáng, thầy giáo.',
      jlptLevel: 'N5',
      order: 2,
    ),
    const Vocabulary(
      id: 'v_greet_3',
      lessonId: 'les_greetings_1',
      kanji: '',
      kana: 'こんばんは',
      romaji: 'konbanwa',
      meaning: 'Chào buổi tối',
      exampleJapanese: 'こんばんは、お元気ですか。',
      exampleVietnamese: 'Chào buổi tối, bạn khỏe không?',
      jlptLevel: 'N5',
      order: 3,
    ),
    const Vocabulary(
      id: 'v_greet_4',
      lessonId: 'les_greetings_1',
      kanji: '',
      kana: 'ありがとうございます',
      romaji: 'arigatou gozaimasu',
      meaning: 'Cảm ơn',
      exampleJapanese: '手伝ってくれてありがとうございます。',
      exampleVietnamese: 'Cảm ơn bạn đã giúp đỡ.',
      jlptLevel: 'N5',
      order: 4,
    ),
    const Vocabulary(
      id: 'v_greet_5',
      lessonId: 'les_greetings_1',
      kanji: '',
      kana: 'すみません',
      romaji: 'sumimasen',
      meaning: 'Xin lỗi / Xin phép',
      exampleJapanese: 'すみません、今何時ですか。',
      exampleVietnamese: 'Xin lỗi, bây giờ là mấy giờ?',
      jlptLevel: 'N5',
      order: 5,
    ),
    const Vocabulary(
      id: 'v_greet_6',
      lessonId: 'les_greetings_2',
      kanji: '',
      kana: 'さようなら',
      romaji: 'sayounara',
      meaning: 'Tạm biệt',
      exampleJapanese: 'さようなら、また明日。',
      exampleVietnamese: 'Tạm biệt, hẹn gặp lại ngày mai.',
      jlptLevel: 'N5',
      order: 1,
    ),
    const Vocabulary(
      id: 'v_greet_7',
      lessonId: 'les_greetings_2',
      kanji: '元気',
      kana: 'げんき',
      romaji: 'genki',
      meaning: 'Khỏe mạnh',
      exampleJapanese: '元気ですか。はい、元気です。',
      exampleVietnamese: 'Bạn khỏe không? Vâng, tôi khỏe.',
      jlptLevel: 'N5',
      order: 2,
    ),
    const Vocabulary(
      id: 'v_greet_8',
      lessonId: 'les_greetings_2',
      kanji: '名前',
      kana: 'なまえ',
      romaji: 'namae',
      meaning: 'Tên',
      exampleJapanese: 'お名前は何ですか。',
      exampleVietnamese: 'Tên bạn là gì?',
      jlptLevel: 'N5',
      order: 3,
    ),
    const Vocabulary(
      id: 'v_greet_9',
      lessonId: 'les_greetings_2',
      kanji: '学生',
      kana: 'がくせい',
      romaji: 'gakusei',
      meaning: 'Học sinh / sinh viên',
      exampleJapanese: '私は学生です。',
      exampleVietnamese: 'Tôi là học sinh.',
      jlptLevel: 'N5',
      order: 4,
    ),
    const Vocabulary(
      id: 'v_greet_10',
      lessonId: 'les_greetings_2',
      kanji: '先生',
      kana: 'せんせい',
      romaji: 'sensei',
      meaning: 'Giáo viên / thầy cô',
      exampleJapanese: '山田先生はやさしいです。',
      exampleVietnamese: 'Thầy Yamada rất hiền.',
      jlptLevel: 'N5',
      order: 5,
    ),
    const Vocabulary(
      id: 'v_family_1',
      lessonId: 'les_family_1',
      kanji: '家族',
      kana: 'かぞく',
      romaji: 'kazoku',
      meaning: 'Gia đình',
      exampleJapanese: '私の家族は四人です。',
      exampleVietnamese: 'Gia đình tôi có bốn người.',
      jlptLevel: 'N5',
      order: 1,
    ),
    const Vocabulary(
      id: 'v_family_2',
      lessonId: 'les_family_1',
      kanji: '父',
      kana: 'ちち',
      romaji: 'chichi',
      meaning: 'Bố (của mình)',
      exampleJapanese: '父は会社員です。',
      exampleVietnamese: 'Bố tôi là nhân viên công ty.',
      jlptLevel: 'N5',
      order: 2,
    ),
    const Vocabulary(
      id: 'v_family_3',
      lessonId: 'les_family_1',
      kanji: '母',
      kana: 'はは',
      romaji: 'haha',
      meaning: 'Mẹ (của mình)',
      exampleJapanese: '母は料理が上手です。',
      exampleVietnamese: 'Mẹ tôi nấu ăn giỏi.',
      jlptLevel: 'N5',
      order: 3,
    ),
    const Vocabulary(
      id: 'v_family_4',
      lessonId: 'les_family_1',
      kanji: '兄',
      kana: 'あに',
      romaji: 'ani',
      meaning: 'Anh trai',
      exampleJapanese: '兄は大学生です。',
      exampleVietnamese: 'Anh trai tôi là sinh viên đại học.',
      jlptLevel: 'N5',
      order: 4,
    ),
    const Vocabulary(
      id: 'v_family_5',
      lessonId: 'les_family_1',
      kanji: '妹',
      kana: 'いもうと',
      romaji: 'imouto',
      meaning: 'Em gái',
      exampleJapanese: '妹は高校生です。',
      exampleVietnamese: 'Em gái tôi là học sinh cấp ba.',
      jlptLevel: 'N5',
      order: 5,
    ),
    const Vocabulary(
      id: 'v_family_6',
      lessonId: 'les_family_2',
      kanji: '友達',
      kana: 'ともだち',
      romaji: 'tomodachi',
      meaning: 'Bạn bè',
      exampleJapanese: '友達と映画を見ます。',
      exampleVietnamese: 'Tôi xem phim với bạn bè.',
      jlptLevel: 'N5',
      order: 1,
    ),
    const Vocabulary(
      id: 'v_family_7',
      lessonId: 'les_family_2',
      kanji: '子供',
      kana: 'こども',
      romaji: 'kodomo',
      meaning: 'Trẻ em',
      exampleJapanese: '公園に子供がたくさんいます。',
      exampleVietnamese: 'Có nhiều trẻ em ở công viên.',
      jlptLevel: 'N5',
      order: 2,
    ),
    const Vocabulary(
      id: 'v_family_8',
      lessonId: 'les_family_2',
      kanji: '男の人',
      kana: 'おとこのひと',
      romaji: 'otoko no hito',
      meaning: 'Người đàn ông',
      exampleJapanese: 'あの男の人は医者です。',
      exampleVietnamese: 'Người đàn ông đó là bác sĩ.',
      jlptLevel: 'N5',
      order: 3,
    ),
    const Vocabulary(
      id: 'v_family_9',
      lessonId: 'les_family_2',
      kanji: '女の人',
      kana: 'おんなのひと',
      romaji: 'onna no hito',
      meaning: 'Người phụ nữ',
      exampleJapanese: 'この女の人は先生です。',
      exampleVietnamese: 'Người phụ nữ này là giáo viên.',
      jlptLevel: 'N5',
      order: 4,
    ),
    const Vocabulary(
      id: 'v_family_10',
      lessonId: 'les_family_2',
      kanji: '背が高い',
      kana: 'せがたかい',
      romaji: 'se ga takai',
      meaning: 'Cao (chiều cao)',
      exampleJapanese: '兄は背が高いです。',
      exampleVietnamese: 'Anh trai tôi cao.',
      jlptLevel: 'N5',
      order: 5,
    ),
    const Vocabulary(
      id: 'v_school_1',
      lessonId: 'les_school_1',
      kanji: '本',
      kana: 'ほん',
      romaji: 'hon',
      meaning: 'Sách',
      exampleJapanese: '図書館で本を読みます。',
      exampleVietnamese: 'Tôi đọc sách ở thư viện.',
      jlptLevel: 'N5',
      order: 1,
    ),
    const Vocabulary(
      id: 'v_school_2',
      lessonId: 'les_school_1',
      kanji: '鉛筆',
      kana: 'えんぴつ',
      romaji: 'enpitsu',
      meaning: 'Bút chì',
      exampleJapanese: '鉛筆で名前を書きます。',
      exampleVietnamese: 'Tôi viết tên bằng bút chì.',
      jlptLevel: 'N5',
      order: 2,
    ),
    const Vocabulary(
      id: 'v_school_3',
      lessonId: 'les_school_1',
      kanji: '教科書',
      kana: 'きょうかしょ',
      romaji: 'kyoukasho',
      meaning: 'Sách giáo khoa',
      exampleJapanese: '教科書を忘れました。',
      exampleVietnamese: 'Tôi quên sách giáo khoa.',
      jlptLevel: 'N5',
      order: 3,
    ),
    const Vocabulary(
      id: 'v_school_4',
      lessonId: 'les_school_1',
      kanji: '机',
      kana: 'つくえ',
      romaji: 'tsukue',
      meaning: 'Cái bàn',
      exampleJapanese: '机の上に本があります。',
      exampleVietnamese: 'Có một cuốn sách trên bàn.',
      jlptLevel: 'N5',
      order: 4,
    ),
    const Vocabulary(
      id: 'v_school_5',
      lessonId: 'les_school_1',
      kanji: '椅子',
      kana: 'いす',
      romaji: 'isu',
      meaning: 'Cái ghế',
      exampleJapanese: '椅子に座ってください。',
      exampleVietnamese: 'Xin hãy ngồi xuống ghế.',
      jlptLevel: 'N5',
      order: 5,
    ),
    const Vocabulary(
      id: 'v_school_6',
      lessonId: 'les_school_2',
      kanji: '学校',
      kana: 'がっこう',
      romaji: 'gakkou',
      meaning: 'Trường học',
      exampleJapanese: '毎日学校へ行きます。',
      exampleVietnamese: 'Tôi đến trường mỗi ngày.',
      jlptLevel: 'N5',
      order: 1,
    ),
    const Vocabulary(
      id: 'v_school_7',
      lessonId: 'les_school_2',
      kanji: '勉強する',
      kana: 'べんきょうする',
      romaji: 'benkyou suru',
      meaning: 'Học tập',
      exampleJapanese: '毎晩日本語を勉強します。',
      exampleVietnamese: 'Tôi học tiếng Nhật mỗi tối.',
      jlptLevel: 'N5',
      order: 2,
    ),
    const Vocabulary(
      id: 'v_school_8',
      lessonId: 'les_school_2',
      kanji: '宿題',
      kana: 'しゅくだい',
      romaji: 'shukudai',
      meaning: 'Bài tập về nhà',
      exampleJapanese: '宿題がたくさんあります。',
      exampleVietnamese: 'Có rất nhiều bài tập về nhà.',
      jlptLevel: 'N5',
      order: 3,
    ),
    const Vocabulary(
      id: 'v_school_9',
      lessonId: 'les_school_2',
      kanji: '忙しい',
      kana: 'いそがしい',
      romaji: 'isogashii',
      meaning: 'Bận rộn',
      exampleJapanese: '今週はとても忙しいです。',
      exampleVietnamese: 'Tuần này tôi rất bận.',
      jlptLevel: 'N5',
      order: 4,
    ),
    const Vocabulary(
      id: 'v_school_10',
      lessonId: 'les_school_2',
      kanji: '楽しい',
      kana: 'たのしい',
      romaji: 'tanoshii',
      meaning: 'Vui vẻ',
      exampleJapanese: '学校生活は楽しいです。',
      exampleVietnamese: 'Cuộc sống ở trường rất vui.',
      jlptLevel: 'N5',
      order: 5,
    ),
    ..._lessonWords('food', 'les_food_1', 1, const [
      ('水', 'みず', 'mizu', 'Nước', '水を飲みます。', 'Tôi uống nước.'),
      ('お茶', 'おちゃ', 'ocha', 'Trà', '毎朝お茶を飲みます。', 'Sáng nào tôi cũng uống trà.'),
      (
        'ご飯',
        'ごはん',
        'gohan',
        'Cơm / bữa ăn',
        'ご飯を食べましょう。',
        'Chúng ta ăn cơm thôi.'
      ),
      ('肉', 'にく', 'niku', 'Thịt', '肉が好きです。', 'Tôi thích thịt.'),
      ('魚', 'さかな', 'sakana', 'Cá', '魚を食べます。', 'Tôi ăn cá.'),
      ('野菜', 'やさい', 'yasai', 'Rau', '野菜を買いました。', 'Tôi đã mua rau.'),
      ('果物', 'くだもの', 'kudamono', 'Hoa quả', '果物はおいしいです。', 'Hoa quả rất ngon.'),
      ('卵', 'たまご', 'tamago', 'Trứng', '卵を二つください。', 'Cho tôi hai quả trứng.'),
      ('', 'パン', 'pan', 'Bánh mì', '朝はパンを食べます。', 'Buổi sáng tôi ăn bánh mì.'),
      (
        '牛乳',
        'ぎゅうにゅう',
        'gyuunyuu',
        'Sữa bò',
        '牛乳を飲みますか。',
        'Bạn có uống sữa không?'
      ),
    ]),
    ..._lessonWords('food', 'les_food_2', 11, const [
      (
        '食べる',
        'たべる',
        'taberu',
        'Ăn',
        '一緒に昼ご飯を食べます。',
        'Chúng tôi ăn trưa cùng nhau.'
      ),
      ('飲む', 'のむ', 'nomu', 'Uống', 'コーヒーを飲みます。', 'Tôi uống cà phê.'),
      (
        '朝ご飯',
        'あさごはん',
        'asagohan',
        'Bữa sáng',
        '七時に朝ご飯を食べます。',
        'Tôi ăn sáng lúc 7 giờ.'
      ),
      (
        '晩ご飯',
        'ばんごはん',
        'bangohan',
        'Bữa tối',
        '家族と晩ご飯を食べます。',
        'Tôi ăn tối cùng gia đình.'
      ),
      (
        '',
        'レストラン',
        'resutoran',
        'Nhà hàng',
        '駅の近くにレストランがあります。',
        'Gần nhà ga có một nhà hàng.'
      ),
      ('', 'おいしい', 'oishii', 'Ngon', 'このケーキはおいしいです。', 'Cái bánh này ngon.'),
      ('甘い', 'あまい', 'amai', 'Ngọt', 'このりんごは甘いです。', 'Quả táo này ngọt.'),
      ('辛い', 'からい', 'karai', 'Cay', 'このカレーは少し辛いです。', 'Món cà ri này hơi cay.'),
      ('お腹', 'おなか', 'onaka', 'Bụng', 'お腹が空きました。', 'Tôi đói bụng rồi.'),
      ('箸', 'はし', 'hashi', 'Đũa', '箸でご飯を食べます。', 'Tôi ăn cơm bằng đũa.'),
    ]),
    ..._lessonWords('time', 'les_time_1', 1, const [
      ('今日', 'きょう', 'kyou', 'Hôm nay', '今日は何曜日ですか。', 'Hôm nay là thứ mấy?'),
      ('明日', 'あした', 'ashita', 'Ngày mai', '明日学校へ行きます。', 'Ngày mai tôi đi học.'),
      (
        '昨日',
        'きのう',
        'kinou',
        'Hôm qua',
        '昨日映画を見ました。',
        'Hôm qua tôi đã xem phim.'
      ),
      (
        '毎日',
        'まいにち',
        'mainichi',
        'Mỗi ngày',
        '毎日日本語を勉強します。',
        'Ngày nào tôi cũng học tiếng Nhật.'
      ),
      (
        '今週',
        'こんしゅう',
        'konshuu',
        'Tuần này',
        '今週はとても忙しいです。',
        'Tuần này rất bận.'
      ),
      (
        '来週',
        'らいしゅう',
        'raishuu',
        'Tuần sau',
        '来週テストがあります。',
        'Tuần sau có bài kiểm tra.'
      ),
      (
        '月曜日',
        'げつようび',
        'getsuyoubi',
        'Thứ Hai',
        '月曜日から仕事です。',
        'Từ thứ Hai tôi đi làm.'
      ),
      (
        '日曜日',
        'にちようび',
        'nichiyoubi',
        'Chủ nhật',
        '日曜日に友達と会います。',
        'Chủ nhật tôi gặp bạn.'
      ),
      (
        '誕生日',
        'たんじょうび',
        'tanjoubi',
        'Sinh nhật',
        '誕生日はいつですか。',
        'Sinh nhật bạn là khi nào?'
      ),
      (
        '休み',
        'やすみ',
        'yasumi',
        'Ngày nghỉ',
        '明日は休みです。',
        'Ngày mai là ngày nghỉ.'
      ),
    ]),
    ..._lessonWords('time', 'les_time_2', 11, const [
      (
        '朝',
        'あさ',
        'asa',
        'Buổi sáng',
        '朝はコーヒーを飲みます。',
        'Buổi sáng tôi uống cà phê.'
      ),
      ('昼', 'ひる', 'hiru', 'Buổi trưa', '昼に友達と会います。', 'Buổi trưa tôi gặp bạn.'),
      (
        '夜',
        'よる',
        'yoru',
        'Buổi tối / ban đêm',
        '夜は本を読みます。',
        'Buổi tối tôi đọc sách.'
      ),
      ('今', 'いま', 'ima', 'Bây giờ', '今何時ですか。', 'Bây giờ là mấy giờ?'),
      (
        '時間',
        'じかん',
        'jikan',
        'Thời gian',
        '時間がありません。',
        'Tôi không có thời gian.'
      ),
      (
        '午前',
        'ごぜん',
        'gozen',
        'Sáng (trước 12 giờ trưa)',
        '授業は午前九時に始まります。',
        'Giờ học bắt đầu lúc 9 giờ sáng.'
      ),
      (
        '午後',
        'ごご',
        'gogo',
        'Chiều (sau 12 giờ trưa)',
        '午後は図書館へ行きます。',
        'Buổi chiều tôi đi thư viện.'
      ),
      (
        '起きる',
        'おきる',
        'okiru',
        'Thức dậy',
        '毎朝六時に起きます。',
        'Sáng nào tôi cũng dậy lúc 6 giờ.'
      ),
      ('寝る', 'ねる', 'neru', 'Đi ngủ', '夜十一時に寝ます。', 'Tôi đi ngủ lúc 11 giờ đêm.'),
      ('早い', 'はやい', 'hayai', 'Sớm', '父は朝が早いです。', 'Bố tôi dậy sớm.'),
    ]),
    ..._lessonWords('shopping', 'les_shopping_1', 1, const [
      ('一', 'いち', 'ichi', 'Số 1', '一月はとても寒いです。', 'Tháng Một rất lạnh.'),
      ('二', 'に', 'ni', 'Số 2', '二時に会いましょう。', 'Hẹn gặp nhau lúc 2 giờ nhé.'),
      ('三', 'さん', 'san', 'Số 3', '三人で行きます。', 'Ba người cùng đi.'),
      ('五', 'ご', 'go', 'Số 5', '毎日五時間勉強します。', 'Mỗi ngày tôi học 5 tiếng.'),
      ('十', 'じゅう', 'juu', 'Số 10', '教室に学生が十人います。', 'Trong lớp có 10 học sinh.'),
      (
        '百',
        'ひゃく',
        'hyaku',
        'Một trăm',
        'このペンは百円です。',
        'Cái bút này giá 100 yên.'
      ),
      ('千', 'せん', 'sen', 'Một nghìn', '千円あります。', 'Tôi có 1000 yên.'),
      (
        '万',
        'まん',
        'man',
        'Mười nghìn (một vạn)',
        'この時計は一万円です。',
        'Chiếc đồng hồ này giá 10.000 yên.'
      ),
      (
        '一つ',
        'ひとつ',
        'hitotsu',
        'Một cái',
        'りんごを一つください。',
        'Cho tôi một quả táo.'
      ),
      ('何', 'なに', 'nani', 'Cái gì', '何を食べますか。', 'Bạn ăn gì?'),
    ]),
    ..._lessonWords('shopping', 'les_shopping_2', 11, const [
      ('店', 'みせ', 'mise', 'Cửa hàng', 'あの店は安いです。', 'Cửa hàng kia bán rẻ.'),
      ('買う', 'かう', 'kau', 'Mua', '新しい靴を買いました。', 'Tôi đã mua giày mới.'),
      ('高い', 'たかい', 'takai', 'Đắt (giá)', 'このかばんは高いです。', 'Cái túi này đắt.'),
      ('安い', 'やすい', 'yasui', 'Rẻ', 'この店の野菜は安いです。', 'Rau ở cửa hàng này rẻ.'),
      ('お金', 'おかね', 'okane', 'Tiền', 'お金がありません。', 'Tôi không có tiền.'),
      ('円', 'えん', 'en', 'Yên (tiền Nhật)', '全部で五百円です。', 'Tất cả là 500 yên.'),
      (
        '',
        'いくら',
        'ikura',
        'Bao nhiêu tiền',
        'これはいくらですか。',
        'Cái này bao nhiêu tiền?'
      ),
      (
        '服',
        'ふく',
        'fuku',
        'Quần áo',
        'デパートで服を買います。',
        'Tôi mua quần áo ở trung tâm thương mại.'
      ),
      ('靴', 'くつ', 'kutsu', 'Giày', 'この靴は大きいです。', 'Đôi giày này to.'),
      (
        '',
        'かばん',
        'kaban',
        'Cặp / túi xách',
        'かばんの中に本があります。',
        'Trong cặp có sách.'
      ),
    ]),
    ..._lessonWords('places', 'les_places_1', 1, const [
      ('駅', 'えき', 'eki', 'Nhà ga', '駅はどこですか。', 'Nhà ga ở đâu?'),
      ('病院', 'びょういん', 'byouin', 'Bệnh viện', '病院へ行きます。', 'Tôi đi bệnh viện.'),
      (
        '銀行',
        'ぎんこう',
        'ginkou',
        'Ngân hàng',
        '銀行は九時からです。',
        'Ngân hàng mở cửa từ 9 giờ.'
      ),
      (
        '郵便局',
        'ゆうびんきょく',
        'yuubinkyoku',
        'Bưu điện',
        '郵便局で切手を買います。',
        'Tôi mua tem ở bưu điện.'
      ),
      (
        '図書館',
        'としょかん',
        'toshokan',
        'Thư viện',
        '図書館で勉強します。',
        'Tôi học ở thư viện.'
      ),
      (
        '公園',
        'こうえん',
        'kouen',
        'Công viên',
        '公園を散歩します。',
        'Tôi đi dạo trong công viên.'
      ),
      (
        '会社',
        'かいしゃ',
        'kaisha',
        'Công ty',
        '兄は会社で働いています。',
        'Anh trai tôi làm việc ở công ty.'
      ),
      ('家', 'いえ', 'ie', 'Nhà', 'あれは私の家です。', 'Kia là nhà của tôi.'),
      ('国', 'くに', 'kuni', 'Đất nước', 'お国はどちらですか。', 'Bạn đến từ nước nào?'),
      (
        '道',
        'みち',
        'michi',
        'Con đường',
        'この道をまっすぐ行ってください。',
        'Hãy đi thẳng con đường này.'
      ),
    ]),
    ..._lessonWords('places', 'les_places_2', 11, const [
      (
        '電車',
        'でんしゃ',
        'densha',
        'Tàu điện',
        '電車で学校へ行きます。',
        'Tôi đi học bằng tàu điện.'
      ),
      ('車', 'くるま', 'kuruma', 'Ô tô', '父の車は白いです。', 'Ô tô của bố tôi màu trắng.'),
      (
        '自転車',
        'じてんしゃ',
        'jitensha',
        'Xe đạp',
        '自転車で公園へ行きます。',
        'Tôi đi xe đạp đến công viên.'
      ),
      ('', 'バス', 'basu', 'Xe buýt', 'バスを待っています。', 'Tôi đang đợi xe buýt.'),
      (
        '飛行機',
        'ひこうき',
        'hikouki',
        'Máy bay',
        '飛行機で日本へ行きます。',
        'Tôi đi Nhật bằng máy bay.'
      ),
      (
        '',
        'タクシー',
        'takushii',
        'Taxi',
        '駅までタクシーで行きます。',
        'Tôi đi taxi đến nhà ga.'
      ),
      ('乗る', 'のる', 'noru', 'Lên (xe, tàu)', 'バスに乗ります。', 'Tôi lên xe buýt.'),
      ('行く', 'いく', 'iku', 'Đi', '明日、東京へ行きます。', 'Ngày mai tôi đi Tokyo.'),
      ('来る', 'くる', 'kuru', 'Đến', '友達が家に来ます。', 'Bạn tôi đến nhà.'),
      (
        '帰る',
        'かえる',
        'kaeru',
        'Về (nhà, nước)',
        '六時に家へ帰ります。',
        'Tôi về nhà lúc 6 giờ.'
      ),
    ]),
    ..._lessonWords('home', 'les_home_1', 1, const [
      ('部屋', 'へや', 'heya', 'Căn phòng', '私の部屋は狭いです。', 'Phòng của tôi chật.'),
      ('窓', 'まど', 'mado', 'Cửa sổ', '窓を開けてください。', 'Hãy mở cửa sổ ra.'),
      ('', 'ドア', 'doa', 'Cửa ra vào', 'ドアを閉めてください。', 'Hãy đóng cửa lại.'),
      (
        '台所',
        'だいどころ',
        'daidokoro',
        'Nhà bếp',
        '母は台所にいます。',
        'Mẹ tôi đang ở trong bếp.'
      ),
      (
        'お風呂',
        'おふろ',
        'ofuro',
        'Bồn tắm',
        '夜、お風呂に入ります。',
        'Buổi tối tôi tắm bồn.'
      ),
      (
        '冷蔵庫',
        'れいぞうこ',
        'reizouko',
        'Tủ lạnh',
        '冷蔵庫に牛乳があります。',
        'Trong tủ lạnh có sữa.'
      ),
      (
        '',
        'テレビ',
        'terebi',
        'Tivi',
        '晩ご飯の後でテレビを見ます。',
        'Sau bữa tối tôi xem tivi.'
      ),
      ('電気', 'でんき', 'denki', 'Đèn điện', '電気をつけてください。', 'Hãy bật đèn lên.'),
      ('時計', 'とけい', 'tokei', 'Đồng hồ', '時計を見てください。', 'Hãy nhìn đồng hồ.'),
      (
        '階段',
        'かいだん',
        'kaidan',
        'Cầu thang',
        '階段で二階へ行きます。',
        'Tôi đi cầu thang lên tầng 2.'
      ),
    ]),
    ..._lessonWords('home', 'les_home_2', 11, const [
      (
        '傘',
        'かさ',
        'kasa',
        'Cái ô',
        '雨ですから、傘を持って行きます。',
        'Trời mưa nên tôi mang ô.'
      ),
      (
        '鍵',
        'かぎ',
        'kagi',
        'Chìa khóa',
        '鍵をなくしました。',
        'Tôi làm mất chìa khóa rồi.'
      ),
      (
        '財布',
        'さいふ',
        'saifu',
        'Ví tiền',
        '財布にお金がありません。',
        'Trong ví không có tiền.'
      ),
      (
        '眼鏡',
        'めがね',
        'megane',
        'Kính mắt',
        '兄は眼鏡をかけています。',
        'Anh trai tôi đeo kính.'
      ),
      ('帽子', 'ぼうし', 'boushi', 'Cái mũ', '赤い帽子をかぶります。', 'Tôi đội mũ đỏ.'),
      (
        '写真',
        'しゃしん',
        'shashin',
        'Bức ảnh',
        '家族の写真を撮ります。',
        'Tôi chụp ảnh gia đình.'
      ),
      ('手紙', 'てがみ', 'tegami', 'Lá thư', '母に手紙を書きます。', 'Tôi viết thư cho mẹ.'),
      (
        '電話',
        'でんわ',
        'denwa',
        'Điện thoại',
        '夜、友達に電話をかけます。',
        'Buổi tối tôi gọi điện cho bạn.'
      ),
      (
        '新聞',
        'しんぶん',
        'shinbun',
        'Báo',
        '父は毎朝新聞を読みます。',
        'Sáng nào bố tôi cũng đọc báo.'
      ),
      ('切手', 'きって', 'kitte', 'Tem thư', '切手を三枚ください。', 'Cho tôi ba con tem.'),
    ]),
    ..._lessonWords('nature', 'les_nature_1', 1, const [
      (
        '天気',
        'てんき',
        'tenki',
        'Thời tiết',
        '今日はいい天気ですね。',
        'Hôm nay thời tiết đẹp nhỉ.'
      ),
      ('雨', 'あめ', 'ame', 'Mưa', '雨が降っています。', 'Trời đang mưa.'),
      ('雪', 'ゆき', 'yuki', 'Tuyết', '冬は雪が降ります。', 'Mùa đông có tuyết rơi.'),
      ('風', 'かぜ', 'kaze', 'Gió', '今日は風が強いです。', 'Hôm nay gió mạnh.'),
      (
        '暑い',
        'あつい',
        'atsui',
        'Nóng (thời tiết)',
        '夏はとても暑いです。',
        'Mùa hè rất nóng.'
      ),
      ('寒い', 'さむい', 'samui', 'Lạnh (thời tiết)', '冬は寒いです。', 'Mùa đông lạnh.'),
      ('暖かい', 'あたたかい', 'atatakai', 'Ấm áp', '春は暖かいです。', 'Mùa xuân ấm áp.'),
      ('涼しい', 'すずしい', 'suzushii', 'Mát mẻ', '秋は涼しいです。', 'Mùa thu mát mẻ.'),
      (
        '晴れ',
        'はれ',
        'hare',
        'Trời nắng',
        '明日は晴れでしょう。',
        'Ngày mai có lẽ trời nắng.'
      ),
      (
        '曇り',
        'くもり',
        'kumori',
        'Trời nhiều mây',
        '今日は一日中曇りです。',
        'Hôm nay trời nhiều mây cả ngày.'
      ),
    ]),
    ..._lessonWords('nature', 'les_nature_2', 11, const [
      (
        '山',
        'やま',
        'yama',
        'Núi',
        '富士山は日本で一番高い山です。',
        'Núi Phú Sĩ là ngọn núi cao nhất Nhật Bản.'
      ),
      ('川', 'かわ', 'kawa', 'Sông', '川で泳ぎます。', 'Tôi bơi ở sông.'),
      ('海', 'うみ', 'umi', 'Biển', '夏休みに海へ行きます。', 'Kỳ nghỉ hè tôi đi biển.'),
      ('空', 'そら', 'sora', 'Bầu trời', '空が青いです。', 'Bầu trời xanh.'),
      (
        '花',
        'はな',
        'hana',
        'Hoa',
        '公園に花がたくさんあります。',
        'Công viên có rất nhiều hoa.'
      ),
      ('木', 'き', 'ki', 'Cây', '庭に大きい木があります。', 'Trong vườn có một cái cây to.'),
      ('犬', 'いぬ', 'inu', 'Con chó', '犬が好きです。', 'Tôi thích chó.'),
      ('猫', 'ねこ', 'neko', 'Con mèo', '家に猫が二匹います。', 'Nhà tôi có hai con mèo.'),
      ('鳥', 'とり', 'tori', 'Con chim', '鳥が飛んでいます。', 'Chim đang bay.'),
      (
        '動物',
        'どうぶつ',
        'doubutsu',
        'Động vật',
        'どんな動物が好きですか。',
        'Bạn thích con vật nào?'
      ),
    ]),
  ];

  /// Sinh từ vựng cho một bài từ danh sách dòng gọn. Id nối tiếp theo chủ đề
  /// ([start] là số thứ tự của từ đầu tiên, vd. 'v_food_11'); order đếm lại từ
  /// 1 trong mỗi bài.
  static List<Vocabulary> _lessonWords(
    String topic,
    String lessonId,
    int start,
    List<_WordRow> rows,
  ) {
    return [
      for (final (i, (kanji, kana, romaji, meaning, exampleJp, exampleVi))
          in rows.indexed)
        Vocabulary(
          id: 'v_${topic}_${start + i}',
          lessonId: lessonId,
          kanji: kanji,
          kana: kana,
          romaji: romaji,
          meaning: meaning,
          exampleJapanese: exampleJp,
          exampleVietnamese: exampleVi,
          jlptLevel: 'N5',
          order: i + 1,
        ),
    ];
  }

  /// Toàn bộ từ vựng mẫu, xếp theo bài.
  static List<Vocabulary> get vocabulary => _vocabulary;

  /// Sinh 9 Progress mẫu (phân bố mức 3-3-1-1-1, tất cả đã học) để trang chủ
  /// và phiên ôn tập có dữ liệu ngay khi mở app, trước khi có Firestore.
  ///
  /// Đúng 3 từ (mức 1) đến hạn ôn tại thời điểm [now]; 6 từ còn lại có lịch
  /// ôn nằm trong tương lai. Nhận [now] qua tham số thay vì hard-code một
  /// ngày cụ thể, để test có thể dùng một mốc thời gian cố định.
  static List<Progress> createInitialProgress({DateTime? now}) {
    final reference = now ?? DateTime.now();

    Progress buildProgress({
      required String vocabularyId,
      required int memoryLevel,
      required Duration reviewedAgo,
    }) {
      final lastReviewedAt = reference.subtract(reviewedAgo);
      return Progress(
        vocabularyId: vocabularyId,
        memoryLevel: memoryLevel,
        correctCount: 1,
        reviewCount: 1,
        isLearned: true,
        lastReviewedAt: lastReviewedAt,
        nextReviewAt: lastReviewedAt.add(
          Duration(days: Progress.reviewIntervalDays[memoryLevel]!),
        ),
      );
    }

    return [
      buildProgress(
        vocabularyId: 'v_greet_1',
        memoryLevel: 1,
        reviewedAgo: const Duration(days: 2),
      ),
      buildProgress(
        vocabularyId: 'v_greet_2',
        memoryLevel: 1,
        reviewedAgo: const Duration(days: 2),
      ),
      buildProgress(
        vocabularyId: 'v_greet_3',
        memoryLevel: 1,
        reviewedAgo: const Duration(days: 2),
      ),
      buildProgress(
        vocabularyId: 'v_greet_6',
        memoryLevel: 2,
        reviewedAgo: const Duration(days: 1),
      ),
      buildProgress(
        vocabularyId: 'v_family_1',
        memoryLevel: 2,
        reviewedAgo: const Duration(days: 1),
      ),
      buildProgress(
        vocabularyId: 'v_family_2',
        memoryLevel: 2,
        reviewedAgo: const Duration(days: 1),
      ),
      buildProgress(
        vocabularyId: 'v_family_6',
        memoryLevel: 3,
        reviewedAgo: const Duration(days: 2),
      ),
      buildProgress(
        vocabularyId: 'v_school_1',
        memoryLevel: 4,
        reviewedAgo: const Duration(days: 3),
      ),
      buildProgress(
        vocabularyId: 'v_school_6',
        memoryLevel: 5,
        reviewedAgo: const Duration(days: 5),
      ),
    ];
  }
}
