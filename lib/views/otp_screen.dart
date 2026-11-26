import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String correctOtp;

  const OtpScreen({super.key, required this.email, required this.correctOtp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // true  = verify automatically right after the code is filled
  // false = the user taps the Verify button
  static const bool autoVerify = true;

  // ---------- TIMING (change these numbers if you want) ----------
  static const Duration bannerDelay = Duration(seconds: 1); // message pops up
  static const Duration fillDelay = Duration(seconds: 3); // code fills itself
  static const Duration verifyDelay = Duration(seconds: 3); // after fill -> Login
  static const Duration bannerHide = Duration(seconds: 6); // message goes away

  final otpController = TextEditingController();
  final List<Timer> timers = [];
  Timer? resendTimer;

  late String currentOtp;
  String? errorText;
  bool showMessage = false;
  bool finished = false;
  int secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    currentOtp = widget.correctOtp;
    startResendTimer();
    simulateIncomingOtp();
  }

  @override
  void dispose() {
    for (final t in timers) {
      t.cancel();
    }
    resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  // ---------- AUTOFILL ----------
  void later(Duration delay, VoidCallback action) {
    timers.add(Timer(delay, () {
      if (mounted) action();
    }));
  }

  // 1) the "message" banner slides in
  // 2) the code is filled automatically
  // 3) a few seconds later it verifies by itself (autoVerify)
  // 4) the banner hides
  void simulateIncomingOtp() {
    for (final t in timers) {
      t.cancel();
    }
    timers.clear();

    later(bannerDelay, () => setState(() => showMessage = true));
    later(fillDelay, fillOtp);
    later(bannerHide, () => setState(() => showMessage = false));
  }

  void fillOtp() {
    otpController.value = TextEditingValue(
      text: currentOtp,
      selection: TextSelection.collapsed(offset: currentOtp.length),
    );
    setState(() => errorText = null);
    HapticFeedback.lightImpact();

    // wait so the user can SEE the code filled, then verify
    if (autoVerify) {
      later(verifyDelay, onVerifyPressed);
    }
  }

  // ---------- RESEND ----------
  void startResendTimer() {
    resendTimer?.cancel();
    resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (secondsLeft <= 1) {
        t.cancel();
        setState(() => secondsLeft = 0);
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  void onResendPressed() {
    setState(() {
      currentOtp = (Random().nextInt(9000) + 1000).toString();
      otpController.clear();
      errorText = null;
      showMessage = false;
      secondsLeft = 30;
    });
    debugPrint('New OTP for ${widget.email}: $currentOtp');
    startResendTimer();
    simulateIncomingOtp();
  }

  // ---------- VERIFY ----------
  void onVerifyPressed() {
    if (finished) return;

    final l = context.l10n;
    final entered = otpController.text.trim();

    if (entered.length != 4) {
      setState(() => errorText = l.enterAllDigits);
      return;
    }

    if (entered == currentOtp) {
      finished = true;
      // tell the Sign up screen: the OTP is correct
      // (the Sign up screen then goes back to the Login page)
      Navigator.pop(context, true);
    } else {
      setState(() => errorText = l.wrongOtp);
    }
  }

  // ---------- UI PIECES ----------
  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  // the "incoming SMS" banner that slides down from the top
  Widget buildMessageBanner() {
    final l = context.l10n;
    final p = context.palette;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      top: showMessage ? 10 : -140,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          fillOtp();
          setState(() => showMessage = false);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.otpBannerBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.emerald,
                child: Icon(AppIcons.sms, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l.messages,
                          style: TextStyle(
                            color: p.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l.now,
                          style: TextStyle(
                            color: p.textSoft,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.otpMessage(AppStrings.appName, currentOtp),
                      style: TextStyle(
                        color: p.textDark,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResend() {
    final l = context.l10n;
    final p = context.palette;

    if (secondsLeft > 0) {
      final time = '0:${secondsLeft.toString().padLeft(2, '0')}';
      return Text(
        l.resendCodeIn(time),
        textAlign: TextAlign.center,
        style: TextStyle(color: p.textSoft, fontSize: 15),
      );
    }
    return TextButton(
      onPressed: onResendPressed,
      child: Text(
        l.resendCode,
        style: TextStyle(
          color: p.accent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          AppIcons.otpHeader,
                          size: 44,
                          color: p.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.verifyYourEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.otpSentTo(widget.email),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.textSoft,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      cursorColor: p.accent,
                      style: TextStyle(
                        color: p.textDark,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 16,
                      ),
                      onChanged: (_) {
                        if (errorText != null) {
                          setState(() => errorText = null);
                        }
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        errorText: errorText,
                        errorStyle: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                        hintText: '----',
                        hintStyle: TextStyle(color: p.hint),
                        filled: true,
                        fillColor: p.card,
                        enabledBorder: border(p.border),
                        focusedBorder: border(p.accent),
                        errorBorder: border(AppColors.error),
                        focusedErrorBorder: border(AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildResend(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onVerifyPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l.verify,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // the "incoming message" banner
          buildMessageBanner(),
        ],
      ),
    );
  }
}