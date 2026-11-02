// Tạo docs/ChibaKanji-so-do-va-giao-dien.docx: sơ đồ thiết kế (docs/diagrams/png)
// và ảnh màn hình (docs/screenshots) để đưa vào báo cáo.
//
// Chạy: dart run tool/make_report_docx.dart
// Cần có ảnh trước: bash tool/render_diagrams.sh và
// flutter test tool/screenshots/screenshots_test.dart --update-goldens
//
// File .docx là một file ZIP chứa các tài liệu XML (chuẩn Office Open XML);
// script ghép các tài liệu đó rồi nén bằng package archive.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

const output = 'docs/ChibaKanji-so-do-va-giao-dien.docx';

/// 1 cm = 360000 EMU (đơn vị đo ảnh của Word); 1 cm = 567 twip (lề trang).
const _emuPerCm = 360000;
const _twipPerCm = 567;

/// Khổ A4 và lề 2 cm.
const _pageShortCm = 21.0;
const _pageLongCm = 29.7;
const _marginCm = 2.0;

typedef Diagram = ({
  String file,
  String title,
  String type,
  List<String> notes
});
typedef Screen = ({String file, String caption});
typedef ScreenGroup = ({String title, String intro, List<Screen> screens});

const diagrams = <Diagram>[
  (
    file: '01-class-models',
    title: 'Sơ đồ lớp dữ liệu (model) và ORM',
    type: 'Class Diagram',
    notes: [
      'GenericEntity<ID> là lớp trừu tượng tổng quát (Generics) cho mọi nội '
          'dung có id, name, description; LearningContent bổ sung thứ tự hiển '
          'thị và trạng thái xuất bản.',
      'Category → Lesson → Vocabulary: một chủ đề có nhiều bài học, một bài '
          'có nhiều từ vựng (liên kết qua categoryId, lessonId).',
      'Progress lưu mức ghi nhớ của người học với một từ; markCorrect và '
          'markWrong trả về đối tượng mới thay vì sửa trực tiếp.',
      'UserProfile chứa StudyPreferences (quan hệ hợp thành); UserTopic gom '
          'các từ người học tự thêm vào chủ đề riêng.',
      'Mọi model có toMap() và fromMap(): ánh xạ đối tượng Dart ↔ document '
          'Firestore (ORM).',
    ],
  ),
  (
    file: '02-class-repositories',
    title: 'Sơ đồ lớp tầng truy cập dữ liệu (Repository)',
    type: 'Class Diagram',
    notes: [
      'Repository<T, ID> là interface tổng quát với 5 thao tác CRUD; mỗi '
          'loại dữ liệu có interface riêng gắn kiểu cụ thể (ghi trên mũi tên, '
          'ví dụ T = Progress).',
      'FirestoreRepository<T> viết thao tác Firestore một lần cho mọi kiểu T; '
          'lớp con chỉ khai báo collection và hàm chuyển đổi, nên ô thuộc tính '
          'của chúng chỉ ghi đường dẫn collection.',
      'InMemoryRepository<T> lưu trong bộ nhớ, dùng cho kiểm thử không cần '
          'mạng.',
      'CombinedVocabularyRepository gộp từ vựng chung (primary) với từ người '
          'học tự thêm (secondary).',
    ],
  ),
  (
    file: '03-class-providers',
    title: 'Sơ đồ lớp tầng trạng thái và dịch vụ (Provider)',
    type: 'Class Diagram',
    notes: [
      'Các lớp «ChangeNotifier» là Provider: màn hình lắng nghe và tự vẽ lại '
          'khi dữ liệu thay đổi.',
      'Provider chỉ phụ thuộc vào interface (AuthService, Repository, Speaker, '
          'MusicPlayer, ReminderScheduler) nên khi kiểm thử được thay bằng bản '
          'giả.',
      'Mixin LatestLoadGuard bảo đảm chỉ nhận kết quả của lần tải mới nhất, '
          'tránh lẫn dữ liệu khi đổi tài khoản nhanh.',
      'QuizProvider báo kết quả từng câu sang ProgressProvider (onAnswer); '
          'ProgressProvider báo sang UserProfileProvider để tính chuỗi ngày học '
          '(onStudyActivity).',
    ],
  ),
  (
    file: '04-seq-khoi-dong',
    title: 'Khởi động ứng dụng và đăng nhập khách',
    type: 'Sequence Diagram',
    notes: [
      'Người dùng mới không phải đăng ký ngay: ứng dụng tự đăng nhập ẩn danh. '
          'Sau khi xác thực, AuthGate tải song song nội dung học và dữ liệu '
          'riêng của đúng uid.',
    ],
  ),
  (
    file: '05-seq-dang-ky',
    title: 'Đăng ký tài khoản bằng email',
    type: 'Sequence Diagram',
    notes: [
      'Form kiểm tra dữ liệu trước khi gọi Firebase. Nếu đang là tài khoản '
          'khách, email được gắn vào chính tài khoản đó (linkWithCredential) '
          'nên giữ nguyên uid và tiến độ đã học. Lỗi của Firebase được đổi '
          'thành câu thông báo tiếng Việt.',
    ],
  ),
  (
    file: '06-seq-hoc-flashcard',
    title: 'Chọn bài học và học bằng flashcard',
    type: 'Sequence Diagram',
    notes: [
      'Mỗi lần vuốt thẻ, tiến độ được lưu ngay lên Firestore. Nếu lưu thất '
          'bại, thẻ được giữ lại để người học thử lại, không mất câu trả lời.',
    ],
  ),
  (
    file: '07-activity-on-tap',
    title: 'Thuật toán ôn tập ngắt quãng',
    type: 'Activity Diagram',
    notes: [
      'Trả lời đúng thì từ lên một mức ghi nhớ (tối đa 5), sai thì về mức 1. '
          'Khoảng cách tới lần ôn tiếp theo tăng theo mức: 1, 3, 7, 14, 30 '
          'ngày. Quy tắc áp dụng cho cả flashcard và quiz.',
    ],
  ),
  (
    file: '08-seq-quiz',
    title: 'Làm quiz và lưu kết quả',
    type: 'Sequence Diagram',
    notes: [
      'QuizGenerator tạo câu hỏi 4 dạng từ các từ đã học. Mỗi câu trả lời cập '
          'nhật tiến độ của từ; hết quiz thì lượt làm (QuizAttempt) được lưu '
          'vào lịch sử. Màn kết quả cho ôn lại ngay các từ sai bằng flashcard.',
    ],
  ),
  (
    file: '09-activity-thi-thu',
    title: 'Thi thử có giới hạn thời gian',
    type: 'Activity Diagram',
    notes: [
      'Đồng hồ trừ mỗi giây, hết giờ thì tự nộp bài. Câu chưa làm tính là '
          'sai; đạt từ 60% trở lên thì đóng dấu 合格 (đỗ). Thoát giữa chừng thì '
          'không chấm và không lưu.',
    ],
  ),
];

typedef Evidence = ({String file, String title, List<String> notes});

/// Ảnh Firebase Console trong docs/firebase (chụp thủ công).
const firebaseEvidence = <Evidence>[
  (
    file: 'fb-01-authentication',
    title: 'Tài khoản trong Firebase Authentication',
    notes: [
      'Mỗi người dùng có một UID; tài khoản khách (anonymous) được tạo tự '
          'động khi mở ứng dụng lần đầu, tài khoản email/Google khi đăng ký.',
    ],
  ),
  (
    file: 'fb-02-categories',
    title: 'Cấu trúc Cloud Firestore và collection categories',
    notes: [
      'Bốn collection gốc: categories, lessons, vocabularies (nội dung học '
          'dùng chung) và users (dữ liệu riêng của từng người).',
      'Document cat_family là bản lưu của đối tượng Category qua toMap().',
    ],
  ),
  (
    file: 'fb-03-lessons',
    title: 'Collection lessons: quan hệ bài học thuộc chủ đề',
    notes: [
      'Trường categoryId = "cat_family" nối bài học với chủ đề (quan hệ một '
          'chủ đề có nhiều bài học); vocabularyCount = 5 là số từ của bài.',
    ],
  ),
  (
    file: 'fb-04-vocabularies',
    title: 'Collection vocabularies: một từ vựng',
    notes: [
      'Các trường kanji, kana, romaji, meaning, câu ví dụ và lessonId tương '
          'ứng đúng các thuộc tính của lớp Vocabulary (ORM).',
    ],
  ),
  (
    file: 'fb-05-ho-so-moi',
    title: 'Hồ sơ của tài khoản mới, chưa học',
    notes: [
      'currentStreak = 0, lastStudyDate = null và chưa có collection con '
          'progress: người dùng chưa học từ nào.',
    ],
  ),
  (
    file: 'fb-06-ho-so-da-hoc',
    title: 'Hồ sơ của tài khoản đã học nhiều ngày',
    notes: [
      'So với tài khoản mới ở hình trên: khi học, ứng dụng cập nhật '
          'lastStudyDate và chuỗi ngày '
          '(longestStreak = 2), đồng thời tạo hai collection con progress và '
          'quizAttempts dưới users/{uid}.',
    ],
  ),
  (
    file: 'fb-07-progress-truoc',
    title: 'TRƯỚC khi học bài "Thành viên gia đình" (users/{uid}/progress)',
    notes: [
      'Mỗi từ đã học là một document. Bài "Thành viên gia đình" gồm 5 từ '
          'v_family_1 đến v_family_5; lúc này ngay sau my_…_54 là v_family_6, '
          'tức là chưa có từ nào của bài này.',
      'Ví dụ một từ đã học: v_food_1 trả lời đúng lúc 16:38 ngày 27/10 nên '
          'memoryLevel = 2 và nextReviewAt = 30/10, đúng 3 ngày theo khoảng ôn '
          'của mức 2.',
      'Các document my_… là từ người học tự import vào Kho từ của tôi.',
    ],
  ),
  (
    file: 'fb-08-progress-sau',
    title: 'SAU khi học bằng flashcard: có thêm v_family_1 đến v_family_4',
    notes: [
      'Cùng tài khoản, 10 phút sau: học bài bằng flashcard (bấm "Đã nhớ") '
          'thì ứng dụng tạo ngay các document v_family_1 đến v_family_4.',
      'v_family_1: lastReviewedAt = 16:48 ngày 27/10, memoryLevel = 2, '
          'correctCount = 1, isLearned = true, nextReviewAt = 30/10 (+3 ngày).',
      'Hồ sơ bên trái: currentStreak = 2, lastStudyDate = 2026-10-27.',
    ],
  ),
  (
    file: 'fb-09-progress-len-muc-3',
    title: 'Trả lời đúng thêm lần nữa trong Quiz nhanh: lên mức 3',
    notes: [
      'v_family_4 được trả lời đúng ở flashcard rồi đúng tiếp trong Quiz '
          'nhanh (16:48:53): correctCount = 2, reviewCount = 2, memoryLevel = 3.',
      'nextReviewAt = 03/11, tức 7 ngày sau: khoảng ôn giãn ra theo mức ghi '
          'nhớ (1 → 3 → 7 → 14 → 30 ngày). Quiz cập nhật tiến độ giống như '
          'flashcard.',
    ],
  ),
  (
    file: 'fb-10-quiz-attempts',
    title: 'Lịch sử quiz và bài thi (users/{uid}/quizAttempts)',
    notes: [
      'Mỗi lượt làm là một document: quick-… (Quiz nhanh), lesson-… (quiz '
          'theo bài) và exam-… (Thi thử), lưu điểm và các đáp án đã chọn.',
    ],
  ),
];

const screenGroups = <ScreenGroup>[
  (
    title: 'Khởi động và tài khoản',
    intro: 'Màn khởi động có Chibi chuyển động và lời giới thiệu bằng giọng '
        'nói, sau đó sang đăng ký hoặc đăng nhập.',
    screens: [
      (file: '01-khoi-dong', caption: 'Màn khởi động'),
      (file: '02-dang-ky', caption: 'Đăng ký'),
      (file: '03-dang-nhap', caption: 'Đăng nhập'),
    ],
  ),
  (
    title: 'Ôn tập và học mới',
    intro: 'Trang chủ cho biết số từ đến hạn ôn và biểu đồ ghi nhớ; tab Học '
        'mới chọn cấp độ, chủ đề, bài học rồi học bằng flashcard.',
    screens: [
      (file: '04-on-tap', caption: 'Trang chủ (Ôn tập)'),
      (file: '05-hoc-moi', caption: 'Học mới: chủ đề'),
      (file: '06-bai-hoc', caption: 'Danh sách bài học'),
      (file: '07-flashcard', caption: 'Flashcard: mặt trước'),
      (file: '08-flashcard-mat-sau', caption: 'Flashcard: mặt sau'),
      (file: '09-ket-qua-hoc', caption: 'Kết quả phiên học'),
    ],
  ),
  (
    title: 'Quiz',
    intro: 'Quiz nhanh từ các từ đã học, có giải thích đáp án và ôn lại từ '
        'sai.',
    screens: [
      (file: '10-quiz', caption: 'Câu hỏi quiz'),
      (file: '11-quiz-giai-thich', caption: 'Trả lời sai: giải thích'),
      (file: '12-ket-qua-quiz', caption: 'Kết quả quiz'),
    ],
  ),
  (
    title: 'Thi thử',
    intro: 'Bài thi trắc nghiệm có giờ như đề JLPT, nộp bài mới chấm điểm.',
    screens: [
      (file: '13-thi-thu', caption: 'Chọn phạm vi thi'),
      (file: '14-bai-thi', caption: 'Làm bài có đồng hồ'),
      (file: '15-ket-qua-thi', caption: 'Kết quả bài thi'),
    ],
  ),
  (
    title: 'Sổ từ và Kho từ của tôi',
    intro: 'Tra cứu, lọc và xem chi tiết từ đã học; tự thêm từ hoặc import từ '
        'file Excel, CSV, PDF.',
    screens: [
      (file: '16-so-tu', caption: 'Sổ từ'),
      (file: '17-chi-tiet-tu', caption: 'Chi tiết từ'),
      (file: '18-kho-tu', caption: 'Kho từ của tôi'),
      (file: '19-them-tu', caption: 'Thêm từ mới'),
      (file: '20-import', caption: 'Import từ file'),
    ],
  ),
  (
    title: 'Cá nhân và cài đặt',
    intro: 'Hồ sơ, tiến độ, thành tích, lịch sử quiz, tài khoản, nhắc học, '
        'âm thanh và giao diện sáng/tối.',
    screens: [
      (file: '21-ca-nhan', caption: 'Cá nhân'),
      (file: '22-tuy-chon-hoc', caption: 'Tùy chọn học'),
      (file: '23-thanh-tich', caption: 'Thành tích'),
      (file: '24-lich-su-quiz', caption: 'Lịch sử quiz'),
      (file: '25-tai-khoan', caption: 'Tài khoản'),
      (file: '26-huong-dan', caption: 'Hướng dẫn sử dụng'),
      (file: '27-nhac-hoc', caption: 'Cài đặt nhắc học'),
      (file: '28-am-thanh', caption: 'Cài đặt âm thanh'),
      (file: '29-giao-dien-toi', caption: 'Giao diện tối'),
    ],
  ),
];

/// Ảnh đã đưa vào file: tên trong word/media và nội dung.
final _media = <String, Uint8List>{};
var _drawingId = 0;

void main() {
  final body = StringBuffer()
    ..write(_coverPage())
    ..write(_tableOfContents())
    ..write(_heading('PHẦN 1. SƠ ĐỒ THIẾT KẾ', 1));

  final portrait = _section(landscape: false);
  body.write(_paragraph(
    'Các sơ đồ được vẽ bằng Mermaid từ mã nguồn hiện tại của ứng dụng: tên '
    'lớp, thuộc tính, phương thức và thứ tự gọi hàm đều lấy từ code. Mã nguồn '
    'sơ đồ nằm trong thư mục docs/diagrams của repository.',
  ));
  body.write(_sectionBreak(portrait));

  for (final (index, diagram) in diagrams.indexed) {
    final png = File('docs/diagrams/png/${diagram.file}.png');
    final size = _pngSize(png);
    // Sơ đồ ngang đặt trên trang ngang để chữ đủ lớn khi in.
    final landscape = size.width > size.height * 1.15;
    final page = _section(landscape: landscape);
    body
      ..write(_heading('1.${index + 1}. ${diagram.title}', 2))
      ..write(_paragraph('Loại sơ đồ: ${diagram.type}', italic: true))
      ..write(_image(png,
          maxWidthCm: page.contentWidth,
          maxHeightCm: page.contentHeight - 5.5,
          center: true))
      ..write(_caption('Hình 1.${index + 1}. ${diagram.title}'));
    for (final note in diagram.notes) {
      body.write(_bullet(note));
    }
    body.write(_sectionBreak(page));
  }

  body.write(_heading('PHẦN 2. GIAO DIỆN MÀN HÌNH', 1));
  body.write(_paragraph(
    'Ảnh chụp từ ứng dụng chạy với dữ liệu mẫu, kích thước điện thoại '
    '412 × 892 điểm ảnh logic.',
  ));
  var figure = 0;
  for (final (index, group) in screenGroups.indexed) {
    body
      ..write(_heading('2.${index + 1}. ${group.title}', 2))
      ..write(_paragraph(group.intro));
    final captions = <String>[];
    for (final screen in group.screens) {
      figure++;
      captions.add('Hình 2.$figure. ${screen.caption}');
    }
    body.write(_screenTable(group.screens, captions));
  }
  body.write(_sectionBreak(portrait));

  body
    ..write(_heading('PHẦN 3. MINH CHỨNG FIREBASE', 1))
    ..write(_paragraph(
      'Ảnh chụp Firebase Console của project csdlck dùng chung của nhóm: '
      'tài khoản trong Firebase Authentication, cấu trúc Cloud Firestore và '
      'dữ liệu được ứng dụng ghi lại khi người học học và làm quiz.',
    ));
  for (final (index, evidence) in firebaseEvidence.indexed) {
    body
      ..write(_heading('3.${index + 1}. ${evidence.title}', 2))
      ..write(_image(File('docs/firebase/${evidence.file}.png'),
          maxWidthCm: portrait.contentWidth, maxHeightCm: 11, center: true))
      ..write(_caption('Hình 3.${index + 1}. ${evidence.title}'));
    for (final note in evidence.notes) {
      body.write(_bullet(note));
    }
  }
  body
    ..write(_heading(
        '3.${firebaseEvidence.length + 1}. Security Rules (firestore.rules)',
        2))
    ..write(_paragraph(
      'Nội dung học chỉ được đọc, không ai ghi được từ ứng dụng; dữ liệu cá '
      'nhân dưới users/{userId} chỉ chính chủ (uid trùng userId) mới đọc và '
      'ghi được.',
    ));
  for (final line in File('firestore.rules').readAsLinesSync()) {
    body.write(_code(line));
  }
  body.write(_sectionBreak(portrait, last: true));

  final archive = Archive();
  void add(String name, List<int> bytes) =>
      archive.addFile(ArchiveFile(name, bytes.length, bytes));

  add('[Content_Types].xml', _xmlBytes(_contentTypes()));
  add('_rels/.rels', _xmlBytes(_rootRels()));
  add('docProps/core.xml', _xmlBytes(_coreProps()));
  add('word/document.xml', _xmlBytes(_document(body.toString())));
  add('word/styles.xml', _xmlBytes(_styles()));
  add('word/settings.xml', _xmlBytes(_settings()));
  add('word/numbering.xml', _xmlBytes(_numbering()));
  add('word/footer1.xml', _xmlBytes(_footer()));
  add('word/_rels/document.xml.rels', _xmlBytes(_documentRels()));
  _media.forEach((name, bytes) => add('word/media/$name', bytes));

  File(output).writeAsBytesSync(ZipEncoder().encode(archive)!);
  stdout.writeln('Đã tạo $output (${File(output).lengthSync() ~/ 1024} KB, '
      '${_media.length} ảnh)');
}

List<int> _xmlBytes(String xml) => utf8
    .encode('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n$xml');

String _esc(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

// ------------------------------------------------------------ Khối nội dung

String _run(String text, {bool bold = false, bool italic = false, int? size}) {
  final props = [
    if (bold) '<w:b/>',
    if (italic) '<w:i/>',
    if (size != null)
      '<w:sz w:val="${size * 2}"/><w:szCs w:val="${size * 2}"/>',
  ].join();
  return '<w:r>${props.isEmpty ? '' : '<w:rPr>$props</w:rPr>'}'
      '<w:t xml:space="preserve">${_esc(text)}</w:t></w:r>';
}

String _paragraph(String text,
    {bool italic = false,
    bool bold = false,
    String align = 'both',
    int? size}) {
  return '<w:p><w:pPr><w:jc w:val="$align"/></w:pPr>'
      '${_run(text, italic: italic, bold: bold, size: size)}</w:p>';
}

String _heading(String text, int level) =>
    '<w:p><w:pPr><w:pStyle w:val="Heading$level"/></w:pPr>${_run(text)}</w:p>';

/// Một dòng mã nguồn: font đơn cách, giữ nguyên khoảng trắng đầu dòng.
String _code(String line) => '<w:p><w:pPr><w:spacing w:after="0" '
    'w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:rPr>'
    '<w:rFonts w:ascii="Consolas" w:hAnsi="Consolas" w:cs="Consolas"/>'
    '<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr>'
    '<w:t xml:space="preserve">${_esc(line)}</w:t></w:r></w:p>';

String _caption(String text) =>
    '<w:p><w:pPr><w:pStyle w:val="Caption"/></w:pPr>${_run(text)}</w:p>';

String _bullet(String text) => '<w:p><w:pPr><w:pStyle w:val="ListParagraph"/>'
    '<w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr>'
    '<w:jc w:val="both"/></w:pPr>${_run(text)}</w:p>';

String _pageBreak() => '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';

String _coverPage() {
  final lines = StringBuffer()
    ..write(_paragraph('TRƯỜNG ĐẠI HỌC PHENIKAA', bold: true, align: 'center'))
    ..write(_paragraph('KHOA CÔNG NGHỆ THÔNG TIN', bold: true, align: 'center'))
    ..write(_blank(5))
    ..write('<w:p><w:pPr><w:pStyle w:val="Title"/></w:pPr>'
        '${_run('ChibaKanji')}</w:p>')
    ..write(_paragraph('Ứng dụng học từ vựng tiếng Nhật',
        align: 'center', size: 16))
    ..write(_blank(2))
    ..write(_paragraph('SƠ ĐỒ THIẾT KẾ VÀ GIAO DIỆN ỨNG DỤNG',
        bold: true, align: 'center', size: 16))
    ..write(_blank(5))
    ..write(_paragraph('Nhóm thực hiện:', bold: true, align: 'left'))
    ..write(_paragraph('Phạm Khương Duy – MSSV: ……………', align: 'left'))
    ..write(_paragraph('Nguyễn Vũ Trường Sơn – MSSV: ……………', align: 'left'))
    ..write(_paragraph(
        'Mã nguồn: https://github.com/Pham-Duyy/Nhom_App_LearnJPVocab',
        align: 'left'))
    ..write(_blank(4))
    ..write(_paragraph('Hà Nội, 2026', italic: true, align: 'center'))
    ..write(_pageBreak());
  return lines.toString();
}

String _blank(int count) => List.filled(count, '<w:p/>').join();

/// Mục lục: Word điền nội dung khi mở file (settings có updateFields).
String _tableOfContents() =>
    '${_paragraph('MỤC LỤC', bold: true, align: 'center', size: 15)}'
    '<w:p><w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
    '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-2" \\h \\z \\u </w:instrText></w:r>'
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    '${_run('Nhấn chuột phải vào đây và chọn Update Field để hiện mục lục.', italic: true)}'
    '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
    '${_pageBreak()}';

// ---------------------------------------------------------------------- Ảnh

({int width, int height}) _pngSize(File file) {
  final bytes = file.readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  return (width: data.getUint32(16), height: data.getUint32(20));
}

String _image(File file,
    {required double maxWidthCm,
    required double maxHeightCm,
    bool center = false}) {
  final size = _pngSize(file);
  var widthCm = maxWidthCm;
  var heightCm = widthCm * size.height / size.width;
  if (heightCm > maxHeightCm) {
    heightCm = maxHeightCm;
    widthCm = heightCm * size.width / size.height;
  }
  final cx = (widthCm * _emuPerCm).round();
  final cy = (heightCm * _emuPerCm).round();
  final name = file.uri.pathSegments.last;
  final mediaName = '${_media.length + 1}-$name';
  _media[mediaName] = file.readAsBytesSync();
  final relId = 'rIdImg${_media.length}';
  final id = ++_drawingId;
  final drawing = '<w:r><w:drawing>'
      '<wp:inline distT="0" distB="0" distL="0" distR="0">'
      '<wp:extent cx="$cx" cy="$cy"/>'
      '<wp:docPr id="$id" name="${_esc(name)}"/>'
      '<wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/>'
      '</wp:cNvGraphicFramePr>'
      '<a:graphic><a:graphicData '
      'uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
      '<pic:pic><pic:nvPicPr><pic:cNvPr id="$id" name="${_esc(name)}"/>'
      '<pic:cNvPicPr/></pic:nvPicPr>'
      '<pic:blipFill><a:blip r:embed="$relId"/><a:stretch><a:fillRect/>'
      '</a:stretch></pic:blipFill>'
      '<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="$cx" cy="$cy"/>'
      '</a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
      '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r>';
  return '<w:p><w:pPr><w:keepNext/>'
      '${center ? '<w:jc w:val="center"/>' : ''}</w:pPr>$drawing</w:p>';
}

/// Ảnh màn hình xếp 3 cột, chú thích dưới mỗi ảnh; bảng không có viền.
String _screenTable(List<Screen> screens, List<String> captions) {
  const columns = 3;
  const contentCm = _pageShortCm - 2 * _marginCm;
  final cellTwip = (contentCm / columns * _twipPerCm).round();
  final rows = StringBuffer();
  for (var start = 0; start < screens.length; start += columns) {
    rows.write('<w:tr><w:trPr><w:cantSplit/></w:trPr>');
    for (var col = 0; col < columns; col++) {
      final index = start + col;
      final content = index < screens.length
          ? _image(File('docs/screenshots/${screens[index].file}.png'),
                  maxWidthCm: contentCm / columns - 0.6,
                  maxHeightCm: 11,
                  center: true) +
              _caption(captions[index])
          : '<w:p/>';
      rows.write('<w:tc><w:tcPr><w:tcW w:w="$cellTwip" w:type="dxa"/>'
          '</w:tcPr>$content</w:tc>');
    }
    rows.write('</w:tr>');
  }
  final grid = List.filled(columns, '<w:gridCol w:w="$cellTwip"/>').join();
  return '<w:tbl><w:tblPr><w:tblW w:w="${cellTwip * columns}" w:type="dxa"/>'
      '<w:jc w:val="center"/>'
      '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/>'
      '<w:bottom w:val="nil"/><w:right w:val="nil"/>'
      '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
      '<w:tblLayout w:type="fixed"/>'
      '</w:tblPr><w:tblGrid>$grid</w:tblGrid>$rows</w:tbl><w:p/>';
}

// ------------------------------------------------------------------ Trang

typedef Section = ({bool landscape, double contentWidth, double contentHeight});

Section _section({required bool landscape}) {
  final width = landscape ? _pageLongCm : _pageShortCm;
  final height = landscape ? _pageShortCm : _pageLongCm;
  return (
    landscape: landscape,
    contentWidth: width - 2 * _marginCm,
    contentHeight: height - 2 * _marginCm,
  );
}

String _sectPr(Section section) {
  final w =
      ((section.landscape ? _pageLongCm : _pageShortCm) * _twipPerCm).round();
  final h =
      ((section.landscape ? _pageShortCm : _pageLongCm) * _twipPerCm).round();
  final margin = (_marginCm * _twipPerCm).round();
  return '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter"/>'
      '<w:pgSz w:w="$w" w:h="$h"'
      '${section.landscape ? ' w:orient="landscape"' : ''}/>'
      '<w:pgMar w:top="$margin" w:right="$margin" w:bottom="$margin" '
      'w:left="$margin" w:header="709" w:footer="709" w:gutter="0"/>'
      '</w:sectPr>';
}

/// Kết thúc một section (mỗi section có khổ trang riêng). Section cuối cùng
/// đặt trực tiếp trong body.
String _sectionBreak(Section section, {bool last = false}) =>
    last ? _sectPr(section) : '<w:p><w:pPr>${_sectPr(section)}</w:pPr></w:p>';

// ------------------------------------------------------------- Tài liệu XML

String _document(String body) => '<w:document '
    'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
    'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
    'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
    'xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'
    '<w:body>$body</w:body></w:document>';

String _footer() =>
    '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:p><w:pPr><w:jc w:val="center"/></w:pPr>'
    '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
    '<w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>'
    '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>';

String _styles() {
  String heading(int level, int size) =>
      '<w:style w:type="paragraph" w:styleId="Heading$level">'
      '<w:name w:val="heading $level"/><w:basedOn w:val="Normal"/>'
      '<w:next w:val="Normal"/><w:qFormat/>'
      '<w:pPr><w:keepNext/><w:spacing w:before="${level == 1 ? 360 : 240}" '
      'w:after="120"/><w:jc w:val="left"/>'
      '<w:outlineLvl w:val="${level - 1}"/></w:pPr>'
      '<w:rPr><w:b/><w:color w:val="1F3A5F"/><w:sz w:val="${size * 2}"/>'
      '<w:szCs w:val="${size * 2}"/></w:rPr></w:style>';
  return '<w:styles '
      'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:docDefaults><w:rPrDefault><w:rPr>'
      '<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" '
      'w:eastAsia="MS Mincho" w:cs="Times New Roman"/>'
      '<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="vi-VN"/>'
      '</w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>'
      '<w:spacing w:after="120" w:line="312" w:lineRule="auto"/>'
      '</w:pPr></w:pPrDefault></w:docDefaults>'
      '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">'
      '<w:name w:val="Normal"/><w:qFormat/></w:style>'
      '${heading(1, 16)}${heading(2, 14)}'
      '<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/>'
      '<w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/>'
      '</w:pPr><w:rPr><w:b/><w:color w:val="1F3A5F"/><w:sz w:val="64"/>'
      '<w:szCs w:val="64"/></w:rPr></w:style>'
      '<w:style w:type="paragraph" w:styleId="Caption"><w:name w:val="caption"/>'
      '<w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="60" '
      'w:after="200"/><w:jc w:val="center"/></w:pPr><w:rPr><w:i/>'
      '<w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>'
      '<w:style w:type="paragraph" w:styleId="ListParagraph">'
      '<w:name w:val="List Paragraph"/><w:basedOn w:val="Normal"/>'
      '<w:pPr><w:ind w:left="720"/></w:pPr></w:style>'
      '</w:styles>';
}

String _numbering() => '<w:numbering '
    'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:abstractNum w:abstractNumId="0"><w:lvl w:ilvl="0">'
    '<w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="•"/>'
    '<w:lvlJc w:val="left"/><w:pPr><w:ind w:left="720" w:hanging="360"/>'
    '</w:pPr></w:lvl></w:abstractNum>'
    '<w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num></w:numbering>';

String _settings() => '<w:settings '
    'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:defaultTabStop w:val="720"/><w:updateFields w:val="true"/>'
    '<w:compat><w:compatSetting w:name="compatibilityMode" '
    'w:uri="http://schemas.microsoft.com/office/word" w:val="15"/></w:compat>'
    '</w:settings>';

String _contentTypes() =>
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" '
    'ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="xml" ContentType="application/xml"/>'
    '<Default Extension="png" ContentType="image/png"/>'
    '<Override PartName="/word/document.xml" ContentType="application/'
    'vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
    '<Override PartName="/word/styles.xml" ContentType="application/'
    'vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
    '<Override PartName="/word/settings.xml" ContentType="application/'
    'vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>'
    '<Override PartName="/word/numbering.xml" ContentType="application/'
    'vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/>'
    '<Override PartName="/word/footer1.xml" ContentType="application/'
    'vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>'
    '<Override PartName="/docProps/core.xml" '
    'ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
    '</Types>';

String _rootRels() => '<Relationships '
    'xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/'
    'officeDocument/2006/relationships/officeDocument" '
    'Target="word/document.xml"/>'
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/'
    '2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
    '</Relationships>';

String _documentRels() {
  const base =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
  final images = [
    for (final (index, name) in _media.keys.indexed)
      '<Relationship Id="rIdImg${index + 1}" Type="$base/image" '
          'Target="media/${_esc(name)}"/>',
  ].join();
  return '<Relationships '
      'xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rIdStyles" Type="$base/styles" Target="styles.xml"/>'
      '<Relationship Id="rIdSettings" Type="$base/settings" '
      'Target="settings.xml"/>'
      '<Relationship Id="rIdNumbering" Type="$base/numbering" '
      'Target="numbering.xml"/>'
      '<Relationship Id="rIdFooter" Type="$base/footer" Target="footer1.xml"/>'
      '$images</Relationships>';
}

String _coreProps() => '<cp:coreProperties '
    'xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
    'xmlns:dc="http://purl.org/dc/elements/1.1/" '
    'xmlns:dcterms="http://purl.org/dc/terms/" '
    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    '<dc:title>ChibaKanji – Sơ đồ thiết kế và giao diện</dc:title>'
    '<dc:creator>Nhóm ChibaKanji</dc:creator>'
    '<dcterms:created xsi:type="dcterms:W3CDTF">'
    '${DateTime.now().toUtc().toIso8601String().split('.').first}Z'
    '</dcterms:created></cp:coreProperties>';
