import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/study_preferences.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../widgets/choice_segments.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';
import 'reminder_settings.dart';

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
        ChoiceSegments<CardFront>(
          options: CardFront.values,
          selected: preferences.cardFront,
          labelOf: (front) =>
              front == CardFront.japanese ? 'Chữ Nhật' : 'Nghĩa',
          onChanged: (front) =>
              _save(context, preferences.copyWith(cardFront: front)),
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
        ChoiceSegments<int>(
          options: StudyPreferences.quizLengthOptions,
          selected: preferences.quizLength,
          labelOf: (length) => '$length câu',
          onChanged: (length) =>
              _save(context, preferences.copyWith(quizLength: length)),
        ),
        const SizedBox(height: 24),
        Text('NHẮC NHỞ', style: palette.sectionLabel),
        const ReminderSettings(),
      ],
    );
  }
}
