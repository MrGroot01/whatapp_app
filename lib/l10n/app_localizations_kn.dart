// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get firebaseCouldNotStart => 'Firebase ಪ್ರಾರಂಭವಾಗಲಿಲ್ಲ';

  @override
  String get newMessage => 'ಹೊಸ ಸಂದೇಶ';

  @override
  String get newGroupMessage => 'ಹೊಸ ಗುಂಪು ಸಂದೇಶ';

  @override
  String get photoWord => 'ಫೋಟೋ';

  @override
  String get chatWord => 'ಚಾಟ್';

  @override
  String get notifTaskChannel => 'ಕಾರ್ಯ ಜ್ಞಾಪನೆಗಳು';

  @override
  String get notifTaskChannelDesc => 'ನಿಮ್ಮ ಕಾರ್ಯಗಳಿಗಾಗಿ ಜ್ಞಾಪನೆಗಳು';

  @override
  String get notifMessagesChannel => 'ಸಂದೇಶಗಳು';

  @override
  String get notifMessagesChannelDesc => 'ನಿಮ್ಮ ಸಂಪರ್ಕಗಳಿಂದ ಹೊಸ ಸಂದೇಶಗಳು';

  @override
  String get notifStatusChannel => 'ಸಂದೇಶದ ಸ್ಥಿತಿ';

  @override
  String get notifStatusChannelDesc =>
      'ಯಶಸ್ವಿಯಾಗಿ ಕಳುಹಿಸಿದ ಸಂದೇಶಗಳ ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get sentPhoto => 'ಫೋಟೋ ಯಶಸ್ವಿಯಾಗಿ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get sentDocument => 'ದಾಖಲೆ ಯಶಸ್ವಿಯಾಗಿ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get sentContact => 'ಸಂಪರ್ಕ ಯಶಸ್ವಿಯಾಗಿ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get sentMessage => 'ಸಂದೇಶ ಯಶಸ್ವಿಯಾಗಿ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get justNow => 'ಇದೀಗ';

  @override
  String minutesAgo(int minutes) {
    return '$minutes ನಿಮಿಷಗಳ ಹಿಂದೆ';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ಗಂಟೆಗಳ ಹಿಂದೆ';
  }

  @override
  String get photoTooLarge =>
      'ಫೋಟೋ ತುಂಬಾ ದೊಡ್ಡದಾಗಿದೆ. ದಯವಿಟ್ಟು ಚಿಕ್ಕದನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get statusText => 'ಪಠ್ಯ';

  @override
  String get addStatusTitle => 'ಸ್ಟೇಟಸ್ ಸೇರಿಸಿ';

  @override
  String get myStatus => 'ನನ್ನ ಸ್ಟೇಟಸ್';

  @override
  String get tapToAddStatus => 'ಸ್ಟೇಟಸ್ ಅಪ್‌ಡೇಟ್ ಸೇರಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get recentUpdates => 'ಇತ್ತೀಚಿನ ಅಪ್‌ಡೇಟ್‌ಗಳು';

  @override
  String get viewedUpdates => 'ನೋಡಿದ ಅಪ್‌ಡೇಟ್‌ಗಳು';

  @override
  String get noRecentUpdates =>
      'ಇತ್ತೀಚಿನ ಅಪ್‌ಡೇಟ್‌ಗಳಿಲ್ಲ.\nನಿಮ್ಮ ಸಂಪರ್ಕಗಳ ಸ್ಟೇಟಸ್‌ಗಳು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ ಮತ್ತು ಸ್ವಲ್ಪ ಸಮಯದ ನಂತರ ಮಾಯವಾಗುತ್ತವೆ.';

  @override
  String get addStatusTooltip => 'ಸ್ಟೇಟಸ್ ಸೇರಿಸಿ';

  @override
  String get textStatusTooltip => 'ಪಠ್ಯ ಸ್ಟೇಟಸ್';

  @override
  String get photoStatusTooltip => 'ಫೋಟೋ ಸ್ಟೇಟಸ್';

  @override
  String get couldNotOpenCameraOrGallery =>
      'ಕ್ಯಾಮೆರಾ ಅಥವಾ ಗ್ಯಾಲರಿ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String statusUpdatesLine(int count, String timeAgo) {
    return '$count ಅಪ್‌ಡೇಟ್‌ಗಳು · $timeAgo';
  }

  @override
  String get typeSomethingFirst => 'ಮೊದಲು ಏನಾದರೂ ಟೈಪ್ ಮಾಡಿ';

  @override
  String get statusOfflineQueued =>
      'ಇಂಟರ್ನೆಟ್ ಇಲ್ಲ. ನೀವು ಮತ್ತೆ ಆನ್‌ಲೈನ್ ಆದಾಗ ನಿಮ್ಮ ಸ್ಟೇಟಸ್ ಪೋಸ್ಟ್ ಆಗುತ್ತದೆ.';

  @override
  String get addCaption => 'ಶೀರ್ಷಿಕೆ ಸೇರಿಸಿ...';

  @override
  String get typeAStatus => 'ಸ್ಟೇಟಸ್ ಟೈಪ್ ಮಾಡಿ';

  @override
  String get changeColour => 'ಬಣ್ಣ ಬದಲಾಯಿಸಿ';

  @override
  String get deleteStatus => 'ಸ್ಟೇಟಸ್ ಅಳಿಸಿ';

  @override
  String get noViewsYet => 'ಇನ್ನೂ ವೀಕ್ಷಣೆಗಳಿಲ್ಲ';

  @override
  String get couldNotLoadPhoto => 'ಈ ಫೋಟೋ ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String viewedBy(int count) {
    return '$count ಜನರು ನೋಡಿದ್ದಾರೆ';
  }

  @override
  String get createTask => 'ಕಾರ್ಯ ರಚಿಸಿ';

  @override
  String get editTask => 'ಕಾರ್ಯ ಸಂಪಾದಿಸಿ';

  @override
  String get assignTo => 'ನಿಯೋಜಿಸಿ';

  @override
  String get mePersonalTask => 'ನಾನು (ವೈಯಕ್ತಿಕ ಕಾರ್ಯ)';

  @override
  String get noSavedContactsAddFirst =>
      'ಇನ್ನೂ ಯಾವುದೇ ಸಂಪರ್ಕ ಉಳಿಸಿಲ್ಲ. ಮೊದಲು ಸಂಪರ್ಕ ಸೇರಿಸಿ.';

  @override
  String get titleLabel => 'ಶೀರ್ಷಿಕೆ';

  @override
  String get taskTitleHint => 'ಕಾರ್ಯದ ಶೀರ್ಷಿಕೆ';

  @override
  String get descriptionOptional => 'ವಿವರಣೆ (ಐಚ್ಛಿಕ)';

  @override
  String get addMoreDetails => 'ಹೆಚ್ಚಿನ ವಿವರ ಸೇರಿಸಿ';

  @override
  String get dueDateTime => 'ನಿಗದಿತ ದಿನಾಂಕ ಮತ್ತು ಸಮಯ';

  @override
  String get reminderLabelText => 'ಜ್ಞಾಪನೆ';

  @override
  String reminderFor(String name) {
    return '$name ಗಾಗಿ ಜ್ಞಾಪನೆ';
  }

  @override
  String reminderGoesToThem(String name) {
    return '$name ಅವರ ಫೋನ್‌ನಲ್ಲಿ ಈ ಜ್ಞಾಪನೆ ಬರುತ್ತದೆ.';
  }

  @override
  String get saveChanges => 'ಬದಲಾವಣೆ ಉಳಿಸಿ';

  @override
  String get assignTask => 'ಕಾರ್ಯ ನಿಯೋಜಿಸಿ';

  @override
  String get saveTask => 'ಕಾರ್ಯ ಉಳಿಸಿ';

  @override
  String get couldNotSaveTask =>
      'ಕಾರ್ಯ ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಮತ್ತು ಡೇಟಾಬೇಸ್ ನಿಯಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String assignedSuccess(String name) {
    return '$name ಗೆ ನಿಯೋಜಿಸಲಾಗಿದೆ. ಅದು ಅವರ ನನ್ನ ಕಾರ್ಯಗಳಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.';
  }

  @override
  String get taskSavedSuccess => 'ನಿಮ್ಮ ಕಾರ್ಯವನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get taskUpdated => 'ಕಾರ್ಯ ನವೀಕರಿಸಲಾಗಿದೆ!';

  @override
  String get taskAssigned => 'ಕಾರ್ಯ ನಿಯೋಜಿಸಲಾಗಿದೆ!';

  @override
  String get taskCreated => 'ಕಾರ್ಯ ರಚಿಸಲಾಗಿದೆ!';

  @override
  String get noReminderScheduled =>
      'ಯಾವುದೇ ಜ್ಞಾಪನೆ ನಿಗದಿಪಡಿಸಲಾಗಿಲ್ಲ: ಜ್ಞಾಪನೆಯ ಸಮಯ ಈಗಾಗಲೇ ಮುಗಿದಿದೆ, ಅಥವಾ ಅಧಿಸೂಚನೆಗಳು ಆಫ್ ಆಗಿವೆ.';

  @override
  String get ok => 'ಸರಿ';

  @override
  String get enterTitle => 'ದಯವಿಟ್ಟು ಶೀರ್ಷಿಕೆ ನಮೂದಿಸಿ';

  @override
  String get titleTooLong => 'ಶೀರ್ಷಿಕೆ ತುಂಬಾ ಉದ್ದವಾಗಿದೆ';

  @override
  String get descTooLong => 'ವಿವರಣೆ ತುಂಬಾ ಉದ್ದವಾಗಿದೆ';

  @override
  String get newTask => 'ಹೊಸ ಕಾರ್ಯ';

  @override
  String get edit => 'ಸಂಪಾದಿಸಿ';

  @override
  String get deleteTaskTitle => 'ಕಾರ್ಯ ಅಳಿಸುವುದೇ?';

  @override
  String get deleteTaskBody => 'ಈ ಕಾರ್ಯ ಮತ್ತು ಅದರ ಜ್ಞಾಪನೆಯನ್ನು ತೆಗೆಯಲಾಗುತ್ತದೆ.';

  @override
  String get taskDeleted => 'ಕಾರ್ಯ ಅಳಿಸಲಾಗಿದೆ';

  @override
  String get taskCompleted => 'ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get noReminder => 'ಜ್ಞಾಪನೆ ಇಲ್ಲ';

  @override
  String get pleaseLogInTasks =>
      'ನಿಮ್ಮ ಕಾರ್ಯಗಳನ್ನು ನೋಡಲು ದಯವಿಟ್ಟು ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get couldNotLoadTasks =>
      'ಕಾರ್ಯಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಮತ್ತು ಡೇಟಾಬೇಸ್ ನಿಯಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get emptyAssignedToMe => 'ನಿಮಗೆ ಇನ್ನೂ ಯಾವುದೂ ನಿಯೋಜಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get emptyAssignedByMe =>
      'ನೀವು ಇನ್ನೂ ಯಾವುದೇ ಕಾರ್ಯ ನಿಯೋಜಿಸಿಲ್ಲ.\nಚಾಟ್ ಸಂದೇಶವನ್ನು ಒತ್ತಿ ಹಿಡಿದು \'ಕಾರ್ಯ ರಚಿಸಿ\' ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get emptyNoTasks =>
      'ಇನ್ನೂ ಕಾರ್ಯಗಳಿಲ್ಲ.\nಚಾಟ್ ಸಂದೇಶವನ್ನು ಒತ್ತಿ ಹಿಡಿದು \'ಕಾರ್ಯ ರಚಿಸಿ\' ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get emptyList => 'ಈ ಪಟ್ಟಿಯಲ್ಲಿ ಕಾರ್ಯಗಳಿಲ್ಲ.';

  @override
  String filterAll(int count) {
    return 'ಎಲ್ಲಾ ($count)';
  }

  @override
  String filterUpcoming(int count) {
    return 'ಮುಂಬರುವ ($count)';
  }

  @override
  String filterCompleted(int count) {
    return 'ಪೂರ್ಣಗೊಂಡ ($count)';
  }

  @override
  String filterAssignedToMe(int count) {
    return 'ನನಗೆ ನಿಯೋಜಿಸಿದ ($count)';
  }

  @override
  String filterAssignedByMe(int count) {
    return 'ನಾನು ನಿಯೋಜಿಸಿದ ($count)';
  }

  @override
  String doneBy(String name) {
    return '$name ಮಾಡಿದ್ದಾರೆ';
  }

  @override
  String waitingFor(String name) {
    return '$name ಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ';
  }

  @override
  String reminderPrefix(String label) {
    return 'ಜ್ಞಾಪನೆ: $label';
  }

  @override
  String assignedByLine(String name) {
    return '$name ನಿಯೋಜಿಸಿದ್ದಾರೆ';
  }

  @override
  String assignedToLine(String name) {
    return '$name ಗೆ ನಿಯೋಜಿಸಲಾಗಿದೆ';
  }

  @override
  String fromLine(String name) {
    return 'ಇವರಿಂದ: $name';
  }

  @override
  String deleteTaskAssignedBody(String name) {
    return 'ಈ ಕಾರ್ಯವನ್ನು ನಿಮಗೆ ಮತ್ತು $name ಅವರಿಗೆ ತೆಗೆಯಲಾಗುತ್ತದೆ.';
  }

  @override
  String get couldNotUpdateTask =>
      'ಕಾರ್ಯ ನವೀಕರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get couldNotDeleteTask =>
      'ಕಾರ್ಯ ಅಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get reminderAtDue => 'ನಿಗದಿತ ಸಮಯದಲ್ಲಿ';

  @override
  String get reminder10Min => '10 ನಿಮಿಷ ಮೊದಲು';

  @override
  String get reminder1Hour => '1 ಗಂಟೆ ಮೊದಲು';

  @override
  String get reminder2Hours => '2 ಗಂಟೆ ಮೊದಲು';

  @override
  String get reminder1Day => '1 ದಿನ ಮೊದಲು';

  @override
  String get dueNow => 'ಈಗ ನಿಗದಿಯಾಗಿದೆ';

  @override
  String dueOn(String date, String time) {
    return 'ನಿಗದಿ: $date, $time';
  }

  @override
  String newTaskFrom(String who) {
    return '$who ಅವರಿಂದ ಹೊಸ ಕಾರ್ಯ';
  }

  @override
  String get aContact => 'ಒಬ್ಬ ಸಂಪರ್ಕ';

  @override
  String get someone => 'ಯಾರೋ';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get groupNameTitle => 'ಗುಂಪಿನ ಹೆಸರು';

  @override
  String get changeGroupName => 'ಗುಂಪಿನ ಹೆಸರು ಬದಲಾಯಿಸಿ';

  @override
  String get addMembers => 'ಸದಸ್ಯರನ್ನು ಸೇರಿಸಿ';

  @override
  String get groupAdminBadge => 'ಗುಂಪಿನ ನಿರ್ವಾಹಕ';

  @override
  String get removeFromGroup => 'ಗುಂಪಿನಿಂದ ತೆಗೆಯಿರಿ';

  @override
  String get removeAction => 'ತೆಗೆಯಿರಿ';

  @override
  String get removeMemberBody =>
      'ಅವರು ಈ ಗುಂಪಿನಿಂದ ಹೊಸ ಸಂದೇಶಗಳನ್ನು ಸ್ವೀಕರಿಸುವುದಿಲ್ಲ.';

  @override
  String get exitGroup => 'ಗುಂಪಿನಿಂದ ನಿರ್ಗಮಿಸಿ';

  @override
  String get exitGroupTitle => 'ಗುಂಪಿನಿಂದ ನಿರ್ಗಮಿಸುವುದೇ?';

  @override
  String get exitAction => 'ನಿರ್ಗಮಿಸಿ';

  @override
  String get exitGroupBody =>
      'ನೀವು ಇನ್ನು ಮುಂದೆ ಈ ಗುಂಪಿನಿಂದ ಸಂದೇಶಗಳನ್ನು ಸ್ವೀಕರಿಸುವುದಿಲ್ಲ.';

  @override
  String get disappearingGroupHelp =>
      'ಈ ಗುಂಪಿನ ಹೊಸ ಸಂದೇಶಗಳು ನೀವು ಆರಿಸಿದ ಸಮಯದ ನಂತರ ಮಾಯವಾಗುತ್ತವೆ.';

  @override
  String removeMemberTitle(String name) {
    return '$name ಅವರನ್ನು ತೆಗೆಯುವುದೇ?';
  }

  @override
  String groupMembersLine(int count) {
    return 'ಗುಂಪು · $count ಸದಸ್ಯರು';
  }

  @override
  String get addGroupMembers => 'ಗುಂಪಿನ ಸದಸ್ಯರನ್ನು ಸೇರಿಸಿ';

  @override
  String get noContactsToAdd =>
      'ಸೇರಿಸಲು ಯಾವುದೇ ಸಂಪರ್ಕಗಳಿಲ್ಲ. ಮೊದಲು ಒಂದು ಸಂಪರ್ಕವನ್ನು ಉಳಿಸಿ.';

  @override
  String selectedOf(int selected, int total) {
    return '$total ರಲ್ಲಿ $selected ಆಯ್ಕೆಯಾಗಿದೆ';
  }

  @override
  String get addAName => 'ಹೆಸರು ಸೇರಿಸಿ';

  @override
  String get groupNameHint => 'ಗುಂಪಿನ ಹೆಸರು (ಕಡ್ಡಾಯ)';

  @override
  String get groupNameRequired => 'ದಯವಿಟ್ಟು ಗುಂಪಿನ ಹೆಸರು ಟೈಪ್ ಮಾಡಿ';

  @override
  String membersTitle(int count) {
    return 'ಸದಸ್ಯರು: $count';
  }

  @override
  String get couldNotRenameGroup => 'ಗುಂಪಿನ ಹೆಸರು ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotAddMembers => 'ಸದಸ್ಯರನ್ನು ಸೇರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotRemoveMember => 'ಈ ಸದಸ್ಯರನ್ನು ತೆಗೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotExitGroup => 'ಗುಂಪಿನಿಂದ ನಿರ್ಗಮಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get pleaseLogInAgain => 'ದಯವಿಟ್ಟು ಮತ್ತೆ ಲಾಗಿನ್ ಮಾಡಿ';

  @override
  String get noLongerInGroup => 'ನೀವು ಇನ್ನು ಮುಂದೆ ಈ ಗುಂಪಿನಲ್ಲಿಲ್ಲ';

  @override
  String get member => 'ಸದಸ್ಯ';

  @override
  String get today => 'ಇಂದು';

  @override
  String get forwarded => 'ಫಾರ್ವರ್ಡ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String disappearingNotice(String label) {
    return '⏱ ಮಾಯವಾಗುವ ಸಂದೇಶಗಳು: $label';
  }

  @override
  String get scheduleTitle => 'ಕಳುಹಿಸುವಿಕೆಯನ್ನು ನಿಗದಿಪಡಿಸಿ';

  @override
  String get scheduleTypeFirst => 'ಮೊದಲು ಸಂದೇಶ ಟೈಪ್ ಮಾಡಿ ಅಥವಾ ಚಿತ್ರ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get scheduleInvalid => 'ಭವಿಷ್ಯದ ಸಮಯವನ್ನು ಆರಿಸಿ';

  @override
  String tomorrowDay(String day) {
    return 'ನಾಳೆ, $day';
  }

  @override
  String scheduleToday(String time) {
    return 'ಇಂದು $time ಕ್ಕೆ';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'ನಾಳೆ $time ಕ್ಕೆ';
  }

  @override
  String scheduleOn(String day, String time) {
    return '$day $time ಕ್ಕೆ';
  }

  @override
  String sendAt(String label) {
    return 'ಕಳುಹಿಸಿ $label';
  }

  @override
  String scheduledFor(String label) {
    return 'ಸಂದೇಶವನ್ನು $label ಕ್ಕೆ ನಿಗದಿಪಡಿಸಲಾಗಿದೆ';
  }

  @override
  String get callsNotInGroups => 'ಗುಂಪುಗಳಲ್ಲಿ ಕರೆಗಳು ಇನ್ನೂ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get couldNotIdentifyContact =>
      'ಸಂಪರ್ಕದ ಖಾತೆಯನ್ನು ಗುರುತಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotOpenDialer => 'ಫೋನ್ ಡೈಲರ್ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String noPhoneSaved(String name) {
    return '$name ಗೆ ಫೋನ್ ಸಂಖ್ಯೆ ಉಳಿಸಿಲ್ಲ';
  }

  @override
  String get couldNotOpenCamera =>
      'ಕ್ಯಾಮೆರಾ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಕ್ಯಾಮೆರಾ ಅನುಮತಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get couldNotOpenGallery => 'ಗ್ಯಾಲರಿ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotPickDocument => 'ದಾಖಲೆಯನ್ನು ಆಯ್ಕೆಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotOpenFile => 'ಫೈಲ್ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get attachCamera => 'ಕ್ಯಾಮೆರಾ';

  @override
  String get attachGallery => 'ಗ್ಯಾಲರಿ';

  @override
  String get attachContact => 'ಸಂಪರ್ಕ';

  @override
  String get attachLocation => 'ಸ್ಥಳ';

  @override
  String get locationComingSoon => 'ಸ್ಥಳ ಹಂಚಿಕೆ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ';

  @override
  String get shareContactTitle => 'ಸಂಪರ್ಕ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get forwardToTitle => 'ಇವರಿಗೆ ಫಾರ್ವರ್ಡ್ ಮಾಡಿ...';

  @override
  String get noSavedContacts => 'ಇನ್ನೂ ಯಾವುದೇ ಸಂಪರ್ಕ ಉಳಿಸಿಲ್ಲ';

  @override
  String get searchNameOrNumber => 'ಹೆಸರು ಅಥವಾ ಸಂಖ್ಯೆ ಹುಡುಕಿ';

  @override
  String get noContactFound => 'ಯಾವುದೇ ಸಂಪರ್ಕ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get selectContacts => 'ಸಂಪರ್ಕಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String sendToCount(int count) {
    return '$count ಜನರಿಗೆ ಕಳುಹಿಸಿ';
  }

  @override
  String get cardMessage => 'ಸಂದೇಶ';

  @override
  String get alreadyInContacts => 'ಈಗಾಗಲೇ ನಿಮ್ಮ ಸಂಪರ್ಕಗಳಲ್ಲಿದೆ';

  @override
  String get ownNumber => 'ಇದು ನಿಮ್ಮ ಸ್ವಂತ ಸಂಖ್ಯೆ';

  @override
  String get contactSavedShort => 'ಸಂಪರ್ಕ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get couldNotSaveContact =>
      'ಸಂಪರ್ಕ ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಡೇಟಾಬೇಸ್ ನಿಯಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get waitUntilSent => 'ಸಂದೇಶ ಕಳುಹಿಸುವವರೆಗೆ ಕಾಯಿರಿ';

  @override
  String get messageForwarded => 'ಸಂದೇಶ ಫಾರ್ವರ್ಡ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String forwardedToCount(int done, int total) {
    return '$total ಸಂಪರ್ಕಗಳಲ್ಲಿ $done ಕ್ಕೆ ಫಾರ್ವರ್ಡ್ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String get voiceLanguageTitle => 'ಧ್ವನಿ ಟೈಪಿಂಗ್ ಭಾಷೆ';

  @override
  String get voiceLanguageHelp =>
      'ಮೈಕ್ ಒಂದು ಸಮಯದಲ್ಲಿ ಒಂದು ಭಾಷೆಯನ್ನು ಮಾತ್ರ ಕೇಳುತ್ತದೆ. ನೀವು ಮಾತನಾಡುವ ಭಾಷೆಯನ್ನು ಆರಿಸಿ.';

  @override
  String get listening => 'ಆಲಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String voiceLanguageChosen(String name) {
    return 'ಧ್ವನಿ ಟೈಪಿಂಗ್ ಭಾಷೆ: $name';
  }

  @override
  String listeningIn(String name) {
    return '$name ನಲ್ಲಿ ಆಲಿಸಲಾಗುತ್ತಿದೆ...';
  }

  @override
  String get reply => 'ಉತ್ತರಿಸಿ';

  @override
  String get forward => 'ಫಾರ್ವರ್ಡ್';

  @override
  String get tryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get copy => 'ನಕಲಿಸಿ';

  @override
  String get copied => 'ನಕಲಿಸಲಾಗಿದೆ';

  @override
  String get messageDeleted => 'ಸಂದೇಶ ಅಳಿಸಲಾಗಿದೆ';

  @override
  String get clearChatTitle => 'ಚಾಟ್ ತೆರವುಗೊಳಿಸುವುದೇ?';

  @override
  String get clear => 'ತೆರವುಗೊಳಿಸಿ';

  @override
  String clearGroupBody(String title) {
    return '$title ನಲ್ಲಿರುವ ಎಲ್ಲಾ ಸಂದೇಶಗಳನ್ನು ಎಲ್ಲರಿಗೂ ಅಳಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String clearChatBody(String name) {
    return '$name ಜೊತೆಗಿನ ಎಲ್ಲಾ ಸಂದೇಶಗಳನ್ನು ಅಳಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String get couldNotLoadMessages =>
      'ಸಂದೇಶಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ Firebase Realtime Database ನಿಯಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get noMessagesYet => 'ಇನ್ನೂ ಸಂದೇಶಗಳಿಲ್ಲ\nಹಾಯ್ ಹೇಳಿ 👋';

  @override
  String get messageHint => 'ಸಂದೇಶ';

  @override
  String get photoAttached => 'ಫೋಟೋ ಲಗತ್ತಿಸಲಾಗಿದೆ';

  @override
  String get removePhoto => 'ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get groupInfo => 'ಗುಂಪಿನ ಮಾಹಿತಿ';

  @override
  String get viewProfile => 'ಪ್ರೊಫೈಲ್ ನೋಡಿ';

  @override
  String get searchHint => 'ಹುಡುಕಿ...';

  @override
  String get noResults => 'ಫಲಿತಾಂಶಗಳಿಲ್ಲ';

  @override
  String matchOf(int current, int total) {
    return '$total ರಲ್ಲಿ $current';
  }

  @override
  String get couldNotSendMessage =>
      'ಸಂದೇಶ ಕಳುಹಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get couldNotScheduleMessage =>
      'ಸಂದೇಶವನ್ನು ನಿಗದಿಪಡಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get nothingToSend => 'ಕಳುಹಿಸಲು ಏನೂ ಇಲ್ಲ';

  @override
  String get imageTooLarge =>
      'ಚಿತ್ರ ತುಂಬಾ ದೊಡ್ಡದಾಗಿದೆ. ದಯವಿಟ್ಟು ಚಿಕ್ಕ ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get couldNotShareContact =>
      'ಸಂಪರ್ಕವನ್ನು ಹಂಚಿಕೊಳ್ಳಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get documentsOnlineOnly =>
      'ನೀವು ಆನ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದಾಗ ಮಾತ್ರ ದಾಖಲೆಗಳನ್ನು ಕಳುಹಿಸಬಹುದು.';

  @override
  String get couldNotSaveAttachment =>
      'ಲಗತ್ತನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get couldNotDeleteMessage => 'ಸಂದೇಶ ಅಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotClearChat => 'ಚಾಟ್ ತೆರವುಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get reactionFailed =>
      'ಪ್ರತಿಕ್ರಿಯೆ ಸೇರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಡೇಟಾಬೇಸ್ ನಿಯಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String voiceNoSpeech(String language) {
    return '$language ನಲ್ಲಿ ನನಗೆ ಏನೂ ಕೇಳಿಸಲಿಲ್ಲ. ಮೈಕ್ ಟ್ಯಾಪ್ ಮಾಡಿ ಸ್ಪಷ್ಟವಾಗಿ ಮಾತನಾಡಿ, ಅಥವಾ ಭಾಷೆ ಬದಲಾಯಿಸಿ (ಮೈಕ್ ಅನ್ನು ಒತ್ತಿ ಹಿಡಿಯಿರಿ).';
  }

  @override
  String get micPermission => 'ದಯವಿಟ್ಟು ಈ ಅಪ್ಲಿಕೇಶನ್‌ಗೆ ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ನೀಡಿ';

  @override
  String voiceLangNotReady(String language) {
    return 'ಈ ಫೋನ್‌ನಲ್ಲಿ $language ಧ್ವನಿ ಟೈಪಿಂಗ್ ಸಿದ್ಧವಾಗಿಲ್ಲ.\nಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿಸಿ, ಅಥವಾ ಫೋನ್‌ನ Google ಧ್ವನಿ ಟೈಪಿಂಗ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ $language ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';
  }

  @override
  String voiceNetworkError(String error, String language) {
    return 'ಧ್ವನಿ ದೋಷ: $error\nನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ, ಅಥವಾ ಆಫ್‌ಲೈನ್ ಬಳಕೆಗಾಗಿ ಫೋನ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ $language ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ, ಅಥವಾ ನಿಮ್ಮ ಸಂದೇಶ ಟೈಪ್ ಮಾಡಿ.';
  }

  @override
  String speechError(String error) {
    return 'ಮಾತಿನ ದೋಷ: $error';
  }

  @override
  String get micPermissionNeeded =>
      'ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಅಗತ್ಯವಿದೆ. ಅಪ್ಲಿಕೇಶನ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅನುಮತಿಸಿ.';

  @override
  String get you => 'ನೀವು';

  @override
  String get attachDocument => 'ದಾಖಲೆ';

  @override
  String get clearChat => 'ಚಾಟ್ ತೆರವುಗೊಳಿಸಿ';

  @override
  String get mediaLinksDocs => 'ಮಾಧ್ಯಮ, ಲಿಂಕ್‌ಗಳು ಮತ್ತು ದಾಖಲೆಗಳು';

  @override
  String get disappearingTitle => 'ಮಾಯವಾಗುವ ಸಂದೇಶಗಳು';

  @override
  String get disappearOff => 'ಆಫ್';

  @override
  String get disappear5Min => '5 ನಿಮಿಷಗಳು';

  @override
  String get disappear1Day => '1 ದಿನ';

  @override
  String get disappear7Days => '7 ದಿನಗಳು';

  @override
  String get contactInfoTitle => 'ಸಂಪರ್ಕ ಮಾಹಿತಿ';

  @override
  String get phoneUnavailable => 'ಫೋನ್ ಸಂಖ್ಯೆ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get actionAudio => 'ಆಡಿಯೋ';

  @override
  String get actionVideo => 'ವೀಡಿಯೊ';

  @override
  String get mediaVisibility => 'ಮಾಧ್ಯಮ ಗೋಚರತೆ';

  @override
  String get encryption => 'ಎನ್‌ಕ್ರಿಪ್ಶನ್';

  @override
  String get encryptionSub =>
      'ಸಂದೇಶಗಳು ಮತ್ತು ಕರೆಗಳು ಇನ್ನೂ ಎಂಡ್-ಟು-ಎಂಡ್ ಎನ್‌ಕ್ರಿಪ್ಟ್ ಆಗಿಲ್ಲ.';

  @override
  String get blockContact => 'ಸಂಪರ್ಕ ನಿರ್ಬಂಧಿಸಿ';

  @override
  String get disappearingChatHelp =>
      'ಈ ಚಾಟ್‌ನ ಹೊಸ ಸಂದೇಶಗಳು ನೀವು ಆರಿಸಿದ ಸಮಯದ ನಂತರ ಮಾಯವಾಗುತ್ತವೆ.';

  @override
  String get couldNotChangeSetting =>
      'ಸೆಟ್ಟಿಂಗ್ ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get notificationSettingsMsg => 'ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get mediaVisibilitySettingsMsg => 'ಮಾಧ್ಯಮ ಗೋಚರತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get encryptionMsg =>
      'ಈ ಅಪ್ಲಿಕೇಶನ್ ಪ್ರಸ್ತುತ ಎಂಡ್-ಟು-ಎಂಡ್ ಎನ್‌ಕ್ರಿಪ್ಶನ್ ಅಳವಡಿಸಿಲ್ಲ.';

  @override
  String get blockingNotImplemented =>
      'ಸಂಪರ್ಕ ನಿರ್ಬಂಧಿಸುವುದನ್ನು ಇನ್ನೂ ಅಳವಡಿಸಿಲ್ಲ.';

  @override
  String get calling => 'ಕರೆ ಮಾಡಲಾಗುತ್ತಿದೆ...';

  @override
  String get videoCalling => 'ವೀಡಿಯೊ ಕರೆ ಮಾಡಲಾಗುತ್ತಿದೆ...';

  @override
  String get callSpeaker => 'ಸ್ಪೀಕರ್';

  @override
  String get callMute => 'ಮ್ಯೂಟ್';

  @override
  String get callFlip => 'ತಿರುಗಿಸಿ';

  @override
  String get callMore => 'ಇನ್ನಷ್ಟು';

  @override
  String get callShare => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get callEnd => 'ಕೊನೆಗೊಳಿಸಿ';

  @override
  String get addPeopleSoon => 'ಜನರನ್ನು ಸೇರಿಸುವುದು ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ';

  @override
  String get moreOptionsSoon => 'ಹೆಚ್ಚಿನ ಆಯ್ಕೆಗಳು ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿವೆ';

  @override
  String get sharingSoon => 'ಹಂಚಿಕೆ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ';

  @override
  String get noCameraFound => 'ಈ ಸಾಧನದಲ್ಲಿ ಕ್ಯಾಮೆರಾ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get cameraPermissionDenied =>
      'ಕ್ಯಾಮೆರಾ ಅನುಮತಿ ನಿರಾಕರಿಸಲಾಗಿದೆ. ಅಪ್ಲಿಕೇಶನ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅನುಮತಿಸಿ.';

  @override
  String get callCouldNotOpenCamera => 'ಕ್ಯಾಮೆರಾ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get nothingToOpen => 'ಇಲ್ಲಿ ತೆರೆಯಲು ಏನೂ ಇಲ್ಲ';

  @override
  String get couldNotOpenThis => 'ಇದನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get tabMedia => 'ಮಾಧ್ಯಮ';

  @override
  String get tabDocs => 'ದಾಖಲೆಗಳು';

  @override
  String get tabLinks => 'ಲಿಂಕ್‌ಗಳು';

  @override
  String get noPhotosYet => 'ಇನ್ನೂ ಯಾವುದೇ ಫೋಟೋ ಹಂಚಿಕೊಂಡಿಲ್ಲ';

  @override
  String get noDocsYet => 'ಇನ್ನೂ ಯಾವುದೇ ದಾಖಲೆ ಹಂಚಿಕೊಂಡಿಲ್ಲ';

  @override
  String get noLinksYet => 'ಇನ್ನೂ ಯಾವುದೇ ಲಿಂಕ್ ಹಂಚಿಕೊಂಡಿಲ್ಲ';

  @override
  String get couldNotLoadMedia =>
      'ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ Firebase Realtime Database ನಿಯಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String sharedBy(String who, String date) {
    return '$who  •  $date';
  }

  @override
  String linkSubtitle(String title, String who, String date) {
    return '$title\n$who  •  $date';
  }

  @override
  String get waitingOne => '1 ಸಂದೇಶ ಕಳುಹಿಸಲು ಕಾಯುತ್ತಿದೆ.';

  @override
  String waitingMany(int count) {
    return '$count ಸಂದೇಶಗಳು ಕಳುಹಿಸಲು ಕಾಯುತ್ತಿವೆ.';
  }

  @override
  String offlineWithPending(String waiting) {
    return 'ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ. $waiting';
  }

  @override
  String get offlineNoPending =>
      'ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಆನ್ ಮಾಡಿ.';

  @override
  String connectingWithPending(String waiting) {
    return 'ಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ... $waiting';
  }

  @override
  String get connecting => 'ಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get backOnlineSending =>
      'ಮತ್ತೆ ಆನ್‌ಲೈನ್ ಆಗಿದ್ದೀರಿ. ನಿಮ್ಮ ಸಂದೇಶಗಳನ್ನು ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get backOnline => 'ನೀವು ಮತ್ತೆ ಆನ್‌ಲೈನ್ ಆಗಿದ್ದೀರಿ.';

  @override
  String get saveContact => 'ಸಂಪರ್ಕ ಉಳಿಸಿ';

  @override
  String get addContactTitle => 'ಸಂಪರ್ಕ ಸೇರಿಸಿ';

  @override
  String get addContactSubtitle =>
      'ನೋಂದಾಯಿತ ಇಮೇಲ್ ನಮೂದಿಸಿ, ಉಳಿದದ್ದು ತಾನಾಗಿ ತುಂಬುತ್ತದೆ.';

  @override
  String get contactNameLabel => 'ಬಳಕೆದಾರರ ಹೆಸರು';

  @override
  String get registeredEmailLabel => 'ನೋಂದಾಯಿತ ಇಮೇಲ್ ವಿಳಾಸ';

  @override
  String get userFound => 'ನೋಂದಾಯಿತ ಬಳಕೆದಾರರು ಕಂಡುಬಂದಿದ್ದಾರೆ';

  @override
  String get userFoundNoPhone =>
      'ನೋಂದಾಯಿತ ಬಳಕೆದಾರರು ಕಂಡುಬಂದಿದ್ದಾರೆ. ಅವರು ಫೋನ್ ಸಂಖ್ಯೆ ಸೇರಿಸಿಲ್ಲ, ದಯವಿಟ್ಟು ಕೆಳಗೆ ಟೈಪ್ ಮಾಡಿ.';

  @override
  String get userNotFound => 'ಈ ಇಮೇಲ್‌ನೊಂದಿಗೆ ನೋಂದಾಯಿತ ಬಳಕೆದಾರರು ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get cannotAddSelf => 'ನೀವು ನಿಮ್ಮ ಸ್ವಂತ ಖಾತೆಯನ್ನು ಸೇರಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get lookupFailed => 'ಈ ಇಮೇಲ್ ಅನ್ನು ಹುಡುಕಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';

  @override
  String get lookupFailedInternet =>
      'ಈ ಇಮೇಲ್ ಅನ್ನು ಹುಡುಕಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ.';

  @override
  String userFoundName(String name) {
    return 'ನೋಂದಾಯಿತ ಬಳಕೆದಾರರು ಕಂಡುಬಂದಿದ್ದಾರೆ: $name';
  }

  @override
  String lookupFailedCode(String code) {
    return 'ಈ ಇಮೇಲ್ ಅನ್ನು ಹುಡುಕಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ ($code).';
  }

  @override
  String get enterContactName => 'ಬಳಕೆದಾರರ ಹೆಸರು ನಮೂದಿಸಿ';

  @override
  String get nameTooShort => 'ಹೆಸರು ಕನಿಷ್ಠ 4 ಅಕ್ಷರಗಳಿರಬೇಕು';

  @override
  String get nameTooLong => 'ಹೆಸರು ಗರಿಷ್ಠ 40 ಅಕ್ಷರಗಳಿರಬೇಕು';

  @override
  String get enterRegisteredEmail => 'ನೋಂದಾಯಿತ ಇಮೇಲ್ ವಿಳಾಸ ನಮೂದಿಸಿ';

  @override
  String get enterValidEmail => 'ಮಾನ್ಯವಾದ ಇಮೇಲ್ ವಿಳಾಸ ನಮೂದಿಸಿ';

  @override
  String get loginAgainToSave =>
      'ಸಂಪರ್ಕಗಳನ್ನು ಉಳಿಸುವ ಮೊದಲು ದಯವಿಟ್ಟು ಮತ್ತೆ ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get userAlreadyInContacts =>
      'ಈ ಬಳಕೆದಾರರು ಈಗಾಗಲೇ ನಿಮ್ಮ ಸಂಪರ್ಕಗಳಲ್ಲಿದ್ದಾರೆ.';

  @override
  String get firebaseDenied =>
      'Firebase ಪ್ರವೇಶ ನಿರಾಕರಿಸಿದೆ. ನಿಮ್ಮ ಡೇಟಾಬೇಸ್ ನಿಯಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get unknownError => 'ಅಜ್ಞಾತ ದೋಷ';

  @override
  String firebaseError(String code, String message) {
    return 'Firebase ದೋಷ ($code): $message';
  }

  @override
  String get profileTitle => 'ಪ್ರೊಫೈಲ್';

  @override
  String get nameLabel => 'ಹೆಸರು';

  @override
  String get phoneLabel => 'ಫೋನ್';

  @override
  String get notAdded => 'ಸೇರಿಸಿಲ್ಲ';

  @override
  String get saveName => 'ಹೆಸರು ಉಳಿಸಿ';

  @override
  String get profileNameUpdated => 'ಹೆಸರು ನವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get nameSavedNote =>
      'ನಿಮ್ಮನ್ನು ಉಳಿಸಿಕೊಂಡವರು ತಾವು ಆರಿಸಿದ ಹೆಸರನ್ನೇ ಉಳಿಸಿಕೊಳ್ಳುತ್ತಾರೆ.';

  @override
  String get enterYourName => 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಹೆಸರು ನಮೂದಿಸಿ';

  @override
  String get pleaseLogInBeforePicture =>
      'ಚಿತ್ರ ಬದಲಾಯಿಸುವ ಮೊದಲು ದಯವಿಟ್ಟು ಮತ್ತೆ ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get pictureTooLarge =>
      'ಈ ಚಿತ್ರ ತುಂಬಾ ದೊಡ್ಡದಾಗಿದೆ. ದಯವಿಟ್ಟು ಚಿಕ್ಕ ಚಿತ್ರ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get youAreOfflineTryAgain =>
      'ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ. ಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String profileUpdateFailed(String error) {
    return 'ಪ್ರೊಫೈಲ್ ನವೀಕರಣ ವಿಫಲವಾಯಿತು: $error';
  }

  @override
  String get pleaseLogInBeforeName =>
      'ಹೆಸರು ಬದಲಾಯಿಸುವ ಮೊದಲು ದಯವಿಟ್ಟು ಮತ್ತೆ ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get serverNoAnswer =>
      'ಸರ್ವರ್ ಪ್ರತಿಕ್ರಿಯಿಸಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String couldNotSaveNameCode(String code) {
    return 'ನಿಮ್ಮ ಹೆಸರನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ ($code). ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get couldNotSaveName =>
      'ನಿಮ್ಮ ಹೆಸರನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get yesterday => 'ನಿನ್ನೆ';

  @override
  String get videoCallNoAnswer => 'ವೀಡಿಯೊ ಕರೆ · ಉತ್ತರವಿಲ್ಲ';

  @override
  String get missedVideoCall => 'ತಪ್ಪಿದ ವೀಡಿಯೊ ಕರೆ';

  @override
  String youPrefix(String text) {
    return 'ನೀವು: $text';
  }

  @override
  String get deleteChatTitle => 'ಚಾಟ್ ಅಳಿಸುವುದೇ?';

  @override
  String deleteChatsTitle(int count) {
    return '$count ಚಾಟ್‌ಗಳನ್ನು ಅಳಿಸುವುದೇ?';
  }

  @override
  String get deleteChatBody =>
      'ಚಾಟ್ ಅನ್ನು ನಿಮ್ಮ ಪಟ್ಟಿಯಿಂದ ಮಾತ್ರ ತೆಗೆಯಲಾಗುತ್ತದೆ. ಇತರರು ತಮ್ಮ ಸಂದೇಶಗಳನ್ನು ಉಳಿಸಿಕೊಳ್ಳುತ್ತಾರೆ. ಹೊಸ ಸಂದೇಶ ಬಂದರೆ ಚಾಟ್ ಮತ್ತೆ ಕಾಣಿಸುತ್ತದೆ.';

  @override
  String get chatDeleted => 'ಚಾಟ್ ಅಳಿಸಲಾಗಿದೆ';

  @override
  String chatsDeleted(int count) {
    return '$count ಚಾಟ್‌ಗಳನ್ನು ಅಳಿಸಲಾಗಿದೆ';
  }

  @override
  String get couldNotDelete =>
      'ಅಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get newChat => 'ಹೊಸ ಚಾಟ್';

  @override
  String get newGroup => 'ಹೊಸ ಗುಂಪು';

  @override
  String get newContact => 'ಹೊಸ ಸಂಪರ್ಕ';

  @override
  String membersCount(int count) {
    return '$count ಸದಸ್ಯರು';
  }

  @override
  String get tapToStartChatting => 'ಚಾಟ್ ಪ್ರಾರಂಭಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get offlineNoContacts =>
      'ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿದ್ದೀರಿ. ಈ ಸಾಧನದಲ್ಲಿ ಇನ್ನೂ ಯಾವುದೇ ಸಂಪರ್ಕಗಳನ್ನು ಉಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get noChatsYet =>
      'ಇನ್ನೂ ಚಾಟ್‌ಗಳಿಲ್ಲ. ಸಂಪರ್ಕ ಸೇರಿಸಲು ಅಥವಾ ಗುಂಪು ರಚಿಸಲು + ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get updates => 'ಅಪ್‌ಡೇಟ್‌ಗಳು';

  @override
  String get chats => 'ಚಾಟ್‌ಗಳು';

  @override
  String get search => 'ಹುಡುಕಿ';

  @override
  String get closeSearch => 'ಹುಡುಕಾಟ ಮುಚ್ಚಿ';

  @override
  String get myTasks => 'ನನ್ನ ಕಾರ್ಯಗಳು';

  @override
  String get pleaseLogIn => 'ನಿಮ್ಮ ಸಂಪರ್ಕಗಳನ್ನು ನೋಡಲು ದಯವಿಟ್ಟು ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get contactSaved => 'ಸಂಪರ್ಕವನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get searchSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get noSettingsFound => 'ಯಾವುದೇ ಸೆಟ್ಟಿಂಗ್‌ಗಳು ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get addNewContact => 'ಹೊಸ ಸಂಪರ್ಕ ಸೇರಿಸಿ';

  @override
  String get addNewContactSub => 'ಚಾಟ್ ಪ್ರಾರಂಭಿಸಲು ಸಂಪರ್ಕ ಉಳಿಸಿ';

  @override
  String get settingsAccount => 'ಖಾತೆ';

  @override
  String get settingsAccountSub => 'ಭದ್ರತಾ ಅಧಿಸೂಚನೆಗಳು, ಖಾತೆ ಮಾಹಿತಿ';

  @override
  String get settingsPrivacy => 'ಗೌಪ್ಯತೆ';

  @override
  String get settingsPrivacySub => 'ನಿರ್ಬಂಧಿತ ಸಂಪರ್ಕಗಳು, ಮಾಯವಾಗುವ ಸಂದೇಶಗಳು';

  @override
  String get settingsChatsSub => 'ಥೀಮ್, ವಾಲ್‌ಪೇಪರ್, ಚಾಟ್ ಇತಿಹಾಸ';

  @override
  String get settingsNotifications => 'ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get settingsNotificationsSub => 'ಸಂದೇಶ, ಗುಂಪು ಮತ್ತು ಕರೆ ಧ್ವನಿಗಳು';

  @override
  String get settingsStorage => 'ಸಂಗ್ರಹಣೆ ಮತ್ತು ಡೇಟಾ';

  @override
  String get settingsStorageSub => 'ನೆಟ್‌ವರ್ಕ್ ಬಳಕೆ, ಸ್ವಯಂ-ಡೌನ್‌ಲೋಡ್';

  @override
  String get settingsHelp => 'ಸಹಾಯ ಮತ್ತು ಪ್ರತಿಕ್ರಿಯೆ';

  @override
  String get settingsHelpSub => 'ಸಹಾಯ ಕೇಂದ್ರ, ನಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಿ, ಗೌಪ್ಯತಾ ನೀತಿ';

  @override
  String get logOut => 'ಲಾಗ್ ಔಟ್';

  @override
  String get logOutTitle => 'ಲಾಗ್ ಔಟ್ ಮಾಡುವುದೇ?';

  @override
  String get logOutBody =>
      'ನಿಮ್ಮ ಖಾತೆಯಿಂದ ಲಾಗ್ ಔಟ್ ಮಾಡಲು ನೀವು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ?';

  @override
  String get profilePhotoUpdated =>
      'ಪ್ರೊಫೈಲ್ ಚಿತ್ರವನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಸಂಪರ್ಕಗಳು ಈಗ ಅದನ್ನು ನೋಡಬಹುದು.';

  @override
  String get createAccount => 'ಖಾತೆ ರಚಿಸಿ';

  @override
  String get signupSubtitle => 'ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ಇಮೇಲ್‌ನೊಂದಿಗೆ ಸೈನ್ ಅಪ್ ಮಾಡಿ.';

  @override
  String get nickname => 'ಅಡ್ಡಹೆಸರು';

  @override
  String get code => 'ಕೋಡ್';

  @override
  String get phoneNumber => 'ಫೋನ್ ಸಂಖ್ಯೆ';

  @override
  String get confirmPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಖಚಿತಪಡಿಸಿ';

  @override
  String get register => 'ನೋಂದಾಯಿಸಿ';

  @override
  String get haveAccount => 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ?';

  @override
  String get logInLink => 'ಲಾಗಿನ್ ಮಾಡಿ';

  @override
  String get ruleLength => 'ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳು';

  @override
  String get ruleCapital => '1 ದೊಡ್ಡ ಅಕ್ಷರ (A-Z)';

  @override
  String get ruleSmall => '1 ಸಣ್ಣ ಅಕ್ಷರ (a-z)';

  @override
  String get ruleNumber => '1 ಸಂಖ್ಯೆ (0-9)';

  @override
  String get ruleSpecial => '1 ವಿಶೇಷ ಅಕ್ಷರ (! @ # \$ %)';

  @override
  String get enterNickname => 'ದಯವಿಟ್ಟು ಅಡ್ಡಹೆಸರು ನಮೂದಿಸಿ';

  @override
  String get useAtLeast3 => 'ಕನಿಷ್ಠ 3 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ';

  @override
  String get useAtMost20 => 'ಗರಿಷ್ಠ 20 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ';

  @override
  String get enterNewPassword => 'ದಯವಿಟ್ಟು ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String get useAtLeast8 => 'ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ';

  @override
  String get noSpaces => 'ಪಾಸ್‌ವರ್ಡ್‌ನಲ್ಲಿ ಖಾಲಿ ಜಾಗ ಇರಬಾರದು';

  @override
  String get addCapital => '1 ದೊಡ್ಡ ಅಕ್ಷರ ಸೇರಿಸಿ (A-Z)';

  @override
  String get addSmall => '1 ಸಣ್ಣ ಅಕ್ಷರ ಸೇರಿಸಿ (a-z)';

  @override
  String get addNumber => '1 ಸಂಖ್ಯೆ ಸೇರಿಸಿ (0-9)';

  @override
  String get addSpecial => '1 ವಿಶೇಷ ಅಕ್ಷರ ಸೇರಿಸಿ (! @ # \$ % & *)';

  @override
  String get confirmYourPassword => 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಖಚಿತಪಡಿಸಿ';

  @override
  String get passwordsDontMatch => 'ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ';

  @override
  String get emailAlreadyRegistered =>
      'ಈ ಇಮೇಲ್ ಈಗಾಗಲೇ ನೋಂದಾಯಿತವಾಗಿದೆ. ದಯವಿಟ್ಟು ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get weakPassword =>
      'ಈ ಪಾಸ್‌ವರ್ಡ್ ತುಂಬಾ ದುರ್ಬಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಬೇರೆ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get signupNotEnabled =>
      'Firebase ಕನ್ಸೋಲ್‌ನಲ್ಲಿ ಇಮೇಲ್/ಪಾಸ್‌ವರ್ಡ್ ಸೈನ್ ಅಪ್ ಸಕ್ರಿಯಗೊಂಡಿಲ್ಲ.';

  @override
  String get signupFailed =>
      'ಖಾತೆ ರಚಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get createAccountWentWrong =>
      'ಖಾತೆ ರಚಿಸುವಾಗ ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get accountNotCreated =>
      'ಖಾತೆ ರಚಿಸಲಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get phoneAlreadyRegistered =>
      'ಈ ಫೋನ್ ಸಂಖ್ಯೆ ಈಗಾಗಲೇ ಬೇರೆ ಖಾತೆಯೊಂದಿಗೆ ನೋಂದಾಯಿತವಾಗಿದೆ. ದಯವಿಟ್ಟು ಬೇರೆ ಸಂಖ್ಯೆ ಬಳಸಿ.';

  @override
  String get phoneCheckFailed =>
      'ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಪರಿಶೀಲಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get phoneJustTaken =>
      'ಈ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಈಗಷ್ಟೇ ಬೇರೆ ಖಾತೆ ನೋಂದಾಯಿಸಿದೆ. ದಯವಿಟ್ಟು ಬೇರೆ ಸಂಖ್ಯೆ ಬಳಸಿ.';

  @override
  String get phoneSaveFailed =>
      'ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String phoneSaveFailedCode(String code) {
    return 'ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ ($code). ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String get verificationCancelled =>
      'ದೃಢೀಕರಣ ರದ್ದುಗೊಂಡಿದ್ದರಿಂದ ಯಾವುದೇ ಖಾತೆ ರಚಿಸಲಾಗಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get enterPhone => 'ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ';

  @override
  String get digitsOnly => 'ಅಂಕಿಗಳನ್ನು ಮಾತ್ರ ಬಳಸಿ';

  @override
  String get invalidPhone => 'ಮಾನ್ಯವಾದ ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ (6–15 ಅಂಕೆಗಳು)';

  @override
  String get verifyYourEmail => 'ನಿಮ್ಮ ಇಮೇಲ್ ದೃಢೀಕರಿಸಿ';

  @override
  String otpSentTo(String email) {
    return 'ಕಳುಹಿಸಲಾದ 4 ಅಂಕಿಯ ಕೋಡ್ ನಮೂದಿಸಿ\n$email';
  }

  @override
  String get enterAllDigits => 'ಎಲ್ಲಾ 4 ಅಂಕೆಗಳನ್ನು ನಮೂದಿಸಿ';

  @override
  String get wrongOtp => 'ತಪ್ಪಾದ OTP, ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get messages => 'ಸಂದೇಶಗಳು';

  @override
  String get now => 'ಈಗ';

  @override
  String otpMessage(String appName, String code) {
    return 'ನಿಮ್ಮ $appName ದೃಢೀಕರಣ ಕೋಡ್ $code. ಇದನ್ನು ಯಾರೊಂದಿಗೂ ಹಂಚಿಕೊಳ್ಳಬೇಡಿ.';
  }

  @override
  String resendCodeIn(String time) {
    return '$time ನಲ್ಲಿ ಕೋಡ್ ಮತ್ತೆ ಕಳುಹಿಸಿ';
  }

  @override
  String get resendCode => 'ಕೋಡ್ ಮತ್ತೆ ಕಳುಹಿಸಿ';

  @override
  String get verify => 'ದೃಢೀಕರಿಸಿ';

  @override
  String get email => 'ಇಮೇಲ್';

  @override
  String get password => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get backToLogin => 'ಲಾಗಿನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get enterEmail => 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ';

  @override
  String get invalidEmail => 'ಮಾನ್ಯವಾದ ಇಮೇಲ್ ನಮೂದಿಸಿ (ಉದಾಹರಣೆ: name@gmail.com)';

  @override
  String get invalidEmailAddress =>
      'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get tooManyAttempts =>
      'ಹಲವಾರು ಪ್ರಯತ್ನಗಳು. ದಯವಿಟ್ಟು ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get networkError =>
      'ನೆಟ್‌ವರ್ಕ್ ದೋಷ. ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get somethingWentWrong => 'ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get enterPassword => 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String get loginCredentials =>
      'ಇಮೇಲ್ ಅಥವಾ ಪಾಸ್‌ವರ್ಡ್ ತಪ್ಪಾಗಿದೆ. ನೀವು ಹೊಸಬರಾಗಿದ್ದರೆ, ಕೆಳಗೆ ಸೈನ್ ಅಪ್ ಒತ್ತಿರಿ.';

  @override
  String get accountDisabled => 'ಈ ಖಾತೆಯನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ.';

  @override
  String get loginFailed =>
      'ಲಾಗಿನ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get verifyEmailFirst =>
      'ದಯವಿಟ್ಟು ಮೊದಲು ನಿಮ್ಮ ಇಮೇಲ್ ಅನ್ನು ದೃಢೀಕರಿಸಿ. ನಿಮ್ಮ ಇನ್‌ಬಾಕ್ಸ್‌ಗೆ ಕಳುಹಿಸಿದ ಲಿಂಕ್ ತೆರೆಯಿರಿ (ಸ್ಪ್ಯಾಮ್ ಕೂಡ ನೋಡಿ), ನಂತರ ಮತ್ತೆ ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get verificationSent =>
      'ದೃಢೀಕರಣ ಇಮೇಲ್ ಕಳುಹಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಇನ್‌ಬಾಕ್ಸ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get accountVerified => 'ಖಾತೆ ದೃಢೀಕರಿಸಲಾಗಿದೆ. ದಯವಿಟ್ಟು ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get welcomeBack => 'ಮತ್ತೆ ಸ್ವಾಗತ';

  @override
  String get loginSubtitle =>
      'ನಿಮ್ಮ ಇಮೇಲ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್‌ನೊಂದಿಗೆ ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get forgotPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?';

  @override
  String get resendVerification => 'ದೃಢೀಕರಣ ಇಮೇಲ್ ಮತ್ತೆ ಕಳುಹಿಸಿ';

  @override
  String get login => 'ಲಾಗಿನ್';

  @override
  String get noAccount => 'ಖಾತೆ ಇಲ್ಲವೇ?';

  @override
  String get signUp => 'ಸೈನ್ ಅಪ್';

  @override
  String get noAccountFound =>
      'ಈ ಇಮೇಲ್‌ನೊಂದಿಗೆ ಯಾವುದೇ ಖಾತೆ ಕಂಡುಬಂದಿಲ್ಲ. ದಯವಿಟ್ಟು ಸೈನ್ ಅಪ್ ಮಾಡಿ.';

  @override
  String get couldNotSendEmail =>
      'ಇಮೇಲ್ ಕಳುಹಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get forgotSubtitle =>
      'ನಿಮ್ಮ ನೋಂದಾಯಿತ ಇಮೇಲ್ ನಮೂದಿಸಿ, ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆ ಮಾಡಲು ನಾವು ನಿಮಗೆ ಲಿಂಕ್ ಕಳುಹಿಸುತ್ತೇವೆ.';

  @override
  String get sendResetLink => 'ರೀಸೆಟ್ ಲಿಂಕ್ ಕಳುಹಿಸಿ';

  @override
  String get checkInbox => 'ನಿಮ್ಮ ಇನ್‌ಬಾಕ್ಸ್ ಪರಿಶೀಲಿಸಿ';

  @override
  String get resendLink => 'ಲಿಂಕ್ ಮತ್ತೆ ಕಳುಹಿಸಿ';

  @override
  String get changeEmail => 'ಇಮೇಲ್ ಬದಲಾಯಿಸಿ';

  @override
  String resendIn(int seconds) {
    return '$seconds ಸೆಕೆಂಡ್‌ನಲ್ಲಿ ಮತ್ತೆ ಕಳುಹಿಸಿ';
  }

  @override
  String resetLinkSent(String email) {
    return 'ನಾವು $email ಗೆ ರೀಸೆಟ್ ಲಿಂಕ್ ಕಳುಹಿಸಿದ್ದೇವೆ. ಅದನ್ನು ತೆರೆಯಿರಿ, ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆಮಾಡಿ, ನಂತರ ಅದರೊಂದಿಗೆ ಲಾಗಿನ್ ಮಾಡಿ.\n\nಕಾಣುತ್ತಿಲ್ಲವೇ? ನಿಮ್ಮ ಸ್ಪ್ಯಾಮ್ ಫೋಲ್ಡರ್ ಕೂಡ ನೋಡಿ.';
  }

  @override
  String get tagline => 'ಸಂದೇಶ ಕಳುಹಿಸುವುದು, ಸುಂದರವಾಗಿ ಸರಳ.';

  @override
  String get premiumMessaging => 'ಪ್ರೀಮಿಯಂ ಸಂದೇಶ ಸೇವೆ';

  @override
  String get welcomeBody =>
      'ನಿಮಗೆ ಮುಖ್ಯವಾದ ಜನರಿಗಾಗಿ ಖಾಸಗಿ ಚಾಟ್‌ಗಳು, ವೇಗದ ಸಂದೇಶ ವಿತರಣೆ ಮತ್ತು ಗುಂಪುಗಳು.';

  @override
  String get getStarted => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get newHere => 'ಹೊಸಬರೇ?';

  @override
  String get createAnAccount => 'ಖಾತೆ ರಚಿಸಿ';

  @override
  String get perkPrivate => 'ಖಾಸಗಿ';

  @override
  String get perkFast => 'ವೇಗ';

  @override
  String get perkGroups => 'ಗುಂಪುಗಳು';

  @override
  String get accountCreated =>
      'ಖಾತೆ ರಚಿಸಲಾಗಿದೆ. ದೃಢೀಕರಣ ಲಿಂಕ್‌ಗಾಗಿ ನಿಮ್ಮ ಇಮೇಲ್ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಲಾಗಿನ್ ಮಾಡಿ.';

  @override
  String get settingsLanguage => 'ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ';

  @override
  String get systemDefault => 'ಸಿಸ್ಟಮ್ ಡೀಫಾಲ್ಟ್';

  @override
  String get chooseLanguageHelp =>
      'ಅಪ್ಲಿಕೇಶನ್‌ನ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ. ನಿಮ್ಮ ಚಾಟ್ ಸಂದೇಶಗಳನ್ನು ಅನುವಾದಿಸಲಾಗುವುದಿಲ್ಲ.';
}
