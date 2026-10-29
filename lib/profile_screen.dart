import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'database_helper.dart';
import 'phone_helper.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _error = Color(0xFFD94B4B);
  static const Color _lockedFill = Color(0xFFEFEBE0);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  StreamSubscription<DatabaseEvent>? _profileSubscription;

  String _savedName = '';
  String? _phone;
  String? _countryCode;
  String? _profileEmail;
  String _photoRaw = '';
  Uint8List? _photoBytes;
  File? _localImage;

  bool _nameTouched = false; // the user typed in the name box
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _savedName = (user?.displayName ?? '').trim();
    nameController.text = _savedName;
    _loadLocalImage();
    _listenForProfile();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    nameController.dispose();
    super.dispose();
  }

  // ---------- LIVE PROFILE ----------
  void _listenForProfile() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _profileSubscription = FirebaseDatabase.instance
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

      // decode the picture only when it changed
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

      if (!mounted) return;
      setState(() {
        if (name.isNotEmpty) {
          _savedName = name;
          if (!_nameTouched) nameController.text = name;
        }
        _phone = phone.isEmpty ? null : phone;
        _countryCode = code.isEmpty ? null : code;
        _profileEmail = email.isEmpty ? null : email;
        _photoRaw = photo;
        _photoBytes = bytes;
      });
    }, onError: (Object error) {
      debugPrint('Could not listen for profile changes: $error');
    });
  }

  Future<void> _loadLocalImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final savedPath = await DatabaseHelper.getProfileImageForUid(uid);
      if (savedPath == null) return;

      final file = File(savedPath);
      if (!file.existsSync()) return;
      if (!mounted) return;

      setState(() => _localImage = file);
    } catch (e) {
      debugPrint('Could not load local profile picture: $e');
    }
  }

  // ---------- VALIDATION (same rules as the nickname) ----------
  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Please enter your name';
    if (name.length < 3) return 'Use at least 3 characters';
    if (name.length > 20) return 'Use at most 20 characters';
    return null;
  }

  bool get _canSave =>
      !_isSaving && nameController.text.trim() != _savedName.trim();

  // ---------- ONLINE CHECK ----------
  // Realtime Database keeps writes in a queue while offline, so we check
  // first and show a clear message instead of a save that never finishes.
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

  // ---------- SAVE THE NAME ----------
  Future<void> _saveName() async {
    if (_isSaving) return;
    if (!formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Please log in again before changing your name.';
      });
      return;
    }

    final newName = nameController.text.trim();
    if (newName == _savedName.trim()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (!await _isOnline()) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
          'You are offline. Connect to the internet and try again.';
        });
        return;
      }

      // 1. the public profile (other people's contact names are NOT changed)
      await FirebaseDatabase.instance
          .ref('publicProfiles/${user.uid}/name')
          .set(newName)
          .timeout(const Duration(seconds: 12));

      // 2. the Firebase Auth display name
      try {
        await user.updateDisplayName(newName);
      } catch (e) {
        debugPrint('Display name not updated: $e');
      }

      // 3. the local SQLite copy
      await _updateLocalCopy(user, newName);

      if (!mounted) return;
      setState(() {
        _savedName = newName;
        _nameTouched = false;
      });
      _showMessage('Name updated');
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _errorMessage =
        'The server did not answer. Check your internet connection and try again.';
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.code == 'permission-denied'
            ? 'Firebase denied access. Check your database rules.'
            : 'Could not save your name (${e.code}). Please try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not save your name. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // the old local users table keeps a nickname per email
  Future<void> _updateLocalCopy(User user, String newName) async {
    try {
      final email = (user.email ?? widget.email).toLowerCase();
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------- UI ----------
  Widget _initialAvatar(String displayName) {
    return Center(
      child: Text(
        displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _fallbackAvatar(String displayName) {
    final file = _localImage;
    if (file != null) {
      return ClipOval(
        child: Image.file(
          file,
          width: 112,
          height: 112,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialAvatar(displayName),
        ),
      );
    }
    return _initialAvatar(displayName);
  }

  Widget _buildAvatar(String displayName) {
    final bytes = _photoBytes;
    if (bytes != null) {
      return ClipOval(
        child: Image.memory(
          bytes,
          width: 112,
          height: 112,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _fallbackAvatar(displayName),
        ),
      );
    }
    return _fallbackAvatar(displayName);
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    bool locked = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSoft, fontSize: 16),
      floatingLabelStyle: TextStyle(
        color: locked ? AppColors.textSoft : AppColors.emerald,
        fontSize: 16,
      ),
      prefixIcon: Icon(
        icon,
        color: locked ? AppColors.textSoft : AppColors.emerald,
      ),
      suffixIcon: locked
          ? const Icon(Icons.lock_outline, color: AppColors.textSoft, size: 20)
          : null,
      filled: true,
      fillColor: locked ? _lockedFill : AppColors.card,
      errorStyle: const TextStyle(color: _error, fontSize: 14),
      border: border(const Color(0xFFE3DED2)),
      enabledBorder: border(const Color(0xFFE3DED2)),
      focusedBorder: border(AppColors.emerald, 1.5),
      errorBorder: border(_error, 1.5),
      focusedErrorBorder: border(_error, 1.5),
    );
  }

  // a greyed, read-only box with a lock icon
  Widget _lockedField({
    required String label,
    required IconData icon,
    required String value,
    bool muted = false,
  }) {
    return InputDecorator(
      isEmpty: false,
      decoration: _decoration(label: label, icon: icon, locked: true),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: muted ? const Color(0xFF9AA5A3) : AppColors.textSoft,
          fontSize: 17,
          fontStyle: muted ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailName = widget.email.split('@')[0];
    final avatarName = _savedName.trim().isNotEmpty ? _savedName : emailName;

    final phoneValue = _phone;
    final hasPhone = phoneValue != null && phoneValue.isNotEmpty;
    final phoneText = hasPhone
        ? PhoneHelper.display(
      _countryCode ?? PhoneHelper.defaultCode,
      phoneValue,
    )
        : 'Not added';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PICTURE (change it from Settings with the camera button)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.gold,
                      child: _buildAvatar(avatarName),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // NAME (editable)
                TextFormField(
                  controller: nameController,
                  enabled: !_isSaving,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                  ),
                  cursorColor: AppColors.emerald,
                  onChanged: (_) => setState(() {
                    _nameTouched = true;
                    _errorMessage = null;
                  }),
                  onFieldSubmitted: (_) {
                    if (_canSave) _saveName();
                  },
                  decoration: _decoration(
                    label: 'Name',
                    icon: Icons.person_outline,
                  ).copyWith(counterText: ''),
                  validator: _validateName,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: Text(
                    'People who saved you keep the name they chose for you.',
                    style: TextStyle(color: AppColors.textSoft, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 18),

                // PHONE (read-only)
                _lockedField(
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  value: phoneText,
                  muted: !hasPhone,
                ),
                const SizedBox(height: 18),

                // EMAIL (read-only)
                _lockedField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  value: _profileEmail ?? widget.email,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCEAEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: _error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: _error,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _canSave ? _saveName : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      disabledBackgroundColor: _isSaving
                          ? AppColors.emerald
                          : const Color(0xFFB8C2C0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Save name',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}