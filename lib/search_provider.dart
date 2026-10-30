import 'package:flutter/foundation.dart';

class SearchProvider extends ChangeNotifier {
  bool _isSearching = false;
  String _query = '';

  bool get isSearching => _isSearching;
  String get query => _query;

  void toggle() {
    _isSearching = !_isSearching;
    if (!_isSearching) _query = ''; // closing clears the text
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }


  void reset() {
    _isSearching = false;
    _query = '';
  }
}