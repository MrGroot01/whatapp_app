import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'home_screen.dart';
import 'session_helper.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    decideNextPage();
  }

  Future<void> decideNextPage() async {
    // do two things at the same time:
    // 1. read the session note  2. keep the logo on screen for 2 seconds
    final results = await Future.wait([
      SessionHelper.getSession(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    final email = results[0] as String?;

    // default: send the user to the Welcome page
    Widget nextPage = const WelcomeScreen();

    // if someone is logged in (and still exists), go to the home page
    if (email != null && await DatabaseHelper.emailExists(email)) {
      nextPage = HomeScreen(email: email);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.emerald, AppColors.emeraldLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // LOGO: white circle, chat icon, small gold star
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 104,
                    height: 104,
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
                      size: 52,
                      color: AppColors.emerald,
                    ),
                  ),
                  const Positioned(
                    right: -6,
                    top: -6,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.gold,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
              const SizedBox(height: 32),

              // small loading circle
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFFF2D98B),
                ),
              ),

              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  AppBrand.tagline,
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}