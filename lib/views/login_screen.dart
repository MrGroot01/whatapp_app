import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_icons.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';
import 'forgot_password_sheet.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // true  = the user must click the link in the verification email
  // false = anyone with a correct password can log in
  static const bool requireVerifiedEmail = false;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;
  bool needsVerification = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.enterEmail;
    final regex =
    RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    if (!regex.hasMatch(email)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.enterPassword;
    return null;
  }

  String firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AppStrings.invalidEmailAddress;
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
      // Firebase uses one answer for "no account" and "wrong password"
        return AppStrings.loginCredentials;
      case 'user-disabled':
        return AppStrings.accountDisabled;
      case 'too-many-requests':
        return AppStrings.tooManyAttempts;
      case 'network-request-failed':
        return AppStrings.networkError;
      default:
        return e.message ?? AppStrings.loginFailed;
    }
  }

  Future<void> onNextPressed() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      needsVerification = false;
    });

    final email = emailController.text.trim().toLowerCase();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );

      // get the latest "email verified" status from Firebase
      await credential.user?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (requireVerifiedEmail && !(user?.emailVerified ?? false)) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        setState(() {
          isLoading = false;
          needsVerification = true;
          errorMessage = AppStrings.verifyEmailFirst;
        });
        return;
      }

      if (!mounted) return;
      final signedInEmail = user?.email ?? email;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(email: signedInEmail),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // the exact reason shows in the Run console
      debugPrint('Login failed: ${e.code}');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = firebaseErrorMessage(e);
      });
    } catch (e) {
      debugPrint('Login failed: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = AppStrings.somethingWentWrong;
      });
    }
  }

  // sign in again only to send the email, then sign out
  Future<void> resendVerification() async {
    setState(() => isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );
      await cred.user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = null;
        needsVerification = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.verificationSent),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = firebaseErrorMessage(e);
      });
    }
  }

  // opens the "Forgot password?" bottom sheet.
  // The email typed on this screen is copied into the sheet.
  Future<void> openForgotPassword() async {
    await showForgotPasswordSheet(
      context,
      initialEmail: emailController.text.trim(),
    );
  }

  Future<void> openSignup() async {
    final newEmail = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );

    if (newEmail != null && mounted) {
      setState(() {
        emailController.text = newEmail;
        passwordController.clear();
        errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.accountVerified),
        ),
      );
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
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSoft, fontSize: 16),
      floatingLabelStyle:
      const TextStyle(color: AppColors.emerald, fontSize: 16),
      prefixIcon: Icon(icon, color: AppColors.emerald),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 14),
      errorMaxLines: 2,
      enabledBorder: boxBorder(AppColors.border),
      focusedBorder: boxBorder(AppColors.emerald),
      errorBorder: boxBorder(AppColors.error),
      focusedErrorBorder: boxBorder(AppColors.error),
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
                        color: AppColors.softGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        AppIcons.loginHeader,
                        size: 44,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppStrings.welcomeBack,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.loginSubtitle,
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
                      label: AppStrings.email,
                      icon: AppIcons.email,
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!isLoading) onNextPressed();
                    },
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
                      label: AppStrings.password,
                      icon: AppIcons.password,
                      suffix: IconButton(
                        icon: Icon(
                          hidePassword
                              ? AppIcons.hidePassword
                              : AppIcons.showPassword,
                          color: AppColors.textSoft,
                        ),
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                      ),
                    ),
                    validator: validatePassword,
                  ),

                  // "Forgot password?" link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : openForgotPassword,
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
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
                    if (needsVerification)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: isLoading ? null : resendVerification,
                          child: const Text(
                            AppStrings.resendVerification,
                            style: TextStyle(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onNextPressed,
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
                        AppStrings.login,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading ? null : openSignup,
                    child: const Text.rich(
                      TextSpan(
                        text: AppStrings.noAccount,
                        style: TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.signUp,
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