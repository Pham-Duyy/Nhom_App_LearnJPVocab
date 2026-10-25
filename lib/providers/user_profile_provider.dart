import 'package:flutter/foundation.dart';

class UserProfileProvider extends ChangeNotifier {
  String _displayName = 'Duy';

  String get displayName => _displayName;

  String get initial =>
      _displayName.isEmpty ? '?' : _displayName[0].toUpperCase();

  void updateDisplayName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == _displayName) return;
    _displayName = trimmed;
    notifyListeners();
  }
}
