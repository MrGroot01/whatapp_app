import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String correctOtp;

  const OtpScreen({super.key, required this.email, required this.correctOtp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const Color _error = Color(0xFFD94B4B);

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

    final entered = otpController.text.trim();

    if (entered.length != 4) {
      setState(() => errorText = 'Enter all 4 digits');
      return;
    }

    if (entered == currentOtp) {
      finished = true;
      // tell the Sign up screen: the OTP is correct
      // (the Sign up screen then goes back to the Login page)
      Navigator.pop(context, true);
    } else {
      setState(() => errorText = 'Wrong OTP, try again');
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x800B6B57)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
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
                child: Icon(Icons.sms_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Messages',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'now',
                          style: TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your ${AppBrand.name} verification code is $currentOtp. '
                          'Do not share it with anyone.',
                      style: const TextStyle(
                        color: AppColors.textDark,
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
    if (secondsLeft > 0) {
      final time = '0:${secondsLeft.toString().padLeft(2, '0')}';
      return Text(
        'Resend code in $time',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSoft, fontSize: 15),
      );
    }
    return TextButton(
      onPressed: onResendPressed,
      child: const Text(
        'Resend code',
        style: TextStyle(
          color: AppColors.emerald,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3F1ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          size: 44,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Verify your email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 4-digit code sent to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSoft,
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
                      cursorColor: AppColors.emerald,
                      style: const TextStyle(
                        color: AppColors.textDark,
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
                        errorStyle:
                        const TextStyle(color: _error, fontSize: 14),
                        hintText: '----',
                        hintStyle: const TextStyle(color: Color(0xFFB8C2C0)),
                        filled: true,
                        fillColor: AppColors.card,
                        enabledBorder: border(const Color(0xFFE3DED2)),
                        focusedBorder: border(AppColors.emerald),
                        errorBorder: border(_error),
                        focusedErrorBorder: border(_error),
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
                        child: const Text(
                          'Verify',
                          style: TextStyle(
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