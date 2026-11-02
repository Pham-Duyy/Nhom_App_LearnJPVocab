/// Mặt trước của thẻ flashcard.
enum CardFront {
  /// Thấy chữ Nhật, đoán nghĩa (mặc định).
  japanese,

  /// Thấy nghĩa tiếng Việt, nhớ lại cách viết tiếng Nhật.
  meaning,
}

/// Các tùy chọn học của người dùng, lưu trong hồ sơ (UserProfile).
class StudyPreferences {
  static const quizLengthOptions = [5, 10, 15];
  static const defaultQuizLength = 10;
  static const defaultReminderHour = 20;

  final CardFront cardFront;

  /// Hiện cách đọc romaji trên thẻ (tắt đi để luyện đọc kana).
  final bool showRomaji;

  /// Số câu tối đa của một lượt quiz.
  final int quizLength;

  /// Nhắc học: thông báo mỗi ngày vào [reminderHour]:[reminderMinute], và
  /// lời nhắc trên trang chủ khi hôm nay chưa học.
  final bool dailyReminder;
  final int reminderHour;
  final int reminderMinute;

  const StudyPreferences({
    this.cardFront = CardFront.japanese,
    this.showRomaji = true,
    this.quizLength = defaultQuizLength,
    this.dailyReminder = true,
    this.reminderHour = defaultReminderHour,
    this.reminderMinute = 0,
  });

  /// Giờ nhắc dạng "20:00".
  String get reminderTimeLabel => '${reminderHour.toString().padLeft(2, '0')}:'
      '${reminderMinute.toString().padLeft(2, '0')}';

  StudyPreferences copyWith({
    CardFront? cardFront,
    bool? showRomaji,
    int? quizLength,
    bool? dailyReminder,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return StudyPreferences(
      cardFront: cardFront ?? this.cardFront,
      showRomaji: showRomaji ?? this.showRomaji,
      quizLength: quizLength ?? this.quizLength,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  Map<String, dynamic> toMap() => {
        'cardFront': cardFront.name,
        'showRomaji': showRomaji,
        'quizLength': quizLength,
        'dailyReminder': dailyReminder,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
      };

  /// Đọc an toàn: trường thiếu hoặc sai thì dùng giá trị mặc định.
  factory StudyPreferences.fromMap(Map<String, dynamic> map) {
    final length = map['quizLength'];
    final hour = map['reminderHour'];
    final minute = map['reminderMinute'];
    return StudyPreferences(
      cardFront: CardFront.values.firstWhere(
        (front) => front.name == map['cardFront'],
        orElse: () => CardFront.japanese,
      ),
      showRomaji: map['showRomaji'] is bool ? map['showRomaji'] as bool : true,
      quizLength: quizLengthOptions.contains(length)
          ? length as int
          : defaultQuizLength,
      dailyReminder:
          map['dailyReminder'] is bool ? map['dailyReminder'] as bool : true,
      reminderHour:
          hour is int && hour >= 0 && hour < 24 ? hour : defaultReminderHour,
      reminderMinute: minute is int && minute >= 0 && minute < 60 ? minute : 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StudyPreferences &&
      other.cardFront == cardFront &&
      other.showRomaji == showRomaji &&
      other.quizLength == quizLength &&
      other.dailyReminder == dailyReminder &&
      other.reminderHour == reminderHour &&
      other.reminderMinute == reminderMinute;

  @override
  int get hashCode => Object.hash(
        cardFront,
        showRomaji,
        quizLength,
        dailyReminder,
        reminderHour,
        reminderMinute,
      );
}
