import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/study_preferences.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';

/// Tùy chọn học: mặt trước của thẻ, romaji, số câu quiz, nhắc học. Mỗi thay
/// đổi được lưu ngay vào hồ sơ trên Firestore.
class StudyPreferencesScreen extends GenericScreen {
  const StudyPreferencesScreen({Key? key}) : super(key: key);

  @override
  String getTitle(BuildContext context) => 'Tùy chọn học';

  Future<void> _save(BuildContext context, StudyPreferences next) async {
    final profile = context.read<UserProfileProvider>();
    await profile.setPreferences(next);
    final error = profile.errorMessage;
    if (error != null && context.mounted) {
      profile.clearError();
      showErrorSnackBar(context, error);
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    final palette = context.palette;
    final preferences = context.watch<UserProfileProvider>().preferences;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text('THẺ FLASHCARD', style: palette.sectionLabel),
        const SizedBox(height: 12),
        const Text('Mặt trước của thẻ'),
        const SizedBox(height: 8),
        SegmentedButton<CardFront>(
          segments: const [
            ButtonSegment(
              value: CardFront.japanese,
              label: Text('Chữ Nhật'),
              icon: Icon(Icons.translate_rounded),
            ),
            ButtonSegment(
              value: CardFront.meaning,
              label: Text('Nghĩa'),
              icon: Icon(Icons.menu_book_outlined),
            ),
          ],
          selected: {preferences.cardFront},
          onSelectionChanged: (selection) => _save(
            context,
            preferences.copyWith(cardFront: selection.single),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          preferences.cardFront == CardFront.japanese
              ? 'Nhìn chữ Nhật, đoán nghĩa.'
              : 'Nhìn nghĩa, nhớ lại cách viết tiếng Nhật.',
          style: palette.body,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Hiện romaji'),
          subtitle: const Text('Tắt đi để luyện đọc kana.'),
          value: preferences.showRomaji,
          onChanged: (value) =>
              _save(context, preferences.copyWith(showRomaji: value)),
        ),
        const SizedBox(height: 24),
        Text('QUIZ', style: palette.sectionLabel),
        const SizedBox(height: 12),
        const Text('Số câu mỗi lượt'),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [
            for (final length in StudyPreferences.quizLengthOptions)
              ButtonSegment(value: length, label: Text('$length câu')),
          ],
          selected: {preferences.quizLength},
          onSelectionChanged: (selection) => _save(
            context,
            preferences.copyWith(quizLength: selection.single),
          ),
        ),
        const SizedBox(height: 24),
        Text('NHẮC NHỞ', style: palette.sectionLabel),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Nhắc học mỗi ngày'),
          subtitle: const Text(
            'Hiện lời nhắc trên trang chủ khi hôm nay bạn chưa học.',
          ),
          value: preferences.dailyReminder,
          onChanged: (value) =>
              _save(context, preferences.copyWith(dailyReminder: value)),
        ),
      ],
    );
  }
}
