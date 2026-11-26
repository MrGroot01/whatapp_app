import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
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
    backgroundColor: context.palette.background,
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
    final l = context.l10n;
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l.enterEmail;
    final regex = RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    if (!regex.hasMatch(email)) {
      return l.invalidEmail;
    }
    return null;
  }

  String firebaseErrorMessage(FirebaseAuthException e) {
    final l = context.l10n;
    switch (e.code) {
      case 'invalid-email':
        return l.invalidEmailAddress;
      case 'user-not-found':
        return l.noAccountFound;
      case 'network-request-failed':
        return l.networkError;
      case 'too-many-requests':
        return l.tooManyAttempts;
      default:
        return e.message ?? l.couldNotSendEmail;
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
        errorMessage = context.l10n.somethingWentWrong;
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
    final p = context.palette;
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: p.sheetHandle,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    final p = context.palette;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.softGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 40, color: p.accent),
      ),
    );
  }

  // ---------- STEP 1: ask for the email ----------
  Widget _buildAskEmail() {
    final l = context.l10n;
    final p = context.palette;

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
          Text(
            l.forgotPassword,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.forgotSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textSoft, fontSize: 15.5),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autofocus: widget.initialEmail.isEmpty,
            style: TextStyle(color: p.textDark, fontSize: 17),
            cursorColor: p.accent,
            onChanged: (_) {
              if (errorMessage != null) setState(() => errorMessage = null);
            },
            onFieldSubmitted: (_) => sendLink(),
            validator: validateEmail,
            decoration: InputDecoration(
              labelText: l.email,
              labelStyle: TextStyle(color: p.textSoft, fontSize: 16),
              floatingLabelStyle: TextStyle(color: p.accent, fontSize: 16),
              prefixIcon: Icon(AppIcons.email, color: p.accent),
              filled: true,
              fillColor: p.card,
              errorStyle:
              const TextStyle(color: AppColors.error, fontSize: 14),
              errorMaxLines: 2,
              enabledBorder: boxBorder(p.border),
              focusedBorder: boxBorder(p.accent),
              errorBorder: boxBorder(AppColors.error),
              focusedErrorBorder: boxBorder(AppColors.error),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.errorBackground,
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
                  : Text(
                l.sendResetLink,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: Text(
              l.backToLogin,
              style: TextStyle(
                color: p.accent,
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
    final l = context.l10n;
    final p = context.palette;
    final email = emailController.text.trim().toLowerCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _handle(),
        const SizedBox(height: 20),
        _iconCircle(AppIcons.inboxHeader),
        const SizedBox(height: 16),
        Text(
          l.checkInbox,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.resetLinkSent(email),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textSoft,
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
            child: Text(
              l.backToLogin,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
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
                cooldown > 0 ? l.resendIn(cooldown) : l.resendLink,
                style: TextStyle(
                  color: cooldown > 0 ? p.textSoft : p.accent,
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
              child: Text(
                l.changeEmail,
                style: TextStyle(
                  color: p.accent,
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