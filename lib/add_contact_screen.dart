import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'database_helper.dart';
import 'phone_helper.dart';

// the registered user found by the email lookup
class _FoundProfile {
  final String uid;
  final String name;
  final String email;
  final String phone; // digits only, empty for accounts made before phones
  final String countryCode;

  const _FoundProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.countryCode,
  });

  bool get hasPhone => phone.isNotEmpty;
}

enum _LookupState { idle, loading, found, notFound, self, error }

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  static const Color _error = Color(0xFFD94B4B);
  static const Color _lockedFill = Color(0xFFEFEBE0);

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final FocusNode emailFocus = FocusNode();

  String countryCode = PhoneHelper.defaultCode;
  bool isSaving = false;
  String? errorMessage;

  // ---------- EMAIL LOOKUP STATE ----------
  Timer? _debounce;
  int _lookupId = 0; // lets us ignore old, slower lookups
  _LookupState _lookupState = _LookupState.idle;
  _FoundProfile? _found;
  String _lookupEmail = '';
  String? _lookupError;
  bool _phoneAutoFilled = false;
  String _suggestedName = '';

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    emailFocus.addListener(_onEmailFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    emailFocus.removeListener(_onEmailFocusChanged);
    emailFocus.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) return 'Enter the contact name';
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (name.length > 40) {
      return 'Name must be 40 characters or less';
    }

    return null;
  }

  String? validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Enter the registered email address';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // the phone is locked when the found profile already has one
  bool get _phoneLocked =>
      _lookupState == _LookupState.found && (_found?.hasPhone ?? false);

  bool _looksLikeEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // ---------- EMAIL LOOKUP ----------
  void _onEmailChanged(String value) {
    _debounce?.cancel();
    _lookupId++; // ignore any lookup that is still running
    _clearLookup();

    final email = value.trim().toLowerCase();
    if (_looksLikeEmail(email)) {
      // wait until the user stops typing
      _debounce = Timer(
        const Duration(milliseconds: 600),
            () => _lookup(email),
      );
    }
  }

  void _onEmailFocusChanged() {
    if (emailFocus.hasFocus) return;

    final email = emailController.text.trim().toLowerCase();
    if (!_looksLikeEmail(email)) return;

    final alreadyDone = _lookupEmail == email &&
        (_lookupState == _LookupState.loading ||
            _lookupState == _LookupState.found ||
            _lookupState == _LookupState.notFound ||
            _lookupState == _LookupState.self);
    if (alreadyDone) return;

    _debounce?.cancel();
    _lookup(email);
  }

  // forget the last lookup and unlock the phone fields
  void _clearLookup() {
    if (!mounted) return;
    setState(() {
      _lookupState = _LookupState.idle;
      _found = null;
      _lookupEmail = '';
      _lookupError = null;
      errorMessage = null;

      if (_phoneAutoFilled) {
        phoneController.clear();
        _phoneAutoFilled = false;
      }
      if (_suggestedName.isNotEmpty && nameController.text == _suggestedName) {
        nameController.clear();
      }
      _suggestedName = '';
    });
  }

  Future<void> _lookup(String email) async {
    if (!mounted) return;
    final user = auth.currentUser;
    final id = ++_lookupId;

    setState(() {
      _lookupState = _LookupState.loading;
      _lookupEmail = email;
      _lookupError = null;
      _found = null;
    });

    try {
      final snapshot = await database
          .ref('publicProfiles')
          .orderByChild('email')
          .equalTo(email)
          .get()
          .timeout(const Duration(seconds: 12));

      if (!mounted || id != _lookupId) return;

      _FoundProfile? found;
      final value = snapshot.value;
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.value is! Map) continue;
          final profile = Map<dynamic, dynamic>.from(entry.value as Map);

          // compare normalized email addresses
          final profileEmail =
          (profile['email'] ?? '').toString().trim().toLowerCase();
          if (profileEmail != email) continue;

          found = _FoundProfile(
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
        setState(() => _lookupState = _LookupState.notFound);
        return;
      }

      if (user != null && found.uid == user.uid) {
        setState(() => _lookupState = _LookupState.self);
        return;
      }

      _applyFound(found);
    } on TimeoutException {
      if (!mounted || id != _lookupId) return;
      setState(() {
        _lookupState = _LookupState.error;
        _lookupError =
        'Could not look up this email. Check your internet connection.';
      });
    } on FirebaseException catch (e) {
      if (!mounted || id != _lookupId) return;
      setState(() {
        _lookupState = _LookupState.error;
        _lookupError = e.code == 'permission-denied'
            ? 'Firebase denied access. Check your database rules.'
            : 'Could not look up this email (${e.code}).';
      });
    } catch (e) {
      if (!mounted || id != _lookupId) return;
      setState(() {
        _lookupState = _LookupState.error;
        _lookupError =
        'Could not look up this email. Check your internet connection.';
      });
    }
  }

  // fill the phone and suggest the registered name
  void _applyFound(_FoundProfile found) {
    setState(() {
      _found = found;
      _lookupState = _LookupState.found;

      if (found.hasPhone) {
        countryCode = found.countryCode.isNotEmpty
            ? found.countryCode
            : PhoneHelper.defaultCode;
        phoneController.text = found.phone;
        _phoneAutoFilled = true;
      }

      // suggest the registered name only if the user has not typed one
      final typedName = nameController.text.trim();
      if (found.name.isNotEmpty &&
          (typedName.isEmpty || nameController.text == _suggestedName)) {
        nameController.text = found.name;
        _suggestedName = found.name;
      }
    });
  }

  // ---------- SAVE ----------
  Future<void> saveContact() async {
    if (isSaving) return;

    final user = auth.currentUser;

    if (user == null) {
      setState(() {
        errorMessage = 'Please log in again before saving contacts.';
      });
      return;
    }

    final email = emailController.text.trim().toLowerCase();
    if (validateEmail(email) != null) {
      formKey.currentState!.validate();
      return;
    }

    _debounce?.cancel();
    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      // make sure the lookup is finished for this exact email
      if (_lookupState != _LookupState.found || _found?.email != email) {
        await _lookup(email);
      }

      final found = _found;
      if (_lookupState != _LookupState.found || found == null) {
        return; // the message under the email box explains why
      }

      // validate the rest (the phone is filled by now)
      if (!formKey.currentState!.validate()) return;

      final otherUid = found.uid;
      if (otherUid == user.uid) {
        throw Exception('You cannot add your own account.');
      }

      final name = nameController.text.trim();

      // phone and country code come from the found profile, so they cannot
      // be faked. Old accounts without a phone use the typed number.
      final phone =
      found.hasPhone ? found.phone : PhoneHelper.clean(phoneController.text);
      final code = found.hasPhone
          ? (found.countryCode.isNotEmpty
          ? found.countryCode
          : PhoneHelper.defaultCode)
          : countryCode;

      // Use the actual Firebase UID as the contact key.
      final contactRef = database.ref(
        'users/${user.uid}/contacts/$otherUid',
      );

      final existingContact =
      await contactRef.get().timeout(const Duration(seconds: 12));

      if (existingContact.exists) {
        throw Exception(
          'This user is already in your contacts.',
        );
      }

      // Save the contact in Firebase Realtime Database.
      await contactRef.set({
        'uid': otherUid,
        'name': name,
        'phone': phone,
        'countryCode': code,
        'email': email,
        'addedAt': ServerValue.timestamp,
        'lastMessage': 'Tap to start chatting',
        'time': '',
      }).timeout(const Duration(seconds: 12));

      // Save the contact in the existing local database.
      await DatabaseHelper.saveContact(
        owner: user.uid,
        id: otherUid,
        name: name,
        phone: phone,
        countryCode: code,
        lastMessage: 'Tap to start chatting',
        time: '',
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.code == 'permission-denied'
            ? 'Firebase denied access. Check your database rules.'
            : 'Firebase error (${e.code}): '
            '${e.message ?? 'Unknown error'}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // the icon is optional (the Code box has no icon, so the text fits)
  InputDecoration decoration({
    required String label,
    IconData? icon,
    Widget? suffix,
    bool locked = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null
          ? null
          : Icon(
        icon,
        color: locked ? AppColors.textSoft : AppColors.emerald,
      ),
      suffixIcon: locked
          ? const Icon(Icons.lock_outline, color: AppColors.textSoft, size: 20)
          : suffix,
      filled: true,
      fillColor: locked ? _lockedFill : AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE3DED2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE3DED2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.emerald,
          width: 1.5,
        ),
      ),
    );
  }

  // one line of text under the email box
  Widget _statusRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lookupStatus() {
    switch (_lookupState) {
      case _LookupState.idle:
      case _LookupState.loading:
        return const SizedBox.shrink();
      case _LookupState.found:
        final found = _found;
        if (found == null) return const SizedBox.shrink();
        if (!found.hasPhone) {
          return _statusRow(
            Icons.info_outline,
            AppColors.textSoft,
            'Registered user found. They have not added a phone number, '
                'so please type it below.',
          );
        }
        return _statusRow(
          Icons.check_circle,
          AppColors.emerald,
          found.name.isEmpty
              ? 'Registered user found'
              : 'Registered user found: ${found.name}',
        );
      case _LookupState.notFound:
        return _statusRow(
          Icons.error_outline,
          _error,
          'No registered user found with this email',
        );
      case _LookupState.self:
        return _statusRow(
          Icons.error_outline,
          _error,
          'You cannot add your own account.',
        );
      case _LookupState.error:
        return _statusRow(
          Icons.error_outline,
          _error,
          _lookupError ?? 'Could not look up this email.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _lookupState == _LookupState.loading ||
        _lookupState == _LookupState.notFound ||
        _lookupState == _LookupState.self;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        title: const Text(
          'New contact',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F1ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: AppColors.emerald,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Add contact',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Enter the contact details and their registered email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 22),

                // Contact name (free text: the user can type any name)
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validateName,
                  enabled: !isSaving,
                  decoration: decoration(
                    label: 'Contact name',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 18),

                // Registered email (the lookup starts when typing stops)
                TextFormField(
                  controller: emailController,
                  focusNode: emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  validator: validateEmail,
                  enabled: !isSaving,
                  onChanged: _onEmailChanged,
                  decoration: decoration(
                    label: 'Registered email address',
                    icon: Icons.email_outlined,
                    suffix: _lookupState == _LookupState.loading
                        ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.emerald,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
                _lookupStatus(),
                const SizedBox(height: 18),

                // Country code and phone number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 108,
                      child: CountryCodeDropdown(
                        value: countryCode,
                        decoration: decoration(label: 'Code'),
                        onChanged: (isSaving || _phoneLocked)
                            ? null
                            : (value) => setState(() => countryCode = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        readOnly: _phoneLocked,
                        enabled: !isSaving,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9\s()\-]'),
                          ),
                        ],
                        validator: (value) =>
                        _phoneLocked ? null : PhoneHelper.validate(value),
                        onFieldSubmitted: (_) {
                          if (!isSaving && !blocked) saveContact();
                        },
                        decoration: decoration(
                          label: 'Phone number',
                          icon: Icons.phone_outlined,
                          locked: _phoneLocked,
                        ),
                      ),
                    ),
                  ],
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCEAEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFD94B4B),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (isSaving || blocked) ? null : saveContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      disabledBackgroundColor: isSaving
                          ? AppColors.emerald
                          : const Color(0xFFB8C2C0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Save contact',
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