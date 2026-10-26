import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vocabulary.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/choice_segments.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import '../vocabulary/vocabulary_detail_screen.dart';
import 'word_form_screen.dart';
import 'word_tile.dart';

enum _Scope { all, mine }

/// Xem tất cả từ vựng (của app và tự thêm), tìm kiếm; từ tự thêm thì sửa
/// hoặc xóa được.
class AllWordsScreen extends StatefulWidget {
  const AllWordsScreen({Key? key}) : super(key: key);

  @override
  State<AllWordsScreen> createState() => _AllWordsScreenState();
}

class _AllWordsScreenState extends GenericScreenState<AllWordsScreen> {
  final _search = TextEditingController();
  _Scope _scope = _Scope.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  String getTitle(BuildContext context) => 'Tất cả từ vựng';

  Future<void> _delete(Vocabulary word) async {
    final error =
        await context.read<MyVocabularyProvider>().deleteWord(word.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Đã xóa "${word.name}".')),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<MyVocabularyProvider>();
    if (provider.errorMessage != null && provider.allWords.isEmpty) {
      return ErrorView(message: provider.errorMessage!, onRetry: provider.load);
    }
    final keyword = _search.text.trim();
    final words = (_scope == _Scope.mine ? provider.myWords : provider.allWords)
        .where((word) => keyword.isEmpty || word.matches(keyword))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            12,
          ),
          child: Column(
            children: [
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Kanji, kana, romaji hoặc nghĩa',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              ChoiceSegments<_Scope>(
                options: _Scope.values,
                selected: _scope,
                labelOf: (scope) => scope == _Scope.all
                    ? 'Tất cả (${provider.allWords.length})'
                    : 'Của tôi (${provider.myWords.length})',
                onChanged: (scope) => setState(() => _scope = scope),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : words.isEmpty
                  ? Center(
                      child: Text(
                        _scope == _Scope.mine && keyword.isEmpty
                            ? 'Bạn chưa thêm từ nào.'
                            : 'Không tìm thấy từ phù hợp.',
                        style: palette.body,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        24,
                      ),
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return WordTile(
                          word: word,
                          onTap: () =>
                              _open(VocabularyDetailScreen(word: word)),
                          trailing: word.isPersonal
                              ? PopupMenuButton<String>(
                                  tooltip: 'Tùy chọn',
                                  onSelected: (action) => action == 'edit'
                                      ? _open(WordFormScreen(word: word))
                                      : _delete(word),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Sửa'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Xóa'),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
