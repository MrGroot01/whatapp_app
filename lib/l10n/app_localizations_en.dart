// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get firebaseCouldNotStart => 'Firebase could not start';

  @override
  String get newMessage => 'New message';

  @override
  String get newGroupMessage => 'New group message';

  @override
  String get photoWord => 'Photo';

  @override
  String get chatWord => 'Chat';

  @override
  String get notifTaskChannel => 'Task reminders';

  @override
  String get notifTaskChannelDesc => 'Reminders for your tasks';

  @override
  String get notifMessagesChannel => 'Messages';

  @override
  String get notifMessagesChannelDesc => 'New messages from your contacts';

  @override
  String get notifStatusChannel => 'Message status';

  @override
  String get notifStatusChannelDesc =>
      'Notifications for successfully sent messages';

  @override
  String get sentPhoto => 'Photo sent successfully';

  @override
  String get sentDocument => 'Document sent successfully';

  @override
  String get sentContact => 'Contact sent successfully';

  @override
  String get sentMessage => 'Message sent successfully';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hr ago';
  }

  @override
  String get photoTooLarge =>
      'Photo is too large. Please choose a smaller one.';

  @override
  String get statusText => 'Text';

  @override
  String get addStatusTitle => 'Add status';

  @override
  String get myStatus => 'My status';

  @override
  String get tapToAddStatus => 'Tap to add status update';

  @override
  String get recentUpdates => 'Recent updates';

  @override
  String get viewedUpdates => 'Viewed updates';

  @override
  String get noRecentUpdates =>
      'No recent updates.\nStatuses from your contacts appear here and disappear after a short time.';

  @override
  String get addStatusTooltip => 'Add status';

  @override
  String get textStatusTooltip => 'Text status';

  @override
  String get photoStatusTooltip => 'Photo status';

  @override
  String get couldNotOpenCameraOrGallery =>
      'Could not open the camera or gallery';

  @override
  String statusUpdatesLine(int count, String timeAgo) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count updates · $timeAgo',
      one: '1 update · $timeAgo',
    );
    return '$_temp0';
  }

  @override
  String get typeSomethingFirst => 'Type something first';

  @override
  String get statusOfflineQueued =>
      'No internet. Your status will post when you are back online.';

  @override
  String get addCaption => 'Add a caption...';

  @override
  String get typeAStatus => 'Type a status';

  @override
  String get changeColour => 'Change colour';

  @override
  String get deleteStatus => 'Delete status';

  @override
  String get noViewsYet => 'No views yet';

  @override
  String get couldNotLoadPhoto => 'Could not load this photo';

  @override
  String viewedBy(int count) {
    return 'Viewed by $count';
  }

  @override
  String get createTask => 'Create Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get assignTo => 'Assign to';

  @override
  String get mePersonalTask => 'Me (personal task)';

  @override
  String get noSavedContactsAddFirst =>
      'No saved contacts yet. Add a contact first.';

  @override
  String get titleLabel => 'Title';

  @override
  String get taskTitleHint => 'Task title';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get addMoreDetails => 'Add more details';

  @override
  String get dueDateTime => 'Due Date & Time';

  @override
  String get reminderLabelText => 'Reminder';

  @override
  String reminderFor(String name) {
    return 'Reminder for $name';
  }

  @override
  String reminderGoesToThem(String name) {
    return '$name gets this reminder on their phone.';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get assignTask => 'Assign Task';

  @override
  String get saveTask => 'Save Task';

  @override
  String get couldNotSaveTask =>
      'Could not save the task. Check your internet and the database rules.';

  @override
  String assignedSuccess(String name) {
    return 'Assigned to $name. It will appear in their My Tasks.';
  }

  @override
  String get taskSavedSuccess => 'Your task has been saved successfully.';

  @override
  String get taskUpdated => 'Task Updated!';

  @override
  String get taskAssigned => 'Task Assigned!';

  @override
  String get taskCreated => 'Task Created!';

  @override
  String get noReminderScheduled =>
      'No reminder was scheduled: the reminder time has already passed, or notifications are off.';

  @override
  String get ok => 'OK';

  @override
  String get enterTitle => 'Please enter a title';

  @override
  String get titleTooLong => 'Title is too long';

  @override
  String get descTooLong => 'Description is too long';

  @override
  String get newTask => 'New task';

  @override
  String get edit => 'Edit';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String get deleteTaskBody => 'This task and its reminder will be removed.';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get noReminder => 'No reminder';

  @override
  String get pleaseLogInTasks => 'Please log in to see your tasks.';

  @override
  String get couldNotLoadTasks =>
      'Unable to load tasks. Check your internet and the database rules.';

  @override
  String get emptyAssignedToMe => 'Nothing is assigned to you yet.';

  @override
  String get emptyAssignedByMe =>
      'You have not assigned any task yet.\nLong-press a chat message and tap Create Task.';

  @override
  String get emptyNoTasks =>
      'No tasks yet.\nLong-press a chat message and tap Create Task.';

  @override
  String get emptyList => 'No tasks in this list.';

  @override
  String filterAll(int count) {
    return 'All ($count)';
  }

  @override
  String filterUpcoming(int count) {
    return 'Upcoming ($count)';
  }

  @override
  String filterCompleted(int count) {
    return 'Completed ($count)';
  }

  @override
  String filterAssignedToMe(int count) {
    return 'Assigned to me ($count)';
  }

  @override
  String filterAssignedByMe(int count) {
    return 'Assigned by me ($count)';
  }

  @override
  String doneBy(String name) {
    return 'Done by $name';
  }

  @override
  String waitingFor(String name) {
    return 'Waiting for $name';
  }

  @override
  String reminderPrefix(String label) {
    return 'Reminder: $label';
  }

  @override
  String assignedByLine(String name) {
    return 'Assigned by $name';
  }

  @override
  String assignedToLine(String name) {
    return 'Assigned to $name';
  }

  @override
  String fromLine(String name) {
    return 'From: $name';
  }

  @override
  String deleteTaskAssignedBody(String name) {
    return 'This task will be removed for you and for $name.';
  }

  @override
  String get couldNotUpdateTask =>
      'Could not update the task. Check your internet connection.';

  @override
  String get couldNotDeleteTask =>
      'Could not delete the task. Check your internet connection.';

  @override
  String get reminderAtDue => 'At due time';

  @override
  String get reminder10Min => '10 minutes before';

  @override
  String get reminder1Hour => '1 hour before';

  @override
  String get reminder2Hours => '2 hours before';

  @override
  String get reminder1Day => '1 day before';

  @override
  String get dueNow => 'Due now';

  @override
  String dueOn(String date, String time) {
    return 'Due $date, $time';
  }

  @override
  String newTaskFrom(String who) {
    return 'New task from $who';
  }

  @override
  String get aContact => 'a contact';

  @override
  String get someone => 'Someone';

  @override
  String get save => 'Save';

  @override
  String get groupNameTitle => 'Group name';

  @override
  String get changeGroupName => 'Change group name';

  @override
  String get addMembers => 'Add members';

  @override
  String get groupAdminBadge => 'Group admin';

  @override
  String get removeFromGroup => 'Remove from group';

  @override
  String get removeAction => 'Remove';

  @override
  String get removeMemberBody =>
      'They will not receive new messages from this group.';

  @override
  String get exitGroup => 'Exit group';

  @override
  String get exitGroupTitle => 'Exit group?';

  @override
  String get exitAction => 'Exit';

  @override
  String get exitGroupBody =>
      'You will no longer receive messages from this group.';

  @override
  String get disappearingGroupHelp =>
      'New messages in this group will disappear after the time you choose.';

  @override
  String removeMemberTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String groupMembersLine(int count) {
    return 'Group · $count members';
  }

  @override
  String get addGroupMembers => 'Add group members';

  @override
  String get noContactsToAdd => 'No contacts to add. Save a contact first.';

  @override
  String selectedOf(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get addAName => 'Add a name';

  @override
  String get groupNameHint => 'Group name (required)';

  @override
  String get groupNameRequired => 'Please type a group name';

  @override
  String membersTitle(int count) {
    return 'Members: $count';
  }

  @override
  String get couldNotRenameGroup => 'Could not rename the group';

  @override
  String get couldNotAddMembers => 'Could not add the members';

  @override
  String get couldNotRemoveMember => 'Could not remove this member';

  @override
  String get couldNotExitGroup => 'Could not exit the group';

  @override
  String get pleaseLogInAgain => 'Please log in again';

  @override
  String get noLongerInGroup => 'You are no longer in this group';

  @override
  String get member => 'Member';

  @override
  String get today => 'Today';

  @override
  String get forwarded => 'Forwarded';

  @override
  String disappearingNotice(String label) {
    return '⏱ Disappearing messages: $label';
  }

  @override
  String get scheduleTitle => 'Schedule sending';

  @override
  String get scheduleTypeFirst => 'Type a message or select an image first';

  @override
  String get scheduleInvalid => 'Pick a time in the future';

  @override
  String tomorrowDay(String day) {
    return 'Tomorrow, $day';
  }

  @override
  String scheduleToday(String time) {
    return 'today at $time';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'tomorrow at $time';
  }

  @override
  String scheduleOn(String day, String time) {
    return 'on $day at $time';
  }

  @override
  String sendAt(String label) {
    return 'Send $label';
  }

  @override
  String scheduledFor(String label) {
    return 'Message scheduled for $label';
  }

  @override
  String get callsNotInGroups => 'Calls are not available in groups yet';

  @override
  String get couldNotIdentifyContact =>
      'Could not identify the contact account';

  @override
  String get couldNotOpenDialer => 'Could not open the phone dialer';

  @override
  String noPhoneSaved(String name) {
    return 'No phone number saved for $name';
  }

  @override
  String get couldNotOpenCamera =>
      'Could not open the camera. Check camera permission.';

  @override
  String get couldNotOpenGallery => 'Could not open the gallery';

  @override
  String get couldNotPickDocument => 'Could not pick the document';

  @override
  String get couldNotOpenFile => 'Could not open the file';

  @override
  String get attachCamera => 'Camera';

  @override
  String get attachGallery => 'Gallery';

  @override
  String get attachContact => 'Contact';

  @override
  String get attachLocation => 'Location';

  @override
  String get locationComingSoon => 'Location sharing is coming soon';

  @override
  String get shareContactTitle => 'Share contact';

  @override
  String get forwardToTitle => 'Forward to...';

  @override
  String get noSavedContacts => 'No saved contacts yet';

  @override
  String get searchNameOrNumber => 'Search name or number';

  @override
  String get noContactFound => 'No contact found';

  @override
  String get selectContacts => 'Select contacts';

  @override
  String sendToCount(int count) {
    return 'Send to $count';
  }

  @override
  String get cardMessage => 'Message';

  @override
  String get alreadyInContacts => 'Already in your contacts';

  @override
  String get ownNumber => 'This is your own number';

  @override
  String get contactSavedShort => 'Contact saved';

  @override
  String get couldNotSaveContact =>
      'Could not save the contact. Check the database rules.';

  @override
  String get waitUntilSent => 'Wait until the message is sent';

  @override
  String get messageForwarded => 'Message forwarded';

  @override
  String forwardedToCount(int done, int total) {
    return 'Forwarded to $done of $total contacts';
  }

  @override
  String get voiceLanguageTitle => 'Voice typing language';

  @override
  String get voiceLanguageHelp =>
      'The mic listens to one language at a time. Choose the language you will speak.';

  @override
  String get listening => 'Listening...';

  @override
  String voiceLanguageChosen(String name) {
    return 'Voice typing language: $name';
  }

  @override
  String listeningIn(String name) {
    return 'Listening in $name...';
  }

  @override
  String get reply => 'Reply';

  @override
  String get forward => 'Forward';

  @override
  String get tryAgain => 'Try again';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get clearChatTitle => 'Clear chat?';

  @override
  String get clear => 'Clear';

  @override
  String clearGroupBody(String title) {
    return 'All messages in $title will be deleted for everyone.';
  }

  @override
  String clearChatBody(String name) {
    return 'All messages with $name will be deleted.';
  }

  @override
  String get couldNotLoadMessages =>
      'Unable to load messages. Check your Firebase Realtime Database rules.';

  @override
  String get noMessagesYet => 'No messages yet\nSay hi 👋';

  @override
  String get messageHint => 'Message';

  @override
  String get photoAttached => 'Photo attached';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get groupInfo => 'Group info';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get searchHint => 'Search...';

  @override
  String get noResults => 'No results';

  @override
  String matchOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get couldNotSendMessage =>
      'Could not send the message. Please try again.';

  @override
  String get couldNotScheduleMessage =>
      'Could not schedule the message. Please try again.';

  @override
  String get nothingToSend => 'Nothing to send';

  @override
  String get imageTooLarge =>
      'Image is too large. Please choose a smaller photo.';

  @override
  String get couldNotShareContact =>
      'Could not share the contact. Please try again.';

  @override
  String get documentsOnlineOnly =>
      'Documents can only be sent when you are online.';

  @override
  String get couldNotSaveAttachment =>
      'Could not save the attachment. Please try again.';

  @override
  String get couldNotDeleteMessage => 'Could not delete the message';

  @override
  String get couldNotClearChat => 'Could not clear the chat';

  @override
  String get reactionFailed =>
      'Could not add the reaction. Check the database rules.';

  @override
  String voiceNoSpeech(String language) {
    return 'I didn\'t hear anything in $language. Tap the mic and speak clearly, or change the language (long-press the mic).';
  }

  @override
  String get micPermission =>
      'Please allow the microphone permission for this app';

  @override
  String voiceLangNotReady(String language) {
    return '$language voice typing is not ready on this phone.\nConnect to the internet, or download $language in the phone\'s Google voice typing settings.';
  }

  @override
  String voiceNetworkError(String error, String language) {
    return 'Voice error: $error\nCheck your internet, or download $language for offline use in the phone settings, or type your message.';
  }

  @override
  String speechError(String error) {
    return 'Speech error: $error';
  }

  @override
  String get micPermissionNeeded =>
      'Microphone permission is needed. Allow it in the app settings.';

  @override
  String get you => 'You';

  @override
  String get attachDocument => 'Document';

  @override
  String get clearChat => 'Clear chat';

  @override
  String get mediaLinksDocs => 'Media, links, and docs';

  @override
  String get disappearingTitle => 'Disappearing messages';

  @override
  String get disappearOff => 'Off';

  @override
  String get disappear5Min => '5 minutes';

  @override
  String get disappear1Day => '1 day';

  @override
  String get disappear7Days => '7 days';

  @override
  String get contactInfoTitle => 'Contact info';

  @override
  String get phoneUnavailable => 'Phone number unavailable';

  @override
  String get actionAudio => 'Audio';

  @override
  String get actionVideo => 'Video';

  @override
  String get mediaVisibility => 'Media visibility';

  @override
  String get encryption => 'Encryption';

  @override
  String get encryptionSub =>
      'Messages and calls are not yet end-to-end encrypted.';

  @override
  String get blockContact => 'Block contact';

  @override
  String get disappearingChatHelp =>
      'New messages in this chat will disappear after the time you choose.';

  @override
  String get couldNotChangeSetting =>
      'Could not change the setting. Check your internet.';

  @override
  String get notificationSettingsMsg => 'Notification settings';

  @override
  String get mediaVisibilitySettingsMsg => 'Media visibility settings';

  @override
  String get encryptionMsg =>
      'This app does not currently implement end-to-end encryption.';

  @override
  String get blockingNotImplemented =>
      'Contact blocking is not implemented yet.';

  @override
  String get calling => 'Calling...';

  @override
  String get videoCalling => 'Video calling...';

  @override
  String get callSpeaker => 'Speaker';

  @override
  String get callMute => 'Mute';

  @override
  String get callFlip => 'Flip';

  @override
  String get callMore => 'More';

  @override
  String get callShare => 'Share';

  @override
  String get callEnd => 'End';

  @override
  String get addPeopleSoon => 'Adding people is coming soon';

  @override
  String get moreOptionsSoon => 'More options are coming soon';

  @override
  String get sharingSoon => 'Sharing is coming soon';

  @override
  String get noCameraFound => 'No camera found on this device';

  @override
  String get cameraPermissionDenied =>
      'Camera permission denied. Allow it in the app settings.';

  @override
  String get callCouldNotOpenCamera => 'Could not open the camera';

  @override
  String get nothingToOpen => 'Nothing to open here';

  @override
  String get couldNotOpenThis => 'Could not open this';

  @override
  String get tabMedia => 'Media';

  @override
  String get tabDocs => 'Docs';

  @override
  String get tabLinks => 'Links';

  @override
  String get noPhotosYet => 'No photos shared yet';

  @override
  String get noDocsYet => 'No documents shared yet';

  @override
  String get noLinksYet => 'No links shared yet';

  @override
  String get couldNotLoadMedia =>
      'Unable to load. Check your Firebase Realtime Database rules.';

  @override
  String sharedBy(String who, String date) {
    return '$who  •  $date';
  }

  @override
  String linkSubtitle(String title, String who, String date) {
    return '$title\n$who  •  $date';
  }

  @override
  String get waitingOne => '1 message is waiting to be sent.';

  @override
  String waitingMany(int count) {
    return '$count messages are waiting to be sent.';
  }

  @override
  String offlineWithPending(String waiting) {
    return 'You are offline. $waiting';
  }

  @override
  String get offlineNoPending =>
      'You are offline. Please turn on your internet connection.';

  @override
  String connectingWithPending(String waiting) {
    return 'Connecting... $waiting';
  }

  @override
  String get connecting => 'Connecting...';

  @override
  String get backOnlineSending => 'Back online. Sending your messages...';

  @override
  String get backOnline => 'You are back online.';

  @override
  String get saveContact => 'Save contact';

  @override
  String get addContactTitle => 'Add contact';

  @override
  String get addContactSubtitle =>
      'Enter the registered email and the rest is filled in automatically.';

  @override
  String get contactNameLabel => 'User name';

  @override
  String get registeredEmailLabel => 'Registered email address';

  @override
  String get userFound => 'Registered user found';

  @override
  String get userFoundNoPhone =>
      'Registered user found. They have not added a phone number, so please type it below.';

  @override
  String get userNotFound => 'No registered user found with this email';

  @override
  String get cannotAddSelf => 'You cannot add your own account.';

  @override
  String get lookupFailed => 'Could not look up this email.';

  @override
  String get lookupFailedInternet =>
      'Could not look up this email. Check your internet connection.';

  @override
  String userFoundName(String name) {
    return 'Registered user found: $name';
  }

  @override
  String lookupFailedCode(String code) {
    return 'Could not look up this email ($code).';
  }

  @override
  String get enterContactName => 'Enter the user name';

  @override
  String get nameTooShort => 'Name must be at least 4 characters';

  @override
  String get nameTooLong => 'Name must be 40 characters or less';

  @override
  String get enterRegisteredEmail => 'Enter the registered email address';

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get loginAgainToSave => 'Please log in again before saving contacts.';

  @override
  String get userAlreadyInContacts => 'This user is already in your contacts.';

  @override
  String get firebaseDenied =>
      'Firebase denied access. Check your database rules.';

  @override
  String get unknownError => 'Unknown error';

  @override
  String firebaseError(String code, String message) {
    return 'Firebase error ($code): $message';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get nameLabel => 'Name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get notAdded => 'Not added';

  @override
  String get saveName => 'Save name';

  @override
  String get profileNameUpdated => 'Name updated';

  @override
  String get nameSavedNote =>
      'People who saved you keep the name they chose for you.';

  @override
  String get enterYourName => 'Please enter your name';

  @override
  String get pleaseLogInBeforePicture =>
      'Please log in again before changing your picture.';

  @override
  String get pictureTooLarge =>
      'This picture is too large. Please choose a smaller image.';

  @override
  String get youAreOfflineTryAgain =>
      'You are offline. Connect to the internet and try again.';

  @override
  String profileUpdateFailed(String error) {
    return 'Profile update failed: $error';
  }

  @override
  String get pleaseLogInBeforeName =>
      'Please log in again before changing your name.';

  @override
  String get serverNoAnswer =>
      'The server did not answer. Check your internet connection and try again.';

  @override
  String couldNotSaveNameCode(String code) {
    return 'Could not save your name ($code). Please try again.';
  }

  @override
  String get couldNotSaveName => 'Could not save your name. Please try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get videoCallNoAnswer => 'Video call · no answer';

  @override
  String get missedVideoCall => 'Missed video call';

  @override
  String youPrefix(String text) {
    return 'You: $text';
  }

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String deleteChatsTitle(int count) {
    return 'Delete $count chats?';
  }

  @override
  String get deleteChatBody =>
      'The chat is removed from your list only. The other people keep their messages. A new message brings the chat back.';

  @override
  String get chatDeleted => 'Chat deleted';

  @override
  String chatsDeleted(int count) {
    return '$count chats deleted';
  }

  @override
  String get couldNotDelete =>
      'Could not delete. Check your internet and try again.';

  @override
  String get newChat => 'New chat';

  @override
  String get newGroup => 'New group';

  @override
  String get newContact => 'New contact';

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String get tapToStartChatting => 'Tap to start chatting';

  @override
  String get offlineNoContacts =>
      'You are offline. No contacts are saved on this device yet.';

  @override
  String get noChatsYet =>
      'No chats yet. Tap + to add a contact or create a group.';

  @override
  String get updates => 'Updates';

  @override
  String get chats => 'Chats';

  @override
  String get search => 'Search';

  @override
  String get closeSearch => 'Close search';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get pleaseLogIn => 'Please log in to view your contacts.';

  @override
  String get contactSaved => 'Contact saved successfully.';

  @override
  String get searchSettings => 'Search settings';

  @override
  String get noSettingsFound => 'No settings found';

  @override
  String get addNewContact => 'Add new contact';

  @override
  String get addNewContactSub => 'Save a contact to start chatting';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsAccountSub => 'Security notifications, account info';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySub => 'Blocked contacts, disappearing messages';

  @override
  String get settingsChatsSub => 'Theme, wallpaper, chat history';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSub => 'Message, group and call tones';

  @override
  String get settingsStorage => 'Storage and data';

  @override
  String get settingsStorageSub => 'Network usage, auto-download';

  @override
  String get settingsHelp => 'Help and feedback';

  @override
  String get settingsHelpSub => 'Help centre, contact us, privacy policy';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutTitle => 'Log out?';

  @override
  String get logOutBody => 'Are you sure you want to log out of your account?';

  @override
  String get profilePhotoUpdated =>
      'Profile picture updated. Your contacts can now see it.';

  @override
  String get createAccount => 'Create account';

  @override
  String get signupSubtitle => 'Sign up with your email to get started.';

  @override
  String get nickname => 'Nickname';

  @override
  String get code => 'Code';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get register => 'Register';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get logInLink => 'Log in';

  @override
  String get ruleLength => 'At least 8 characters';

  @override
  String get ruleCapital => '1 capital letter (A-Z)';

  @override
  String get ruleSmall => '1 small letter (a-z)';

  @override
  String get ruleNumber => '1 number (0-9)';

  @override
  String get ruleSpecial => '1 special character (! @ # \$ %)';

  @override
  String get enterNickname => 'Please enter a nickname';

  @override
  String get useAtLeast3 => 'Use at least 3 characters';

  @override
  String get useAtMost20 => 'Use at most 20 characters';

  @override
  String get enterNewPassword => 'Please enter a password';

  @override
  String get useAtLeast8 => 'Use at least 8 characters';

  @override
  String get noSpaces => 'Password cannot contain spaces';

  @override
  String get addCapital => 'Add 1 capital letter (A-Z)';

  @override
  String get addSmall => 'Add 1 small letter (a-z)';

  @override
  String get addNumber => 'Add 1 number (0-9)';

  @override
  String get addSpecial => 'Add 1 special character (! @ # \$ % & *)';

  @override
  String get confirmYourPassword => 'Please confirm your password';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get emailAlreadyRegistered =>
      'This email is already registered. Please log in.';

  @override
  String get weakPassword =>
      'This password is too weak. Please choose another.';

  @override
  String get signupNotEnabled =>
      'Email/password sign-up is not enabled in Firebase Console.';

  @override
  String get signupFailed => 'Unable to create account. Please try again.';

  @override
  String get createAccountWentWrong =>
      'Something went wrong while creating the account. Please try again.';

  @override
  String get accountNotCreated =>
      'Account could not be created. Please try again.';

  @override
  String get phoneAlreadyRegistered =>
      'This phone number is already registered with another account. Please use a different number.';

  @override
  String get phoneCheckFailed =>
      'Could not check the phone number. Check your internet connection and try again.';

  @override
  String get phoneJustTaken =>
      'This phone number was just registered by another account. Please use a different number.';

  @override
  String get phoneSaveFailed =>
      'Could not save the phone number. Check your internet connection and try again.';

  @override
  String phoneSaveFailedCode(String code) {
    return 'Could not save the phone number ($code). Please try again.';
  }

  @override
  String get verificationCancelled =>
      'Verification was cancelled, so no account was created. Please try again.';

  @override
  String get enterPhone => 'Enter the phone number';

  @override
  String get digitsOnly => 'Use digits only';

  @override
  String get invalidPhone => 'Enter a valid phone number (6–15 digits)';

  @override
  String get verifyYourEmail => 'Verify your email';

  @override
  String otpSentTo(String email) {
    return 'Enter the 4-digit code sent to\n$email';
  }

  @override
  String get enterAllDigits => 'Enter all 4 digits';

  @override
  String get wrongOtp => 'Wrong OTP, try again';

  @override
  String get messages => 'Messages';

  @override
  String get now => 'now';

  @override
  String otpMessage(String appName, String code) {
    return 'Your $appName verification code is $code. Do not share it with anyone.';
  }

  @override
  String resendCodeIn(String time) {
    return 'Resend code in $time';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get verify => 'Verify';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get invalidEmail => 'Enter a valid email (example: name@gmail.com)';

  @override
  String get invalidEmailAddress => 'Please enter a valid email address.';

  @override
  String get tooManyAttempts => 'Too many attempts. Please try again later.';

  @override
  String get networkError => 'Network error. Check your internet connection.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get loginCredentials =>
      'Email or password is incorrect. If you are new here, tap Sign up below.';

  @override
  String get accountDisabled => 'This account has been disabled.';

  @override
  String get loginFailed => 'Unable to log in. Please try again.';

  @override
  String get verifyEmailFirst =>
      'Please verify your email first. Open the link we sent to your inbox (check Spam too), then log in again.';

  @override
  String get verificationSent => 'Verification email sent. Check your inbox.';

  @override
  String get accountVerified => 'Account verified. Please log in.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in with your email and password.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resendVerification => 'Resend verification email';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get noAccountFound =>
      'No account found with this email. Please sign up.';

  @override
  String get couldNotSendEmail => 'Could not send the email. Please try again.';

  @override
  String get forgotSubtitle =>
      'Enter your registered email and we will send you a link to choose a new password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get checkInbox => 'Check your inbox';

  @override
  String get resendLink => 'Resend link';

  @override
  String get changeEmail => 'Change email';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String resetLinkSent(String email) {
    return 'We sent a reset link to $email. Open it, choose a new password, then log in with it.\n\nCannot see it? Check your Spam folder too.';
  }

  @override
  String get tagline => 'Messaging, beautifully simple.';

  @override
  String get premiumMessaging => 'PREMIUM MESSAGING';

  @override
  String get welcomeBody =>
      'Private chats, fast delivery and groups for the people who matter.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get newHere => 'New here?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get perkPrivate => 'Private';

  @override
  String get perkFast => 'Fast';

  @override
  String get perkGroups => 'Groups';

  @override
  String get accountCreated =>
      'Account created. Check your email for the verification link, then log in.';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get systemDefault => 'System default';

  @override
  String get chooseLanguageHelp =>
      'Choose the language of the app. Your chat messages are not translated.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get chooseTheme => 'Choose theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';
}
