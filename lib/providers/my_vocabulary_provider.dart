import 'package:flutter/foundation.dart';

import '../models/user_topic.dart';
import '../models/vocabulary.dart';
import '../models/word_draft.dart';
import '../repositories/user_topic_repository.dart';
import '../repositories/user_word_repository.dart';
import '../repositories/vocabulary_repository.dart';
import '../utils/app_error.dart';

/// Kho từ của người học: chủ đề tự tạo và từ tự thêm. Các hàm thay đổi dữ
/// liệu trả về thông báo lỗi (dữ liệu nhập sai hoặc lưu thất bại), null nếu
/// thành công, để form hiện lỗi ngay tại chỗ.
class MyVocabularyProvider extends ChangeNotifier {
  MyVocabularyProvider(
    this._topics,
    this._words,
    this._vocabulary, {
    this.onWordsChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final UserTopicRepository _topics;
  final UserWordRepository _words;

  /// Kho gộp (từ của app và từ tự thêm), để chọn từ có sẵn cho chủ đề.
  final VocabularyRepository _vocabulary;

  /// Gọi khi từ tự thêm thay đổi, vd. để Sổ từ tải lại.
  final Future<void> Function()? onWordsChanged;
  final DateTime Function() _clock;

  List<UserTopic> _topicList = [];
  List<Vocabulary> _allWords = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _idCounter = 0;

  List<UserTopic> get topics => _topicList;

  /// Mọi từ: của app lẫn tự thêm.
  List<Vocabulary> get allWords => _allWords;
  List<Vocabulary> get myWords =>
      _allWords.where((word) => word.isPersonal).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserTopic? topicById(String id) {
    for (final topic in _topicList) {
      if (topic.id == id) return topic;
    }
    return null;
  }

  /// Chủ đề cùng tên với [name] (không phân biệt hoa thường), nếu có.
  UserTopic? topicByName(String name) {
    final lower = name.trim().toLowerCase();
    for (final topic in _topicList) {
      if (topic.name.toLowerCase() == lower) return topic;
    }
    return null;
  }

  /// Từ của [topic] theo thứ tự đã thêm; bỏ qua id không còn tồn tại.
  List<Vocabulary> wordsOf(UserTopic topic) {
    final byId = {for (final word in _allWords) word.id: word};
    return [
      for (final id in topic.wordIds)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait<List<Object>>([
        _topics.getAll(),
        _vocabulary.getAll(),
      ]);
      _topicList = results[0].cast<UserTopic>().toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _allWords = results[1].cast<Vocabulary>().toList();
    } catch (e, stack) {
      AppError.log('MyVocabularyProvider.load', e, stack);
      _errorMessage = AppError.message(e, action: 'tải kho từ');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------- Chủ đề

  Future<String?> createTopic(String name, {String description = ''}) async {
    final error = _checkTopicName(name);
    if (error != null) return error;
    final topic = UserTopic(
      id: 'topic_${_clock().microsecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      order: _topicList.isEmpty ? 1 : _topicList.last.order + 1,
      createdAt: _clock(),
    );
    return _run('tạo chủ đề', () async {
      await _topics.save(topic);
      _topicList = [..._topicList, topic];
    });
  }

  Future<String?> updateTopic(
    UserTopic topic, {
    required String name,
    String description = '',
  }) async {
    final error = _checkTopicName(name, except: topic);
    if (error != null) return error;
    return _saveTopic(
      topic.copyWith(name: name.trim(), description: description.trim()),
      action: 'lưu chủ đề',
    );
  }

  /// Xóa chủ đề; các từ trong đó vẫn còn trong kho.
  Future<String?> deleteTopic(String topicId) {
    return _run('xóa chủ đề', () async {
      await _topics.delete(topicId);
      _topicList = _topicList.where((t) => t.id != topicId).toList();
    });
  }

  Future<String?> addWordsToTopic(String topicId, List<String> wordIds) {
    final topic = topicById(topicId);
    if (topic == null) return Future.value('Không tìm thấy chủ đề.');
    return _saveTopic(
      topic.copyWith(wordIds: {...topic.wordIds, ...wordIds}.toList()),
      action: 'thêm từ vào chủ đề',
    );
  }

  Future<String?> removeWordFromTopic(String topicId, String wordId) {
    final topic = topicById(topicId);
    if (topic == null) return Future.value('Không tìm thấy chủ đề.');
    return _saveTopic(
      topic.copyWith(
        wordIds: topic.wordIds.where((id) => id != wordId).toList(),
      ),
      action: 'bỏ từ khỏi chủ đề',
    );
  }

  // ------------------------------------------------------------------- Từ

  /// Thêm một từ vào kho, và vào chủ đề [topicId] nếu có.
  Future<String?> addWord(WordDraft draft, {String? topicId}) async {
    final error = draft.validate() ?? _checkDuplicate(draft);
    if (error != null) return error;
    final word = draft.toVocabulary(id: _newWordId(), order: _nextOrder());
    var result = await _run('thêm từ', () async {
      await _words.save(word);
      _allWords = [..._allWords, word];
    });
    if (result == null && topicId != null) {
      result = await addWordsToTopic(topicId, [word.id]);
    }
    return _afterWordsChanged(result);
  }

  Future<String?> updateWord(Vocabulary word, WordDraft draft) async {
    final error = draft.validate() ?? _checkDuplicate(draft, except: word);
    if (error != null) return error;
    final updated = draft.toVocabulary(id: word.id, order: word.order);
    return _afterWordsChanged(
      await _run('lưu từ', () async {
        await _words.save(updated);
        _allWords = [
          for (final w in _allWords) w.id == word.id ? updated : w,
        ];
      }),
    );
  }

  /// Xóa một từ tự thêm khỏi kho và khỏi mọi chủ đề đang chứa nó.
  Future<String?> deleteWord(String wordId) async {
    return _afterWordsChanged(
      await _run('xóa từ', () async {
        await _words.delete(wordId);
        _allWords = _allWords.where((w) => w.id != wordId).toList();
        for (final topic in _topicList.where((t) => t.contains(wordId))) {
          final updated = topic.copyWith(
            wordIds: topic.wordIds.where((id) => id != wordId).toList(),
          );
          await _topics.save(updated);
          _replaceTopic(updated);
        }
      }),
    );
  }

  /// Thêm nhiều từ một lúc; từ trùng với từ đã có trong kho thì bỏ qua.
  /// [words] là các từ vừa thêm, để học ngay sau khi import.
  Future<({List<Vocabulary> words, int skipped, String? error})> importWords(
    List<WordDraft> drafts, {
    String? topicId,
  }) async {
    final fresh = <Vocabulary>[];
    for (final draft in drafts) {
      final isDuplicate = _checkDuplicate(draft) != null ||
          fresh.any((word) => draft.sameAs(word));
      if (draft.validate() == null && !isDuplicate) {
        fresh.add(
          draft.toVocabulary(
            id: _newWordId(),
            order: _nextOrder() + fresh.length,
          ),
        );
      }
    }
    var error = await _run('import từ vựng', () async {
      for (final word in fresh) {
        await _words.save(word);
      }
      _allWords = [..._allWords, ...fresh];
    });
    if (error == null && topicId != null && fresh.isNotEmpty) {
      error = await addWordsToTopic(topicId, [for (final w in fresh) w.id]);
    }
    await _afterWordsChanged(error);
    return (
      words: error == null ? fresh : const <Vocabulary>[],
      skipped: drafts.length - fresh.length,
      error: error,
    );
  }

  // ------------------------------------------------------------ Nội bộ

  String? _checkTopicName(String name, {UserTopic? except}) {
    final error = UserTopic.validateName(name);
    if (error != null) return error;
    final lower = name.trim().toLowerCase();
    final taken = _topicList.any(
      (t) => t.id != except?.id && t.name.toLowerCase() == lower,
    );
    return taken ? 'Đã có chủ đề "${name.trim()}".' : null;
  }

  String? _checkDuplicate(WordDraft draft, {Vocabulary? except}) {
    final taken =
        myWords.any((word) => word.id != except?.id && draft.sameAs(word));
    return taken ? 'Từ này đã có trong kho của bạn.' : null;
  }

  String _newWordId() => '${Vocabulary.personalIdPrefix}'
      '${_clock().microsecondsSinceEpoch}_${_idCounter++}';

  int _nextOrder() => myWords.length + 1;

  void _replaceTopic(UserTopic updated) {
    _topicList = [
      for (final t in _topicList) t.id == updated.id ? updated : t,
    ];
  }

  Future<String?> _saveTopic(UserTopic topic, {required String action}) {
    return _run(action, () async {
      await _topics.save(topic);
      _replaceTopic(topic);
    });
  }

  /// Chạy [body], báo giao diện vẽ lại; lỗi thì ghi log và trả về câu báo
  /// lỗi dễ hiểu cho [action].
  Future<String?> _run(String action, Future<void> Function() body) async {
    try {
      await body();
      notifyListeners();
      return null;
    } catch (e, stack) {
      AppError.log('MyVocabularyProvider', e, stack);
      return AppError.message(e, action: action);
    }
  }

  Future<String?> _afterWordsChanged(String? error) async {
    final callback = onWordsChanged;
    if (error == null && callback != null) await callback();
    return error;
  }
}
