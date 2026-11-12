class AppStrings {
  AppStrings._(); // nobody makes an object of this class

  // ---------- BRAND ----------
  static const String appName = 'Velora';
  static const String tagline = 'Messaging, beautifully simple.';

  static const String homeTitle = appName;

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

  // ---------- HOME ----------
  static const String updates = 'Updates';
  static const String chats = 'Chats';
  static const String search = 'Search';
  static const String closeSearch = 'Close search';
  static const String myTasks = 'My Tasks';
  static const String newChat = 'New chat';
  static const String newGroup = 'New group';
  static const String newContact = 'New contact';
  static const String pleaseLogIn = 'Please log in to view your contacts.';
  static const String noChatsYet =
      'No chats yet. Tap + to add a contact or create a group.';
  static const String offlineNoContacts =
      'You are offline. No contacts are saved on this device yet.';
  static const String tapToStartChatting = 'Tap to start chatting';
  static const String yesterday = 'Yesterday';
  static const String contactSaved = 'Contact saved successfully.';

  // last message line in the chat list
  static const String videoCallNoAnswer = 'Video call · no answer';
  static const String missedVideoCall = 'Missed video call';

  static String youPrefix(String text) => 'You: $text';

  static String membersCount(int count) => '$count members';

  // delete chats (long-press)
  static const String deleteChatTitle = 'Delete chat?';
  static const String deleteChatBody =
      'The chat is removed from your list only. '
      'The other people keep their messages. '
      'A new message brings the chat back.';
  static const String chatDeleted = 'Chat deleted';
  static const String couldNotDelete =
      'Could not delete. Check your internet and try again.';

  static String deleteChatsTitle(int count) => 'Delete $count chats?';

  static String chatsDeleted(int count) => '$count chats deleted';

  // ---------- SETTINGS ----------
  static const String searchSettings = 'Search settings';
  static const String noSettingsFound = 'No settings found';
  static const String addNewContact = 'Add new contact';
  static const String addNewContactSub = 'Save a contact to start chatting';

  static const String settingsAccount = 'Account';
  static const String settingsAccountSub =
      'Security notifications, account info';
  static const String settingsPrivacy = 'Privacy';
  static const String settingsPrivacySub =
      'Blocked contacts, disappearing messages';
  static const String settingsChatsSub = 'Theme, wallpaper, chat history';
  static const String settingsNotifications = 'Notifications';
  static const String settingsNotificationsSub =
      'Message, group and call tones';
  static const String settingsStorage = 'Storage and data';
  static const String settingsStorageSub = 'Network usage, auto-download';
  static const String settingsLanguage = 'App language';
  static const String settingsLanguageSub = 'English';
  static const String settingsHelp = 'Help and feedback';
  static const String settingsHelpSub =
      'Help centre, contact us, privacy policy';

  static const String logOutTitle = 'Log out?';
  static const String logOutBody =
      'Are you sure you want to log out of your account?';
  static const String profilePhotoUpdated =
      'Profile picture updated. Your contacts can now see it.';

  // ---------- CHAT ----------
  // names and labels
  static const String you = 'You';
  static const String member = 'Member';
  static const String today = 'Today';
  static const String forwarded = 'Forwarded';
  static const String pleaseLogInAgain = 'Please log in again';
  static const String noLongerInGroup = 'You are no longer in this group';

  static const List<String> monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // disappearing messages
  static const String disappearOff = 'Off';
  static const String disappear5Min = '5 minutes';
  static const String disappear1Day = '1 day';
  static const String disappear7Days = '7 days';

  static String disappearingNotice(String label) =>
      '⏱ Disappearing messages: $label';

  // send later (schedule)
  static const String scheduleTitle = 'Schedule sending';
  static const String scheduleTypeFirst =
      'Type a message or select an image first';
  static const String scheduleInvalid = 'Pick a time in the future';

  static String tomorrowDay(String day) => 'Tomorrow, $day';

  static String scheduleToday(String time) => 'today at $time';

  static String scheduleTomorrow(String time) => 'tomorrow at $time';

  static String scheduleOn(String day, String time) => 'on $day at $time';

  static String sendAt(String label) => 'Send $label';

  static String scheduledFor(String label) =>
      'Message scheduled for $label';

  // calls
  static const String callsNotInGroups =
      'Calls are not available in groups yet';
  static const String couldNotIdentifyContact =
      'Could not identify the contact account';
  static const String couldNotOpenDialer = 'Could not open the phone dialer';

  static String noPhoneSaved(String name) =>
      'No phone number saved for $name';

  // camera, gallery, documents
  static const String couldNotOpenCamera =
      'Could not open the camera. Check camera permission.';
  static const String couldNotOpenGallery = 'Could not open the gallery';
  static const String couldNotPickDocument = 'Could not pick the document';
  static const String couldNotOpenFile = 'Could not open the file';

  // attach menu
  static const String attachDocument = 'Document';
  static const String attachCamera = 'Camera';
  static const String attachGallery = 'Gallery';
  static const String attachContact = 'Contact';
  static const String attachLocation = 'Location';
  static const String locationComingSoon =
      'Location sharing is coming soon';

  // contact pickers (share contact, forward)
  static const String shareContactTitle = 'Share contact';
  static const String forwardToTitle = 'Forward to...';
  static const String noSavedContacts = 'No saved contacts yet';
  static const String searchNameOrNumber = 'Search name or number';
  static const String noContactFound = 'No contact found';
  static const String selectContacts = 'Select contacts';

  static String sendToCount(int count) => 'Send to $count';

  // shared contact card
  static const String cardMessage = 'Message';
  static const String saveContact = 'Save contact';
  static const String alreadyInContacts = 'Already in your contacts';
  static const String ownNumber = 'This is your own number';
  static const String contactSavedShort = 'Contact saved';
  static const String couldNotSaveContact =
      'Could not save the contact. Check the database rules.';

  // forward
  static const String waitUntilSent = 'Wait until the message is sent';
  static const String messageForwarded = 'Message forwarded';

  static String forwardedToCount(int done, int total) =>
      'Forwarded to $done of $total contacts';

  // voice typing
  static const String voiceLanguageTitle = 'Voice typing language';
  static const String voiceLanguageHelp =
      'The mic listens to one language at a time. '
      'Choose the language you will speak.';
  static const String listening = 'Listening...';

  static String voiceLanguageChosen(String name) =>
      'Voice typing language: $name';

  static String listeningIn(String name) => 'Listening in $name...';

  // message options (long-press on a message)
  static const String reply = 'Reply';
  static const String forward = 'Forward';
  static const String tryAgain = 'Try again';
  static const String copy = 'Copy';
  static const String copied = 'Copied';
  static const String messageDeleted = 'Message deleted';

  // clear chat
  static const String clearChatTitle = 'Clear chat?';
  static const String clear = 'Clear';

  static String clearGroupBody(String title) =>
      'All messages in $title will be deleted for everyone.';

  static String clearChatBody(String name) =>
      'All messages with $name will be deleted.';

  // message list
  static const String couldNotLoadMessages =
      'Unable to load messages. Check your Firebase Realtime Database rules.';
  static const String noMessagesYet = 'No messages yet\nSay hi 👋';

  // input bar
  static const String messageHint = 'Message';
  static const String photoAttached = 'Photo attached';
  static const String removePhoto = 'Remove photo';

  // top bar and menu
  static const String groupInfo = 'Group info';
  static const String viewProfile = 'View Profile';
  static const String mediaLinksDocs = 'Media, links, and docs';
  static const String clearChat = 'Clear chat';

  // search inside a chat
  static const String searchHint = 'Search...';
  static const String noResults = 'No results';

  static String matchOf(int current, int total) => '$current of $total';
}