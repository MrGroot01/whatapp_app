import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../services/phone_helper.dart';
import 'otp_screen.dart';
import 'widgets/country_code_dropdown.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
    final l = context.l10n;
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l.enterEmail;
    final regex =
    RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    if (!regex.hasMatch(email)) {
      return l.invalidEmail;
    }
    return null;
  }

  String? validateNickname(String? value) {
    final l = context.l10n;
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l.enterNickname;
    if (name.length < 3) return l.useAtLeast3;
    if (name.length > 20) return l.useAtMost20;
    return null;
  }

  String? validatePassword(String? value) {
    final l = context.l10n;
    final pass = value ?? '';
    if (pass.isEmpty) return l.enterNewPassword;
    if (pass.length < 8) return l.useAtLeast8;
    if (pass.contains(' ')) return l.noSpaces;
    if (!RegExp(r'[A-Z]').hasMatch(pass)) return l.addCapital;
    if (!RegExp(r'[a-z]').hasMatch(pass)) return l.addSmall;
    if (!RegExp(r'[0-9]').hasMatch(pass)) return l.addNumber;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(pass)) {
      return l.addSpecial;
    }
    return null;
  }

  String? validateConfirm(String? value) {
    final l = context.l10n;
    if (value == null || value.isEmpty) {
      return l.confirmYourPassword;
    }
    if (value != passwordController.text) return l.passwordsDontMatch;
    return null;
  }

  bool get hasLength => password.length >= 8;
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);

  // l is passed in, so the message can be built after an "await"
  String firebaseErrorMessage(FirebaseAuthException e, AppLocalizations l) {
    switch (e.code) {
      case 'email-already-in-use':
        return l.emailAlreadyRegistered;
      case 'invalid-email':
        return l.invalidEmailAddress;
      case 'weak-password':
        return l.weakPassword;
      case 'operation-not-allowed':
        return l.signupNotEnabled;
      case 'network-request-failed':
        return l.networkError;
      case 'too-many-requests':
        return l.tooManyAttempts;
      default:
        return e.message ?? l.signupFailed;
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
  Future<String?> _claimPhone(
      String phoneKey,
      String uid,
      AppLocalizations l,
      ) async {
    try {
      await FirebaseDatabase.instance
          .ref('phoneIndex/$phoneKey')
          .set(uid)
          .timeout(const Duration(seconds: 10));
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return l.phoneJustTaken;
      }
      return l.phoneSaveFailedCode(e.code);
    } catch (e) {
      return l.phoneSaveFailed;
    }
  }

  // ---------- REGISTER: account -> phone check -> OTP -> Login ----------
  Future<void> onRegisterPressed() async {
    if (!formKey.currentState!.validate()) return;

    // read the texts now (before any "await")
    final l = context.l10n;

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
        errorMessage = firebaseErrorMessage(e, l);
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = l.createAccountWentWrong;
      });
      return;
    }

    final newUser = created;
    if (newUser == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = l.accountNotCreated;
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
            ? l.phoneAlreadyRegistered
            : l.phoneCheckFailed;
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
        errorMessage = l.verificationCancelled;
      });
      return;
    }

    // show the loading circle while the profile is being saved
    if (mounted) setState(() => isLoading = true);

    // STEP 4a: the OTP was correct -> claim the phone number (write once)
    final claimError = await _claimPhone(phoneKey, newUser.uid, l);
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
    final p = context.palette;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: p.textSoft, fontSize: 16),
      floatingLabelStyle: TextStyle(color: p.accent, fontSize: 16),
      prefixIcon: icon == null ? null : Icon(icon, color: p.accent),
      suffixIcon: suffix,
      filled: true,
      fillColor: p.card,
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 14),
      errorMaxLines: 2,
      enabledBorder: boxBorder(p.border),
      focusedBorder: boxBorder(p.accent),
      errorBorder: boxBorder(AppColors.error),
      focusedErrorBorder: boxBorder(AppColors.error),
    );
  }

  Widget rule(String text, bool done) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? AppIcons.ruleDone : AppIcons.ruleTodo,
            size: 20,
            color: done ? p.accent : p.hint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                color: done ? p.textDark : p.textSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.textDark,
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
                      decoration: BoxDecoration(
                        color: p.softGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.signupHeader,
                        size: 44,
                        color: p.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.createAccount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.signupSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.textSoft,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: TextStyle(
                      color: p.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: p.accent,
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setState(() => errorMessage = null);
                      }
                    },
                    decoration: fieldDecoration(
                      label: l.email,
                      icon: AppIcons.email,
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nicknameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: TextStyle(
                      color: p.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: p.accent,
                    decoration: fieldDecoration(
                      label: l.nickname,
                      icon: AppIcons.person,
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
                          decoration: fieldDecoration(label: l.code),
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
                          style: TextStyle(
                            color: p.textDark,
                            fontSize: 17,
                          ),
                          cursorColor: p.accent,
                          onChanged: (_) {
                            if (errorMessage != null) {
                              setState(() => errorMessage = null);
                            }
                          },
                          decoration: fieldDecoration(
                            label: l.phoneNumber,
                            icon: AppIcons.phone,
                          ),
                          validator: (value) => PhoneHelper.validateLocalized(
                            context.l10n,
                            value,
                          ),
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
                    style: TextStyle(
                      color: p.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: p.accent,
                    onChanged: (value) => setState(() {
                      password = value;
                      if (errorMessage != null) errorMessage = null;
                    }),
                    decoration: fieldDecoration(
                      label: l.password,
                      icon: AppIcons.password,
                      suffix: IconButton(
                        icon: Icon(
                          hidePassword
                              ? AppIcons.hidePassword
                              : AppIcons.showPassword,
                          color: p.textSoft,
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
                    style: TextStyle(
                      color: p.textDark,
                      fontSize: 17,
                    ),
                    cursorColor: p.accent,
                    decoration: fieldDecoration(
                      label: l.confirmPassword,
                      icon: AppIcons.confirmPassword,
                      suffix: IconButton(
                        icon: Icon(
                          hideConfirm
                              ? AppIcons.hidePassword
                              : AppIcons.showPassword,
                          color: p.textSoft,
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
                      color: p.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: p.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        rule(l.ruleLength, hasLength),
                        rule(l.ruleCapital, hasUpper),
                        rule(l.ruleSmall, hasLower),
                        rule(l.ruleNumber, hasNumber),
                        rule(l.ruleSpecial, hasSpecial),
                      ],
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: p.errorBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            AppIcons.error,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
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
                          : Text(
                        l.register,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: Text.rich(
                      TextSpan(
                        text: '${l.haveAccount} ',
                        style: TextStyle(
                          color: p.textSoft,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: l.logInLink,
                            style: TextStyle(
                              color: p.accent,
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