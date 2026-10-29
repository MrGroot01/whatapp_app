import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'otp_screen.dart';
import 'phone_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const Color _error = Color(0xFFD94B4B);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nicknameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String countryCode = PhoneHelper.defaultCode;
  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;
  String password = '';
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    nicknameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    final regex =
    RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    if (!regex.hasMatch(email)) {
      return 'Enter a valid email (example: name@gmail.com)';
    }
    return null;
  }

  String? validateNickname(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Please enter a nickname';
    if (name.length < 3) return 'Use at least 3 characters';
    if (name.length > 20) return 'Use at most 20 characters';
    return null;
  }

  String? validatePassword(String? value) {
    final pass = value ?? '';
    if (pass.isEmpty) return 'Please enter a password';
    if (pass.length < 8) return 'Use at least 8 characters';
    if (pass.contains(' ')) return 'Password cannot contain spaces';
    if (!RegExp(r'[A-Z]').hasMatch(pass)) return 'Add 1 capital letter (A-Z)';
    if (!RegExp(r'[a-z]').hasMatch(pass)) return 'Add 1 small letter (a-z)';
    if (!RegExp(r'[0-9]').hasMatch(pass)) return 'Add 1 number (0-9)';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(pass)) {
      return 'Add 1 special character (! @ # \$ % & *)';
    }
    return null;
  }

  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  bool get hasLength => password.length >= 8;
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);

  String firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'This password is too weak. Please choose another.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Unable to create account. Please try again.';
    }
  }

  // ---------- PHONE NUMBER CHECKS ----------

  // true = free, false = already used, null = could not check
  Future<bool?> _isPhoneFree(String phoneKey) async {
    try {
      final snap = await FirebaseDatabase.instance
          .ref('phoneIndex/$phoneKey')
          .get()
          .timeout(const Duration(seconds: 10));
      return !snap.exists;
    } catch (e) {
      debugPrint('Phone check failed: $e');
      return null;
    }
  }

  // write phoneIndex/{key} = uid (the rules allow this only once per number)
  // returns null when it worked, otherwise the message to show
  Future<String?> _claimPhone(String phoneKey, String uid) async {
    try {
      await FirebaseDatabase.instance
          .ref('phoneIndex/$phoneKey')
          .set(uid)
          .timeout(const Duration(seconds: 10));
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'This phone number was just registered by another account. '
            'Please use a different number.';
      }
      return 'Could not save the phone number (${e.code}). Please try again.';
    } catch (e) {
      return 'Could not save the phone number. '
          'Check your internet connection and try again.';
    }
  }

  // ---------- REGISTER: account -> phone check -> OTP -> Login ----------
  Future<void> onRegisterPressed() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim().toLowerCase();
    final nickname = nicknameController.text.trim();
    final phone = PhoneHelper.clean(phoneController.text);
    final code = countryCode;
    final phoneKey = PhoneHelper.indexKey(code, phone);

    // STEP 1: create the Firebase account.
    // This also checks that the email is new, before we ask for an OTP.
    User? created;
    try {
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );
      created = credential.user;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = firebaseErrorMessage(e);
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
        'Something went wrong while creating the account. Please try again.';
      });
      return;
    }

    final newUser = created;
    if (newUser == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Account could not be created. Please try again.';
      });
      return;
    }

    // STEP 1b: is the phone number free? (reading needs a signed-in user,
    // so we check right after the account is created)
    final phoneFree = await _isPhoneFree(phoneKey);
    if (phoneFree != true) {
      await _cancelSignup(newUser); // no half-created account is left behind
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = phoneFree == false
            ? 'This phone number is already registered with another '
            'account. Please use a different number.'
            : 'Could not check the phone number. '
            'Check your internet connection and try again.';
      });
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = false);

    // STEP 2: make a 4-digit OTP and open the OTP screen
    final otp = (Random().nextInt(9000) + 1000).toString();
    debugPrint('OTP for $email: $otp');

    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(email: email, correctOtp: otp),
      ),
    );

    // STEP 3: the user pressed Back -> remove the account we just made
    if (verified != true) {
      await _cancelSignup(newUser);
      if (!mounted) return;
      setState(() {
        errorMessage =
        'Verification was cancelled, so no account was created. Please try again.';
      });
      return;
    }

    // show the loading circle while the profile is being saved
    if (mounted) setState(() => isLoading = true);

    // STEP 4a: the OTP was correct -> claim the phone number (write once)
    final claimError = await _claimPhone(phoneKey, newUser.uid);
    if (claimError != null) {
      await _cancelSignup(newUser);
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = claimError;
      });
      return;
    }

    // STEP 4b: save the name and the public profile (with the phone)
    try {
      await newUser.updateDisplayName(nickname);
    } catch (e) {
      debugPrint('Display name not saved: $e');
    }

    final profile = {
      'uid': newUser.uid,
      'email': email,
      'name': nickname,
      'phone': phone,
      'countryCode': code,
      'createdAt': ServerValue.timestamp,
    };

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await FirebaseDatabase.instance
            .ref('publicProfiles/${newUser.uid}')
            .set(profile)
            .timeout(const Duration(seconds: 10));
        break;
      } catch (e) {
        debugPrint('Public profile not saved (try ${attempt + 1}): $e');
      }
    }

    // sign out, so the user comes back to the Login screen
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.pop(context, email);
  }

  // delete the half-made account (used when sign-up is cancelled or fails)
  Future<void> _cancelSignup(User user) async {
    try {
      await user.delete(); // this also signs the user out
    } catch (e) {
      debugPrint('Could not delete the unverified account: $e');
      await FirebaseAuth.instance.signOut();
    }
  }

  OutlineInputBorder boxBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  InputDecoration fieldDecoration({
    required String label,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSoft, fontSize: 16),
      floatingLabelStyle:
      const TextStyle(color: AppColors.emerald, fontSize: 16),
      prefixIcon: icon == null ? null : Icon(icon, color: AppColors.emerald),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      errorStyle: const TextStyle(color: _error, fontSize: 14),
      errorMaxLines: 2,
      enabledBorder: boxBorder(const Color(0xFFE3DED2)),
      focusedBorder: boxBorder(AppColors.emerald),
      errorBorder: boxBorder(_error),
      focusedErrorBorder: boxBorder(_error),
    );
  }

  Widget rule(String text, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: done ? AppColors.emerald : const Color(0xFFB8C2C0),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              color: done ? AppColors.textDark : AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE3F1ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 44,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign up with your email to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSoft, fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: AppColors.emerald,
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setState(() => errorMessage = null);
                      }
                    },
                    decoration: fieldDecoration(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nicknameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: AppColors.emerald,
                    decoration: fieldDecoration(
                      label: 'Nickname',
                      icon: Icons.person_outline,
                    ),
                    validator: validateNickname,
                  ),
                  const SizedBox(height: 16),

                  // Country code + phone number
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 108,
                        child: CountryCodeDropdown(
                          value: countryCode,
                          decoration: fieldDecoration(label: 'Code'),
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() {
                            countryCode = value;
                            errorMessage = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9\s()\-]'),
                            ),
                          ],
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 17,
                          ),
                          cursorColor: AppColors.emerald,
                          onChanged: (_) {
                            if (errorMessage != null) {
                              setState(() => errorMessage = null);
                            }
                          },
                          decoration: fieldDecoration(
                            label: 'Phone number',
                            icon: Icons.phone_outlined,
                          ),
                          validator: PhoneHelper.validate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: AppColors.emerald,
                    onChanged: (value) => setState(() {
                      password = value;
                      if (errorMessage != null) errorMessage = null;
                    }),
                    decoration: fieldDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSoft,
                        ),
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmController,
                    obscureText: hideConfirm,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: AppColors.emerald,
                    decoration: fieldDecoration(
                      label: 'Confirm password',
                      icon: Icons.lock_reset,
                      suffix: IconButton(
                        icon: Icon(
                          hideConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSoft,
                        ),
                        onPressed: () =>
                            setState(() => hideConfirm = !hideConfirm),
                      ),
                    ),
                    validator: validateConfirm,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE3DED2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        rule('At least 8 characters', hasLength),
                        rule('1 capital letter (A-Z)', hasUpper),
                        rule('1 small letter (a-z)', hasLower),
                        rule('1 number (0-9)', hasNumber),
                        rule('1 special character (! @ # \$ %)', hasSpecial),
                      ],
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEAEA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: _error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}