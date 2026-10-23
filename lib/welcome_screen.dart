import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // darker than AppColors.textSoft, so the small text is easy to read
  static const Color _bodyText = Color(0xFF4F5E5C);

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // Sign up first. When the account is created, go to Login.
  Future<void> _openSignup(BuildContext context) async {
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );

    if (email == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account created. Check your email for the verification link, then log in.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // light (white) clock and icons on top of the green header
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ---------- TOP: green curved header with logo and brand ----------
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.emerald, AppColors.emeraldLight],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LOGO: a bigger white circle with the chat icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 24,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          size: 60,
                          color: AppColors.emerald,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // BRAND NAME
                      Text(
                        AppBrand.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'PREMIUM MESSAGING',
                        style: TextStyle(
                          color: Color(0xFFF2D98B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- BOTTOM: tagline, three perks, buttons ----------
            Expanded(
              flex: 4,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        AppBrand.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Private chats, fast delivery and groups for the people who matter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _bodyText,
                          fontSize: 16,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Perk(icon: Icons.lock_rounded, label: 'Private'),
                          _Perk(icon: Icons.bolt_rounded, label: 'Fast'),
                          _Perk(icon: Icons.groups_rounded, label: 'Groups'),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // MAIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _openLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // NEW USERS
                      TextButton(
                        onPressed: () => _openSignup(context),
                        child: const Text.rich(
                          TextSpan(
                            text: 'New here? ',
                            style: TextStyle(color: _bodyText, fontSize: 15),
                            children: [
                              TextSpan(
                                text: 'Create an account',
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
          ],
        ),
      ),
    );
  }
}

// One small perk: round icon with a label below
class _Perk extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Perk({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFE3F1ED),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.emerald, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}