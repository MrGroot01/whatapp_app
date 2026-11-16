import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../services/database_helper.dart';
class ProfileProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  File? _localImage;
  String _sharedEncoded = ''; // the last base64 text from Firebase
  MemoryImage? _sharedImage; // decoded once, not on every rebuild

  StreamSubscription<DatabaseEvent>? _subscription;
  bool _started = false;
  bool _disposed = false;

  ImageProvider? get avatar {
    if (_sharedImage != null) return _sharedImage;
    final local = _localImage;
    return local != null ? FileImage(local) : null;
  }

  void start() {
    if (_started) return;
    _started = true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    unawaited(reload());

    _subscription = _database
        .ref('publicProfiles/$uid/photoBase64')
        .onValue
        .listen(
          (event) {
        final value = event.snapshot.value;
        final encoded = value is String ? value : '';

        // nothing new: do not decode again
        if (encoded == _sharedEncoded) return;
        _sharedEncoded = encoded;
        _sharedImage = _decode(encoded);
        _notify();
      },
      onError: (Object e) =>
          debugPrint('[ProfileProvider] Profile photo error: $e'),
    );
  }

  Future<void> reload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final savedPath = await DatabaseHelper.getProfileImageForUid(uid);
      File? file;
      if (savedPath != null && File(savedPath).existsSync()) {
        file = File(savedPath);
      }
      if (_disposed) return;
      _localImage = file;
      _notify();
    } catch (e) {
      debugPrint('[ProfileProvider] Could not load local profile picture: $e');
    }
  }

  MemoryImage? _decode(String encoded) {
    if (encoded.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(encoded));
    } catch (e) {
      debugPrint('[ProfileProvider] Invalid own DP data: $e');
      return null;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}