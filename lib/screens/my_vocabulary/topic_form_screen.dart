import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_topic.dart';
import '../../providers/my_vocabulary_provider.dart';
import '../../theme/app_styles.dart';
import '../../widgets/error_view.dart';
import '../common/generic_screen.dart';

/// Tạo chủ đề mới, hoặc sửa tên và mô tả của [topic].
class TopicFormScreen extends StatefulWidget {
  const TopicFormScreen({Key? key, this.topic}) : super(key: key);

  final UserTopic? topic;

  @override
  State<TopicFormScreen> createState() => _TopicFormScreenState();
}

class _TopicFormScreenState extends GenericScreenState<TopicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.topic?.name);
  late final _description =
      TextEditingController(text: widget.topic?.description);
  bool _isSaving = false;

  bool get _isEditing => widget.topic != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  String getTitle(BuildContext context) =>
      _isEditing ? 'Sửa chủ đề' : 'Tạo chủ đề';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<MyVocabularyProvider>();
    final error = _isEditing
        ? await provider.updateTopic(
            widget.topic!,
            name: _name.text,
            description: _description.text,
          )
        : await provider.createTopic(
            _name.text,
            description: _description.text,
          );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Đã lưu chủ đề.' : 'Đã tạo chủ đề.'),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          TextFormField(
            controller: _name,
            autofocus: !_isEditing,
            maxLength: UserTopic.maxNameLength,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Tên chủ đề',
              hintText: 'Vd. Từ vựng ở chỗ làm',
            ),
            validator: (value) => UserTopic.validateName(value ?? ''),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả (không bắt buộc)',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: Text(_isEditing ? 'Lưu thay đổi' : 'Tạo chủ đề'),
          ),
        ],
      ),
    );
  }
}
