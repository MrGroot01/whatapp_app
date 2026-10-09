import 'dart:math';
import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'home_screen.dart';
import 'database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _bg = Color(0xFF0F1B3D);
  static const Color _accent = Color(0xFF00C2A8);
  static const Color _card = Color(0xFF1A2A55);
  static const Color _text = Color(0xFFE0E6F5);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;
  String password = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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

  String? validatePassword(String? value) {
    final pass = value ?? '';
    if (pass.isEmpty) return 'Please enter your password';
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

  bool get hasLength => password.length >= 8;
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);

  // ---------- ACTION ----------
  Future<void> onNextPressed() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final email = emailController.text.trim().toLowerCase();

    // ask the database: is this email already verified?
    final alreadyVerified = await DatabaseHelper.isVerified(email);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (alreadyVerified) {
      // OLD USER -> go directly to Home
      debugPrint('$email already verified -> Home');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(email: email)),
            (route) => false,
      );
    } else {
      // NEW USER -> OTP first
      final otp = (Random().nextInt(9000) + 1000).toString();
      debugPrint('OTP for $email: $otp');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(email: email, correctOtp: otp),
        ),
      );
    }
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
      labelStyle: const TextStyle(color: _text, fontSize: 16),
      floatingLabelStyle: const TextStyle(color: _accent, fontSize: 16),
      prefixIcon: Icon(icon, color: _accent),
      suffixIcon: suffix,
      filled: true,
      fillColor: _card,
      errorStyle: const TextStyle(color: Color(0xFFFF8A80), fontSize: 14),
      errorMaxLines: 2,
      enabledBorder: boxBorder(const Color(0xFF3A4C80)),
      focusedBorder: boxBorder(_accent),
      errorBorder: boxBorder(const Color(0xFFFF8A80)),
      focusedErrorBorder: boxBorder(const Color(0xFFFF8A80)),
    );
  }

  Widget rule(String text, bool done) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: done ? _accent : const Color(0xFF8E9BC0),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: done ? Colors.white : _text,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
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
                        color: _accent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded,
                          size: 44, color: _accent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log in with your email and password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _text, fontSize: 16),
                  ),
                  const SizedBox(height: 28),

                  // EMAIL
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                    cursorColor: _accent,
                    decoration: fieldDecoration(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD
                  TextFormField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                    cursorColor: _accent,
                    onChanged: (v) => setState(() => password = v),
                    decoration: fieldDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _text,
                        ),
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 14),

                  // LIVE PASSWORD CHECKLIST
                  rule('At least 8 characters', hasLength),
                  rule('1 capital letter (A-Z)', hasUpper),
                  rule('1 small letter (a-z)', hasLower),
                  rule('1 number (0-9)', hasNumber),
                  rule('1 special character (! @ # \$ %)', hasSpecial),
                  const SizedBox(height: 28),

                  // BUTTON
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black,
                        ),
                      )
                          : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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