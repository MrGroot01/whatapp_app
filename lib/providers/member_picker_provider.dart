import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/database_helper.dart';
import '../group_service.dart';

class MemberPickerProvider extends ChangeNotifier {
  MemberPickerProvider({required this._excludeIds}) {
    _load();
  }

  // people who are already in the group (add-members mode)
  final Set<String> _excludeIds;

  List<PickedContact> _all = [];
  // the ticked people, in the order they were ticked
  final Map<String, PickedContact> _selected = {};
  bool _loading = true;
  String _query = '';
  bool _disposed = false;

  // ---------- WHAT THE SCREEN READS ----------
  bool get loading => _loading;
  int get allCount => _all.length;

  // the ticked people, in the order they were ticked
  List<PickedContact> get selected => _selected.values.toList();
  int get selectedCount => _selected.length;

  bool isSelected(String id) => _selected.containsKey(id);

  // the contacts that match the search
  List<PickedContact> get shown {
    final q = _query.trim().toLowerCase();
    return _all.where((c) {
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          '${c.countryCode}${c.phone}'.contains(q);
    }).toList();
  }

  List<Object> get items {
    final list = <Object>[];
    var lastLetter = '';
    for (final c in shown) {
      final letter = c.name.isNotEmpty ? c.name[0].toUpperCase() : '#';
      if (letter != lastLetter) {
        list.add(letter);
        lastLetter = letter;
      }
      list.add(c);
    }
    return list;
  }

  // ---------- LOAD ----------
  // the saved contacts are kept on the phone too, so this also works offline
  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final list = <PickedContact>[];

    if (uid.isNotEmpty) {
      try {
        final rows = await DatabaseHelper.getContacts(uid);
        for (final r in rows) {
          final id = r['id'].toString();
          if (id == uid || _excludeIds.contains(id)) continue;
          list.add(
            PickedContact(
              id: id,
              name: (r['name'] ?? 'Contact').toString(),
              phone: (r['phone'] ?? '').toString(),
              countryCode: (r['country_code'] ?? '+91').toString(),
            ),
          );
        }
      } catch (e) {
        debugPrint('Could not load contacts for the group: $e');
      }
    }

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (_disposed) return;
    _all = list;
    _loading = false;
    notifyListeners();
  }

  // ---------- ACTIONS ----------
  // tick or untick a person
  void toggle(PickedContact c) {
    if (_selected.containsKey(c.id)) {
      _selected.remove(c.id);
    } else {
      _selected[c.id] = c;
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}