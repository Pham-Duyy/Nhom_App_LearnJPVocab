# Kiểm thử ChibaKanji

Bộ test chạy hoàn toàn không cần mạng hay Firebase: mọi repository được thay
bằng bản lưu trong bộ nhớ (`InMemoryRepository<T>` và các lớp `Mock...`),
còn đăng nhập dùng `FakeAuthService`.

## Cách chạy

```bash
flutter test                 # chạy toàn bộ 357 test
flutter test --coverage      # kèm độ phủ, kết quả ở coverage/lcov.info
flutter test --plain-name US16   # chỉ chạy test của một user story
```

Kết quả hiện tại: **357/357 test qua**, độ phủ code **86.0%**.

## Cấu trúc thư mục

| Thư mục | Loại test | Nội dung |
|---|---|---|
| `models/` | Unit test | Logic thuần của model: ôn tập ngắt quãng, chuỗi ngày học, ORM `toMap`/`fromMap` |
| `data/` | Unit test | Bộ tạo câu hỏi quiz, dữ liệu mẫu |
| `repositories/` | Unit test | Repository tổng quát `Repository<T, ID>` |
| `providers/` | Unit test | Trạng thái và quy tắc nghiệp vụ của từng màn hình |
| `auth/` | Unit test | Đăng nhập, đăng ký, kiểm tra dữ liệu nhập |
| `services/` | Unit test | Lưu trên thiết bị (đã xem màn chào) |
| `utils/` | Unit test | Đổi lỗi kỹ thuật thành thông báo dễ hiểu |
| `widgets/` | Widget test | Widget dùng chung, vd. thanh chọn generic `ChoiceSegments<T>`, `PillChoices<T>` |
| `screens/` | Widget test | Thao tác trên giao diện như người dùng thật |
| `fakes/`, `helpers/` | Hỗ trợ | Dịch vụ giả, repository bật/tắt lỗi được, dựng app để test |

Tên mỗi test bắt đầu bằng mã user story (`US01`–`US23`) hoặc mã yêu cầu kiểm
thử của đề bài (`8a`, `8c`, `8e`), nên lọc được bằng `--plain-name`.

## 8b. Đối chiếu user story với test

| Mã | User story | Số test | File test |
|---|---|---|---|
| US01 | Là khách, tôi có thể xem màn hình giới thiệu ứng dụng | 2 | `screens/welcome_and_level_test.dart` |
| US02 | Là khách, tôi có thể dùng thử app mà không cần tạo tài khoản | 4 | `auth/auth_controller_test.dart`, `screens/auth_gate_test.dart`, `screens/welcome_and_level_test.dart` |
| US03 | Là khách, tôi có thể đăng ký tài khoản bằng email và mật khẩu | 11 | `auth/auth_controller_test.dart`, `auth/auth_validators_test.dart`, `screens/welcome_flow_test.dart` |
| US04 | Là người dùng, tôi có thể đăng nhập bằng email hoặc Google | 24 | `auth/auth_controller_test.dart`, `auth/auth_validators_test.dart`, `screens/auth_screen_test.dart` |
| US05 | Là người dùng, tôi có thể đăng xuất | 3 | `auth/auth_controller_test.dart`, `screens/sign_out_test.dart`, `screens/welcome_and_level_test.dart` |
| US06 | Là người học, tôi có thể xem danh sách chủ đề theo cấp độ JLPT | 3 | `screens/welcome_and_level_test.dart`, `widget_test.dart` |
| US07 | Là người học, tôi có thể xem các bài học trong một chủ đề | 2 | `screens/lesson_screen_test.dart`, `widget_test.dart` |
| US08 | Là người học, tôi có thể học từ mới bằng flashcard lật thẻ | 2 | `screens/flashcard_flow_test.dart` |
| US09 | Là người học, tôi có thể đánh dấu một từ là đã nhớ hoặc chưa nhớ | 9 | `models/progress_test.dart`, `providers/progress_provider_test.dart`, `screens/flashcard_flow_test.dart` |
| US10 | Là người học, tôi có thể xem kết quả sau mỗi buổi học | 2 | `screens/flashcard_flow_test.dart` |
| US11 | Là người học, tôi có thể ôn lại các từ đã đến hạn | 7 | `models/progress_test.dart`, `screens/review_home_test.dart` |
| US12 | Là người học, tôi có thể xem số từ theo từng mức ghi nhớ | 2 | `providers/progress_provider_test.dart`, `screens/review_home_test.dart` |
| US13 | Là người học, tôi có thể tìm kiếm từ đã học | 9 | `models/vocabulary_test.dart`, `screens/vocabulary_book_test.dart` |
| US14 | Là người học, tôi có thể đánh dấu từ yêu thích và lọc theo yêu thích | 2 | `screens/vocabulary_book_test.dart` |
| US15 | Là người học, tôi có thể xem chi tiết và câu ví dụ của một từ | 2 | `screens/vocabulary_book_test.dart` |
| US16 | Là người học, tôi có thể làm quiz trắc nghiệm từ vựng | 20 | `data/quiz_generator_test.dart`, `providers/quiz_provider_test.dart`, `screens/quiz_flow_test.dart`, `screens/listening_quiz_test.dart` |
| US17 | Là người học, tôi có thể xem điểm và lịch sử các lần làm quiz | 5 | `providers/quiz_provider_test.dart`, `screens/quiz_flow_test.dart` |
| US18 | Là người học, tôi có thể đặt mục tiêu số từ mỗi ngày | 4 | `providers/user_profile_provider_test.dart`, `screens/profile_settings_test.dart` |
| US19 | Là người học, tôi có thể xem chuỗi ngày học liên tiếp | 15 | `models/user_profile_test.dart`, `providers/progress_provider_test.dart`, `providers/user_profile_provider_test.dart`, `screens/profile_settings_test.dart` |
| US20 | Là người học, tôi có thể đổi tên hiển thị và chế độ sáng/tối | 13 | `models/user_profile_test.dart`, `providers/user_profile_provider_test.dart`, `screens/profile_settings_test.dart`, `screens/theme_mode_test.dart` |
| US21 | Là người học, tôi có thể làm bài thi thử trắc nghiệm có giới hạn thời gian | 16 | `providers/exam_provider_test.dart`, `screens/exam_flow_test.dart` |
| US22 | Là người học, tôi có thể tạo chủ đề và thêm từ vựng của riêng mình để học | 12 | `providers/my_vocabulary_provider_test.dart`, `screens/my_vocabulary_flow_test.dart` |
| US23 | Là người học, tôi có thể import từ vựng từ file Excel, CSV hoặc PDF | 18 | `data/vocabulary_file_reader_test.dart`, `data/vocabulary_import_parser_test.dart`, `providers/my_vocabulary_provider_test.dart`, `screens/my_vocabulary_flow_test.dart` |

Một test có thể thuộc nhiều story (vd. `US06, US07`) nên tổng cột "Số test"
lớn hơn số test chỉ gắn một mã.

## 8c. Kiểm thử toàn bộ ứng dụng

`screens/app_journey_test.dart` đi trọn hành trình của một người dùng mới,
qua các tính năng chính theo đúng thứ tự dùng thật:

> Màn chào → đăng ký → chọn chủ đề, bài học → học hết 5 thẻ → làm quiz bài đó
> → về trang chủ, chuỗi ngày từ 0 lên 1 → Cá nhân hiện đúng tên → Lịch sử quiz
> có lượt vừa làm.

## 8d. Phân tích ca lỗi và ca thành công

| Tình huống | Kết quả mong đợi | Test |
|---|---|---|
| Đăng nhập đúng email, mật khẩu | Vào trang chủ của tài khoản đó | `auth_screen_test`: US04 đăng nhập đúng |
| Sai mật khẩu, hoặc email chưa đăng ký | Cùng một thông báo "Email hoặc mật khẩu không đúng.", không lộ email nào đã đăng ký | `auth_controller_test`: US04 sai mật khẩu |
| Email sai định dạng | Báo lỗi ngay trên form, không gọi Firebase | `auth_screen_test`: US04 email sai định dạng |
| Đăng ký với email đã dùng | Báo lỗi, giữ nguyên tài khoản đang dùng | `auth_controller_test`: US03 email đã được dùng |
| Khách đăng ký tài khoản | Giữ nguyên uid nên không mất tiến độ đã học | `auth_controller_test`: US03 gắn email vào tài khoản khách |
| Đóng cửa sổ đăng nhập Google | Báo "Bạn đã hủy đăng nhập Google.", ở lại màn đăng nhập | `auth_screen_test`: US04 hủy cửa sổ Google |
| Mất mạng khi mở app | Hiện lỗi dễ hiểu, bấm Thử lại khi có mạng là vào được | `error_ui_test`: 8a/8e mất mạng khi mở app |
| Mất mạng khi tải chủ đề, bài học, từ vựng, sổ từ | Thông báo không chứa chi tiết kỹ thuật, có nút Thử lại | `error_handling_test`, `library_provider_test` |
| Lưu yêu thích lỗi | Báo lỗi, trạng thái yêu thích giữ nguyên | `error_ui_test`: 8a/8e đánh dấu yêu thích lỗi |
| Lưu tiến độ thẻ lỗi | Thẻ giữ nguyên để thử lại, không bỏ qua từ | `error_handling_test`: lưu tiến độ thẻ lỗi |
| Bấm đúp nút trả lời thẻ | Chỉ ghi nhận một lần | `flashcard_flow_test`: 8a khoá nút khi đang lưu |
| Học chưa đủ 4 từ mà làm quiz | Báo cần học thêm, không vào quiz | `quiz_provider_test`: US16 học chưa đủ 4 từ |
| Chọn đáp án quiz lần thứ hai | Bị bỏ qua, mỗi câu chỉ chọn một lần | `quiz_provider_test`: US16 mỗi câu chỉ chọn một lần |
| Lưu kết quả quiz lỗi | Vẫn hiện điểm, có thông báo lỗi | `quiz_provider_test`: US17 lưu lỗi |
| Tên hiển thị rỗng hoặc dài quá 30 ký tự | Báo lỗi, không lưu | `profile_settings_test`, `user_profile_test` |
| Học lúc 23:59 rồi 00:01 hôm sau | Tính là 2 ngày liên tiếp | `user_profile_test`: US19 23:59 rồi 00:01 |
| Bỏ lỡ một ngày học | Chuỗi ngày về 0 | `user_profile_test`: US19 bỏ lỡ một ngày |
| Dữ liệu hồ sơ trên Firestore bị hỏng | Dùng giá trị mặc định, app không lỗi | `user_profile_test`: dữ liệu sai kiểu |

## 8e. Kiểm thử giao diện

- Mọi màn hình có widget test riêng trong `screens/`.
- `screens/responsive_layout_test.dart` mở lần lượt các màn hình chính trên
  điện thoại 360dp, cả khi phóng to chữ 130%, dùng đúng font Be Vietnam Pro
  của app. Flutter coi tràn bố cục là lỗi nên màn nào tràn thì test thất bại.
