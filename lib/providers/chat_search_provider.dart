
import 'package:flutter/foundation.dart';

import '../models/message.dart';

class ChatSearchProvider extends ChangeNotifier {
  bool _searching = false;
  String _query = '';
  int _currentMatch = 0; // 0 = the newest match
  String? _currentMatchId;
  bool _disposed = false;

  bool get searching => _searching;
  String get query => _query;
  int get currentMatch => _currentMatch;
  String? get currentMatchId => _currentMatchId;

  void start() {
    _searching = true;
    _query = '';
    _currentMatch = 0;
    _currentMatchId = null;
    _notify();
  }

  void stop() {
    _searching = false;
    _query = '';
    _currentMatch = 0;
    _currentMatchId = null;
    _notify();
  }

  void setQuery(String value) {
    _query = value.trim();
    _currentMatch = 0; // start from the newest match
    _notify();
  }
  static bool messageMatches(Message m, String query) {
    final needle = query.toLowerCase();
    switch (m.type) {
      case 'text':
        return m.text.toLowerCase().contains(needle);
      case 'file':
        final name = m.fileName.isNotEmpty ? m.fileName : m.text;
        return name.toLowerCase().contains(needle);
      case 'contact':
        return m.contactName.toLowerCase().contains(needle) ||
            m.contactPhone.contains(needle);
      default:
        return false; // photos have no text to search
    }
  }

  List<int> matches(List<Object> items) {
    final q = _query.trim();
    if (q.isEmpty) return <int>[];

    final result = <int>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is Message && messageMatches(item, q)) result.add(i);
    }
    return result;
  }
  List<int> refresh(List<Object> items) {
    final found = matches(items);
    if (_currentMatch >= found.length) {
      _currentMatch = found.isEmpty ? 0 : found.length - 1;
    }
    _currentMatchId = found.isEmpty
        ? null
        : (items[found[_currentMatch]] as Message).id;
    return found;
  }
  bool move(int delta, List<Object> items) {
    final found = matches(items);
    if (found.isEmpty) return false;
    _currentMatch = (_currentMatch + delta).clamp(0, found.length - 1).toInt();
    _notify();
    return true;
  }

  int? currentIndex(List<Object> items) {
    final found = matches(items);
    if (found.isEmpty) return null;
    return found[_currentMatch.clamp(0, found.length - 1).toInt()];
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}