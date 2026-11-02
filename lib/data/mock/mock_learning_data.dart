import '../../models/category.dart';
import '../../models/lesson.dart';
import '../../models/progress.dart';
import '../../models/vocabulary.dart';

/// Một từ viết gọn trên một dòng:
/// (kanji, kana, romaji, nghĩa, câu ví dụ, nghĩa câu ví dụ).
typedef _WordRow = (String, String, String, String, String, String);

/// Dữ liệu mẫu N5, N4, N3 và từ vựng ngành: nguồn để nạp lên Firestore (xem
/// FirestoreSeeder) và dữ liệu cho test.
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
    Category(
      id: 'cat_ind_food',
      name: 'Chế biến thực phẩm',
      description: 'Vệ sinh, dây chuyền và kiểm hàng ở nhà máy thực phẩm.',
      jlptLevel: Category.industryLevel,
      order: 10,
    ),
    Category(
      id: 'cat_ind_build',
      name: 'Xây dựng',
      description: 'An toàn lao động, vật liệu và dụng cụ ở công trường.',
      jlptLevel: Category.industryLevel,
      order: 11,
    ),
    Category(
      id: 'cat_ind_care',
      name: 'Điều dưỡng (Kaigo)',
      description: 'Chăm sóc người cao tuổi, sức khỏe và ghi chép hằng ngày.',
      jlptLevel: Category.industryLevel,
      order: 12,
    ),
    Category(
      id: 'cat_n4_work',
      name: 'Công việc và công ty',
      description: 'Đi làm, lương thưởng, họp hành và liên lạc trong công ty.',
      jlptLevel: 'N4',
      order: 13,
    ),
    Category(
      id: 'cat_n4_health',
      name: 'Sức khỏe và cơ thể',
      description: 'Các bộ phận cơ thể và từ vựng khi đi khám bệnh.',
      jlptLevel: 'N4',
      order: 14,
    ),
    Category(
      id: 'cat_n4_travel',
      name: 'Du lịch và giao thông',
      description: 'Đặt chỗ, tham quan và đi lại trên đường.',
      jlptLevel: 'N4',
      order: 15,
    ),
    Category(
      id: 'cat_n3_society',
      name: 'Xã hội và tin tức',
      description: 'Tin tức thời sự, môi trường và thiên tai.',
      jlptLevel: 'N3',
      order: 16,
    ),
    Category(
      id: 'cat_n3_feelings',
      name: 'Cảm xúc và tính cách',
      description: 'Diễn tả cảm xúc và nhận xét tính cách con người.',
      jlptLevel: 'N3',
      order: 17,
    ),
    Category(
      id: 'cat_n3_life',
      name: 'Đời sống và thủ tục',
      description: 'Giấy tờ hành chính, thuê nhà và sống cùng hàng xóm.',
      jlptLevel: 'N3',
      order: 18,
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
    Lesson(
      id: 'les_ind_food_1',
      categoryId: 'cat_ind_food',
      title: 'Nhà xưởng và vệ sinh',
      description: 'Quy tắc vệ sinh trước và trong khi làm việc.',
      jlptLevel: Category.industryLevel,
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_ind_food_2',
      categoryId: 'cat_ind_food',
      title: 'Dây chuyền sản xuất',
      description: 'Nguyên liệu, gia nhiệt, đóng gói và xuất hàng.',
      jlptLevel: Category.industryLevel,
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_ind_build_1',
      categoryId: 'cat_ind_build',
      title: 'Công trường và an toàn',
      description: 'Đồ bảo hộ, biển báo và họp đầu giờ.',
      jlptLevel: Category.industryLevel,
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_ind_build_2',
      categoryId: 'cat_ind_build',
      title: 'Vật liệu và dụng cụ',
      description: 'Gỗ, thép, bê tông và các việc tay chân.',
      jlptLevel: Category.industryLevel,
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_ind_care_1',
      categoryId: 'cat_ind_care',
      title: 'Chăm sóc hằng ngày',
      description: 'Ăn uống, tắm, thay đồ và đi lại.',
      jlptLevel: Category.industryLevel,
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_ind_care_2',
      categoryId: 'cat_ind_care',
      title: 'Sức khỏe và ghi chép',
      description: 'Thân nhiệt, huyết áp, thuốc và báo cáo.',
      jlptLevel: Category.industryLevel,
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n4_work_1',
      categoryId: 'cat_n4_work',
      title: 'Nơi làm việc',
      description: 'Lương, làm thêm giờ, đi công tác và giờ giấc.',
      jlptLevel: 'N4',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n4_work_2',
      categoryId: 'cat_n4_work',
      title: 'Họp và liên lạc',
      description: 'Cuộc họp, báo cáo, xin ý kiến và hồi âm.',
      jlptLevel: 'N4',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n4_health_1',
      categoryId: 'cat_n4_health',
      title: 'Cơ thể',
      description: 'Tên các bộ phận cơ thể thường gặp.',
      jlptLevel: 'N4',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n4_health_2',
      categoryId: 'cat_n4_health',
      title: 'Ở bệnh viện',
      description: 'Triệu chứng, khám bệnh, nhập viện và xuất viện.',
      jlptLevel: 'N4',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n4_travel_1',
      categoryId: 'cat_n4_travel',
      title: 'Chuẩn bị chuyến đi',
      description: 'Đặt chỗ, nơi ở, tham quan và quà lưu niệm.',
      jlptLevel: 'N4',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n4_travel_2',
      categoryId: 'cat_n4_travel',
      title: 'Trên đường',
      description: 'Đèn giao thông, tắc đường, lái xe và đổi tàu.',
      jlptLevel: 'N4',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n3_society_1',
      categoryId: 'cat_n3_society',
      title: 'Tin tức',
      description: 'Chính trị, kinh tế, bài báo và số liệu.',
      jlptLevel: 'N3',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n3_society_2',
      categoryId: 'cat_n3_society',
      title: 'Môi trường và thiên tai',
      description: 'Bảo vệ môi trường, tiết kiệm và phòng thiên tai.',
      jlptLevel: 'N3',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n3_feelings_1',
      categoryId: 'cat_n3_feelings',
      title: 'Cảm xúc',
      description: 'Vui, buồn, lo lắng, ngạc nhiên và hồi hộp.',
      jlptLevel: 'N3',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n3_feelings_2',
      categoryId: 'cat_n3_feelings',
      title: 'Tính cách',
      description: 'Nhận xét tính cách tốt và chưa tốt của con người.',
      jlptLevel: 'N3',
      order: 2,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n3_life_1',
      categoryId: 'cat_n3_life',
      title: 'Thủ tục hành chính',
      description: 'Đăng ký, nộp giấy tờ, gia hạn visa và đóng thuế.',
      jlptLevel: 'N3',
      order: 1,
      vocabularyCount: 10,
    ),
    Lesson(
      id: 'les_n3_life_2',
      categoryId: 'cat_n3_life',
      title: 'Nhà ở và hàng xóm',
      description: 'Thuê nhà, hợp đồng, sửa chữa và phép lịch sự với hàng xóm.',
      jlptLevel: 'N3',
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
    ..._lessonWords(
        'ind_food',
        'les_ind_food_1',
        1,
        level: Category.industryLevel,
        const [
          (
            '工場',
            'こうじょう',
            'koujou',
            'Nhà máy, xưởng',
            '毎朝八時に工場へ行きます。',
            'Mỗi sáng tôi đến xưởng lúc 8 giờ.'
          ),
          (
            '衛生',
            'えいせい',
            'eisei',
            'Vệ sinh',
            '食品工場では衛生がいちばん大切です。',
            'Ở nhà máy thực phẩm, vệ sinh là quan trọng nhất.'
          ),
          (
            '手洗い',
            'てあらい',
            'tearai',
            'Rửa tay',
            '作業の前に手洗いをします。',
            'Rửa tay trước khi bắt đầu làm.'
          ),
          (
            '消毒',
            'しょうどく',
            'shoudoku',
            'Khử trùng',
            '道具をアルコールで消毒します。',
            'Khử trùng dụng cụ bằng cồn.'
          ),
          (
            '作業着',
            'さぎょうぎ',
            'sagyougi',
            'Quần áo làm việc',
            '作業着に着替えてください。',
            'Hãy thay quần áo làm việc.'
          ),
          (
            '手袋',
            'てぶくろ',
            'tebukuro',
            'Găng tay',
            '手袋をしてから肉を切ります。',
            'Đeo găng tay rồi mới cắt thịt.'
          ),
          (
            '',
            'マスク',
            'masuku',
            'Khẩu trang',
            '工場の中ではマスクをつけます。',
            'Trong xưởng phải đeo khẩu trang.'
          ),
          (
            '異物',
            'いぶつ',
            'ibutsu',
            'Dị vật',
            '製品に異物が入っていないか見ます。',
            'Kiểm tra xem sản phẩm có lẫn dị vật không.'
          ),
          (
            '賞味期限',
            'しょうみきげん',
            'shoumikigen',
            'Hạn sử dụng',
            '箱に賞味期限を印刷します。',
            'In hạn sử dụng lên hộp.'
          ),
          (
            '温度',
            'おんど',
            'ondo',
            'Nhiệt độ',
            '冷蔵庫の温度を記録します。',
            'Ghi lại nhiệt độ của tủ lạnh.'
          ),
        ]),
    ..._lessonWords(
        'ind_food',
        'les_ind_food_2',
        11,
        level: Category.industryLevel,
        const [
          (
            '材料',
            'ざいりょう',
            'zairyou',
            'Nguyên liệu',
            '材料の量を量ります。',
            'Cân lượng nguyên liệu.'
          ),
          (
            '計量',
            'けいりょう',
            'keiryou',
            'Cân đo',
            '計量を間違えないでください。',
            'Đừng cân đo sai.'
          ),
          (
            '加熱',
            'かねつ',
            'kanetsu',
            'Gia nhiệt, làm chín',
            '肉は中までしっかり加熱します。',
            'Làm chín thịt kỹ đến tận bên trong.'
          ),
          (
            '冷却',
            'れいきゃく',
            'reikyaku',
            'Làm nguội',
            '焼いたパンを冷却します。',
            'Làm nguội bánh mì vừa nướng.'
          ),
          (
            '包装',
            'ほうそう',
            'housou',
            'Đóng gói',
            '包装する前に重さを確認します。',
            'Kiểm tra trọng lượng trước khi đóng gói.'
          ),
          (
            '検品',
            'けんぴん',
            'kenpin',
            'Kiểm hàng',
            '出荷の前に検品をします。',
            'Kiểm hàng trước khi xuất.'
          ),
          (
            '不良品',
            'ふりょうひん',
            'furyouhin',
            'Hàng lỗi',
            '不良品はこの箱に入れてください。',
            'Hãy bỏ hàng lỗi vào thùng này.'
          ),
          (
            '出荷',
            'しゅっか',
            'shukka',
            'Xuất hàng',
            '午後三時に出荷します。',
            'Xuất hàng lúc 3 giờ chiều.'
          ),
          (
            '',
            'ライン',
            'rain',
            'Dây chuyền',
            '今日は二番のラインで働きます。',
            'Hôm nay tôi làm ở dây chuyền số 2.'
          ),
          (
            '休憩',
            'きゅうけい',
            'kyuukei',
            'Giờ giải lao',
            '十時から十五分休憩です。',
            'Nghỉ giải lao 15 phút từ 10 giờ.'
          ),
        ]),
    ..._lessonWords(
        'ind_build',
        'les_ind_build_1',
        1,
        level: Category.industryLevel,
        const [
          (
            '現場',
            'げんば',
            'genba',
            'Công trường',
            '現場には七時半に集まります。',
            'Tập trung ở công trường lúc 7 giờ rưỡi.'
          ),
          (
            '安全',
            'あんぜん',
            'anzen',
            'An toàn',
            '安全第一で作業しましょう。',
            'Hãy làm việc với an toàn là trên hết.'
          ),
          (
            '',
            'ヘルメット',
            'herumetto',
            'Mũ bảo hộ',
            '現場ではヘルメットをかぶってください。',
            'Ở công trường hãy đội mũ bảo hộ.'
          ),
          (
            '安全帯',
            'あんぜんたい',
            'anzentai',
            'Dây đai an toàn',
            '高い所では安全帯を使います。',
            'Làm ở chỗ cao phải dùng dây đai an toàn.'
          ),
          (
            '足場',
            'あしば',
            'ashiba',
            'Giàn giáo',
            '足場の上では走らないでください。',
            'Đừng chạy trên giàn giáo.'
          ),
          (
            '朝礼',
            'ちょうれい',
            'chourei',
            'Họp đầu giờ sáng',
            '朝礼で今日の作業を確認します。',
            'Xác nhận việc hôm nay trong buổi họp sáng.'
          ),
          (
            '危ない',
            'あぶない',
            'abunai',
            'Nguy hiểm',
            '危ない！上から物が落ちます。',
            'Nguy hiểm! Có đồ rơi từ trên xuống.'
          ),
          (
            '立入禁止',
            'たちいりきんし',
            'tachiirikinshi',
            'Cấm vào',
            'ここは立入禁止です。',
            'Khu vực này cấm vào.'
          ),
          (
            '怪我',
            'けが',
            'kega',
            'Vết thương, bị thương',
            '怪我をしたら、すぐに言ってください。',
            'Nếu bị thương hãy báo ngay.'
          ),
          (
            '図面',
            'ずめん',
            'zumen',
            'Bản vẽ',
            '図面を見ながら作業します。',
            'Vừa xem bản vẽ vừa làm.'
          ),
        ]),
    ..._lessonWords(
        'ind_build',
        'les_ind_build_2',
        11,
        level: Category.industryLevel,
        const [
          (
            '材木',
            'ざいもく',
            'zaimoku',
            'Gỗ xây dựng',
            '材木をトラックから降ろします。',
            'Dỡ gỗ từ xe tải xuống.'
          ),
          (
            '鉄筋',
            'てっきん',
            'tekkin',
            'Cốt thép',
            '鉄筋を図面どおりに並べます。',
            'Xếp cốt thép theo đúng bản vẽ.'
          ),
          (
            '',
            'コンクリート',
            'konkuriito',
            'Bê tông',
            'コンクリートが固まるまで待ちます。',
            'Chờ đến khi bê tông đông cứng.'
          ),
          (
            '',
            'セメント',
            'semento',
            'Xi măng',
            'セメントと砂と水を混ぜます。',
            'Trộn xi măng với cát và nước.'
          ),
          (
            '',
            'ハンマー',
            'hanmaa',
            'Cái búa',
            'ハンマーで釘を打ちます。',
            'Đóng đinh bằng búa.'
          ),
          ('釘', 'くぎ', 'kugi', 'Cái đinh', '釘が足りません。', 'Không đủ đinh.'),
          (
            '運ぶ',
            'はこぶ',
            'hakobu',
            'Khiêng, vận chuyển',
            '二人でこの板を運んでください。',
            'Hai người hãy khiêng tấm ván này.'
          ),
          (
            '測る',
            'はかる',
            'hakaru',
            'Đo',
            'メジャーで長さを測ります。',
            'Đo chiều dài bằng thước dây.'
          ),
          ('掘る', 'ほる', 'horu', 'Đào', 'スコップで土を掘ります。', 'Đào đất bằng xẻng.'),
          (
            '片付け',
            'かたづけ',
            'katazuke',
            'Dọn dẹp',
            '作業のあとは片付けをします。',
            'Làm xong thì dọn dẹp.'
          ),
        ]),
    ..._lessonWords(
        'ind_care',
        'les_ind_care_1',
        1,
        level: Category.industryLevel,
        const [
          (
            '介護',
            'かいご',
            'kaigo',
            'Chăm sóc, điều dưỡng',
            '祖母は介護が必要です。',
            'Bà tôi cần được chăm sóc.'
          ),
          (
            '利用者',
            'りようしゃ',
            'riyousha',
            'Người dùng dịch vụ',
            '利用者の名前を早く覚えましょう。',
            'Hãy sớm nhớ tên người dùng dịch vụ.'
          ),
          (
            '食事介助',
            'しょくじかいじょ',
            'shokujikaijo',
            'Hỗ trợ ăn uống',
            '昼は食事介助をします。',
            'Buổi trưa tôi hỗ trợ ăn uống.'
          ),
          (
            '入浴',
            'にゅうよく',
            'nyuuyoku',
            'Tắm rửa',
            '入浴の前に体温を測ります。',
            'Đo thân nhiệt trước khi tắm.'
          ),
          (
            '着替え',
            'きがえ',
            'kigae',
            'Thay quần áo',
            '朝の着替えを手伝います。',
            'Giúp thay quần áo buổi sáng.'
          ),
          (
            '車いす',
            'くるまいす',
            'kurumaisu',
            'Xe lăn',
            '車いすで食堂へ行きます。',
            'Đi đến nhà ăn bằng xe lăn.'
          ),
          (
            '歩行',
            'ほこう',
            'hokou',
            'Đi bộ, tập đi',
            '一緒に歩行の練習をします。',
            'Cùng nhau tập đi.'
          ),
          (
            '',
            'トイレ',
            'toire',
            'Nhà vệ sinh',
            'トイレまでご案内します。',
            'Tôi sẽ đưa bác đến nhà vệ sinh.'
          ),
          (
            '声かけ',
            'こえかけ',
            'koekake',
            'Lời hỏi han',
            'やさしい声かけが大切です。',
            'Lời hỏi han nhẹ nhàng rất quan trọng.'
          ),
          (
            '見守り',
            'みまもり',
            'mimamori',
            'Trông chừng',
            '夜は利用者の見守りをします。',
            'Buổi tối tôi trông chừng người dùng dịch vụ.'
          ),
        ]),
    ..._lessonWords(
        'ind_care',
        'les_ind_care_2',
        11,
        level: Category.industryLevel,
        const [
          (
            '体温',
            'たいおん',
            'taion',
            'Thân nhiệt',
            '毎朝体温を測ります。',
            'Đo thân nhiệt mỗi sáng.'
          ),
          (
            '血圧',
            'けつあつ',
            'ketsuatsu',
            'Huyết áp',
            '今日は血圧が少し高いです。',
            'Hôm nay huyết áp hơi cao.'
          ),
          (
            '熱',
            'ねつ',
            'netsu',
            'Sốt',
            '熱があるので、休んでください。',
            'Bị sốt nên hãy nghỉ ngơi.'
          ),
          (
            '薬',
            'くすり',
            'kusuri',
            'Thuốc',
            '食後に薬を飲みます。',
            'Uống thuốc sau bữa ăn.'
          ),
          ('痛い', 'いたい', 'itai', 'Đau', 'どこが痛いですか。', 'Bác đau ở đâu ạ?'),
          (
            '転倒',
            'てんとう',
            'tentou',
            'Té ngã',
            '転倒しないように気をつけます。',
            'Cẩn thận để không bị ngã.'
          ),
          (
            '記録',
            'きろく',
            'kiroku',
            'Ghi chép',
            '毎日介護の記録を書きます。',
            'Mỗi ngày tôi viết nhật ký chăm sóc.'
          ),
          (
            '報告',
            'ほうこく',
            'houkoku',
            'Báo cáo',
            'いつもと違うことはすぐ報告します。',
            'Có gì khác thường thì báo cáo ngay.'
          ),
          (
            '看護師',
            'かんごし',
            'kangoshi',
            'Y tá',
            '看護師に相談します。',
            'Trao đổi với y tá.'
          ),
          (
            '様子',
            'ようす',
            'yousu',
            'Tình trạng',
            '今日の様子はどうですか。',
            'Hôm nay tình trạng của bác thế nào?'
          ),
        ]),
    // ------------------------------------------------------------------ N4
    ..._lessonWords('n4_work', 'les_n4_work_1', 1, level: 'N4', const [
      (
        '残業',
        'ざんぎょう',
        'zangyou',
        'Làm thêm giờ',
        '今日は二時間残業しました。',
        'Hôm nay tôi làm thêm hai tiếng.'
      ),
      (
        '給料',
        'きゅうりょう',
        'kyuuryou',
        'Tiền lương',
        '給料は毎月二十五日にもらいます。',
        'Tôi nhận lương vào ngày 25 hằng tháng.'
      ),
      (
        '社長',
        'しゃちょう',
        'shachou',
        'Giám đốc',
        '社長は今、出張中です。',
        'Giám đốc hiện đang đi công tác.'
      ),
      (
        '出張',
        'しゅっちょう',
        'shucchou',
        'Đi công tác',
        '来週、大阪へ出張します。',
        'Tuần sau tôi đi công tác Osaka.'
      ),
      (
        '受付',
        'うけつけ',
        'uketsuke',
        'Quầy lễ tân',
        '受付で名前を書いてください。',
        'Hãy ghi tên ở quầy lễ tân.'
      ),
      (
        '書類',
        'しょるい',
        'shorui',
        'Giấy tờ, tài liệu',
        'この書類にサインしてください。',
        'Hãy ký vào giấy tờ này.'
      ),
      (
        '予定',
        'よてい',
        'yotei',
        'Dự định, lịch trình',
        '明日の予定を教えてください。',
        'Hãy cho tôi biết lịch trình ngày mai.'
      ),
      (
        '遅刻',
        'ちこく',
        'chikoku',
        'Đến muộn',
        '電車が遅れて、遅刻しました。',
        'Tàu bị trễ nên tôi đến muộn.'
      ),
      (
        '昼休み',
        'ひるやすみ',
        'hiruyasumi',
        'Giờ nghỉ trưa',
        '昼休みに同僚とお弁当を食べます。',
        'Giờ nghỉ trưa tôi ăn cơm hộp với đồng nghiệp.'
      ),
      (
        '経験',
        'けいけん',
        'keiken',
        'Kinh nghiệm',
        '日本で働いた経験があります。',
        'Tôi có kinh nghiệm làm việc ở Nhật.'
      ),
    ]),
    ..._lessonWords('n4_work', 'les_n4_work_2', 11, level: 'N4', const [
      (
        '会議',
        'かいぎ',
        'kaigi',
        'Cuộc họp',
        '三時から会議があります。',
        'Từ 3 giờ có cuộc họp.'
      ),
      (
        '連絡',
        'れんらく',
        'renraku',
        'Liên lạc',
        '遅れるときは連絡してください。',
        'Khi đến muộn hãy liên lạc nhé.'
      ),
      (
        '相談',
        'そうだん',
        'soudan',
        'Bàn bạc, xin ý kiến',
        '困ったことを先輩に相談しました。',
        'Tôi đã hỏi ý kiến tiền bối về chuyện khó khăn.'
      ),
      (
        '説明',
        'せつめい',
        'setsumei',
        'Giải thích',
        'もう一度説明してください。',
        'Xin hãy giải thích lại một lần nữa.'
      ),
      (
        '準備',
        'じゅんび',
        'junbi',
        'Chuẩn bị',
        '会議の準備はできましたか。',
        'Đã chuẩn bị xong cho cuộc họp chưa?'
      ),
      (
        '断る',
        'ことわる',
        'kotowaru',
        'Từ chối',
        '忙しかったので、誘いを断りました。',
        'Vì bận nên tôi đã từ chối lời mời.'
      ),
      (
        '意見',
        'いけん',
        'iken',
        'Ý kiến',
        'あなたの意見を聞かせてください。',
        'Hãy cho tôi nghe ý kiến của bạn.'
      ),
      (
        '約束',
        'やくそく',
        'yakusoku',
        'Lời hứa, cuộc hẹn',
        '約束の時間を守りましょう。',
        'Hãy giữ đúng giờ hẹn.'
      ),
      (
        '返事',
        'へんじ',
        'henji',
        'Trả lời, hồi âm',
        'メールの返事を書きます。',
        'Tôi viết thư trả lời email.'
      ),
      (
        '伝える',
        'つたえる',
        'tsutaeru',
        'Truyền đạt, nhắn lại',
        '田中さんによろしく伝えてください。',
        'Cho tôi gửi lời hỏi thăm anh Tanaka.'
      ),
    ]),
    ..._lessonWords('n4_health', 'les_n4_health_1', 1, level: 'N4', const [
      (
        '首',
        'くび',
        'kubi',
        'Cổ',
        '長い時間パソコンを使うと、首が痛くなります。',
        'Dùng máy tính lâu thì bị đau cổ.'
      ),
      (
        '肩',
        'かた',
        'kata',
        'Vai',
        '重い荷物を持って、肩が痛いです。',
        'Mang đồ nặng nên tôi bị đau vai.'
      ),
      ('背中', 'せなか', 'senaka', 'Lưng', '背中がかゆいです。', 'Lưng tôi bị ngứa.'),
      (
        '腕',
        'うで',
        'ude',
        'Cánh tay',
        'テニスで腕をけがしました。',
        'Tôi bị thương ở cánh tay khi chơi tennis.'
      ),
      (
        '指',
        'ゆび',
        'yubi',
        'Ngón tay',
        'ナイフで指を切りました。',
        'Tôi bị dao cứa vào ngón tay.'
      ),
      (
        '歯',
        'は',
        'ha',
        'Răng',
        '毎日三回歯をみがきます。',
        'Mỗi ngày tôi đánh răng ba lần.'
      ),
      (
        '喉',
        'のど',
        'nodo',
        'Họng',
        '喉が痛くて、声が出ません。',
        'Họng đau nên tôi không nói ra tiếng.'
      ),
      (
        '胸',
        'むね',
        'mune',
        'Ngực',
        '走ったあと、胸が苦しくなりました。',
        'Chạy xong tôi thấy tức ngực.'
      ),
      (
        '心',
        'こころ',
        'kokoro',
        'Tấm lòng, trái tim',
        '心から感謝しています。',
        'Tôi xin cảm ơn từ tận đáy lòng.'
      ),
      (
        '骨',
        'ほね',
        'hone',
        'Xương',
        '転んで足の骨が折れました。',
        'Tôi bị ngã và gãy xương chân.'
      ),
    ]),
    ..._lessonWords('n4_health', 'les_n4_health_2', 11, level: 'N4', const [
      (
        '頭痛',
        'ずつう',
        'zutsuu',
        'Đau đầu',
        '頭痛がするので、薬を飲みました。',
        'Vì đau đầu nên tôi đã uống thuốc.'
      ),
      (
        '吐き気',
        'はきけ',
        'hakike',
        'Buồn nôn',
        '朝から吐き気がします。',
        'Từ sáng tôi thấy buồn nôn.'
      ),
      (
        '注射',
        'ちゅうしゃ',
        'chuusha',
        'Tiêm',
        '病院で注射をしてもらいました。',
        'Tôi được tiêm ở bệnh viện.'
      ),
      ('咳', 'せき', 'seki', 'Ho', '夜になると咳が出ます。', 'Cứ đến tối là tôi bị ho.'),
      (
        '入院',
        'にゅういん',
        'nyuuin',
        'Nhập viện',
        '祖父は一週間入院しました。',
        'Ông tôi đã nhập viện một tuần.'
      ),
      (
        '退院',
        'たいいん',
        'taiin',
        'Xuất viện',
        '明日、退院できます。',
        'Ngày mai tôi có thể xuất viện.'
      ),
      (
        '歯医者',
        'はいしゃ',
        'haisha',
        'Nha sĩ',
        '歯が痛いので、歯医者に行きます。',
        'Vì đau răng nên tôi đi nha sĩ.'
      ),
      (
        '診察',
        'しんさつ',
        'shinsatsu',
        'Khám bệnh',
        '診察は九時からです。',
        'Giờ khám bệnh bắt đầu từ 9 giờ.'
      ),
      (
        '保険証',
        'ほけんしょう',
        'hokenshou',
        'Thẻ bảo hiểm y tế',
        '病院へ行くとき、保険証を忘れないでください。',
        'Khi đi bệnh viện đừng quên thẻ bảo hiểm.'
      ),
      (
        '治る',
        'なおる',
        'naoru',
        'Khỏi bệnh',
        '薬を飲んだら、すぐ治りました。',
        'Uống thuốc xong là tôi khỏi ngay.'
      ),
    ]),
    ..._lessonWords('n4_travel', 'les_n4_travel_1', 1, level: 'N4', const [
      (
        '予約',
        'よやく',
        'yoyaku',
        'Đặt chỗ, đặt trước',
        'ホテルを予約しました。',
        'Tôi đã đặt phòng khách sạn.'
      ),
      (
        '観光',
        'かんこう',
        'kankou',
        'Tham quan, du lịch',
        '京都で観光しました。',
        'Tôi đã đi tham quan ở Kyoto.'
      ),
      (
        '案内',
        'あんない',
        'annai',
        'Hướng dẫn, dẫn đường',
        '町を案内してあげます。',
        'Tôi sẽ dẫn bạn đi tham quan thị trấn.'
      ),
      (
        'お土産',
        'おみやげ',
        'omiyage',
        'Quà lưu niệm',
        '家族にお土産を買いました。',
        'Tôi đã mua quà lưu niệm cho gia đình.'
      ),
      (
        '旅館',
        'りょかん',
        'ryokan',
        'Nhà trọ kiểu Nhật',
        '温泉のある旅館に泊まりました。',
        'Tôi đã trọ ở lữ quán có suối nước nóng.'
      ),
      (
        '泊まる',
        'とまる',
        'tomaru',
        'Trọ lại, ngủ lại',
        '今夜は友だちの家に泊まります。',
        'Tối nay tôi ngủ lại nhà bạn.'
      ),
      (
        '景色',
        'けしき',
        'keshiki',
        'Phong cảnh',
        '山の上から見た景色はきれいでした。',
        'Phong cảnh nhìn từ trên núi rất đẹp.'
      ),
      (
        '計画',
        'けいかく',
        'keikaku',
        'Kế hoạch',
        '夏休みの計画を立てました。',
        'Tôi đã lên kế hoạch cho kỳ nghỉ hè.'
      ),
      (
        '出発',
        'しゅっぱつ',
        'shuppatsu',
        'Xuất phát',
        '朝七時に出発します。',
        'Chúng tôi xuất phát lúc 7 giờ sáng.'
      ),
      (
        '到着',
        'とうちゃく',
        'touchaku',
        'Đến nơi',
        '飛行機は十時に到着します。',
        'Máy bay hạ cánh lúc 10 giờ.'
      ),
    ]),
    ..._lessonWords('n4_travel', 'les_n4_travel_2', 11, level: 'N4', const [
      (
        '交差点',
        'こうさてん',
        'kousaten',
        'Ngã tư',
        '次の交差点を右に曲がってください。',
        'Hãy rẽ phải ở ngã tư tiếp theo.'
      ),
      (
        '信号',
        'しんごう',
        'shingou',
        'Đèn giao thông',
        '信号が青になったら、渡ります。',
        'Khi đèn chuyển xanh thì sang đường.'
      ),
      (
        '渋滞',
        'じゅうたい',
        'juutai',
        'Tắc đường',
        '朝は道がとても渋滞します。',
        'Buổi sáng đường rất tắc.'
      ),
      (
        '事故',
        'じこ',
        'jiko',
        'Tai nạn',
        '駅の前で事故がありました。',
        'Đã có tai nạn trước nhà ga.'
      ),
      (
        '乗り換える',
        'のりかえる',
        'norikaeru',
        'Đổi tàu, chuyển xe',
        '新宿で電車を乗り換えます。',
        'Tôi đổi tàu ở Shinjuku.'
      ),
      ('運転', 'うんてん', 'unten', 'Lái xe', '父は運転が上手です。', 'Bố tôi lái xe giỏi.'),
      (
        '駐車場',
        'ちゅうしゃじょう',
        'chuushajou',
        'Bãi đỗ xe',
        '駐車場はどこですか。',
        'Bãi đỗ xe ở đâu ạ?'
      ),
      (
        '急行',
        'きゅうこう',
        'kyuukou',
        'Tàu tốc hành',
        '急行は小さい駅に止まりません。',
        'Tàu tốc hành không dừng ở ga nhỏ.'
      ),
      (
        '間に合う',
        'まにあう',
        'maniau',
        'Kịp giờ',
        '走ったので、電車に間に合いました。',
        'Nhờ chạy nên tôi đã kịp tàu.'
      ),
      (
        '道路',
        'どうろ',
        'douro',
        'Đường bộ, con đường',
        '道路を渡るときは気をつけてください。',
        'Khi sang đường hãy cẩn thận.'
      ),
    ]),
    // ------------------------------------------------------------------ N3
    ..._lessonWords('n3_society', 'les_n3_society_1', 1, level: 'N3', const [
      (
        '政治',
        'せいじ',
        'seiji',
        'Chính trị',
        '政治に興味がありますか。',
        'Bạn có quan tâm đến chính trị không?'
      ),
      (
        '経済',
        'けいざい',
        'keizai',
        'Kinh tế',
        '日本の経済について調べています。',
        'Tôi đang tìm hiểu về kinh tế Nhật Bản.'
      ),
      ('選挙', 'せんきょ', 'senkyo', 'Bầu cử', '来月、選挙があります。', 'Tháng sau có bầu cử.'),
      (
        '記事',
        'きじ',
        'kiji',
        'Bài báo',
        '新聞の記事を読みました。',
        'Tôi đã đọc bài báo trên tờ báo.'
      ),
      (
        '情報',
        'じょうほう',
        'jouhou',
        'Thông tin',
        'インターネットで情報を集めます。',
        'Tôi thu thập thông tin trên mạng.'
      ),
      (
        '事件',
        'じけん',
        'jiken',
        'Vụ việc, vụ án',
        '昨日、近くで事件が起きました。',
        'Hôm qua có một vụ việc xảy ra gần đây.'
      ),
      (
        '増える',
        'ふえる',
        'fueru',
        'Tăng lên',
        '外国人の観光客が増えています。',
        'Khách du lịch nước ngoài đang tăng lên.'
      ),
      (
        '減る',
        'へる',
        'heru',
        'Giảm đi',
        '子どもの数が減っています。',
        'Số trẻ em đang giảm đi.'
      ),
      (
        '原因',
        'げんいん',
        'gen\'in',
        'Nguyên nhân',
        '事故の原因はまだ分かりません。',
        'Vẫn chưa rõ nguyên nhân vụ tai nạn.'
      ),
      (
        '結果',
        'けっか',
        'kekka',
        'Kết quả',
        '試験の結果はいつ分かりますか。',
        'Khi nào thì biết kết quả thi?'
      ),
    ]),
    ..._lessonWords('n3_society', 'les_n3_society_2', 11, level: 'N3', const [
      (
        '環境',
        'かんきょう',
        'kankyou',
        'Môi trường',
        '環境を守ることは大切です。',
        'Bảo vệ môi trường là điều quan trọng.'
      ),
      (
        '資源',
        'しげん',
        'shigen',
        'Tài nguyên',
        '資源を大切に使いましょう。',
        'Hãy sử dụng tài nguyên một cách tiết kiệm.'
      ),
      (
        '温暖化',
        'おんだんか',
        'ondanka',
        'Sự nóng lên toàn cầu',
        '地球温暖化が問題になっています。',
        'Sự nóng lên toàn cầu đang trở thành vấn đề.'
      ),
      (
        '汚染',
        'おせん',
        'osen',
        'Ô nhiễm',
        '川の汚染が進んでいます。',
        'Tình trạng ô nhiễm sông ngày càng nặng.'
      ),
      (
        '節約',
        'せつやく',
        'setsuyaku',
        'Tiết kiệm',
        '毎月、電気を節約しています。',
        'Tháng nào tôi cũng tiết kiệm điện.'
      ),
      (
        '分別',
        'ぶんべつ',
        'bunbetsu',
        'Phân loại rác',
        'ごみは分別して出してください。',
        'Hãy phân loại rác rồi mới bỏ.'
      ),
      (
        '再利用',
        'さいりよう',
        'sairiyou',
        'Tái sử dụng',
        '使った紙を再利用しています。',
        'Tôi đang tái sử dụng giấy đã dùng.'
      ),
      (
        '地震',
        'じしん',
        'jishin',
        'Động đất',
        '日本は地震が多い国です。',
        'Nhật Bản là nước có nhiều động đất.'
      ),
      (
        '災害',
        'さいがい',
        'saigai',
        'Thiên tai',
        '災害に備えて、水を買っておきます。',
        'Tôi mua sẵn nước để phòng thiên tai.'
      ),
      (
        '被害',
        'ひがい',
        'higai',
        'Thiệt hại',
        '台風で大きな被害が出ました。',
        'Cơn bão đã gây thiệt hại lớn.'
      ),
    ]),
    ..._lessonWords('n3_feelings', 'les_n3_feelings_1', 1, level: 'N3', const [
      (
        '嬉しい',
        'うれしい',
        'ureshii',
        'Vui mừng',
        '試験に合格して、とても嬉しいです。',
        'Thi đỗ rồi nên tôi rất vui.'
      ),
      (
        '寂しい',
        'さびしい',
        'sabishii',
        'Cô đơn',
        '家族と離れて、寂しいです。',
        'Xa gia đình nên tôi thấy cô đơn.'
      ),
      (
        '恥ずかしい',
        'はずかしい',
        'hazukashii',
        'Xấu hổ, ngại ngùng',
        '人の前で話すのは恥ずかしいです。',
        'Nói trước nhiều người thật ngại.'
      ),
      (
        '悔しい',
        'くやしい',
        'kuyashii',
        'Tiếc nuối, cay cú',
        '試合に負けて、悔しいです。',
        'Thua trận nên tôi thấy cay cú.'
      ),
      (
        '心配',
        'しんぱい',
        'shinpai',
        'Lo lắng',
        '母はいつも私のことを心配しています。',
        'Mẹ lúc nào cũng lo lắng cho tôi.'
      ),
      (
        '安心',
        'あんしん',
        'anshin',
        'Yên tâm',
        '無事に着いて、安心しました。',
        'Đến nơi bình an nên tôi yên tâm.'
      ),
      (
        '驚く',
        'おどろく',
        'odoroku',
        'Ngạc nhiên',
        'そのニュースを聞いて、驚きました。',
        'Nghe tin đó tôi rất ngạc nhiên.'
      ),
      (
        '怒る',
        'おこる',
        'okoru',
        'Tức giận',
        '約束を破ると、父は怒ります。',
        'Thất hứa là bố sẽ giận.'
      ),
      (
        '感動',
        'かんどう',
        'kandou',
        'Cảm động',
        'その映画にとても感動しました。',
        'Tôi rất cảm động với bộ phim đó.'
      ),
      (
        '緊張',
        'きんちょう',
        'kinchou',
        'Căng thẳng, hồi hộp',
        '面接でとても緊張しました。',
        'Tôi đã rất hồi hộp khi phỏng vấn.'
      ),
    ]),
    ..._lessonWords('n3_feelings', 'les_n3_feelings_2', 11, level: 'N3', const [
      (
        '真面目',
        'まじめ',
        'majime',
        'Nghiêm túc, chăm chỉ',
        '彼はとても真面目な学生です。',
        'Cậu ấy là sinh viên rất chăm chỉ.'
      ),
      (
        '素直',
        'すなお',
        'sunao',
        'Ngoan, thật thà',
        '弟は素直な子です。',
        'Em trai tôi là đứa trẻ ngoan.'
      ),
      (
        '正直',
        'しょうじき',
        'shoujiki',
        'Thành thật',
        '正直に話してください。',
        'Hãy nói thật đi.'
      ),
      (
        '我慢',
        'がまん',
        'gaman',
        'Chịu đựng, nhẫn nại',
        '痛いけれど、我慢します。',
        'Đau nhưng tôi sẽ chịu đựng.'
      ),
      (
        '性格',
        'せいかく',
        'seikaku',
        'Tính cách',
        '姉は明るい性格です。',
        'Chị tôi có tính cách vui vẻ.'
      ),
      (
        '積極的',
        'せっきょくてき',
        'sekkyokuteki',
        'Tích cực, chủ động',
        '授業で積極的に質問します。',
        'Tôi chủ động đặt câu hỏi trong giờ học.'
      ),
      (
        '頑固',
        'がんこ',
        'ganko',
        'Bướng bỉnh, cứng đầu',
        '祖父は頑固な人です。',
        'Ông tôi là người cứng đầu.'
      ),
      (
        'わがまま',
        'わがまま',
        'wagamama',
        'Ích kỷ, hay đòi hỏi',
        '子どものわがままに困っています。',
        'Tôi khổ vì con hay đòi hỏi.'
      ),
      (
        '丁寧',
        'ていねい',
        'teinei',
        'Lịch sự, chu đáo',
        '店員さんは丁寧に説明してくれました。',
        'Nhân viên giải thích rất chu đáo.'
      ),
      (
        '意地悪',
        'いじわる',
        'ijiwaru',
        'Xấu tính, hay bắt nạt',
        '意地悪なことを言わないでください。',
        'Đừng nói những lời xấu tính như vậy.'
      ),
    ]),
    ..._lessonWords('n3_life', 'les_n3_life_1', 1, level: 'N3', const [
      (
        '手続き',
        'てつづき',
        'tetsuzuki',
        'Thủ tục',
        '市役所で引っ越しの手続きをしました。',
        'Tôi đã làm thủ tục chuyển nhà ở tòa thị chính.'
      ),
      (
        '申し込む',
        'もうしこむ',
        'moushikomu',
        'Đăng ký',
        '日本語の講座に申し込みました。',
        'Tôi đã đăng ký khóa học tiếng Nhật.'
      ),
      (
        '提出',
        'ていしゅつ',
        'teishutsu',
        'Nộp (giấy tờ, bài)',
        '金曜日までにレポートを提出してください。',
        'Hãy nộp báo cáo trước thứ Sáu.'
      ),
      (
        '記入',
        'きにゅう',
        'kinyuu',
        'Điền vào (mẫu đơn)',
        'この用紙に住所を記入してください。',
        'Hãy điền địa chỉ vào tờ đơn này.'
      ),
      (
        '印鑑',
        'いんかん',
        'inkan',
        'Con dấu cá nhân',
        '銀行で口座を作るとき、印鑑が必要です。',
        'Khi mở tài khoản ngân hàng cần có con dấu.'
      ),
      (
        '在留カード',
        'ざいりゅうカード',
        'zairyuu kaado',
        'Thẻ cư trú',
        '在留カードはいつも持っていてください。',
        'Hãy luôn mang theo thẻ cư trú.'
      ),
      (
        '期限',
        'きげん',
        'kigen',
        'Thời hạn',
        'ビザの期限が来月切れます。',
        'Visa của tôi hết hạn vào tháng sau.'
      ),
      (
        '更新',
        'こうしん',
        'koushin',
        'Gia hạn, cập nhật',
        '入管でビザを更新しました。',
        'Tôi đã gia hạn visa ở cục xuất nhập cảnh.'
      ),
      (
        '窓口',
        'まどぐち',
        'madoguchi',
        'Quầy tiếp nhận',
        '二番の窓口へどうぞ。',
        'Mời anh chị đến quầy số 2.'
      ),
      (
        '税金',
        'ぜいきん',
        'zeikin',
        'Tiền thuế',
        '毎年、税金を払います。',
        'Hằng năm tôi đều đóng thuế.'
      ),
    ]),
    ..._lessonWords('n3_life', 'les_n3_life_2', 11, level: 'N3', const [
      (
        '家賃',
        'やちん',
        'yachin',
        'Tiền thuê nhà',
        'このアパートの家賃は五万円です。',
        'Tiền thuê căn hộ này là 50.000 yên.'
      ),
      (
        '大家',
        'おおや',
        'ooya',
        'Chủ nhà (cho thuê)',
        '大家さんに鍵を返しました。',
        'Tôi đã trả chìa khóa cho chủ nhà.'
      ),
      (
        '近所',
        'きんじょ',
        'kinjo',
        'Khu lân cận, hàng xóm',
        '近所に大きいスーパーがあります。',
        'Gần nhà tôi có một siêu thị lớn.'
      ),
      (
        '引っ越し',
        'ひっこし',
        'hikkoshi',
        'Chuyển nhà',
        '来週、引っ越しをします。',
        'Tuần sau tôi chuyển nhà.'
      ),
      (
        '契約',
        'けいやく',
        'keiyaku',
        'Hợp đồng',
        'アパートの契約をしました。',
        'Tôi đã ký hợp đồng thuê căn hộ.'
      ),
      (
        '騒音',
        'そうおん',
        'souon',
        'Tiếng ồn',
        '夜の騒音に困っています。',
        'Tôi khổ vì tiếng ồn ban đêm.'
      ),
      (
        '迷惑',
        'めいわく',
        'meiwaku',
        'Phiền hà, làm phiền',
        '近所の人に迷惑をかけないようにしましょう。',
        'Hãy cố gắng đừng làm phiền hàng xóm.'
      ),
      (
        '管理人',
        'かんりにん',
        'kanrinin',
        'Người quản lý tòa nhà',
        '故障したら、管理人に連絡してください。',
        'Nếu có gì hỏng hãy liên lạc người quản lý.'
      ),
      (
        '修理',
        'しゅうり',
        'shuuri',
        'Sửa chữa',
        'エアコンの修理を頼みました。',
        'Tôi đã nhờ người sửa điều hòa.'
      ),
      (
        '回覧板',
        'かいらんばん',
        'kairanban',
        'Bảng tin chuyền tay',
        '回覧板を隣の家に回します。',
        'Tôi chuyền bảng tin sang nhà bên cạnh.'
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
    List<_WordRow> rows, {
    String level = 'N5',
  }) {
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
          jlptLevel: level,
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
