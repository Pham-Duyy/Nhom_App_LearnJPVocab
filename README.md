# LearnJPVocab 🇯🇵

> Ứng dụng Flutter học từ vựng tiếng Nhật theo cấp độ JLPT, ôn tập bằng thuật toán Leitner box và kiểm tra kiến thức qua quiz trắc nghiệm.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Mobile-3DDC84)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

---

## 📖 Giới thiệu

**LearnJPVocab** là đồ án môn Lập trình thiết bị di động, xây dựng bằng Flutter, giúp người học tiếng Nhật ghi nhớ từ vựng hiệu quả hơn thông qua:

- Flashcard theo chủ đề (`Category`) và bài học (`Lesson`)
- Ôn tập giãn cách theo thuật toán **Leitner box** — từ càng thuộc thì càng lâu mới cần ôn lại
- Quiz trắc nghiệm để tự kiểm tra kiến thức
- Theo dõi tiến độ học riêng cho từng người dùng

## ✨ Tính năng chính

- [x] Quản lý kho từ vựng theo cấp độ JLPT (N5–N3)
- [x] Tìm kiếm từ vựng theo từ khoá
- [x] Theo dõi tiến độ ôn tập theo thuật toán Leitner (5 box)
- [x] Xác thực người dùng cơ bản
- [ ] Quiz trắc nghiệm sinh tự động
- [ ] Thông báo nhắc ôn tập hàng ngày

## 🛠 Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter |
| Ngôn ngữ | Dart |
| Lưu trữ local | SQLite / Hive |
| State management | Provider |
| Thiết kế | UML Class Diagram (draw.io) |

## 📂 Cấu trúc thư mục

```
lib/
├── main.dart
├── models/                # Các class dữ liệu chính
│   ├── user.dart
│   ├── vocabulary.dart
│   ├── category.dart
│   ├── lesson.dart
│   ├── quiz.dart
│   ├── question.dart
│   ├── quiz_attempt.dart
│   └── progress.dart
├── services/               # Xử lý dữ liệu, không phụ thuộc UI
│   ├── database_service.dart
│   └── auth_service.dart
├── providers/               # State management
│   ├── vocabulary_provider.dart
│   ├── quiz_provider.dart
│   └── progress_provider.dart
├── screens/                 # Các màn hình
│   ├── home/
│   ├── lesson/
│   ├── flashcard/
│   ├── quiz/
│   └── progress/
└── widgets/                 # UI components dùng lại
    ├── flashcard_widget.dart
    └── progress_bar.dart
```

## 🧩 UML Class Diagram

Toàn bộ thiết kế lớp được vẽ bằng [draw.io](https://app.diagrams.net/), file nguồn nằm tại [`docs/class-diagram.drawio`](./docs/class-diagram.drawio).

Sơ đồ gồm 8 class chính: `User`, `Vocabulary`, `Category`, `Lesson`, `Quiz`, `Question`, `QuizAttempt`, `Progress` — thể hiện quan hệ aggregation (Category/Lesson chứa Vocabulary), composition (Quiz chứa Question), và association (User theo dõi Progress, User làm QuizAttempt).

## 🚀 Bắt đầu nhanh

### Yêu cầu

- Flutter SDK đã thêm vào biến môi trường `PATH`
- Kiểm tra môi trường: `flutter doctor`

### Cài đặt & chạy

```bash
git clone https://github.com/Pham-Duyy/Nhom_App_LearnJPVocab.git
cd Nhom_App_LearnJPVocab
flutter pub get
flutter run
```

---

## 👥 Phân công & chi tiết từng đối tượng

Theo yêu cầu bài tập: mỗi thành viên lựa chọn 1 đối tượng, viết code, commit và cập nhật phần README tương ứng dưới đây.

### `Vocabulary` — thực hiện bởi: *[Tên thành viên 1]*

Đại diện cho một từ vựng tiếng Nhật trong kho dữ liệu của app.

**Thuộc tính**

| Field | Kiểu | Mô tả |
|---|---|---|
| `id` | `int` | Khoá chính |
| `japanese` | `String` | Từ tiếng Nhật (kanji/kana) |
| `meaning` | `String` | Nghĩa tiếng Việt |
| `pronunciation` | `String` | Cách đọc (furigana) |
| `example` | `String` | Câu ví dụ |
| `level` | `String` | Cấp độ JLPT (N5–N3) |
| `categoryId` | `int` | Khoá ngoại tới `Category` |

**Phương thức**

| Method | Mô tả |
|---|---|
| `getMeaning(): String` | Trả về nghĩa tiếng Việt của từ |
| `matches(String keyword): bool` | Kiểm tra từ có khớp từ khoá tìm kiếm không (so khớp trên cả 3 trường: chữ Nhật, nghĩa, cách đọc) |

**Ví dụ sử dụng**

```dart
final vocab = Vocabulary(
  id: 1,
  japanese: '食べる',
  meaning: 'ăn',
  pronunciation: 'たべる',
  example: 'ご飯を食べる。',
  level: 'N5',
  categoryId: 3,
);

print(vocab.getMeaning());        // "ăn"
print(vocab.matches('たべる'));    // true
```

---

### `Progress` — thực hiện bởi: *[Tên thành viên 2]*

Theo dõi tiến độ ôn tập của một người dùng đối với một từ vựng cụ thể, sử dụng thuật toán **Leitner box** (5 cấp độ).

**Thuộc tính**

| Field | Kiểu | Mô tả |
|---|---|---|
| `id` | `int` | Khoá chính |
| `userId` | `int` | Khoá ngoại tới `User` |
| `vocabularyId` | `int` | Khoá ngoại tới `Vocabulary` |
| `box` | `int` | Cấp độ Leitner hiện tại (1–5) |
| `lastReviewedAt` | `DateTime` | Lần ôn gần nhất |
| `nextReviewAt` | `DateTime` | Ngày cần ôn tiếp theo |

**Phương thức**

| Method | Mô tả |
|---|---|
| `updateBox(bool isCorrect): void` | Đúng → tăng box (tối đa 5), giãn ngày ôn. Sai → về box 1, ôn lại ngày mai |
| `isDueForReview(): bool` | Kiểm tra hôm nay có cần ôn từ này không |
| `reset(): void` | Đặt lại tiến độ về trạng thái ban đầu |

**Thuật toán Leitner áp dụng**

| Box | Khoảng cách ôn lại |
|---|---|
| 1 | 1 ngày |
| 2 | 3 ngày |
| 3 | 7 ngày |
| 4 | 14 ngày |
| 5 | 30 ngày |

**Ví dụ sử dụng**

```dart
final progress = Progress(id: 1, userId: 1, vocabularyId: 1);

progress.updateBox(true);   // trả lời đúng → box tăng lên 2
print(progress.isDueForReview());  // false, phải chờ 3 ngày
```

---

### `User` — thực hiện bởi: *[Tên thành viên phụ trách]*

Đại diện cho một người dùng của app.

**Thuộc tính**

| Field | Kiểu | Mô tả |
|---|---|---|
| `id` | `int` | Khoá chính |
| `username` | `String` | Tên đăng nhập |
| `email` | `String` | Email |
| `passwordHash` | `String` | Mật khẩu đã mã hoá (không lưu plain text) |

**Phương thức**

| Method | Mô tả |
|---|---|
| `isValidEmail(): bool` | Kiểm tra định dạng email hợp lệ |
| `getDisplayName(): String` | Tên hiển thị trên UI (viết hoa chữ đầu) |

**Ví dụ sử dụng**

```dart
final user = User(
  id: 1,
  username: 'duy23010743',
  email: 'duy@example.com',
  passwordHash: '••••••••',
);

print(user.isValidEmail());     // true
print(user.getDisplayName());   // "Duy23010743"
```

---

## 🗺 Hướng phát triển

- Hoàn thiện `Category`, `Lesson`, `Quiz`, `Question`, `QuizAttempt`
- Kết nối các Model với `DatabaseService` (SQLite)
- Xây dựng `AuthService` cho đăng nhập/đăng xuất thật
- Thêm local notification nhắc ôn tập hàng ngày
- Giao diện flashcard có animation lật thẻ

---

*Đồ án môn Lập trình thiết bị di động — Phenikaa University.*