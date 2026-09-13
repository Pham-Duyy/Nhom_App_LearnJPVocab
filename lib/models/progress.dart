class Progress {
  final int _id;
  final int _userId;
  final int _vocabularyId;
  int _box;
  DateTime _lastReviewedAt;
  DateTime _nextReviewAt;

  Progress({
    required int id,
    required int userId,
    required int vocabularyId,
    int box = 1,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  })  : _id = id,
        _userId = userId,
        _vocabularyId = vocabularyId,
        _box = box,
        _lastReviewedAt = lastReviewedAt ?? DateTime.now(),
        _nextReviewAt = nextReviewAt ?? DateTime.now();

  int get id => _id;
  int get userId => _userId;
  int get vocabularyId => _vocabularyId;
  int get box => _box;
  DateTime get lastReviewedAt => _lastReviewedAt;
  DateTime get nextReviewAt => _nextReviewAt;

  /// Cập nhật box theo thuật toán Leitner sau một lượt ôn tập.
  /// Trả lời đúng -> tăng box (tối đa 5), giãn ngày ôn tiếp theo.
  /// Trả lời sai -> về box 1, ôn lại ngay ngày mai.
  void updateBox(bool isCorrect) {
    _box = isCorrect ? (_box < 5 ? _box + 1 : 5) : 1;
    _lastReviewedAt = DateTime.now();
    _nextReviewAt = _lastReviewedAt.add(Duration(days: _intervalForBox(_box)));
  }

  bool isDueForReview() => !_nextReviewAt.isAfter(DateTime.now());


  void reset() {
    _box = 1;
    _lastReviewedAt = DateTime.now();
    _nextReviewAt = DateTime.now();
  }

  int _intervalForBox(int box) {
    switch (box) {
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 7;
      case 4:
        return 14;
      default:
        return 30;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': _id,
        'userId': _userId,
        'vocabularyId': _vocabularyId,
        'box': _box,
        'lastReviewedAt': _lastReviewedAt.toIso8601String(),
        'nextReviewAt': _nextReviewAt.toIso8601String(),
      };

  factory Progress.fromMap(Map<String, dynamic> map) => Progress(
        id: map['id'] as int,
        userId: map['userId'] as int,
        vocabularyId: map['vocabularyId'] as int,
        box: map['box'] as int,
        lastReviewedAt: DateTime.parse(map['lastReviewedAt'] as String),
        nextReviewAt: DateTime.parse(map['nextReviewAt'] as String),
      );

  @override
  String toString() => 'Progress(vocabularyId: $_vocabularyId, box: $_box)';
}