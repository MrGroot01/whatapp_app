import 'package:flutter/foundation.dart';
class ChatSelectionProvider extends ChangeNotifier {
  final Set<String> _selected = {};

  bool get isSelecting => _selected.isNotEmpty;
  int get count => _selected.length;

  Set<String> get selectedIds => Set<String>.of(_selected);

  bool isSelected(String chatId) => _selected.contains(chatId);

  void toggle(String chatId) {
    if (!_selected.remove(chatId)) _selected.add(chatId);
    notifyListeners();
  }

  void remove(String chatId) {
    if (_selected.remove(chatId)) notifyListeners();
  }

  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}