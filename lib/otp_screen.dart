import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String correctOtp;

  const OtpScreen({super.key, required this.email, required this.correctOtp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const Color _bg = Color(0xFF0F1B3D);
  static const Color _accent = Color(0xFF00C2A8);
  static const Color _card = Color(0xFF1A2A55);
  static const Color _text = Color(0xFFE0E6F5);

  final otpController = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void onVerifyPressed() {
    final entered = otpController.text.trim();

    if (entered.length != 4) {
      setState(() => errorText = 'Enter all 4 digits');
      return;
    }

    if (entered == widget.correctOtp) {
      // tell the Sign up screen: the OTP is correct
      Navigator.pop(context, true);
    } else {
      setState(() => errorText = 'Wrong OTP, try again');
    }
  }

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    child: const Icon(Icons.mark_email_read_rounded,
                        size: 44, color: _accent),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 4-digit code sent to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  cursorColor: _accent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                  ),
                  onChanged: (_) {
                    if (errorText != null) setState(() => errorText = null);
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: errorText,
                    errorStyle: const TextStyle(
                      color: Color(0xFFFF8A80),
                      fontSize: 14,
                    ),
                    hintText: '----',
                    hintStyle: const TextStyle(color: Color(0xFF8E9BC0)),
                    filled: true,
                    fillColor: _card,
                    enabledBorder: border(const Color(0xFF3A4C80)),
                    focusedBorder: border(_accent),
                    errorBorder: border(const Color(0xFFFF8A80)),
                    focusedErrorBorder: border(const Color(0xFFFF8A80)),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onVerifyPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Verify',
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
    );
  }
}