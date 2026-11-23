// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get firebaseCouldNotStart => 'Firebase ആരംഭിക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get newMessage => 'പുതിയ സന്ദേശം';

  @override
  String get newGroupMessage => 'പുതിയ ഗ്രൂപ്പ് സന്ദേശം';

  @override
  String get photoWord => 'ഫോട്ടോ';

  @override
  String get chatWord => 'ചാറ്റ്';

  @override
  String get notifTaskChannel => 'ജോലി റിമൈൻഡറുകൾ';

  @override
  String get notifTaskChannelDesc => 'നിങ്ങളുടെ ജോലികൾക്കുള്ള റിമൈൻഡറുകൾ';

  @override
  String get notifMessagesChannel => 'സന്ദേശങ്ങൾ';

  @override
  String get notifMessagesChannelDesc =>
      'നിങ്ങളുടെ കോൺടാക്റ്റുകളിൽ നിന്നുള്ള പുതിയ സന്ദേശങ്ങൾ';

  @override
  String get notifStatusChannel => 'സന്ദേശ നില';

  @override
  String get notifStatusChannelDesc =>
      'വിജയകരമായി അയച്ച സന്ദേശങ്ങൾക്കുള്ള അറിയിപ്പുകൾ';

  @override
  String get sentPhoto => 'ഫോട്ടോ വിജയകരമായി അയച്ചു';

  @override
  String get sentDocument => 'ഡോക്യുമെന്റ് വിജയകരമായി അയച്ചു';

  @override
  String get sentContact => 'കോൺടാക്റ്റ് വിജയകരമായി അയച്ചു';

  @override
  String get sentMessage => 'സന്ദേശം വിജയകരമായി അയച്ചു';

  @override
  String get justNow => 'ഇപ്പോൾ';

  @override
  String minutesAgo(int minutes) {
    return '$minutes മിനിറ്റ് മുമ്പ്';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours മണിക്കൂർ മുമ്പ്';
  }

  @override
  String get photoTooLarge => 'ഫോട്ടോ വളരെ വലുതാണ്. ചെറുത് തിരഞ്ഞെടുക്കുക.';

  @override
  String get statusText => 'ടെക്സ്റ്റ്';

  @override
  String get addStatusTitle => 'സ്റ്റാറ്റസ് ചേർക്കുക';

  @override
  String get myStatus => 'എന്റെ സ്റ്റാറ്റസ്';

  @override
  String get tapToAddStatus => 'സ്റ്റാറ്റസ് അപ്ഡേറ്റ് ചേർക്കാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get recentUpdates => 'സമീപകാല അപ്ഡേറ്റുകൾ';

  @override
  String get viewedUpdates => 'കണ്ട അപ്ഡേറ്റുകൾ';

  @override
  String get noRecentUpdates =>
      'സമീപകാല അപ്ഡേറ്റുകളില്ല.\nനിങ്ങളുടെ കോൺടാക്റ്റുകളുടെ സ്റ്റാറ്റസുകൾ ഇവിടെ കാണാം, കുറച്ച് സമയത്തിന് ശേഷം അപ്രത്യക്ഷമാകും.';

  @override
  String get addStatusTooltip => 'സ്റ്റാറ്റസ് ചേർക്കുക';

  @override
  String get textStatusTooltip => 'ടെക്സ്റ്റ് സ്റ്റാറ്റസ്';

  @override
  String get photoStatusTooltip => 'ഫോട്ടോ സ്റ്റാറ്റസ്';

  @override
  String get couldNotOpenCameraOrGallery =>
      'ക്യാമറയോ ഗാലറിയോ തുറക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String statusUpdatesLine(int count, String timeAgo) {
    return '$count അപ്ഡേറ്റുകൾ · $timeAgo';
  }

  @override
  String get typeSomethingFirst => 'ആദ്യം എന്തെങ്കിലും ടൈപ്പ് ചെയ്യുക';

  @override
  String get statusOfflineQueued =>
      'ഇന്റർനെറ്റ് ഇല്ല. വീണ്ടും ഓൺലൈനാകുമ്പോൾ നിങ്ങളുടെ സ്റ്റാറ്റസ് പോസ്റ്റ് ചെയ്യും.';

  @override
  String get addCaption => 'ക്യാപ്ഷൻ ചേർക്കുക...';

  @override
  String get typeAStatus => 'ഒരു സ്റ്റാറ്റസ് ടൈപ്പ് ചെയ്യുക';

  @override
  String get changeColour => 'നിറം മാറ്റുക';

  @override
  String get deleteStatus => 'സ്റ്റാറ്റസ് ഇല്ലാതാക്കുക';

  @override
  String get noViewsYet => 'ഇതുവരെ കണ്ടവരില്ല';

  @override
  String get couldNotLoadPhoto => 'ഈ ഫോട്ടോ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String viewedBy(int count) {
    return '$count പേർ കണ്ടു';
  }

  @override
  String get createTask => 'ജോലി സൃഷ്ടിക്കുക';

  @override
  String get editTask => 'ജോലി എഡിറ്റ് ചെയ്യുക';

  @override
  String get assignTo => 'ഏൽപ്പിക്കുക';

  @override
  String get mePersonalTask => 'ഞാൻ (വ്യക്തിഗത ജോലി)';

  @override
  String get noSavedContactsAddFirst =>
      'ഇതുവരെ കോൺടാക്റ്റുകൾ സേവ് ചെയ്തിട്ടില്ല. ആദ്യം ഒരു കോൺടാക്റ്റ് ചേർക്കുക.';

  @override
  String get titleLabel => 'തലക്കെട്ട്';

  @override
  String get taskTitleHint => 'ജോലിയുടെ തലക്കെട്ട്';

  @override
  String get descriptionOptional => 'വിവരണം (ഓപ്ഷണൽ)';

  @override
  String get addMoreDetails => 'കൂടുതൽ വിവരങ്ങൾ ചേർക്കുക';

  @override
  String get dueDateTime => 'അവസാന തീയതിയും സമയവും';

  @override
  String get reminderLabelText => 'റിമൈൻഡർ';

  @override
  String reminderFor(String name) {
    return '$name നുള്ള റിമൈൻഡർ';
  }

  @override
  String reminderGoesToThem(String name) {
    return '$name ന് ഈ റിമൈൻഡർ അവരുടെ ഫോണിൽ ലഭിക്കും.';
  }

  @override
  String get saveChanges => 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get assignTask => 'ജോലി ഏൽപ്പിക്കുക';

  @override
  String get saveTask => 'ജോലി സേവ് ചെയ്യുക';

  @override
  String get couldNotSaveTask =>
      'ജോലി സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റും ഡാറ്റാബേസ് നിയമങ്ങളും പരിശോധിക്കുക.';

  @override
  String assignedSuccess(String name) {
    return '$name ന് ഏൽപ്പിച്ചു. ഇത് അവരുടെ \'എന്റെ ജോലികൾ\' ൽ കാണാം.';
  }

  @override
  String get taskSavedSuccess => 'നിങ്ങളുടെ ജോലി വിജയകരമായി സേവ് ചെയ്തു.';

  @override
  String get taskUpdated => 'ജോലി അപ്ഡേറ്റ് ചെയ്തു!';

  @override
  String get taskAssigned => 'ജോലി ഏൽപ്പിച്ചു!';

  @override
  String get taskCreated => 'ജോലി സൃഷ്ടിച്ചു!';

  @override
  String get noReminderScheduled =>
      'റിമൈൻഡർ ഷെഡ്യൂൾ ചെയ്തില്ല: റിമൈൻഡർ സമയം കഴിഞ്ഞു, അല്ലെങ്കിൽ അറിയിപ്പുകൾ ഓഫാണ്.';

  @override
  String get ok => 'ശരി';

  @override
  String get enterTitle => 'തലക്കെട്ട് നൽകുക';

  @override
  String get titleTooLong => 'തലക്കെട്ട് വളരെ നീണ്ടതാണ്';

  @override
  String get descTooLong => 'വിവരണം വളരെ നീണ്ടതാണ്';

  @override
  String get newTask => 'പുതിയ ജോലി';

  @override
  String get edit => 'എഡിറ്റ് ചെയ്യുക';

  @override
  String get deleteTaskTitle => 'ജോലി ഇല്ലാതാക്കണോ?';

  @override
  String get deleteTaskBody => 'ഈ ജോലിയും അതിന്റെ റിമൈൻഡറും നീക്കം ചെയ്യും.';

  @override
  String get taskDeleted => 'ജോലി ഇല്ലാതാക്കി';

  @override
  String get taskCompleted => 'പൂർത്തിയായി';

  @override
  String get noReminder => 'റിമൈൻഡർ ഇല്ല';

  @override
  String get pleaseLogInTasks => 'നിങ്ങളുടെ ജോലികൾ കാണാൻ ലോഗിൻ ചെയ്യുക.';

  @override
  String get couldNotLoadTasks =>
      'ജോലികൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റും ഡാറ്റാബേസ് നിയമങ്ങളും പരിശോധിക്കുക.';

  @override
  String get emptyAssignedToMe => 'നിങ്ങൾക്ക് ഇതുവരെ ഒന്നും ഏൽപ്പിച്ചിട്ടില്ല.';

  @override
  String get emptyAssignedByMe =>
      'നിങ്ങൾ ഇതുവരെ ഒരു ജോലിയും ഏൽപ്പിച്ചിട്ടില്ല.\nചാറ്റ് സന്ദേശം അമർത്തിപ്പിടിച്ച് \'ജോലി സൃഷ്ടിക്കുക\' ടാപ്പ് ചെയ്യുക.';

  @override
  String get emptyNoTasks =>
      'ഇതുവരെ ജോലികളില്ല.\nചാറ്റ് സന്ദേശം അമർത്തിപ്പിടിച്ച് \'ജോലി സൃഷ്ടിക്കുക\' ടാപ്പ് ചെയ്യുക.';

  @override
  String get emptyList => 'ഈ ലിസ്റ്റിൽ ജോലികളില്ല.';

  @override
  String filterAll(int count) {
    return 'എല്ലാം ($count)';
  }

  @override
  String filterUpcoming(int count) {
    return 'വരാനിരിക്കുന്നവ ($count)';
  }

  @override
  String filterCompleted(int count) {
    return 'പൂർത്തിയായവ ($count)';
  }

  @override
  String filterAssignedToMe(int count) {
    return 'എനിക്ക് ഏൽപ്പിച്ചവ ($count)';
  }

  @override
  String filterAssignedByMe(int count) {
    return 'ഞാൻ ഏൽപ്പിച്ചവ ($count)';
  }

  @override
  String doneBy(String name) {
    return '$name പൂർത്തിയാക്കി';
  }

  @override
  String waitingFor(String name) {
    return '$name നായി കാത്തിരിക്കുന്നു';
  }

  @override
  String reminderPrefix(String label) {
    return 'റിമൈൻഡർ: $label';
  }

  @override
  String assignedByLine(String name) {
    return '$name ഏൽപ്പിച്ചു';
  }

  @override
  String assignedToLine(String name) {
    return '$name ന് ഏൽപ്പിച്ചു';
  }

  @override
  String fromLine(String name) {
    return 'അയച്ചത്: $name';
  }

  @override
  String deleteTaskAssignedBody(String name) {
    return 'ഈ ജോലി നിങ്ങൾക്കും $name നും നീക്കം ചെയ്യും.';
  }

  @override
  String get couldNotUpdateTask =>
      'ജോലി അപ്ഡേറ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിക്കുക.';

  @override
  String get couldNotDeleteTask =>
      'ജോലി ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിക്കുക.';

  @override
  String get reminderAtDue => 'നിശ്ചിത സമയത്ത്';

  @override
  String get reminder10Min => '10 മിനിറ്റ് മുമ്പ്';

  @override
  String get reminder1Hour => '1 മണിക്കൂർ മുമ്പ്';

  @override
  String get reminder2Hours => '2 മണിക്കൂർ മുമ്പ്';

  @override
  String get reminder1Day => '1 ദിവസം മുമ്പ്';

  @override
  String get dueNow => 'ഇപ്പോൾ സമയമായി';

  @override
  String dueOn(String date, String time) {
    return 'സമയം: $date, $time';
  }

  @override
  String newTaskFrom(String who) {
    return '$who യിൽ നിന്ന് പുതിയ ജോലി';
  }

  @override
  String get aContact => 'ഒരു കോൺടാക്റ്റ്';

  @override
  String get someone => 'ആരോ';

  @override
  String get save => 'സേവ് ചെയ്യുക';

  @override
  String get groupNameTitle => 'ഗ്രൂപ്പിന്റെ പേര്';

  @override
  String get changeGroupName => 'ഗ്രൂപ്പിന്റെ പേര് മാറ്റുക';

  @override
  String get addMembers => 'അംഗങ്ങളെ ചേർക്കുക';

  @override
  String get groupAdminBadge => 'ഗ്രൂപ്പ് അഡ്മിൻ';

  @override
  String get removeFromGroup => 'ഗ്രൂപ്പിൽ നിന്ന് നീക്കം ചെയ്യുക';

  @override
  String get removeAction => 'നീക്കം ചെയ്യുക';

  @override
  String get removeMemberBody =>
      'ഈ ഗ്രൂപ്പിലെ പുതിയ സന്ദേശങ്ങൾ അവർക്ക് ലഭിക്കില്ല.';

  @override
  String get exitGroup => 'ഗ്രൂപ്പിൽ നിന്ന് പുറത്തുകടക്കുക';

  @override
  String get exitGroupTitle => 'ഗ്രൂപ്പിൽ നിന്ന് പുറത്തുകടക്കണോ?';

  @override
  String get exitAction => 'പുറത്തുകടക്കുക';

  @override
  String get exitGroupBody =>
      'ഇനി ഈ ഗ്രൂപ്പിലെ സന്ദേശങ്ങൾ നിങ്ങൾക്ക് ലഭിക്കില്ല.';

  @override
  String get disappearingGroupHelp =>
      'ഈ ഗ്രൂപ്പിലെ പുതിയ സന്ദേശങ്ങൾ നിങ്ങൾ തിരഞ്ഞെടുത്ത സമയത്തിന് ശേഷം അപ്രത്യക്ഷമാകും.';

  @override
  String removeMemberTitle(String name) {
    return '$name നെ നീക്കം ചെയ്യണോ?';
  }

  @override
  String groupMembersLine(int count) {
    return 'ഗ്രൂപ്പ് · $count അംഗങ്ങൾ';
  }

  @override
  String get addGroupMembers => 'ഗ്രൂപ്പ് അംഗങ്ങളെ ചേർക്കുക';

  @override
  String get noContactsToAdd =>
      'ചേർക്കാൻ കോൺടാക്റ്റുകളില്ല. ആദ്യം ഒരു കോൺടാക്റ്റ് സേവ് ചെയ്യുക.';

  @override
  String selectedOf(int selected, int total) {
    return '$total ൽ $selected തിരഞ്ഞെടുത്തു';
  }

  @override
  String get addAName => 'ഒരു പേര് ചേർക്കുക';

  @override
  String get groupNameHint => 'ഗ്രൂപ്പിന്റെ പേര് (നിർബന്ധം)';

  @override
  String get groupNameRequired => 'ഗ്രൂപ്പിന്റെ പേര് ടൈപ്പ് ചെയ്യുക';

  @override
  String membersTitle(int count) {
    return 'അംഗങ്ങൾ: $count';
  }

  @override
  String get couldNotRenameGroup => 'ഗ്രൂപ്പിന്റെ പേര് മാറ്റാൻ കഴിഞ്ഞില്ല';

  @override
  String get couldNotAddMembers => 'അംഗങ്ങളെ ചേർക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get couldNotRemoveMember => 'ഈ അംഗത്തെ നീക്കം ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String get couldNotExitGroup => 'ഗ്രൂപ്പിൽ നിന്ന് പുറത്തുകടക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get pleaseLogInAgain => 'വീണ്ടും ലോഗിൻ ചെയ്യുക';

  @override
  String get noLongerInGroup => 'നിങ്ങൾ ഇനി ഈ ഗ്രൂപ്പിൽ ഇല്ല';

  @override
  String get member => 'അംഗം';

  @override
  String get today => 'ഇന്ന്';

  @override
  String get forwarded => 'ഫോർവേഡ് ചെയ്തത്';

  @override
  String disappearingNotice(String label) {
    return '⏱ അപ്രത്യക്ഷമാകുന്ന സന്ദേശങ്ങൾ: $label';
  }

  @override
  String get scheduleTitle => 'അയയ്ക്കൽ ഷെഡ്യൂൾ ചെയ്യുക';

  @override
  String get scheduleTypeFirst =>
      'ആദ്യം ഒരു സന്ദേശം ടൈപ്പ് ചെയ്യുക അല്ലെങ്കിൽ ചിത്രം തിരഞ്ഞെടുക്കുക';

  @override
  String get scheduleInvalid => 'ഭാവിയിലെ ഒരു സമയം തിരഞ്ഞെടുക്കുക';

  @override
  String tomorrowDay(String day) {
    return 'നാളെ, $day';
  }

  @override
  String scheduleToday(String time) {
    return 'ഇന്ന് $time ന്';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'നാളെ $time ന്';
  }

  @override
  String scheduleOn(String day, String time) {
    return '$day ന് $time ന്';
  }

  @override
  String sendAt(String label) {
    return '$label അയയ്ക്കുക';
  }

  @override
  String scheduledFor(String label) {
    return 'സന്ദേശം $label ന് ഷെഡ്യൂൾ ചെയ്തു';
  }

  @override
  String get callsNotInGroups => 'ഗ്രൂപ്പുകളിൽ കോളുകൾ ഇതുവരെ ലഭ്യമല്ല';

  @override
  String get couldNotIdentifyContact =>
      'കോൺടാക്റ്റ് അക്കൗണ്ട് തിരിച്ചറിയാൻ കഴിഞ്ഞില്ല';

  @override
  String get couldNotOpenDialer => 'ഫോൺ ഡയലർ തുറക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String noPhoneSaved(String name) {
    return '$name ന് ഫോൺ നമ്പർ സേവ് ചെയ്തിട്ടില്ല';
  }

  @override
  String get couldNotOpenCamera =>
      'ക്യാമറ തുറക്കാൻ കഴിഞ്ഞില്ല. ക്യാമറ അനുമതി പരിശോധിക്കുക.';

  @override
  String get couldNotOpenGallery => 'ഗാലറി തുറക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get couldNotPickDocument => 'ഡോക്യുമെന്റ് തിരഞ്ഞെടുക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get couldNotOpenFile => 'ഫയൽ തുറക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get attachCamera => 'ക്യാമറ';

  @override
  String get attachGallery => 'ഗാലറി';

  @override
  String get attachContact => 'കോൺടാക്റ്റ്';

  @override
  String get attachLocation => 'ലൊക്കേഷൻ';

  @override
  String get locationComingSoon => 'ലൊക്കേഷൻ ഷെയറിംഗ് ഉടൻ വരുന്നു';

  @override
  String get shareContactTitle => 'കോൺടാക്റ്റ് ഷെയർ ചെയ്യുക';

  @override
  String get forwardToTitle => 'ഇവർക്ക് ഫോർവേഡ് ചെയ്യുക...';

  @override
  String get noSavedContacts => 'ഇതുവരെ കോൺടാക്റ്റുകൾ സേവ് ചെയ്തിട്ടില്ല';

  @override
  String get searchNameOrNumber => 'പേരോ നമ്പറോ തിരയുക';

  @override
  String get noContactFound => 'കോൺടാക്റ്റ് കണ്ടെത്തിയില്ല';

  @override
  String get selectContacts => 'കോൺടാക്റ്റുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String sendToCount(int count) {
    return '$count പേർക്ക് അയയ്ക്കുക';
  }

  @override
  String get cardMessage => 'സന്ദേശം';

  @override
  String get alreadyInContacts => 'ഇതിനകം നിങ്ങളുടെ കോൺടാക്റ്റുകളിലുണ്ട്';

  @override
  String get ownNumber => 'ഇത് നിങ്ങളുടെ സ്വന്തം നമ്പറാണ്';

  @override
  String get contactSavedShort => 'കോൺടാക്റ്റ് സേവ് ചെയ്തു';

  @override
  String get couldNotSaveContact =>
      'കോൺടാക്റ്റ് സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല. ഡാറ്റാബേസ് നിയമങ്ങൾ പരിശോധിക്കുക.';

  @override
  String get waitUntilSent => 'സന്ദേശം അയയ്ക്കുന്നത് വരെ കാത്തിരിക്കുക';

  @override
  String get messageForwarded => 'സന്ദേശം ഫോർവേഡ് ചെയ്തു';

  @override
  String forwardedToCount(int done, int total) {
    return '$total കോൺടാക്റ്റുകളിൽ $done പേർക്ക് ഫോർവേഡ് ചെയ്തു';
  }

  @override
  String get voiceLanguageTitle => 'വോയ്സ് ടൈപ്പിംഗ് ഭാഷ';

  @override
  String get voiceLanguageHelp =>
      'മൈക്ക് ഒരു സമയം ഒരു ഭാഷ മാത്രം കേൾക്കുന്നു. നിങ്ങൾ സംസാരിക്കുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക.';

  @override
  String get listening => 'കേൾക്കുന്നു...';

  @override
  String voiceLanguageChosen(String name) {
    return 'വോയ്സ് ടൈപ്പിംഗ് ഭാഷ: $name';
  }

  @override
  String listeningIn(String name) {
    return '$name ൽ കേൾക്കുന്നു...';
  }

  @override
  String get reply => 'മറുപടി';

  @override
  String get forward => 'ഫോർവേഡ്';

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get copy => 'പകർത്തുക';

  @override
  String get copied => 'പകർത്തി';

  @override
  String get messageDeleted => 'സന്ദേശം ഇല്ലാതാക്കി';

  @override
  String get clearChatTitle => 'ചാറ്റ് മായ്ക്കണോ?';

  @override
  String get clear => 'മായ്ക്കുക';

  @override
  String clearGroupBody(String title) {
    return '$title ലെ എല്ലാ സന്ദേശങ്ങളും എല്ലാവർക്കുമായി ഇല്ലാതാക്കും.';
  }

  @override
  String clearChatBody(String name) {
    return '$name ഉമായുള്ള എല്ലാ സന്ദേശങ്ങളും ഇല്ലാതാക്കും.';
  }

  @override
  String get couldNotLoadMessages =>
      'സന്ദേശങ്ങൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ Firebase Realtime Database നിയമങ്ങൾ പരിശോധിക്കുക.';

  @override
  String get noMessagesYet => 'ഇതുവരെ സന്ദേശങ്ങളില്ല\nഹായ് പറയൂ 👋';

  @override
  String get messageHint => 'സന്ദേശം';

  @override
  String get photoAttached => 'ഫോട്ടോ ചേർത്തു';

  @override
  String get removePhoto => 'ഫോട്ടോ നീക്കം ചെയ്യുക';

  @override
  String get groupInfo => 'ഗ്രൂപ്പ് വിവരങ്ങൾ';

  @override
  String get viewProfile => 'പ്രൊഫൈൽ കാണുക';

  @override
  String get searchHint => 'തിരയുക...';

  @override
  String get noResults => 'ഫലങ്ങളില്ല';

  @override
  String matchOf(int current, int total) {
    return '$total ൽ $current';
  }

  @override
  String get couldNotSendMessage =>
      'സന്ദേശം അയയ്ക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get couldNotScheduleMessage =>
      'സന്ദേശം ഷെഡ്യൂൾ ചെയ്യാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get nothingToSend => 'അയയ്ക്കാൻ ഒന്നുമില്ല';

  @override
  String get imageTooLarge =>
      'ചിത്രം വളരെ വലുതാണ്. ചെറിയ ഫോട്ടോ തിരഞ്ഞെടുക്കുക.';

  @override
  String get couldNotShareContact =>
      'കോൺടാക്റ്റ് ഷെയർ ചെയ്യാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get documentsOnlineOnly =>
      'നിങ്ങൾ ഓൺലൈനിലായിരിക്കുമ്പോൾ മാത്രമേ ഡോക്യുമെന്റുകൾ അയയ്ക്കാൻ കഴിയൂ.';

  @override
  String get couldNotSaveAttachment =>
      'അറ്റാച്ച്‌മെന്റ് സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get couldNotDeleteMessage => 'സന്ദേശം ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get couldNotClearChat => 'ചാറ്റ് മായ്ക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get reactionFailed =>
      'പ്രതികരണം ചേർക്കാൻ കഴിഞ്ഞില്ല. ഡാറ്റാബേസ് നിയമങ്ങൾ പരിശോധിക്കുക.';

  @override
  String voiceNoSpeech(String language) {
    return '$language ൽ ഒന്നും കേട്ടില്ല. മൈക്കിൽ ടാപ്പ് ചെയ്ത് വ്യക്തമായി സംസാരിക്കുക, അല്ലെങ്കിൽ ഭാഷ മാറ്റുക (മൈക്ക് അമർത്തിപ്പിടിക്കുക).';
  }

  @override
  String get micPermission => 'ഈ ആപ്പിന് മൈക്രോഫോൺ അനുമതി നൽകുക';

  @override
  String voiceLangNotReady(String language) {
    return 'ഈ ഫോണിൽ $language വോയ്സ് ടൈപ്പിംഗ് തയ്യാറല്ല.\nഇന്റർനെറ്റിൽ കണക്ട് ചെയ്യുക, അല്ലെങ്കിൽ ഫോണിലെ Google വോയ്സ് ടൈപ്പിംഗ് ക്രമീകരണങ്ങളിൽ $language ഡൗൺലോഡ് ചെയ്യുക.';
  }

  @override
  String voiceNetworkError(String error, String language) {
    return 'വോയ്സ് പിശക്: $error\nനിങ്ങളുടെ ഇന്റർനെറ്റ് പരിശോധിക്കുക, അല്ലെങ്കിൽ ഓഫ്‌ലൈൻ ഉപയോഗത്തിനായി ഫോൺ ക്രമീകരണങ്ങളിൽ $language ഡൗൺലോഡ് ചെയ്യുക, അല്ലെങ്കിൽ സന്ദേശം ടൈപ്പ് ചെയ്യുക.';
  }

  @override
  String speechError(String error) {
    return 'സ്പീച്ച് പിശക്: $error';
  }

  @override
  String get micPermissionNeeded =>
      'മൈക്രോഫോൺ അനുമതി ആവശ്യമാണ്. ആപ്പ് ക്രമീകരണങ്ങളിൽ അനുവദിക്കുക.';

  @override
  String get you => 'നിങ്ങൾ';

  @override
  String get attachDocument => 'ഡോക്യുമെന്റ്';

  @override
  String get clearChat => 'ചാറ്റ് മായ്ക്കുക';

  @override
  String get mediaLinksDocs => 'മീഡിയ, ലിങ്കുകൾ, ഡോക്യുമെന്റുകൾ';

  @override
  String get disappearingTitle => 'അപ്രത്യക്ഷമാകുന്ന സന്ദേശങ്ങൾ';

  @override
  String get disappearOff => 'ഓഫ്';

  @override
  String get disappear5Min => '5 മിനിറ്റ്';

  @override
  String get disappear1Day => '1 ദിവസം';

  @override
  String get disappear7Days => '7 ദിവസം';

  @override
  String get contactInfoTitle => 'കോൺടാക്റ്റ് വിവരങ്ങൾ';

  @override
  String get phoneUnavailable => 'ഫോൺ നമ്പർ ലഭ്യമല്ല';

  @override
  String get actionAudio => 'ഓഡിയോ';

  @override
  String get actionVideo => 'വീഡിയോ';

  @override
  String get mediaVisibility => 'മീഡിയ ദൃശ്യത';

  @override
  String get encryption => 'എൻക്രിപ്ഷൻ';

  @override
  String get encryptionSub =>
      'സന്ദേശങ്ങളും കോളുകളും ഇതുവരെ എൻഡ്-ടു-എൻഡ് എൻക്രിപ്റ്റ് ചെയ്തിട്ടില്ല.';

  @override
  String get blockContact => 'കോൺടാക്റ്റ് ബ്ലോക്ക് ചെയ്യുക';

  @override
  String get disappearingChatHelp =>
      'ഈ ചാറ്റിലെ പുതിയ സന്ദേശങ്ങൾ നിങ്ങൾ തിരഞ്ഞെടുത്ത സമയത്തിന് ശേഷം അപ്രത്യക്ഷമാകും.';

  @override
  String get couldNotChangeSetting =>
      'ക്രമീകരണം മാറ്റാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് പരിശോധിക്കുക.';

  @override
  String get notificationSettingsMsg => 'അറിയിപ്പ് ക്രമീകരണങ്ങൾ';

  @override
  String get mediaVisibilitySettingsMsg => 'മീഡിയ ദൃശ്യത ക്രമീകരണങ്ങൾ';

  @override
  String get encryptionMsg =>
      'ഈ ആപ്പ് നിലവിൽ എൻഡ്-ടു-എൻഡ് എൻക്രിപ്ഷൻ നടപ്പിലാക്കുന്നില്ല.';

  @override
  String get blockingNotImplemented =>
      'കോൺടാക്റ്റ് ബ്ലോക്കിംഗ് ഇതുവരെ നടപ്പിലാക്കിയിട്ടില്ല.';

  @override
  String get calling => 'വിളിക്കുന്നു...';

  @override
  String get videoCalling => 'വീഡിയോ കോൾ ചെയ്യുന്നു...';

  @override
  String get callSpeaker => 'സ്പീക്കർ';

  @override
  String get callMute => 'മ്യൂട്ട്';

  @override
  String get callFlip => 'മാറ്റുക';

  @override
  String get callMore => 'കൂടുതൽ';

  @override
  String get callShare => 'ഷെയർ';

  @override
  String get callEnd => 'അവസാനിപ്പിക്കുക';

  @override
  String get addPeopleSoon => 'ആളുകളെ ചേർക്കുന്നത് ഉടൻ വരുന്നു';

  @override
  String get moreOptionsSoon => 'കൂടുതൽ ഓപ്ഷനുകൾ ഉടൻ വരുന്നു';

  @override
  String get sharingSoon => 'ഷെയറിംഗ് ഉടൻ വരുന്നു';

  @override
  String get noCameraFound => 'ഈ ഉപകരണത്തിൽ ക്യാമറ കണ്ടെത്തിയില്ല';

  @override
  String get cameraPermissionDenied =>
      'ക്യാമറ അനുമതി നിഷേധിച്ചു. ആപ്പ് ക്രമീകരണങ്ങളിൽ അനുവദിക്കുക.';

  @override
  String get callCouldNotOpenCamera => 'ക്യാമറ തുറക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get nothingToOpen => 'ഇവിടെ തുറക്കാൻ ഒന്നുമില്ല';

  @override
  String get couldNotOpenThis => 'ഇത് തുറക്കാൻ കഴിഞ്ഞില്ല';

  @override
  String get tabMedia => 'മീഡിയ';

  @override
  String get tabDocs => 'ഡോക്സ്';

  @override
  String get tabLinks => 'ലിങ്കുകൾ';

  @override
  String get noPhotosYet => 'ഇതുവരെ ഫോട്ടോകൾ ഷെയർ ചെയ്തിട്ടില്ല';

  @override
  String get noDocsYet => 'ഇതുവരെ ഡോക്യുമെന്റുകൾ ഷെയർ ചെയ്തിട്ടില്ല';

  @override
  String get noLinksYet => 'ഇതുവരെ ലിങ്കുകൾ ഷെയർ ചെയ്തിട്ടില്ല';

  @override
  String get couldNotLoadMedia =>
      'ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ Firebase Realtime Database നിയമങ്ങൾ പരിശോധിക്കുക.';

  @override
  String sharedBy(String who, String date) {
    return '$who  •  $date';
  }

  @override
  String linkSubtitle(String title, String who, String date) {
    return '$title\n$who  •  $date';
  }

  @override
  String get waitingOne => '1 സന്ദേശം അയയ്ക്കാൻ കാത്തിരിക്കുന്നു.';

  @override
  String waitingMany(int count) {
    return '$count സന്ദേശങ്ങൾ അയയ്ക്കാൻ കാത്തിരിക്കുന്നു.';
  }

  @override
  String offlineWithPending(String waiting) {
    return 'നിങ്ങൾ ഓഫ്‌ലൈനിലാണ്. $waiting';
  }

  @override
  String get offlineNoPending =>
      'നിങ്ങൾ ഓഫ്‌ലൈനിലാണ്. ദയവായി ഇന്റർനെറ്റ് കണക്ഷൻ ഓണാക്കുക.';

  @override
  String connectingWithPending(String waiting) {
    return 'കണക്ട് ചെയ്യുന്നു... $waiting';
  }

  @override
  String get connecting => 'കണക്ട് ചെയ്യുന്നു...';

  @override
  String get backOnlineSending =>
      'വീണ്ടും ഓൺലൈനായി. നിങ്ങളുടെ സന്ദേശങ്ങൾ അയയ്ക്കുന്നു...';

  @override
  String get backOnline => 'നിങ്ങൾ വീണ്ടും ഓൺലൈനിലാണ്.';

  @override
  String get saveContact => 'കോൺടാക്റ്റ് സേവ് ചെയ്യുക';

  @override
  String get addContactTitle => 'കോൺടാക്റ്റ് ചേർക്കുക';

  @override
  String get addContactSubtitle =>
      'രജിസ്റ്റർ ചെയ്ത ഇമെയിൽ നൽകുക, ബാക്കി സ്വയം പൂരിപ്പിക്കപ്പെടും.';

  @override
  String get contactNameLabel => 'ഉപയോക്തൃ നാമം';

  @override
  String get registeredEmailLabel => 'രജിസ്റ്റർ ചെയ്ത ഇമെയിൽ വിലാസം';

  @override
  String get userFound => 'രജിസ്റ്റർ ചെയ്ത ഉപയോക്താവിനെ കണ്ടെത്തി';

  @override
  String get userFoundNoPhone =>
      'രജിസ്റ്റർ ചെയ്ത ഉപയോക്താവിനെ കണ്ടെത്തി. അവർ ഫോൺ നമ്പർ ചേർത്തിട്ടില്ല, താഴെ ടൈപ്പ് ചെയ്യുക.';

  @override
  String get userNotFound =>
      'ഈ ഇമെയിലിൽ രജിസ്റ്റർ ചെയ്ത ഉപയോക്താവിനെ കണ്ടെത്തിയില്ല';

  @override
  String get cannotAddSelf => 'നിങ്ങളുടെ സ്വന്തം അക്കൗണ്ട് ചേർക്കാൻ കഴിയില്ല.';

  @override
  String get lookupFailed => 'ഈ ഇമെയിൽ തിരയാൻ കഴിഞ്ഞില്ല.';

  @override
  String get lookupFailedInternet =>
      'ഈ ഇമെയിൽ തിരയാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിക്കുക.';

  @override
  String userFoundName(String name) {
    return 'രജിസ്റ്റർ ചെയ്ത ഉപയോക്താവിനെ കണ്ടെത്തി: $name';
  }

  @override
  String lookupFailedCode(String code) {
    return 'ഈ ഇമെയിൽ തിരയാൻ കഴിഞ്ഞില്ല ($code).';
  }

  @override
  String get enterContactName => 'ഉപയോക്തൃ നാമം നൽകുക';

  @override
  String get nameTooShort => 'പേര് കുറഞ്ഞത് 4 അക്ഷരങ്ങൾ വേണം';

  @override
  String get nameTooLong => 'പേര് പരമാവധി 40 അക്ഷരങ്ങൾ മാത്രം';

  @override
  String get enterRegisteredEmail => 'രജിസ്റ്റർ ചെയ്ത ഇമെയിൽ വിലാസം നൽകുക';

  @override
  String get enterValidEmail => 'സാധുവായ ഇമെയിൽ വിലാസം നൽകുക';

  @override
  String get loginAgainToSave =>
      'കോൺടാക്റ്റുകൾ സേവ് ചെയ്യുന്നതിന് മുമ്പ് വീണ്ടും ലോഗിൻ ചെയ്യുക.';

  @override
  String get userAlreadyInContacts =>
      'ഈ ഉപയോക്താവ് ഇതിനകം നിങ്ങളുടെ കോൺടാക്റ്റുകളിലുണ്ട്.';

  @override
  String get firebaseDenied =>
      'Firebase ആക്സസ് നിഷേധിച്ചു. നിങ്ങളുടെ ഡാറ്റാബേസ് നിയമങ്ങൾ പരിശോധിക്കുക.';

  @override
  String get unknownError => 'അജ്ഞാത പിശക്';

  @override
  String firebaseError(String code, String message) {
    return 'Firebase പിശക് ($code): $message';
  }

  @override
  String get profileTitle => 'പ്രൊഫൈൽ';

  @override
  String get nameLabel => 'പേര്';

  @override
  String get phoneLabel => 'ഫോൺ';

  @override
  String get notAdded => 'ചേർത്തിട്ടില്ല';

  @override
  String get saveName => 'പേര് സേവ് ചെയ്യുക';

  @override
  String get profileNameUpdated => 'പേര് അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get nameSavedNote =>
      'നിങ്ങളെ സേവ് ചെയ്തവർ അവർ തിരഞ്ഞെടുത്ത പേര് തന്നെ സൂക്ഷിക്കും.';

  @override
  String get enterYourName => 'നിങ്ങളുടെ പേര് നൽകുക';

  @override
  String get pleaseLogInBeforePicture =>
      'ചിത്രം മാറ്റുന്നതിന് മുമ്പ് വീണ്ടും ലോഗിൻ ചെയ്യുക.';

  @override
  String get pictureTooLarge =>
      'ഈ ചിത്രം വളരെ വലുതാണ്. ചെറിയ ചിത്രം തിരഞ്ഞെടുക്കുക.';

  @override
  String get youAreOfflineTryAgain =>
      'നിങ്ങൾ ഓഫ്‌ലൈനിലാണ്. ഇന്റർനെറ്റിൽ കണക്ട് ചെയ്ത് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String profileUpdateFailed(String error) {
    return 'പ്രൊഫൈൽ അപ്ഡേറ്റ് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get pleaseLogInBeforeName =>
      'പേര് മാറ്റുന്നതിന് മുമ്പ് വീണ്ടും ലോഗിൻ ചെയ്യുക.';

  @override
  String get serverNoAnswer =>
      'സെർവർ പ്രതികരിച്ചില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String couldNotSaveNameCode(String code) {
    return 'നിങ്ങളുടെ പേര് സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല ($code). വീണ്ടും ശ്രമിക്കുക.';
  }

  @override
  String get couldNotSaveName =>
      'നിങ്ങളുടെ പേര് സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get delete => 'ഇല്ലാതാക്കുക';

  @override
  String get yesterday => 'ഇന്നലെ';

  @override
  String get videoCallNoAnswer => 'വീഡിയോ കോൾ · മറുപടിയില്ല';

  @override
  String get missedVideoCall => 'മിസ്ഡ് വീഡിയോ കോൾ';

  @override
  String youPrefix(String text) {
    return 'നിങ്ങൾ: $text';
  }

  @override
  String get deleteChatTitle => 'ചാറ്റ് ഇല്ലാതാക്കണോ?';

  @override
  String deleteChatsTitle(int count) {
    return '$count ചാറ്റുകൾ ഇല്ലാതാക്കണോ?';
  }

  @override
  String get deleteChatBody =>
      'ചാറ്റ് നിങ്ങളുടെ ലിസ്റ്റിൽ നിന്ന് മാത്രമേ നീക്കം ചെയ്യൂ. മറ്റുള്ളവരുടെ പക്കൽ അവരുടെ സന്ദേശങ്ങൾ ഉണ്ടാകും. പുതിയ സന്ദേശം വന്നാൽ ചാറ്റ് തിരിച്ചുവരും.';

  @override
  String get chatDeleted => 'ചാറ്റ് ഇല്ലാതാക്കി';

  @override
  String chatsDeleted(int count) {
    return '$count ചാറ്റുകൾ ഇല്ലാതാക്കി';
  }

  @override
  String get couldNotDelete =>
      'ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get newChat => 'പുതിയ ചാറ്റ്';

  @override
  String get newGroup => 'പുതിയ ഗ്രൂപ്പ്';

  @override
  String get newContact => 'പുതിയ കോൺടാക്റ്റ്';

  @override
  String membersCount(int count) {
    return '$count അംഗങ്ങൾ';
  }

  @override
  String get tapToStartChatting => 'ചാറ്റ് തുടങ്ങാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get offlineNoContacts =>
      'നിങ്ങൾ ഓഫ്‌ലൈനിലാണ്. ഈ ഉപകരണത്തിൽ ഇതുവരെ കോൺടാക്റ്റുകൾ സേവ് ചെയ്തിട്ടില്ല.';

  @override
  String get noChatsYet =>
      'ഇതുവരെ ചാറ്റുകളില്ല. കോൺടാക്റ്റ് ചേർക്കാനോ ഗ്രൂപ്പ് സൃഷ്ടിക്കാനോ + ടാപ്പ് ചെയ്യുക.';

  @override
  String get updates => 'അപ്‌ഡേറ്റുകൾ';

  @override
  String get chats => 'ചാറ്റുകൾ';

  @override
  String get search => 'തിരയുക';

  @override
  String get closeSearch => 'തിരയൽ അടയ്ക്കുക';

  @override
  String get myTasks => 'എന്റെ ജോലികൾ';

  @override
  String get pleaseLogIn => 'നിങ്ങളുടെ കോൺടാക്റ്റുകൾ കാണാൻ ലോഗിൻ ചെയ്യുക.';

  @override
  String get contactSaved => 'കോൺടാക്റ്റ് വിജയകരമായി സേവ് ചെയ്തു.';

  @override
  String get searchSettings => 'സെറ്റിംഗ്‌സ് തിരയുക';

  @override
  String get noSettingsFound => 'സെറ്റിംഗ്‌സ് ഒന്നും കണ്ടെത്തിയില്ല';

  @override
  String get addNewContact => 'പുതിയ കോൺടാക്റ്റ് ചേർക്കുക';

  @override
  String get addNewContactSub => 'ചാറ്റ് തുടങ്ങാൻ ഒരു കോൺടാക്റ്റ് സേവ് ചെയ്യുക';

  @override
  String get settingsAccount => 'അക്കൗണ്ട്';

  @override
  String get settingsAccountSub => 'സുരക്ഷാ അറിയിപ്പുകൾ, അക്കൗണ്ട് വിവരങ്ങൾ';

  @override
  String get settingsPrivacy => 'സ്വകാര്യത';

  @override
  String get settingsPrivacySub =>
      'ബ്ലോക്ക് ചെയ്ത കോൺടാക്റ്റുകൾ, അപ്രത്യക്ഷമാകുന്ന സന്ദേശങ്ങൾ';

  @override
  String get settingsChatsSub => 'തീം, വാൾപേപ്പർ, ചാറ്റ് ചരിത്രം';

  @override
  String get settingsNotifications => 'അറിയിപ്പുകൾ';

  @override
  String get settingsNotificationsSub => 'സന്ദേശം, ഗ്രൂപ്പ്, കോൾ ടോണുകൾ';

  @override
  String get settingsStorage => 'സ്റ്റോറേജും ഡാറ്റയും';

  @override
  String get settingsStorageSub => 'നെറ്റ്‌വർക്ക് ഉപയോഗം, ഓട്ടോ-ഡൗൺലോഡ്';

  @override
  String get settingsHelp => 'സഹായവും ഫീഡ്‌ബാക്കും';

  @override
  String get settingsHelpSub =>
      'സഹായ കേന്ദ്രം, ഞങ്ങളെ ബന്ധപ്പെടുക, സ്വകാര്യതാ നയം';

  @override
  String get logOut => 'ലോഗ് ഔട്ട്';

  @override
  String get logOutTitle => 'ലോഗ് ഔട്ട് ചെയ്യണോ?';

  @override
  String get logOutBody =>
      'നിങ്ങളുടെ അക്കൗണ്ടിൽ നിന്ന് ലോഗ് ഔട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?';

  @override
  String get profilePhotoUpdated =>
      'പ്രൊഫൈൽ ചിത്രം അപ്ഡേറ്റ് ചെയ്തു. ഇപ്പോൾ നിങ്ങളുടെ കോൺടാക്റ്റുകൾക്ക് അത് കാണാം.';

  @override
  String get createAccount => 'അക്കൗണ്ട് സൃഷ്ടിക്കുക';

  @override
  String get signupSubtitle =>
      'തുടങ്ങാൻ നിങ്ങളുടെ ഇമെയിൽ ഉപയോഗിച്ച് സൈൻ അപ്പ് ചെയ്യുക.';

  @override
  String get nickname => 'വിളിപ്പേര്';

  @override
  String get code => 'കോഡ്';

  @override
  String get phoneNumber => 'ഫോൺ നമ്പർ';

  @override
  String get confirmPassword => 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String get register => 'രജിസ്റ്റർ ചെയ്യുക';

  @override
  String get haveAccount => 'ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ?';

  @override
  String get logInLink => 'ലോഗിൻ ചെയ്യുക';

  @override
  String get ruleLength => 'കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ';

  @override
  String get ruleCapital => '1 വലിയ അക്ഷരം (A-Z)';

  @override
  String get ruleSmall => '1 ചെറിയ അക്ഷരം (a-z)';

  @override
  String get ruleNumber => '1 അക്കം (0-9)';

  @override
  String get ruleSpecial => '1 പ്രത്യേക ചിഹ്നം (! @ # \$ %)';

  @override
  String get enterNickname => 'വിളിപ്പേര് നൽകുക';

  @override
  String get useAtLeast3 => 'കുറഞ്ഞത് 3 അക്ഷരങ്ങൾ ഉപയോഗിക്കുക';

  @override
  String get useAtMost20 => 'പരമാവധി 20 അക്ഷരങ്ങൾ ഉപയോഗിക്കുക';

  @override
  String get enterNewPassword => 'പാസ്‌വേഡ് നൽകുക';

  @override
  String get useAtLeast8 => 'കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ ഉപയോഗിക്കുക';

  @override
  String get noSpaces => 'പാസ്‌വേഡിൽ സ്‌പേസ് പാടില്ല';

  @override
  String get addCapital => '1 വലിയ അക്ഷരം ചേർക്കുക (A-Z)';

  @override
  String get addSmall => '1 ചെറിയ അക്ഷരം ചേർക്കുക (a-z)';

  @override
  String get addNumber => '1 അക്കം ചേർക്കുക (0-9)';

  @override
  String get addSpecial => '1 പ്രത്യേക ചിഹ്നം ചേർക്കുക (! @ # \$ % & *)';

  @override
  String get confirmYourPassword => 'നിങ്ങളുടെ പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String get passwordsDontMatch => 'പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല';

  @override
  String get emailAlreadyRegistered =>
      'ഈ ഇമെയിൽ ഇതിനകം രജിസ്റ്റർ ചെയ്തിട്ടുണ്ട്. ലോഗിൻ ചെയ്യുക.';

  @override
  String get weakPassword =>
      'ഈ പാസ്‌വേഡ് വളരെ ദുർബലമാണ്. മറ്റൊന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get signupNotEnabled =>
      'Firebase കൺസോളിൽ ഇമെയിൽ/പാസ്‌വേഡ് സൈൻ അപ്പ് പ്രവർത്തനക്ഷമമാക്കിയിട്ടില്ല.';

  @override
  String get signupFailed =>
      'അക്കൗണ്ട് സൃഷ്ടിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get createAccountWentWrong =>
      'അക്കൗണ്ട് സൃഷ്ടിക്കുമ്പോൾ എന്തോ കുഴപ്പം സംഭവിച്ചു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get accountNotCreated =>
      'അക്കൗണ്ട് സൃഷ്ടിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get phoneAlreadyRegistered =>
      'ഈ ഫോൺ നമ്പർ ഇതിനകം മറ്റൊരു അക്കൗണ്ടിൽ രജിസ്റ്റർ ചെയ്തിട്ടുണ്ട്. മറ്റൊരു നമ്പർ ഉപയോഗിക്കുക.';

  @override
  String get phoneCheckFailed =>
      'ഫോൺ നമ്പർ പരിശോധിക്കാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get phoneJustTaken =>
      'ഈ ഫോൺ നമ്പർ ഇപ്പോൾ മറ്റൊരു അക്കൗണ്ട് രജിസ്റ്റർ ചെയ്തു. മറ്റൊരു നമ്പർ ഉപയോഗിക്കുക.';

  @override
  String get phoneSaveFailed =>
      'ഫോൺ നമ്പർ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String phoneSaveFailedCode(String code) {
    return 'ഫോൺ നമ്പർ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല ($code). വീണ്ടും ശ്രമിക്കുക.';
  }

  @override
  String get verificationCancelled =>
      'സ്ഥിരീകരണം റദ്ദാക്കിയതിനാൽ അക്കൗണ്ട് സൃഷ്ടിച്ചില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get enterPhone => 'ഫോൺ നമ്പർ നൽകുക';

  @override
  String get digitsOnly => 'അക്കങ്ങൾ മാത്രം ഉപയോഗിക്കുക';

  @override
  String get invalidPhone => 'സാധുവായ ഫോൺ നമ്പർ നൽകുക (6–15 അക്കങ്ങൾ)';

  @override
  String get verifyYourEmail => 'നിങ്ങളുടെ ഇമെയിൽ സ്ഥിരീകരിക്കുക';

  @override
  String otpSentTo(String email) {
    return 'അയച്ച 4 അക്ക കോഡ് നൽകുക\n$email';
  }

  @override
  String get enterAllDigits => '4 അക്കങ്ങളും നൽകുക';

  @override
  String get wrongOtp => 'തെറ്റായ OTP, വീണ്ടും ശ്രമിക്കുക';

  @override
  String get messages => 'സന്ദേശങ്ങൾ';

  @override
  String get now => 'ഇപ്പോൾ';

  @override
  String otpMessage(String appName, String code) {
    return 'നിങ്ങളുടെ $appName സ്ഥിരീകരണ കോഡ് $code. ഇത് ആരുമായും പങ്കിടരുത്.';
  }

  @override
  String resendCodeIn(String time) {
    return '$time ൽ കോഡ് വീണ്ടും അയയ്ക്കാം';
  }

  @override
  String get resendCode => 'കോഡ് വീണ്ടും അയയ്ക്കുക';

  @override
  String get verify => 'സ്ഥിരീകരിക്കുക';

  @override
  String get email => 'ഇമെയിൽ';

  @override
  String get password => 'പാസ്‌വേഡ്';

  @override
  String get backToLogin => 'ലോഗിനിലേക്ക് മടങ്ങുക';

  @override
  String get enterEmail => 'നിങ്ങളുടെ ഇമെയിൽ നൽകുക';

  @override
  String get invalidEmail => 'സാധുവായ ഇമെയിൽ നൽകുക (ഉദാഹരണം: name@gmail.com)';

  @override
  String get invalidEmailAddress => 'സാധുവായ ഇമെയിൽ വിലാസം നൽകുക.';

  @override
  String get tooManyAttempts =>
      'വളരെയധികം ശ്രമങ്ങൾ. കുറച്ച് കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get networkError =>
      'നെറ്റ്‌വർക്ക് പിശക്. നിങ്ങളുടെ ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിക്കുക.';

  @override
  String get somethingWentWrong =>
      'എന്തോ കുഴപ്പം സംഭവിച്ചു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get enterPassword => 'നിങ്ങളുടെ പാസ്‌വേഡ് നൽകുക';

  @override
  String get loginCredentials =>
      'ഇമെയിലോ പാസ്‌വേഡോ തെറ്റാണ്. നിങ്ങൾ പുതിയ ആളാണെങ്കിൽ, താഴെ സൈൻ അപ്പ് അമർത്തുക.';

  @override
  String get accountDisabled => 'ഈ അക്കൗണ്ട് പ്രവർത്തനരഹിതമാക്കിയിരിക്കുന്നു.';

  @override
  String get loginFailed => 'ലോഗിൻ ചെയ്യാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get verifyEmailFirst =>
      'ആദ്യം നിങ്ങളുടെ ഇമെയിൽ സ്ഥിരീകരിക്കുക. നിങ്ങളുടെ ഇൻബോക്സിലേക്ക് അയച്ച ലിങ്ക് തുറക്കുക (സ്പാമും നോക്കുക), തുടർന്ന് വീണ്ടും ലോഗിൻ ചെയ്യുക.';

  @override
  String get verificationSent =>
      'സ്ഥിരീകരണ ഇമെയിൽ അയച്ചു. നിങ്ങളുടെ ഇൻബോക്സ് പരിശോധിക്കുക.';

  @override
  String get accountVerified => 'അക്കൗണ്ട് സ്ഥിരീകരിച്ചു. ലോഗിൻ ചെയ്യുക.';

  @override
  String get welcomeBack => 'വീണ്ടും സ്വാഗതം';

  @override
  String get loginSubtitle =>
      'നിങ്ങളുടെ ഇമെയിലും പാസ്‌വേഡും ഉപയോഗിച്ച് ലോഗിൻ ചെയ്യുക.';

  @override
  String get forgotPassword => 'പാസ്‌വേഡ് മറന്നോ?';

  @override
  String get resendVerification => 'സ്ഥിരീകരണ ഇമെയിൽ വീണ്ടും അയയ്ക്കുക';

  @override
  String get login => 'ലോഗിൻ';

  @override
  String get noAccount => 'അക്കൗണ്ട് ഇല്ലേ?';

  @override
  String get signUp => 'സൈൻ അപ്പ്';

  @override
  String get noAccountFound =>
      'ഈ ഇമെയിലിൽ അക്കൗണ്ട് കണ്ടെത്തിയില്ല. സൈൻ അപ്പ് ചെയ്യുക.';

  @override
  String get couldNotSendEmail =>
      'ഇമെയിൽ അയയ്ക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get forgotSubtitle =>
      'നിങ്ങളുടെ രജിസ്റ്റർ ചെയ്ത ഇമെയിൽ നൽകുക, പുതിയ പാസ്‌വേഡ് തിരഞ്ഞെടുക്കാൻ ഞങ്ങൾ ഒരു ലിങ്ക് അയയ്ക്കും.';

  @override
  String get sendResetLink => 'റീസെറ്റ് ലിങ്ക് അയയ്ക്കുക';

  @override
  String get checkInbox => 'നിങ്ങളുടെ ഇൻബോക്സ് പരിശോധിക്കുക';

  @override
  String get resendLink => 'ലിങ്ക് വീണ്ടും അയയ്ക്കുക';

  @override
  String get changeEmail => 'ഇമെയിൽ മാറ്റുക';

  @override
  String resendIn(int seconds) {
    return '$seconds സെക്കൻഡിൽ വീണ്ടും അയയ്ക്കാം';
  }

  @override
  String resetLinkSent(String email) {
    return 'ഞങ്ങൾ $email ലേക്ക് റീസെറ്റ് ലിങ്ക് അയച്ചു. അത് തുറന്ന്, പുതിയ പാസ്‌വേഡ് തിരഞ്ഞെടുത്ത്, അതുപയോഗിച്ച് ലോഗിൻ ചെയ്യുക.\n\nകാണുന്നില്ലേ? നിങ്ങളുടെ സ്പാം ഫോൾഡറും നോക്കുക.';
  }

  @override
  String get tagline => 'സന്ദേശമയയ്ക്കൽ, മനോഹരമായി ലളിതം.';

  @override
  String get premiumMessaging => 'പ്രീമിയം മെസേജിംഗ്';

  @override
  String get welcomeBody =>
      'നിങ്ങൾക്ക് പ്രധാനപ്പെട്ടവർക്കായി സ്വകാര്യ ചാറ്റുകൾ, വേഗത്തിലുള്ള വിതരണം, ഗ്രൂപ്പുകൾ.';

  @override
  String get getStarted => 'തുടങ്ങാം';

  @override
  String get newHere => 'പുതിയ ആളാണോ?';

  @override
  String get createAnAccount => 'അക്കൗണ്ട് സൃഷ്ടിക്കുക';

  @override
  String get perkPrivate => 'സ്വകാര്യം';

  @override
  String get perkFast => 'വേഗം';

  @override
  String get perkGroups => 'ഗ്രൂപ്പുകൾ';

  @override
  String get accountCreated =>
      'അക്കൗണ്ട് സൃഷ്ടിച്ചു. സ്ഥിരീകരണ ലിങ്കിനായി നിങ്ങളുടെ ഇമെയിൽ പരിശോധിക്കുക, തുടർന്ന് ലോഗിൻ ചെയ്യുക.';

  @override
  String get settingsLanguage => 'ആപ്പ് ഭാഷ';

  @override
  String get systemDefault => 'സിസ്റ്റം ഡിഫോൾട്ട്';

  @override
  String get chooseLanguageHelp =>
      'ആപ്പിന്റെ ഭാഷ തിരഞ്ഞെടുക്കുക. നിങ്ങളുടെ ചാറ്റ് സന്ദേശങ്ങൾ വിവർത്തനം ചെയ്യില്ല.';
}
