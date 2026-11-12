// All the texts the user can read, in one place.
// To change a text, change it here and every screen updates.
class AppStrings {
  AppStrings._(); // nobody makes an object of this class

  // ---------- BRAND ----------
  static const String appName = 'Velora';
  static const String tagline = 'Messaging, beautifully simple.';

  // ---------- COMMON ----------
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String logOut = 'Log out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';
  static const String nickname = 'Nickname';
  static const String phoneNumber = 'Phone number';
  static const String code = 'Code';
  static const String backToLogin = 'Back to login';

  // ---------- ERRORS (shared) ----------
  static const String invalidEmailAddress =
      'Please enter a valid email address.';
  static const String tooManyAttempts =
      'Too many attempts. Please try again later.';
  static const String networkError =
      'Network error. Check your internet connection.';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';

  // ---------- VALIDATION ----------
  static const String enterEmail = 'Please enter your email';
  static const String invalidEmail =
      'Enter a valid email (example: name@gmail.com)';
  static const String enterPassword = 'Please enter your password';
  static const String enterNewPassword = 'Please enter a password';
  static const String confirmYourPassword = 'Please confirm your password';
  static const String passwordsDontMatch = 'Passwords do not match';
  static const String enterNickname = 'Please enter a nickname';
  static const String useAtLeast3 = 'Use at least 3 characters';
  static const String useAtMost20 = 'Use at most 20 characters';
  static const String useAtLeast8 = 'Use at least 8 characters';
  static const String noSpaces = 'Password cannot contain spaces';
  static const String addCapital = 'Add 1 capital letter (A-Z)';
  static const String addSmall = 'Add 1 small letter (a-z)';
  static const String addNumber = 'Add 1 number (0-9)';
  static const String addSpecial = 'Add 1 special character (! @ # \$ % & *)';

  // ---------- WELCOME ----------
  static const String premiumMessaging = 'PREMIUM MESSAGING';
  static const String welcomeBody =
      'Private chats, fast delivery and groups for the people who matter.';
  static const String getStarted = 'Get Started';
  static const String newHere = 'New here? ';
  static const String createAnAccount = 'Create an account';
  static const String perkPrivate = 'Private';
  static const String perkFast = 'Fast';
  static const String perkGroups = 'Groups';
  static const String accountCreated =
      'Account created. Check your email for the verification link, then log in.';

  // ---------- LOGIN ----------
  static const String welcomeBack = 'Welcome back';
  static const String loginSubtitle = 'Log in with your email and password.';
  static const String login = 'Login';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account? ";
  static const String signUp = 'Sign up';
  static const String resendVerification = 'Resend verification email';
  static const String verificationSent =
      'Verification email sent. Check your inbox.';
  static const String accountVerified = 'Account verified. Please log in.';
  static const String loginCredentials =
      'Email or password is incorrect. '
      'If you are new here, tap Sign up below.';
  static const String accountDisabled = 'This account has been disabled.';
  static const String loginFailed = 'Unable to log in. Please try again.';
  static const String verifyEmailFirst =
      'Please verify your email first. Open the link we sent to your '
      'inbox (check Spam too), then log in again.';

  // ---------- SIGN UP ----------
  static const String createAccount = 'Create account';
  static const String signupSubtitle = 'Sign up with your email to get started.';
  static const String register = 'Register';
  static const String haveAccount = 'Already have an account? ';
  static const String logIn = 'Log in';
  static const String ruleLength = 'At least 8 characters';
  static const String ruleCapital = '1 capital letter (A-Z)';
  static const String ruleSmall = '1 small letter (a-z)';
  static const String ruleNumber = '1 number (0-9)';
  static const String ruleSpecial = '1 special character (! @ # \$ %)';

  // ---------- SIGN UP ERRORS ----------
  static const String emailAlreadyRegistered =
      'This email is already registered. Please log in.';
  static const String weakPassword =
      'This password is too weak. Please choose another.';
  static const String signupNotEnabled =
      'Email/password sign-up is not enabled in Firebase Console.';
  static const String signupFailed =
      'Unable to create account. Please try again.';
  static const String createAccountWentWrong =
      'Something went wrong while creating the account. Please try again.';
  static const String accountNotCreated =
      'Account could not be created. Please try again.';
  static const String phoneAlreadyRegistered =
      'This phone number is already registered with another '
      'account. Please use a different number.';
  static const String phoneCheckFailed =
      'Could not check the phone number. '
      'Check your internet connection and try again.';
  static const String phoneJustTaken =
      'This phone number was just registered by another account. '
      'Please use a different number.';
  static const String phoneSaveFailed =
      'Could not save the phone number. '
      'Check your internet connection and try again.';
  static const String verificationCancelled =
      'Verification was cancelled, so no account was created. '
      'Please try again.';

  static String phoneSaveFailedCode(String code) =>
      'Could not save the phone number ($code). Please try again.';

  // ---------- OTP ----------
  static const String verifyYourEmail = 'Verify your email';
  static const String verify = 'Verify';
  static const String resendCode = 'Resend code';
  static const String enterAllDigits = 'Enter all 4 digits';
  static const String wrongOtp = 'Wrong OTP, try again';
  static const String messages = 'Messages';
  static const String now = 'now';

  static String otpSentTo(String email) =>
      'Enter the 4-digit code sent to\n$email';

  static String resendCodeIn(String time) => 'Resend code in $time';

  static String otpMessage(String code) =>
      'Your $appName verification code is $code. '
          'Do not share it with anyone.';

  // ---------- FORGOT PASSWORD ----------
  static const String forgotSubtitle =
      'Enter your registered email and we will send you a link to '
      'choose a new password.';
  static const String sendResetLink = 'Send reset link';
  static const String checkInbox = 'Check your inbox';
  static const String resendLink = 'Resend link';
  static const String changeEmail = 'Change email';
  static const String noAccountFound =
      'No account found with this email. Please sign up.';
  static const String couldNotSendEmail =
      'Could not send the email. Please try again.';

  static String resendIn(int seconds) => 'Resend in ${seconds}s';

  static String resetLinkSent(String email) =>
      'We sent a reset link to $email. '
          'Open it, choose a new password, then log in with it.\n\n'
          'Cannot see it? Check your Spam folder too.';
}