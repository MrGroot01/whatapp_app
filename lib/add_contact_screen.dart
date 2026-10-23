import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'database_helper.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String countryCode = '+91';
  bool isSaving = false;
  String? errorMessage;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  void dispose() {
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

  String? validatePhone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'[\s()-]'), '');

    if (phone.isEmpty) return 'Enter the phone number';

    if (!RegExp(r'^[0-9]{6,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number (6–15 digits)';
    }

    return null;
  }

  Future<void> saveContact() async {
    if (isSaving) return;
    if (!formKey.currentState!.validate()) return;

    final user = auth.currentUser;

    if (user == null) {
      setState(() {
        errorMessage = 'Please log in again before saving contacts.';
      });
      return;
    }

    final name = nameController.text.trim();
    final phone = phoneController.text.replaceAll(RegExp(r'[\s()-]'), '');
    final email = emailController.text.trim().toLowerCase();

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      // Find the registered Firebase user by email.
      final profilesRef = database.ref('publicProfiles');

      final profileSnapshot = await profilesRef
          .orderByChild('email')
          .equalTo(email)
          .get()
          .timeout(const Duration(seconds: 12));

      if (!profileSnapshot.exists || profileSnapshot.value is! Map) {
        throw Exception(
          'No registered user found with this email address.',
        );
      }

      final profiles = Map<dynamic, dynamic>.from(
        profileSnapshot.value as Map,
      );

      // Compare normalized email addresses.
      final matchedEntry = profiles.entries.firstWhere(
            (entry) {
          if (entry.value is! Map) return false;

          final profile = Map<dynamic, dynamic>.from(
            entry.value as Map,
          );

          return (profile['email'] ?? '').toString().trim().toLowerCase() ==
              email;
        },
        orElse: () => MapEntry('', null),
      );

      final otherUid = matchedEntry.key.toString();

      if (otherUid.isEmpty) {
        throw Exception(
          'Could not identify this registered user.',
        );
      }

      if (otherUid == user.uid) {
        throw Exception(
          'You cannot add your own account.',
        );
      }

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
        'countryCode': countryCode,
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
        countryCode: countryCode,
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

  // the icon is optional now (the Code box has no icon, so the text fits)
  InputDecoration decoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null
          ? null
          : Icon(
        icon,
        color: AppColors.emerald,
      ),
      filled: true,
      fillColor: AppColors.card,
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

  @override
  Widget build(BuildContext context) {
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

                // Contact name
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

                // Registered email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  validator: validateEmail,
                  enabled: !isSaving,
                  decoration: decoration(
                    label: 'Registered email address',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 18),

                // Country code and phone number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 118,
                      child: DropdownButtonFormField<String>(
                        initialValue: countryCode,
                        isExpanded: true,
                        decoration: decoration(label: 'Code'),
                        // the closed box shows only the code, so it always fits
                        selectedItemBuilder: (context) =>
                            ['+91', '+1', '+44', '+61', '+971']
                                .map(
                                  (c) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(c),
                              ),
                            )
                                .toList(),
                        items: const [
                          DropdownMenuItem(
                            value: '+91',
                            child: Text('+91 IN'),
                          ),
                          DropdownMenuItem(
                            value: '+1',
                            child: Text('+1 US/CA'),
                          ),
                          DropdownMenuItem(
                            value: '+44',
                            child: Text('+44 UK'),
                          ),
                          DropdownMenuItem(
                            value: '+61',
                            child: Text('+61 AU'),
                          ),
                          DropdownMenuItem(
                            value: '+971',
                            child: Text('+971 UAE'),
                          ),
                        ],
                        onChanged: isSaving
                            ? null
                            : (value) {
                          if (value != null) {
                            setState(() {
                              countryCode = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        validator: validatePhone,
                        enabled: !isSaving,
                        onFieldSubmitted: (_) {
                          if (!isSaving) saveContact();
                        },
                        decoration: decoration(
                          label: 'Phone number',
                          icon: Icons.phone_outlined,
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
                    onPressed: isSaving ? null : saveContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      disabledBackgroundColor: AppColors.emerald,
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