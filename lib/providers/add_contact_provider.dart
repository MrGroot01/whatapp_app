import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../core/app_strings.dart';
import '../services/database_helper.dart';
import '../models/found_profile.dart';
import '../services/phone_helper.dart';

enum LookupState { idle, loading, found, notFound, self, error }

class ContactForm {
  final String name;
  final String phone;
  final String countryCode;

  const ContactForm({
    required this.name,
    required this.phone,
    required this.countryCode,
  });
}

class AddContactProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  void Function(FoundProfile found)? onFound;
  VoidCallback? onCleared;
  VoidCallback? onSaved;

  Timer? _debounce;
  int _lookupId = 0; // lets us ignore old, slower lookups
  LookupState _state = LookupState.idle;
  FoundProfile? _found;
  String _lookupEmail = '';
  String? _lookupError;
  bool _saving = false;
  bool _disposed = false;

  LookupState get state => _state;
  FoundProfile? get found => _found;
  String? get lookupError => _lookupError;
  bool get saving => _saving;

  bool get phoneLocked =>
      _state == LookupState.found && (_found?.hasPhone ?? false);

  bool get blocked =>
      _state == LookupState.loading ||
          _state == LookupState.notFound ||
          _state == LookupState.self;

  static bool looksLikeEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) return AppStrings.enterContactName;
    if (name.length < 4) return AppStrings.nameTooShort;
    if (name.length > 40) return AppStrings.nameTooLong;

    return null;
  }

  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) return AppStrings.enterRegisteredEmail;
    if (!looksLikeEmail(email)) return AppStrings.enterValidEmail;

    return null;
  }

  void onEmailChanged(String value) {
    _debounce?.cancel();
    _lookupId++; // ignore any lookup that is still running
    _clearLookup();

    final email = value.trim().toLowerCase();
    if (looksLikeEmail(email)) {
      _debounce = Timer(
        const Duration(milliseconds: 600),
            () => lookup(email),
      );
    }
  }

  void onEmailFocusLost(String rawEmail) {
    final email = rawEmail.trim().toLowerCase();
    if (!looksLikeEmail(email)) return;

    final alreadyDone = _lookupEmail == email &&
        (_state == LookupState.loading ||
            _state == LookupState.found ||
            _state == LookupState.notFound ||
            _state == LookupState.self);
    if (alreadyDone) return;

    _debounce?.cancel();
    lookup(email);
  }

  void _clearLookup() {
    _state = LookupState.idle;
    _found = null;
    _lookupEmail = '';
    _lookupError = null;
    onCleared?.call();
    _safeNotify();
  }

  Future<void> lookup(String email) async {
    if (_disposed) return;
    final user = _auth.currentUser;
    final id = ++_lookupId;

    _state = LookupState.loading;
    _lookupEmail = email;
    _lookupError = null;
    _found = null;
    _safeNotify();

    try {
      final snapshot = await _database
          .ref('publicProfiles')
          .orderByChild('email')
          .equalTo(email)
          .get()
          .timeout(const Duration(seconds: 12));

      if (_disposed || id != _lookupId) return;

      FoundProfile? found;
      final value = snapshot.value;
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.value is! Map) continue;
          final profile = Map<dynamic, dynamic>.from(entry.value as Map);

          // compare normalized email addresses
          final profileEmail =
          (profile['email'] ?? '').toString().trim().toLowerCase();
          if (profileEmail != email) continue;

          found = FoundProfile(
            uid: entry.key.toString(),
            name: (profile['name'] ?? '').toString().trim(),
            email: email,
            phone: PhoneHelper.clean((profile['phone'] ?? '').toString()),
            countryCode: (profile['countryCode'] ?? '').toString().trim(),
          );
          break;
        }
      }

      if (found == null) {
        _state = LookupState.notFound;
        _safeNotify();
        return;
      }

      if (user != null && found.uid == user.uid) {
        _state = LookupState.self;
        _safeNotify();
        return;
      }

      _found = found;
      _state = LookupState.found;
      onFound?.call(found); // the screen fills the phone and suggests the name
      _safeNotify();
    } on TimeoutException {
      if (_disposed || id != _lookupId) return;
      _state = LookupState.error;
      _lookupError = AppStrings.lookupFailedInternet;
      _safeNotify();
    } on FirebaseException catch (e) {
      if (_disposed || id != _lookupId) return;
      _state = LookupState.error;
      _lookupError = e.code == 'permission-denied'
          ? AppStrings.firebaseDenied
          : AppStrings.lookupFailedCode(e.code);
      _safeNotify();
    } catch (e) {
      if (_disposed || id != _lookupId) return;
      _state = LookupState.error;
      _lookupError = AppStrings.lookupFailedInternet;
      _safeNotify();
    }
  }

  Future<String?> save({
    required String email,
    required ContactForm? Function() readForm,
  }) async {
    if (_saving) return null;

    final user = _auth.currentUser;
    if (user == null) {
      return AppStrings.loginAgainToSave;
    }

    final mail = email.trim().toLowerCase();

    _debounce?.cancel();
    _saving = true;
    _safeNotify();

    try {
      if (_state != LookupState.found || _found?.email != mail) {
        await lookup(mail);
      }

      final found = _found;
      if (_state != LookupState.found || found == null) {
        return null; // the message under the email box explains why
      }

      final form = readForm();
      if (form == null) return null;

      final otherUid = found.uid;
      if (otherUid == user.uid) {
        throw Exception(AppStrings.cannotAddSelf);
      }

      final name = form.name.trim();

      final phone =
      found.hasPhone ? found.phone : PhoneHelper.clean(form.phone);
      final code = found.hasPhone
          ? (found.countryCode.isNotEmpty
          ? found.countryCode
          : PhoneHelper.defaultCode)
          : form.countryCode;

      final contactRef = _database.ref('users/${user.uid}/contacts/$otherUid');

      final existingContact =
      await contactRef.get().timeout(const Duration(seconds: 12));

      if (existingContact.exists) {
        throw Exception(AppStrings.userAlreadyInContacts);
      }

      await contactRef.set({
        'uid': otherUid,
        'name': name,
        'phone': phone,
        'countryCode': code,
        'email': mail,
        'addedAt': ServerValue.timestamp,
        'lastMessage': 'Tap to start chatting',
        'time': '',
      }).timeout(const Duration(seconds: 12));

      await DatabaseHelper.saveContact(
        owner: user.uid,
        id: otherUid,
        name: name,
        phone: phone,
        countryCode: code,
        lastMessage: 'Tap to start chatting',
        time: '',
      );

      onSaved?.call();
      return null;
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied'
          ? AppStrings.firebaseDenied
          : AppStrings.firebaseError(
        e.code,
        e.message ?? AppStrings.unknownError,
      );
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _saving = false;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}