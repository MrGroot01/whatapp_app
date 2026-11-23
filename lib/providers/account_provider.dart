import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../core/app_text.dart';
import '../l10n/app_localizations.dart';
import '../services/database_helper.dart';
import '../services/fcm_service.dart';
import '../services/phone_helper.dart';

class AccountProvider extends ChangeNotifier {
  AccountProvider({required this.fallbackEmail}) {
    _savedName =
        (FirebaseAuth.instance.currentUser?.displayName ?? '').trim();
    _loadLocalImage();
    _listenProfile();
  }

  final String fallbackEmail;
  VoidCallback? onPhotoUpdated;
  void Function(String name)? onNameChanged;

  StreamSubscription<DatabaseEvent>? _profileSub;
  bool _disposed = false;

  String _savedName = '';
  String? _phone;
  String? _countryCode;
  String? _profileEmail;
  String _photoRaw = '';
  Uint8List? _photoBytes;
  File? _localImage; // the phone's own copy of my picture
  bool _uploadingPhoto = false;
  bool _savingName = false;

  String get savedName => _savedName;
  Uint8List? get photoBytes => _photoBytes;
  File? get localImage => _localImage;
  bool get uploadingPhoto => _uploadingPhoto;
  bool get savingName => _savingName;
  bool get hasPhone => _phone != null && _phone!.isNotEmpty;

  String get email => _profileEmail ?? fallbackEmail;

  String get displayName {
    if (_savedName.trim().isNotEmpty) return _savedName;
    return fallbackEmail.split('@')[0];
  }

  String? get fullPhone {
    final phone = _phone;
    if (phone == null || phone.isEmpty) return null;
    return PhoneHelper.display(_countryCode ?? PhoneHelper.defaultCode, phone);
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // the same rules as the nickname
  static String? validateName(AppLocalizations l, String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l.enterYourName;
    if (name.length < 3) return l.useAtLeast3;
    if (name.length > 20) return l.useAtMost20;
    return null;
  }

  void _listenProfile() {
    final uid = _uid;
    if (uid == null) return;

    _profileSub = FirebaseDatabase.instance
        .ref('publicProfiles/$uid')
        .onValue
        .listen((event) {
      final value = event.snapshot.value;

      String name = '';
      String phone = '';
      String code = '';
      String email = '';
      String photo = '';

      if (value is Map) {
        String read(String key) => (value[key] ?? '').toString().trim();
        name = read('name');
        phone = read('phone');
        code = read('countryCode');
        email = read('email');
        photo = read('photoBase64');
      }

      Uint8List? bytes = _photoBytes;
      if (photo != _photoRaw) {
        bytes = null;
        if (photo.isNotEmpty) {
          try {
            bytes = base64Decode(photo);
          } catch (e) {
            debugPrint('Invalid profile picture data: $e');
          }
        }
      }

      if (name.isNotEmpty) {
        _savedName = name;
        onNameChanged?.call(name);
      }
      _phone = phone.isEmpty ? null : phone;
      _countryCode = code.isEmpty ? null : code;
      _profileEmail = email.isEmpty ? null : email;
      _photoRaw = photo;
      _photoBytes = bytes;
      _safeNotify();
    }, onError: (Object error) {
      debugPrint('Could not listen for profile changes: $error');
    });
  }

  // the picture saved on this phone (works offline)
  Future<void> _loadLocalImage() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final savedPath = await DatabaseHelper.getProfileImageForUid(uid);
      if (savedPath == null) return;

      final file = File(savedPath);
      if (!file.existsSync()) return;

      _localImage = file;
      _safeNotify();
    } catch (e) {
      debugPrint('Could not load local profile picture: $e');
    }
  }

  Future<bool> _isOnline() async {
    try {
      await FirebaseDatabase.instance
          .ref('.info/connected')
          .onValue
          .map((event) => event.snapshot.value == true)
          .firstWhere((connected) => connected)
          .timeout(const Duration(seconds: 4));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> changePhoto() async {
    if (_uploadingPhoto) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppText.l.pleaseLogInBeforePicture;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 480,
        maxHeight: 480,
      );

      if (picked == null) return null;

      _uploadingPhoto = true;
      _safeNotify();

      final imageBytes = await picked.readAsBytes();
      if (imageBytes.length > 650 * 1024) {
        return AppText.l.pictureTooLarge;
      }

      if (!await _isOnline()) {
        return AppText.l.youAreOfflineTryAgain;
      }

      final encoded = base64Encode(imageBytes);

      final folder = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile =
      await File(picked.path).copy('${folder.path}/$fileName');

      await FirebaseDatabase.instance.ref('publicProfiles/${user.uid}').update({
        'uid': user.uid,
        'photoBase64': encoded,
        'photoUpdatedAt': ServerValue.timestamp,
      });

      final oldPath = await DatabaseHelper.getProfileImageForUid(user.uid);
      await DatabaseHelper.saveProfileImageForUid(user.uid, savedFile.path);

      if (oldPath != null && oldPath != savedFile.path) {
        final oldFile = File(oldPath);
        if (oldFile.existsSync()) {
          try {
            await oldFile.delete();
          } catch (e) {
            debugPrint('Could not delete old profile image: $e');
          }
        }
      }

      _localImage = savedFile;
      _photoRaw = encoded;
      _photoBytes = imageBytes;
      onPhotoUpdated?.call();
      return null;
    } catch (e, stackTrace) {
      debugPrint('Profile picture update failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      return AppText.l.profileUpdateFailed(e.toString());
    } finally {
      _uploadingPhoto = false;
      _safeNotify();
    }
  }

  Future<String?> saveName(String newName) async {
    if (_savingName) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppText.l.pleaseLogInBeforeName;
    }

    final name = newName.trim();
    if (name == _savedName.trim()) return null;

    _savingName = true;
    _safeNotify();

    try {
      if (!await _isOnline()) {
        return AppText.l.youAreOfflineTryAgain;
      }

      await FirebaseDatabase.instance
          .ref('publicProfiles/${user.uid}/name')
          .set(name)
          .timeout(const Duration(seconds: 12));

      try {
        await user.updateDisplayName(name);
      } catch (e) {
        debugPrint('Display name not updated: $e');
      }

      await _updateLocalCopy(user, name);

      _savedName = name;
      return null;
    } on TimeoutException {
      return AppText.l.serverNoAnswer;
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied'
          ? AppText.l.firebaseDenied
          : AppText.l.couldNotSaveNameCode(e.code);
    } catch (e) {
      return AppText.l.couldNotSaveName;
    } finally {
      _savingName = false;
      _safeNotify();
    }
  }

  Future<void> _updateLocalCopy(User user, String newName) async {
    try {
      final email = (user.email ?? fallbackEmail).toLowerCase();
      final db = await DatabaseHelper.getDatabase();
      await db.update(
        'users',
        {'nickname': newName},
        where: 'email = ?',
        whereArgs: [email],
      );
    } catch (e) {
      debugPrint('Local nickname not updated: $e');
    }
  }

  Future<void> logout() async {
    await _profileSub?.cancel();
    _profileSub = null;

    await FcmService.removeCurrentToken();

    await FirebaseAuth.instance.signOut();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _profileSub?.cancel();
    super.dispose();
  }
}