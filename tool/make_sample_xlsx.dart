import 'dart:io';

import 'package:excel/excel.dart';

/// Một từ: (kanji, kana, romaji, nghĩa, câu ví dụ, nghĩa câu ví dụ).
typedef Row = (String, String, String, String, String, String);

/// Các bộ từ vựng mẫu, mỗi bộ thành một file Excel để thử chức năng Import.
const Map<String, List<Row>> topics = {
  'so-thich-the-thao': [
    (
      '趣味',
      'しゅみ',
      'shumi',
      'Sở thích',
      '私の趣味は読書です。',
      'Sở thích của tôi là đọc sách.'
    ),
    (
      '音楽',
      'おんがく',
      'ongaku',
      'Âm nhạc',
      '毎日音楽を聞きます。',
      'Ngày nào tôi cũng nghe nhạc.'
    ),
    ('映画', 'えいが', 'eiga', 'Phim', '週末に映画を見ます。', 'Cuối tuần tôi xem phim.'),
    ('歌', 'うた', 'uta', 'Bài hát', 'この歌が好きです。', 'Tôi thích bài hát này.'),
    ('歌う', 'うたう', 'utau', 'Hát', 'カラオケで歌います。', 'Tôi hát ở quán karaoke.'),
    ('泳ぐ', 'およぐ', 'oyogu', 'Bơi', '夏は海で泳ぎます。', 'Mùa hè tôi bơi ở biển.'),
    (
      '走る',
      'はしる',
      'hashiru',
      'Chạy',
      '毎朝公園を走ります。',
      'Sáng nào tôi cũng chạy trong công viên.'
    ),
    ('絵', 'え', 'e', 'Bức tranh', '絵を描くのが好きです。', 'Tôi thích vẽ tranh.'),
    (
      '旅行',
      'りょこう',
      'ryokou',
      'Du lịch',
      '夏休みに旅行します。',
      'Kỳ nghỉ hè tôi đi du lịch.'
    ),
    (
      '料理',
      'りょうり',
      'ryouri',
      'Nấu ăn, món ăn',
      '母は料理が上手です。',
      'Mẹ tôi nấu ăn giỏi.'
    ),
    (
      '',
      'サッカー',
      'sakkaa',
      'Bóng đá',
      '友達とサッカーをします。',
      'Tôi chơi bóng đá với bạn.'
    ),
    (
      '',
      'テニス',
      'tenisu',
      'Quần vợt',
      '土曜日にテニスをします。',
      'Thứ Bảy tôi chơi quần vợt.'
    ),
    (
      '野球',
      'やきゅう',
      'yakyuu',
      'Bóng chày',
      '日本では野球が人気です。',
      'Ở Nhật, bóng chày rất được yêu thích.'
    ),
    (
      '',
      'ゲーム',
      'geemu',
      'Trò chơi điện tử',
      '弟はゲームが好きです。',
      'Em trai tôi thích chơi game.'
    ),
    (
      '',
      'ギター',
      'gitaa',
      'Đàn ghi-ta',
      '兄はギターを弾きます。',
      'Anh trai tôi chơi đàn ghi-ta.'
    ),
    ('弾く', 'ひく', 'hiku', 'Chơi (đàn)', 'ピアノを弾きます。', 'Tôi chơi đàn piano.'),
    (
      '散歩',
      'さんぽ',
      'sanpo',
      'Đi dạo',
      '夕方、犬と散歩します。',
      'Chiều tối tôi dắt chó đi dạo.'
    ),
    (
      '試合',
      'しあい',
      'shiai',
      'Trận đấu',
      '明日サッカーの試合があります。',
      'Ngày mai có trận bóng đá.'
    ),
    (
      '練習',
      'れんしゅう',
      'renshuu',
      'Luyện tập',
      '毎日ピアノを練習します。',
      'Ngày nào tôi cũng luyện piano.'
    ),
    ('上手', 'じょうず', 'jouzu', 'Giỏi', '日本語が上手ですね。', 'Bạn giỏi tiếng Nhật nhỉ.'),
    ('下手', 'へた', 'heta', 'Kém, dở', '私は歌が下手です。', 'Tôi hát dở.'),
    (
      '好き',
      'すき',
      'suki',
      'Thích',
      '何のスポーツが好きですか。',
      'Bạn thích môn thể thao nào?'
    ),
  ],
  'co-the-suc-khoe': [
    ('頭', 'あたま', 'atama', 'Đầu', '朝から頭が痛いです。', 'Từ sáng tôi đã bị đau đầu.'),
    ('顔', 'かお', 'kao', 'Khuôn mặt', '顔を洗ってください。', 'Hãy rửa mặt đi.'),
    ('目', 'め', 'me', 'Mắt', '目が疲れました。', 'Mắt tôi mỏi rồi.'),
    ('耳', 'みみ', 'mimi', 'Tai', '祖父は耳が遠いです。', 'Ông tôi bị nặng tai.'),
    ('口', 'くち', 'kuchi', 'Miệng', '口を大きく開けてください。', 'Hãy há miệng to ra.'),
    ('歯', 'は', 'ha', 'Răng', '毎晩歯を磨きます。', 'Tối nào tôi cũng đánh răng.'),
    ('手', 'て', 'te', 'Tay', '食べる前に手を洗います。', 'Tôi rửa tay trước khi ăn.'),
    (
      '足',
      'あし',
      'ashi',
      'Chân',
      '足が痛くて歩けません。',
      'Chân đau quá, tôi không đi được.'
    ),
    ('体', 'からだ', 'karada', 'Cơ thể', '体に気をつけてください。', 'Hãy giữ gìn sức khỏe.'),
    ('喉', 'のど', 'nodo', 'Cổ họng', '喉が渇きました。', 'Tôi khát nước rồi.'),
    (
      '病気',
      'びょうき',
      'byouki',
      'Bệnh',
      '病気で学校を休みました。',
      'Tôi nghỉ học vì bị bệnh.'
    ),
    ('風邪', 'かぜ', 'kaze', 'Cảm lạnh', '風邪をひきました。', 'Tôi bị cảm rồi.'),
    (
      '医者',
      'いしゃ',
      'isha',
      'Bác sĩ',
      '医者に行ったほうがいいです。',
      'Bạn nên đi khám bác sĩ.'
    ),
    ('疲れる', 'つかれる', 'tsukareru', 'Mệt', '今日はとても疲れました。', 'Hôm nay tôi rất mệt.'),
    (
      '寝坊',
      'ねぼう',
      'nebou',
      'Ngủ quên',
      '寝坊して遅刻しました。',
      'Tôi ngủ quên nên bị muộn.'
    ),
    (
      '健康',
      'けんこう',
      'kenkou',
      'Sức khỏe',
      '健康のために野菜を食べます。',
      'Tôi ăn rau để tốt cho sức khỏe.'
    ),
    (
      '運動',
      'うんどう',
      'undou',
      'Vận động, tập thể dục',
      '毎日少し運動します。',
      'Mỗi ngày tôi vận động một chút.'
    ),
  ],
  'cong-viec-van-phong': [
    (
      '仕事',
      'しごと',
      'shigoto',
      'Công việc',
      '仕事は九時からです。',
      'Công việc bắt đầu từ 9 giờ.'
    ),
    (
      '会議',
      'かいぎ',
      'kaigi',
      'Cuộc họp',
      '午後二時から会議があります。',
      'Có cuộc họp từ 2 giờ chiều.'
    ),
    (
      '社長',
      'しゃちょう',
      'shachou',
      'Giám đốc',
      '社長は今出張中です。',
      'Giám đốc hiện đang đi công tác.'
    ),
    (
      '社員',
      'しゃいん',
      'shain',
      'Nhân viên công ty',
      'この会社には社員が百人います。',
      'Công ty này có 100 nhân viên.'
    ),
    (
      '上司',
      'じょうし',
      'joushi',
      'Cấp trên',
      '上司に相談しました。',
      'Tôi đã trao đổi với cấp trên.'
    ),
    (
      '同僚',
      'どうりょう',
      'douryou',
      'Đồng nghiệp',
      '同僚と昼ご飯を食べます。',
      'Tôi ăn trưa với đồng nghiệp.'
    ),
    (
      '名刺',
      'めいし',
      'meishi',
      'Danh thiếp',
      '名刺を交換しましょう。',
      'Chúng ta trao đổi danh thiếp nhé.'
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
      '出張',
      'しゅっちょう',
      'shucchou',
      'Đi công tác',
      '来週大阪へ出張します。',
      'Tuần sau tôi đi công tác Osaka.'
    ),
    (
      '残業',
      'ざんぎょう',
      'zangyou',
      'Làm thêm giờ',
      '今日は残業があります。',
      'Hôm nay tôi phải làm thêm giờ.'
    ),
    (
      '給料',
      'きゅうりょう',
      'kyuuryou',
      'Tiền lương',
      '給料は毎月二十五日です。',
      'Lương trả vào ngày 25 hằng tháng.'
    ),
    (
      '休暇',
      'きゅうか',
      'kyuuka',
      'Nghỉ phép',
      '来月休暇を取ります。',
      'Tháng sau tôi xin nghỉ phép.'
    ),
    (
      '締め切り',
      'しめきり',
      'shimekiri',
      'Hạn chót',
      'レポートの締め切りは金曜日です。',
      'Hạn nộp báo cáo là thứ Sáu.'
    ),
    (
      '予定',
      'よてい',
      'yotei',
      'Kế hoạch, lịch trình',
      '明日の予定を確認します。',
      'Tôi kiểm tra lịch trình ngày mai.'
    ),
    (
      '連絡',
      'れんらく',
      'renraku',
      'Liên lạc',
      '遅れるときは連絡してください。',
      'Khi đến muộn hãy liên lạc.'
    ),
    (
      '相談',
      'そうだん',
      'soudan',
      'Trao đổi, hỏi ý kiến',
      '先生に相談します。',
      'Tôi sẽ hỏi ý kiến thầy.'
    ),
    (
      '説明',
      'せつめい',
      'setsumei',
      'Giải thích',
      'もう一度説明してください。',
      'Hãy giải thích lại một lần nữa.'
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
      '働く',
      'はたらく',
      'hataraku',
      'Làm việc',
      '父は銀行で働いています。',
      'Bố tôi làm việc ở ngân hàng.'
    ),
    (
      '会社員',
      'かいしゃいん',
      'kaishain',
      'Nhân viên văn phòng',
      '兄は会社員です。',
      'Anh trai tôi là nhân viên văn phòng.'
    ),
  ],
  'mau-sac-tinh-chat': [
    ('赤い', 'あかい', 'akai', 'Màu đỏ', '赤いりんごを買いました。', 'Tôi đã mua táo đỏ.'),
    (
      '青い',
      'あおい',
      'aoi',
      'Màu xanh dương',
      '今日は空が青いです。',
      'Hôm nay bầu trời xanh.'
    ),
    (
      '白い',
      'しろい',
      'shiroi',
      'Màu trắng',
      '白いシャツを着ます。',
      'Tôi mặc áo sơ mi trắng.'
    ),
    ('黒い', 'くろい', 'kuroi', 'Màu đen', '黒い猫がいます。', 'Có một con mèo đen.'),
    ('黄色い', 'きいろい', 'kiiroi', 'Màu vàng', '黄色い花が咲いています。', 'Hoa vàng đang nở.'),
    (
      '緑',
      'みどり',
      'midori',
      'Màu xanh lá',
      '公園は緑がきれいです。',
      'Cây xanh ở công viên rất đẹp.'
    ),
    (
      '茶色',
      'ちゃいろ',
      'chairo',
      'Màu nâu',
      '茶色のかばんがほしいです。',
      'Tôi muốn có cái cặp màu nâu.'
    ),
    ('色', 'いろ', 'iro', 'Màu sắc', '何色が好きですか。', 'Bạn thích màu gì?'),
    (
      '大きい',
      'おおきい',
      'ookii',
      'To, lớn',
      '大きい家に住みたいです。',
      'Tôi muốn sống trong ngôi nhà lớn.'
    ),
    ('小さい', 'ちいさい', 'chiisai', 'Nhỏ', 'この靴は小さいです。', 'Đôi giày này nhỏ.'),
    ('長い', 'ながい', 'nagai', 'Dài', '妹は髪が長いです。', 'Em gái tôi tóc dài.'),
    ('短い', 'みじかい', 'mijikai', 'Ngắn', '夏休みは短いです。', 'Kỳ nghỉ hè ngắn.'),
    ('丸い', 'まるい', 'marui', 'Tròn', '丸いテーブルがあります。', 'Có một cái bàn tròn.'),
    (
      '新しい',
      'あたらしい',
      'atarashii',
      'Mới',
      '新しい携帯を買いました。',
      'Tôi đã mua điện thoại mới.'
    ),
    ('古い', 'ふるい', 'furui', 'Cũ', 'このお寺はとても古いです。', 'Ngôi chùa này rất cổ.'),
    ('広い', 'ひろい', 'hiroi', 'Rộng', 'この公園は広いです。', 'Công viên này rộng.'),
    ('重い', 'おもい', 'omoi', 'Nặng', 'このかばんは重いです。', 'Cái cặp này nặng.'),
    ('軽い', 'かるい', 'karui', 'Nhẹ', 'このパソコンは軽いです。', 'Cái máy tính này nhẹ.'),
    (
      '明るい',
      'あかるい',
      'akarui',
      'Sáng sủa',
      'この部屋は明るいです。',
      'Căn phòng này sáng sủa.'
    ),
    ('暗い', 'くらい', 'kurai', 'Tối', '外はもう暗いです。', 'Bên ngoài trời đã tối.'),
  ],
  'dong-tu-hang-ngay': [
    ('見る', 'みる', 'miru', 'Xem, nhìn', '夜テレビを見ます。', 'Buổi tối tôi xem tivi.'),
    (
      '聞く',
      'きく',
      'kiku',
      'Nghe',
      'ラジオでニュースを聞きます。',
      'Tôi nghe tin tức trên radio.'
    ),
    ('読む', 'よむ', 'yomu', 'Đọc', '電車で本を読みます。', 'Tôi đọc sách trên tàu.'),
    ('書く', 'かく', 'kaku', 'Viết', 'ノートに名前を書きます。', 'Tôi viết tên vào vở.'),
    (
      '話す',
      'はなす',
      'hanasu',
      'Nói chuyện',
      '友達と日本語で話します。',
      'Tôi nói chuyện với bạn bằng tiếng Nhật.'
    ),
    ('会う', 'あう', 'au', 'Gặp', '駅で友達に会います。', 'Tôi gặp bạn ở nhà ga.'),
    (
      '待つ',
      'まつ',
      'matsu',
      'Chờ đợi',
      'ここで少し待ってください。',
      'Hãy đợi ở đây một chút.'
    ),
    (
      '使う',
      'つかう',
      'tsukau',
      'Sử dụng',
      'このペンを使ってもいいですか。',
      'Tôi dùng cái bút này được không?'
    ),
    ('作る', 'つくる', 'tsukuru', 'Làm, nấu', '母と料理を作ります。', 'Tôi nấu ăn cùng mẹ.'),
    (
      '洗う',
      'あらう',
      'arau',
      'Rửa, giặt',
      '毎晩お皿を洗います。',
      'Tối nào tôi cũng rửa bát.'
    ),
    ('開ける', 'あける', 'akeru', 'Mở', '窓を開けてもいいですか。', 'Tôi mở cửa sổ được không?'),
    ('閉める', 'しめる', 'shimeru', 'Đóng', 'ドアを閉めてください。', 'Hãy đóng cửa lại.'),
    (
      '教える',
      'おしえる',
      'oshieru',
      'Dạy, cho biết',
      '電話番号を教えてください。',
      'Hãy cho tôi biết số điện thoại.'
    ),
    (
      '習う',
      'ならう',
      'narau',
      'Học (từ ai đó)',
      '先生にピアノを習います。',
      'Tôi học piano với cô giáo.'
    ),
    ('住む', 'すむ', 'sumu', 'Sống, cư trú', '私はハノイに住んでいます。', 'Tôi sống ở Hà Nội.'),
    ('持つ', 'もつ', 'motsu', 'Cầm, mang', '傘を持っていますか。', 'Bạn có mang ô không?'),
    (
      '着る',
      'きる',
      'kiru',
      'Mặc (áo)',
      '寒いのでセーターを着ます。',
      'Trời lạnh nên tôi mặc áo len.'
    ),
    ('入る', 'はいる', 'hairu', 'Vào', '部屋に入ってください。', 'Mời vào phòng.'),
    (
      '出る',
      'でる',
      'deru',
      'Ra, đi ra',
      '七時に家を出ます。',
      'Tôi ra khỏi nhà lúc 7 giờ.'
    ),
    (
      '休む',
      'やすむ',
      'yasumu',
      'Nghỉ ngơi',
      '疲れたら少し休みましょう。',
      'Mệt thì nghỉ một chút nhé.'
    ),
  ],
  'cam-xuc-tinh-cach': [
    (
      '嬉しい',
      'うれしい',
      'ureshii',
      'Vui mừng',
      'プレゼントをもらって嬉しいです。',
      'Tôi vui vì được nhận quà.'
    ),
    (
      '悲しい',
      'かなしい',
      'kanashii',
      'Buồn',
      '友達が帰国して悲しいです。',
      'Bạn tôi về nước nên tôi buồn.'
    ),
    (
      '寂しい',
      'さびしい',
      'sabishii',
      'Cô đơn',
      '家族に会えなくて寂しいです。',
      'Không gặp được gia đình nên tôi thấy cô đơn.'
    ),
    (
      '怖い',
      'こわい',
      'kowai',
      'Sợ, đáng sợ',
      '夜の道は怖いです。',
      'Đường ban đêm thật đáng sợ.'
    ),
    (
      '恥ずかしい',
      'はずかしい',
      'hazukashii',
      'Xấu hổ, ngại',
      '人の前で歌うのは恥ずかしいです。',
      'Hát trước mọi người thật ngại.'
    ),
    (
      '心配',
      'しんぱい',
      'shinpai',
      'Lo lắng',
      '母はいつも私を心配しています。',
      'Mẹ lúc nào cũng lo cho tôi.'
    ),
    (
      '安心',
      'あんしん',
      'anshin',
      'Yên tâm',
      '試験に合格して安心しました。',
      'Đỗ kỳ thi rồi nên tôi yên tâm.'
    ),
    (
      '怒る',
      'おこる',
      'okoru',
      'Nổi giận',
      '父はめったに怒りません。',
      'Bố tôi hiếm khi nổi giận.'
    ),
    ('笑う', 'わらう', 'warau', 'Cười', '赤ちゃんがよく笑います。', 'Em bé hay cười.'),
    ('泣く', 'なく', 'naku', 'Khóc', '映画を見て泣きました。', 'Tôi đã khóc khi xem phim.'),
    (
      '優しい',
      'やさしい',
      'yasashii',
      'Hiền, tốt bụng',
      '私の先生はとても優しいです。',
      'Thầy giáo tôi rất hiền.'
    ),
    ('親切', 'しんせつ', 'shinsetsu', 'Tử tế', '日本の人は親切です。', 'Người Nhật rất tử tế.'),
    (
      '静か',
      'しずか',
      'shizuka',
      'Yên tĩnh',
      '図書館では静かにしてください。',
      'Trong thư viện hãy giữ yên lặng.'
    ),
    (
      '賑やか',
      'にぎやか',
      'nigiyaka',
      'Nhộn nhịp',
      'この町は夜も賑やかです。',
      'Thị trấn này ban đêm cũng nhộn nhịp.'
    ),
    (
      '真面目',
      'まじめ',
      'majime',
      'Nghiêm túc, chăm chỉ',
      '彼は真面目な学生です。',
      'Anh ấy là sinh viên chăm chỉ.'
    ),
    (
      '面白い',
      'おもしろい',
      'omoshiroi',
      'Thú vị, hay',
      'この本はとても面白いです。',
      'Cuốn sách này rất hay.'
    ),
    (
      '嫌い',
      'きらい',
      'kirai',
      'Ghét, không thích',
      '私は虫が嫌いです。',
      'Tôi ghét côn trùng.'
    ),
    (
      '大丈夫',
      'だいじょうぶ',
      'daijoubu',
      'Không sao, ổn',
      '大丈夫ですか。',
      'Bạn có sao không?'
    ),
  ],
};

const _titles = [
  'Kanji',
  'Kana',
  'Romaji',
  'Nghĩa',
  'Câu ví dụ',
  'Nghĩa câu ví dụ',
];

/// Chạy: dart run tool/make_sample_xlsx.dart <thư mục lưu file>
void main(List<String> args) {
  final folder = Directory(args.first)..createSync(recursive: true);
  for (final MapEntry(key: name, value: words) in topics.entries) {
    final path = '${folder.path}/tu-vung-$name.xlsx';
    File(path).writeAsBytesSync(_buildBook(words).encode()!);
    stdout.writeln('${words.length} từ → $path');
  }
}

Excel _buildBook(List<Row> words) {
  final book = Excel.createExcel();
  book.rename(book.getDefaultSheet()!, 'Tu vung');
  final sheet = book['Tu vung'];

  sheet.appendRow([for (final title in _titles) TextCellValue(title)]);
  for (var column = 0; column < _titles.length; column++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0))
        .cellStyle = CellStyle(bold: true);
  }
  for (final (kanji, kana, romaji, meaning, example, exampleVi) in words) {
    sheet.appendRow([
      for (final value in [kanji, kana, romaji, meaning, example, exampleVi])
        TextCellValue(value),
    ]);
  }
  for (final (column, width) in [
    (0, 10.0),
    (1, 14.0),
    (2, 12.0),
    (3, 22.0),
    (4, 34.0),
    (5, 42.0),
  ]) {
    sheet.setColumnWidth(column, width);
  }
  return book;
}
