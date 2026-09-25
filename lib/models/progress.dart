/// Tiến độ ghi nhớ của một từ vựng theo thuật toán lặp lại ngắt quãng
/// (spaced repetition) 5 mức. `lastReviewedAt`/`nextReviewAt` được lưu dưới
/// dạng [DateTime] và chuyển sang ISO-8601 String trong [toMap]/[fromMap] để
/// dữ liệu mock hoạt động độc lập; khi chuyển sang Firestore, chỉ cần đổi
/// phần đọc/ghi hai trường này sang Timestamp mà không phải sửa model.
class Progress {
  static const Map<int, int> reviewIntervalDays = {
    1: 1,
    2: 3,
    3: 7,
    4: 14,
    5: 30,
  };

  final String vocabularyId;
  final int memoryLevel;
  final int correctCount;
  final int wrongCount;
  final int reviewCount;
  final bool isLearned;
  final bool isFavorite;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;

  const Progress({
    required this.vocabularyId,
    this.memoryLevel = 1,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.reviewCount = 0,
    this.isLearned = false,
    this.isFavorite = false,
    this.lastReviewedAt,
    this.nextReviewAt,
  }) : assert(memoryLevel >= 1 && memoryLevel <= 5);

  Progress copyWith({
    String? vocabularyId,
    int? memoryLevel,
    int? correctCount,
    int? wrongCount,
    int? reviewCount,
    bool? isLearned,
    bool? isFavorite,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) {
    return Progress(
      vocabularyId: vocabularyId ?? this.vocabularyId,
      memoryLevel: memoryLevel ?? this.memoryLevel,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      reviewCount: reviewCount ?? this.reviewCount,
      isLearned: isLearned ?? this.isLearned,
      isFavorite: isFavorite ?? this.isFavorite,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  /// Trả lời đúng: tăng mức ghi nhớ (tối đa 5) và giãn lịch ôn tiếp theo.
  Progress markCorrect() {
    final newLevel = memoryLevel < 5 ? memoryLevel + 1 : 5;
    final now = DateTime.now();
    return copyWith(
      memoryLevel: newLevel,
      correctCount: correctCount + 1,
      reviewCount: reviewCount + 1,
      isLearned: true,
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(days: reviewIntervalDays[newLevel]!)),
    );
  }

  /// Trả lời sai: quay về mức 1, ôn lại sớm nhất.
  Progress markWrong() {
    final now = DateTime.now();
    return copyWith(
      memoryLevel: 1,
      wrongCount: wrongCount + 1,
      reviewCount: reviewCount + 1,
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(days: reviewIntervalDays[1]!)),
    );
  }

  /// Từ chưa từng được ôn (`nextReviewAt` null) luôn coi là đến hạn.
  bool isDueForReview([DateTime? now]) {
    if (nextReviewAt == null) return true;
    final reference = now ?? DateTime.now();
    return !nextReviewAt!.isAfter(reference);
  }

  Map<String, dynamic> toMap() => {
        'vocabularyId': vocabularyId,
        'memoryLevel': memoryLevel,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'reviewCount': reviewCount,
        'isLearned': isLearned,
        'isFavorite': isFavorite,
        'lastReviewedAt': lastReviewedAt?.toIso8601String(),
        'nextReviewAt': nextReviewAt?.toIso8601String(),
      };

  factory Progress.fromMap(Map<String, dynamic> map) => Progress(
        vocabularyId: map['vocabularyId'] as String,
        memoryLevel: map['memoryLevel'] as int? ?? 1,
        correctCount: map['correctCount'] as int? ?? 0,
        wrongCount: map['wrongCount'] as int? ?? 0,
        reviewCount: map['reviewCount'] as int? ?? 0,
        isLearned: map['isLearned'] as bool? ?? false,
        isFavorite: map['isFavorite'] as bool? ?? false,
        lastReviewedAt: map['lastReviewedAt'] != null
            ? DateTime.parse(map['lastReviewedAt'] as String)
            : null,
        nextReviewAt: map['nextReviewAt'] != null
            ? DateTime.parse(map['nextReviewAt'] as String)
            : null,
      );

  @override
  String toString() => 'Progress($vocabularyId, level: $memoryLevel)';
}
