# ChibaKanji 🇯🇵

Ứng dụng Flutter học và ôn tập từ vựng tiếng Nhật JLPT N5 và từ vựng chuyên ngành cho thực tập sinh, theo phiên ngắn mỗi ngày với thuật toán ôn tập ngắt quãng. Dữ liệu lưu trên Firebase.

## Chức năng chính

Ứng dụng có 5 tab trên Bottom Navigation Bar:

| Tab | Chức năng |
|---|---|
| 復 **Ôn tập** | Số từ đến hạn ôn, 5 mức ghi nhớ, mục tiêu hôm nay, chuỗi ngày học, Quiz nhanh |
| 学 **Học mới** | Chọn cấp độ (N5 hoặc Ngành), chủ đề, bài học rồi học bằng flashcard |
| 試 **Thi thử** | Bài trắc nghiệm có giờ như đề JLPT, nộp bài mới chấm, đóng dấu 合格 / 不合格 |
| 辞 **Sổ từ** | Tìm, lọc và xem chi tiết từ đã học, đánh dấu yêu thích; vào **Kho từ của tôi** |
| 私 **Cá nhân** | Hồ sơ, tài khoản, tùy chọn học, nhắc học, thành tích, lịch sử quiz, giao diện sáng/tối |

Các chức năng khác:

- **Flashcard:** lật thẻ, vuốt hoặc bấm Nhớ/Chưa nhớ, nghe phát âm, xem kết quả phiên học.
- **Quiz:** 4 dạng câu hỏi (kana → nghĩa, nghĩa → kana, kanji → nghĩa, nghe → từ), giải thích đáp án, lưu lịch sử; đúng thì từ lên mức ghi nhớ, sai thì về mức 1; ôn lại ngay các từ sai bằng flashcard.
- **Ôn tập ngắt quãng:** 5 mức ghi nhớ, lịch ôn 1/3/7/14/30 ngày.
- **Kho từ của tôi:** tự tạo chủ đề, thêm từ, import từ file Excel, CSV, PDF hoặc dán danh sách; từ tự thêm học được như từ có sẵn.
- **Tài khoản:** dùng thử không cần đăng ký (khách), đăng ký/đăng nhập bằng email hoặc Google; tài khoản khách được liên kết nên không mất tiến độ; đổi mật khẩu; xóa tài khoản kèm toàn bộ dữ liệu học.
- **Nhắc học:** thông báo mỗi ngày vào giờ tự chọn (Android/iOS) và lời nhắc trên trang chủ.
- **Âm thanh:** lời giới thiệu và lời chào tiếng Nhật theo giờ, nhạc nền chuông gió; bật/tắt và chỉnh âm lượng.
- **Nội dung:** 150 từ N5 (9 chủ đề) và 60 từ chuyên ngành (Chế biến thực phẩm, Xây dựng, Điều dưỡng).

## Công nghệ

- Flutter 3.47 / Dart 3, Material Design, giao diện phong cách washi với font Shippori Mincho
- Provider để quản lý trạng thái
- Repository tổng quát `Repository<T, ID>` với các bản Firestore, bộ nhớ (test) và `CombinedRepository<T>`
- Firebase Authentication và Cloud Firestore
- `flutter_tts` (phát âm), `audioplayers` (nhạc nền), `flutter_local_notifications` (nhắc học), `shared_preferences` (ghi nhớ trên thiết bị)
- Flutter Test: hơn 300 test, xem [test/README.md](test/README.md)

## Cấu trúc thư mục

| Thư mục | Nội dung |
|---|---|
| [`lib/models`](lib/models) | Model và ORM `toMap`/`fromMap` |
| [`lib/repositories`](lib/repositories) | Truy cập dữ liệu: Firestore, mock, kho gộp |
| [`lib/providers`](lib/providers) | Trạng thái và quy tắc nghiệp vụ của từng màn hình |
| [`lib/screens`](lib/screens) | Màn hình, chia theo chức năng |
| [`lib/widgets`](lib/widgets) | Widget dùng chung |
| [`lib/data`](lib/data) | Dữ liệu mẫu, bộ tạo câu hỏi quiz, đọc file import, nạp dữ liệu |
| [`test`](test) | Unit test và widget test |
| [`docs`](docs) | Sơ đồ thiết kế ([xem](docs/so-do-thiet-ke.md)), ảnh màn hình ([`docs/screenshots`](docs/screenshots)) và bản Word tổng hợp |

## Chạy dự án

```bash
git clone https://github.com/Pham-Duyy/Nhom_App_LearnJPVocab.git
cd Nhom_App_LearnJPVocab
flutter pub get
flutter run -d edge
```

Kiểm tra trước khi commit (GitHub Actions cũng chạy các bước này mỗi lần push):

```bash
dart format lib test
flutter analyze
flutter test
```

## Nạp nội dung lên Firestore

Nội dung học (`categories`, `lessons`, `vocabularies`) chỉ đọc được từ app; [`firestore.rules`](firestore.rules) chặn mọi thao tác ghi để người dùng không sửa được bài học. Khi thêm nội dung mới vào [`mock_learning_data.dart`](lib/data/mock/mock_learning_data.dart):

1. Trên Firebase Console, tạm đổi `allow write: if false;` thành `allow write: if request.auth != null;` cho 3 collection nội dung.
2. Chạy app một lần với cờ nạp dữ liệu; app chỉ thêm những document còn thiếu:
   ```bash
   flutter run -d edge --dart-define=SEED_CONTENT=true
   ```
3. Đổi Rules về lại `allow write: if false;`.

Chạy bình thường (không có cờ) thì app không ghi gì vào nội dung học.

## Phân công nhóm

| Thành viên | Công việc |
|---|---|
| Phạm Khương Duy | Kiến trúc dữ liệu, Provider, Firebase, các chức năng học, quiz, thi thử, kho từ, kiểm thử |
| Nguyễn Vũ Trường Sơn | Hỗ trợ phát triển, flashcard lật thẻ, tài liệu báo cáo |

> Nhóm cập nhật họ tên đầy đủ, mã số sinh viên và phần đóng góp chi tiết của từng thành viên trước khi nộp bài.

## Trạng thái

- [x] Bottom Navigation Bar 5 tab
- [x] Ôn tập ngắt quãng, Học mới, Flashcard, Sổ từ, Cá nhân
- [x] Firebase Authentication (khách, email, Google) và Cloud Firestore
- [x] Quiz, kết quả và lịch sử quiz
- [x] Thi thử có giờ
- [x] Phát âm tiếng Nhật
- [x] Kho từ của tôi và import từ vựng
- [x] Từ vựng chuyên ngành
- [x] CI chạy analyze và test
- [x] Thông báo nhắc học theo lịch (Android/iOS; web chỉ nhắc trên trang chủ)
- [x] Đổi mật khẩu, xóa tài khoản và dữ liệu
- [x] Âm thanh: lời chào tiếng Nhật, nhạc nền, chỉnh âm lượng
- [ ] Nội dung N4, N3

---

Đồ án môn Lập trình thiết bị di động — Phenikaa University.
