import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'home_screen.dart';
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
    // keep the logo on screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // default: send the user to the Welcome page
    Widget nextPage = const WelcomeScreen();

    // Firebase remembers the logged-in user by itself
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // ask the server: does this account still exist and is it enabled?
        await user.reload().timeout(const Duration(seconds: 6));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'user-disabled' ||
            e.code == 'user-token-expired') {
          // the account was deleted or disabled: log out on this phone too
          await FirebaseAuth.instance.signOut();
        }
      } catch (_) {
        // offline or slow network: keep the saved login
      }

      user = FirebaseAuth.instance.currentUser;
    }

    final email = user?.email;
    if (user != null && email != null && email.isNotEmpty) {
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

              // LOGO IMAGE from assets/icon/app_icon.png
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 120,
                    height: 120,
                    // if the image is missing, show an icon instead of crashing
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.chat_bubble_rounded,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
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