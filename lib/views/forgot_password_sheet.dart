import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_icons.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';

// Opens the "Forgot password?" bottom sheet.
// initialEmail = the email the user already typed on the login screen.
Future<void> showForgotPasswordSheet(
    BuildContext context, {
      String initialEmail = '',
    }) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => ForgotPasswordSheet(initialEmail: initialEmail),
  );
}

class ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordSheet({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  static const int _cooldownSeconds = 60;

  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;

  bool isLoading = false;
  bool linkSent = false; // false = ask for the email, true = "check inbox"
  String? errorMessage;
  int cooldown = 0; // seconds left before "Resend" works again
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.enterEmail;
    final regex = RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    if (!regex.hasMatch(email)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  String firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AppStrings.invalidEmailAddress;
      case 'user-not-found':
        return AppStrings.noAccountFound;
      case 'network-request-failed':
        return AppStrings.networkError;
      case 'too-many-requests':
        return AppStrings.tooManyAttempts;
      default:
        return e.message ?? AppStrings.couldNotSendEmail;
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => cooldown = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (cooldown <= 1) {
        t.cancel();
        setState(() => cooldown = 0);
      } else {
        setState(() => cooldown--);
      }
    });
  }

  // sends the reset link (used by "Send reset link" and "Resend")
  Future<void> sendLink() async {
    if (isLoading) return;
    // the form is not on screen during "Check your inbox" (Resend), and the
    // email was already validated then
    if (formKey.currentState?.validate() == false) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim().toLowerCase();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        isLoading = false;
        linkSent = true;
      });
      _startCooldown();
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset failed: ${e.code}');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = firebaseErrorMessage(e);
      });
    } catch (e) {
      debugPrint('Password reset failed: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = AppStrings.somethingWentWrong;
      });
    }
  }

  OutlineInputBorder boxBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD5D5D5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.softGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 40, color: AppColors.emerald),
      ),
    );
  }

  // ---------- STEP 1: ask for the email ----------
  Widget _buildAskEmail() {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _handle(),
          const SizedBox(height: 20),
          _iconCircle(AppIcons.forgotHeader),
          const SizedBox(height: 16),
          const Text(
            AppStrings.forgotPassword,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.forgotSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSoft, fontSize: 15.5),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autofocus: widget.initialEmail.isEmpty,
            style: const TextStyle(color: AppColors.textDark, fontSize: 17),
            cursorColor: AppColors.emerald,
            onChanged: (_) {
              if (errorMessage != null) setState(() => errorMessage = null);
            },
            onFieldSubmitted: (_) => sendLink(),
            validator: validateEmail,
            decoration: InputDecoration(
              labelText: AppStrings.email,
              labelStyle:
              const TextStyle(color: AppColors.textSoft, fontSize: 16),
              floatingLabelStyle:
              const TextStyle(color: AppColors.emerald, fontSize: 16),
              prefixIcon: const Icon(AppIcons.email, color: AppColors.emerald),
              filled: true,
              fillColor: AppColors.card,
              errorStyle:
              const TextStyle(color: AppColors.error, fontSize: 14),
              errorMaxLines: 2,
              enabledBorder: boxBorder(AppColors.border),
              focusedBorder: boxBorder(AppColors.emerald),
              errorBorder: boxBorder(AppColors.error),
              focusedErrorBorder: boxBorder(AppColors.error),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(AppIcons.error, color: AppColors.error, size: 20),
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
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : sendLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.emerald,
                disabledForegroundColor: Colors.white,
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
                AppStrings.sendResetLink,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text(
              AppStrings.backToLogin,
              style: TextStyle(
                color: AppColors.emerald,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- STEP 2: "check your inbox" ----------
  Widget _buildSent() {
    final email = emailController.text.trim().toLowerCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _handle(),
        const SizedBox(height: 20),
        _iconCircle(AppIcons.inboxHeader),
        const SizedBox(height: 16),
        const Text(
          AppStrings.checkInbox,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.resetLinkSent(email),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 15.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              AppStrings.backToLogin,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 14.5),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: (cooldown > 0 || isLoading) ? null : sendLink,
              child: Text(
                cooldown > 0
                    ? AppStrings.resendIn(cooldown)
                    : AppStrings.resendLink,
                style: TextStyle(
                  color: cooldown > 0 ? AppColors.textSoft : AppColors.emerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => setState(() {
                linkSent = false;
                errorMessage = null;
              }),
              child: const Text(
                AppStrings.changeEmail,
                style: TextStyle(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // moves the sheet above the keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey<bool>(linkSent),
              child: linkSent ? _buildSent() : _buildAskEmail(),
            ),
          ),
        ),
      ),
    );
  }
}