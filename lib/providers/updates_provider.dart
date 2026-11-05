import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/status_entry.dart';
import '../status_service.dart';

// The controller for the Updates tab.
// It watches my own statuses and the statuses of every contact in my list,
// hides the ones that expired, and splits the contacts into
// "Recent updates" (something I have not seen) and "Viewed updates".
//
// The screen only draws the rows and opens the other screens.
class UpdatesProvider extends ChangeNotifier {
  UpdatesProvider({required List<StatusContact> contacts})
      : _contacts = contacts {
    _start();
  }

  // my contacts (Home gives a new list when it changes)
  List<StatusContact> _contacts;

  // contact id -> that person's statuses (one live listener per contact)
  final Map<String, StreamSubscription<List<StatusItem>>> _subs = {};
  final Map<String, List<StatusItem>> _items = {};

  StreamSubscription<List<StatusItem>>? _mineSub;
  List<StatusItem> _mine = [];
  Timer? _tick;
  bool _disposed = false;

  // ---------- WHAT THE SCREEN READS ----------
  // my own statuses that have not expired
  List<StatusItem> get mine => StatusService.active(_mine);

  // contacts with a status I have not seen, newest first
  List<StatusEntry> get recent =>
      _entries().where((e) => e.unseen > 0).toList();

  // contacts whose statuses I have all seen, newest first
  List<StatusEntry> get viewed =>
      _entries().where((e) => e.unseen == 0).toList();

  // the viewer starts at the first status I have not seen
  int firstUnseenIndex(List<StatusItem> items) {
    final index = items.indexWhere((i) => !i.seenBy(StatusService.myUid));
    return index < 0 ? 0 : index;
  }

  // ---------- START ----------
  void _start() {
    final me = StatusService.myUid;
    if (me.isNotEmpty) {
      _mineSub = StatusService.watch(me).listen(
            (list) {
          _mine = list;
          _safeNotify();
        },
        onError: (Object e) => debugPrint('My status error: $e'),
      );
    }

    _syncSubscriptions();
    StatusService.cleanupMine();

    // every 20 seconds: hide expired statuses and clean up my old ones
    _tick = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_disposed) return;
      _safeNotify();
      StatusService.cleanupMine();
    });
  }

  // ---------- CONTACTS ----------
  // Home calls this every time it redraws, so it must be cheap:
  // nothing happens unless the list really changed.
  void setContacts(List<StatusContact> contacts) {
    if (_sameContacts(_contacts, contacts)) return;

    _contacts = contacts;
    _syncSubscriptions();

    // we are inside a build when Home calls this: notify a moment later
    scheduleMicrotask(_safeNotify);
  }

  bool _sameContacts(List<StatusContact> a, List<StatusContact> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].name != b[i].name ||
          a[i].color != b[i].color) {
        return false;
      }
    }
    return true;
  }

  // watch the statuses of every contact in my list
  void _syncSubscriptions() {
    final ids = _contacts.map((c) => c.id).toSet();

    // stop watching contacts that are gone
    for (final id in _subs.keys.toList()) {
      if (!ids.contains(id)) {
        _subs.remove(id)?.cancel();
        _items.remove(id);
      }
    }

    // start watching new contacts
    for (final id in ids) {
      if (_subs.containsKey(id)) continue;
      _subs[id] = StatusService.watch(id).listen(
            (list) {
          _items[id] = list;
          _safeNotify();
        },
        onError: (Object e) => debugPrint('Status of $id: $e'),
      );
    }
  }

  // the contacts that have at least one active status, newest first
  List<StatusEntry> _entries() {
    final list = <StatusEntry>[];
    for (final c in _contacts) {
      final items = StatusService.active(_items[c.id] ?? const []);
      if (items.isEmpty) continue;
      list.add(StatusEntry(c, items));
    }
    list.sort((a, b) => b.latest.compareTo(a.latest));
    return list;
  }

  // the screen calls this when the viewer closes (the "seen" marks changed)
  void refresh() => _safeNotify();

  // ---------- HELPERS ----------
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    _mineSub?.cancel();
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    super.dispose();
  }
}