
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

  String countryCode = '+91';
  bool isSaving = false;
  String? errorMessage;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter the contact name';
    if (name.length < 2) return 'Name must be at least 2 characters';
    if (name.length > 40) return 'Name must be 40 characters or less';
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

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      final contactsRef = database.ref('users/${user.uid}/contacts');
      final normalizedPhone = '$countryCode$phone'.replaceAll('+', '');

      debugPrint('[AddContact] Checking existing contacts at ${contactsRef.path}');

      // Bound the read so the UI cannot spin forever if the network/rules fail.
      final existingSnapshot = await contactsRef.get().timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception(
          'Timed out while reading contacts. Check your internet connection and Firebase rules.',
        ),
      );

      if (existingSnapshot.value is Map) {
        final existing =
        Map<dynamic, dynamic>.from(existingSnapshot.value as Map);
        final duplicate = existing.values.any((value) {
          if (value is! Map) return false;
          final map = Map<dynamic, dynamic>.from(value);
          final savedCode = (map['countryCode'] ?? '+91').toString();
          final savedPhone = (map['phone'] ?? '')
              .toString()
              .replaceAll(RegExp(r'[\s()-]'), '');
          return '$savedCode$savedPhone'.replaceAll('+', '') ==
              normalizedPhone;
        });

        if (duplicate) {
          if (!mounted) return;
          setState(() {
            isSaving = false;
            errorMessage = 'This phone number is already in your contacts.';
          });
          return;
        }
      }

      final contactRef = contactsRef.push();
      debugPrint('[AddContact] Writing contact to ${contactRef.path}');

      await contactRef.set({
        'uid': contactRef.key,
        'name': name,
        'phone': phone,
        'countryCode': countryCode,
        'email': '',
        'addedAt': ServerValue.timestamp,
        'lastMessage': 'Tap to start chatting',
        'time': '',
      }).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception(
          'Timed out while saving. Check internet connectivity and Firebase rules.',
        ),
      );

      // Save a local copy so this contact remains available offline.
      await DatabaseHelper.saveContact(
        owner: user.uid,
        id: contactRef.key!,
        name: name,
        phone: phone,
        countryCode: countryCode,
        lastMessage: 'Tap to start chatting',
        time: '',
      );

      debugPrint('[AddContact] Contact saved successfully');

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('[AddContact] Firebase error: ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        isSaving = false;
        errorMessage = e.code == 'permission-denied'
            ? 'Firebase denied this write. Check Realtime Database rules.'
            : 'Firebase error (${e.code}): ${e.message ?? 'Unknown error'}';
      });
    } catch (e, stackTrace) {
      debugPrint('[AddContact] Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        isSaving = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  InputDecoration decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.emerald),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3DED2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3DED2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
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
          style: TextStyle(fontWeight: FontWeight.w700),
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
                  'Save a name and phone number to your contacts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSoft, fontSize: 15),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validateName,
                  decoration: decoration(
                    label: 'Contact name',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 116,
                      child: DropdownButtonFormField<String>(
                        initialValue: countryCode,
                        decoration: decoration(
                          label: 'Code',
                          icon: Icons.flag_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(value: '+91', child: Text('+91 IN')),
                          DropdownMenuItem(value: '+1', child: Text('+1 US/CA')),
                          DropdownMenuItem(value: '+44', child: Text('+44 UK')),
                          DropdownMenuItem(value: '+61', child: Text('+61 AU')),
                          DropdownMenuItem(value: '+971', child: Text('+971 UAE')),
                        ],
                        onChanged: isSaving
                            ? null
                            : (value) {
                          if (value != null) {
                            setState(() => countryCode = value);
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
                      style: const TextStyle(color: Color(0xFFD94B4B)),
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

