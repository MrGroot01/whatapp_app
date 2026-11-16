import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../services/database_helper.dart';
import '../models/contact.dart';

class ContactsProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _hasRemoteContacts = false;
  bool _disposed = false;

  StreamSubscription<DatabaseEvent>? _subscription;
  DatabaseReference? _syncedRef;

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;

  // called once when the home screen opens
  void start() {
    if (_subscription != null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _isLoading = false;
      return;
    }

    final ref = _database.ref('users/$uid/contacts');
    _syncedRef = ref;
    ref.keepSynced(true);

    unawaited(_loadLocal(uid));

    _subscription = ref.onValue.listen(
      _onRemoteEvent,
      onError: (Object error) {
        debugPrint('[ContactsProvider] Firebase contacts error: $error');
        if (!_hasRemoteContacts) {
          _isLoading = false;
          _notify();
        }
      },
    );
  }

  // ---------- 1. SQLITE (works offline) ----------
  Future<void> _loadLocal(String uid) async {
    try {
      final rows = await DatabaseHelper.getContacts(uid);
      final local = rows.map((row) {
        return Contact.fromMap(row['id'].toString(), {
          'name': row['name'],
          'phone': row['phone'],
          'countryCode': row['country_code'],
          'lastMessage': row['last_message'],
          'time': row['time'],
        });
      }).toList();

      if (_disposed) return;
      // Use local data immediately; Firebase can refresh it afterward.
      if (!_hasRemoteContacts) _contacts = local;
      _isLoading = false;
      _notify();
    } catch (e) {
      debugPrint('[ContactsProvider] Failed to load local contacts: $e');
      if (_disposed) return;
      _isLoading = false;
      _notify();
    }
  }

  Future<void> _onRemoteEvent(DatabaseEvent event) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final remote = _parse(event.snapshot.value);

    if (event.snapshot.value == null && _contacts.isNotEmpty) {
      _isLoading = false;
      _notify();
      return;
    }

    try {
      await DatabaseHelper.saveContacts(
        uid,
        remote
            .map((contact) => <String, dynamic>{
          'id': contact.id,
          'name': contact.name,
          'phone': contact.phone,
          'countryCode': contact.countryCode,
          'lastMessage': contact.message,
          'time': contact.time,
        })
            .toList(),
      );
    } catch (e) {
      debugPrint('[ContactsProvider] Failed to cache Firebase contacts: $e');
    }

    if (_disposed) return;
    _contacts = remote.isNotEmpty ? remote : _contacts;
    _hasRemoteContacts = true;
    _isLoading = false;
    _notify();
  }

  List<Contact> _parse(Object? value) {
    if (value is! Map) return [];
    final map = Map<dynamic, dynamic>.from(value);
    final contacts = <Contact>[];

    for (final entry in map.entries) {
      if (entry.value is Map) {
        contacts.add(
          Contact.fromMap(
            entry.key.toString(),
            Map<dynamic, dynamic>.from(entry.value as Map),
          ),
        );
      }
    }

    contacts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return contacts;
  }

  // never notify after dispose (a late SQLite / Firebase answer)
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    _syncedRef?.keepSynced(false);
    super.dispose();
  }
}