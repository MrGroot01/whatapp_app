import 'dart:math';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'otp_screen.dart';

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
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;
  String password = '';
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    nicknameController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // ---------- VALIDATION ----------
  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    final regex = RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
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
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  bool get hasLength => password.length >= 8;
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);

  // ---------- ACTION ----------
  Future<void> onRegisterPressed() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim().toLowerCase();

    final exists = await DatabaseHelper.emailExists(email);
    if (!mounted) return;

    if (exists) {
      setState(() {
        isLoading = false;
        errorMessage = 'This email is already registered. Please log in.';
      });
      return;
    }

    setState(() => isLoading = false);

    // make an OTP and ask the user to verify the email
    final otp = (Random().nextInt(9000) + 1000).toString();
    debugPrint('OTP for $email: $otp');

    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(email: email, correctOtp: otp),
      ),
    );

    // user pressed Back on the OTP screen -> no account is created
    if (verified != true || !mounted) return;

    // OTP is correct -> now save the account
    await DatabaseHelper.registerUser(
      email: email,
      nickname: nicknameController.text.trim(),
      password: passwordController.text,
    );
    await DatabaseHelper.markVerified(email);
    if (!mounted) return;

    // go back to Login and give it the new email
    Navigator.pop(context, email);
  }

  // ---------- UI HELPERS ----------
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
                  // ICON
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

                  // EMAIL
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

                  // NICKNAME
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

                  // PASSWORD
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
                    onChanged: (v) => setState(() => password = v),
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

                  // CONFIRM PASSWORD
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

                  // LIVE PASSWORD CHECKLIST (inside a white card)
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

                  // ERROR MESSAGE (soft red box)
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
                          const Icon(Icons.error_outline,
                              color: _error, size: 20),
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

                  // REGISTER BUTTON
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

                  // BACK TO LOGIN
                  TextButton(
                    onPressed: () => Navigator.pop(context),
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