// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get firebaseCouldNotStart => 'Firebase தொடங்கவில்லை';

  @override
  String get newMessage => 'புதிய செய்தி';

  @override
  String get newGroupMessage => 'புதிய குழுச் செய்தி';

  @override
  String get photoWord => 'புகைப்படம்';

  @override
  String get chatWord => 'அரட்டை';

  @override
  String get notifTaskChannel => 'பணி நினைவூட்டல்கள்';

  @override
  String get notifTaskChannelDesc => 'உங்கள் பணிகளுக்கான நினைவூட்டல்கள்';

  @override
  String get notifMessagesChannel => 'செய்திகள்';

  @override
  String get notifMessagesChannelDesc =>
      'உங்கள் தொடர்புகளிடமிருந்து புதிய செய்திகள்';

  @override
  String get notifStatusChannel => 'செய்தி நிலை';

  @override
  String get notifStatusChannelDesc =>
      'வெற்றிகரமாக அனுப்பிய செய்திகளுக்கான அறிவிப்புகள்';

  @override
  String get sentPhoto => 'புகைப்படம் வெற்றிகரமாக அனுப்பப்பட்டது';

  @override
  String get sentDocument => 'ஆவணம் வெற்றிகரமாக அனுப்பப்பட்டது';

  @override
  String get sentContact => 'தொடர்பு வெற்றிகரமாக அனுப்பப்பட்டது';

  @override
  String get sentMessage => 'செய்தி வெற்றிகரமாக அனுப்பப்பட்டது';

  @override
  String get justNow => 'இப்போதுதான்';

  @override
  String minutesAgo(int minutes) {
    return '$minutes நிமிடங்களுக்கு முன்';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours மணி நேரத்திற்கு முன்';
  }

  @override
  String get photoTooLarge =>
      'புகைப்படம் மிகவும் பெரியது. சிறியதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get statusText => 'உரை';

  @override
  String get addStatusTitle => 'ஸ்டேட்டஸ் சேர்';

  @override
  String get myStatus => 'என் ஸ்டேட்டஸ்';

  @override
  String get tapToAddStatus => 'ஸ்டேட்டஸ் புதுப்பிப்பைச் சேர்க்கத் தட்டவும்';

  @override
  String get recentUpdates => 'சமீபத்திய புதுப்பிப்புகள்';

  @override
  String get viewedUpdates => 'பார்த்த புதுப்பிப்புகள்';

  @override
  String get noRecentUpdates =>
      'சமீபத்திய புதுப்பிப்புகள் இல்லை.\nஉங்கள் தொடர்புகளின் ஸ்டேட்டஸ்கள் இங்கே தோன்றும், சிறிது நேரத்திற்குப் பிறகு மறைந்துவிடும்.';

  @override
  String get addStatusTooltip => 'ஸ்டேட்டஸ் சேர்';

  @override
  String get textStatusTooltip => 'உரை ஸ்டேட்டஸ்';

  @override
  String get photoStatusTooltip => 'புகைப்பட ஸ்டேட்டஸ்';

  @override
  String get couldNotOpenCameraOrGallery =>
      'கேமரா அல்லது கேலரியைத் திறக்க முடியவில்லை';

  @override
  String statusUpdatesLine(int count, String timeAgo) {
    return '$count புதுப்பிப்புகள் · $timeAgo';
  }

  @override
  String get typeSomethingFirst => 'முதலில் ஏதாவது தட்டச்சு செய்யவும்';

  @override
  String get statusOfflineQueued =>
      'இணையம் இல்லை. நீங்கள் மீண்டும் ஆன்லைனுக்கு வந்ததும் உங்கள் ஸ்டேட்டஸ் பதிவிடப்படும்.';

  @override
  String get addCaption => 'தலைப்பைச் சேர்...';

  @override
  String get typeAStatus => 'ஸ்டேட்டஸை தட்டச்சு செய்யவும்';

  @override
  String get changeColour => 'நிறத்தை மாற்று';

  @override
  String get deleteStatus => 'ஸ்டேட்டஸை நீக்கு';

  @override
  String get noViewsYet => 'இன்னும் பார்வைகள் இல்லை';

  @override
  String get couldNotLoadPhoto => 'இந்தப் புகைப்படத்தை ஏற்ற முடியவில்லை';

  @override
  String viewedBy(int count) {
    return '$count பேர் பார்த்தனர்';
  }

  @override
  String get createTask => 'பணியை உருவாக்கு';

  @override
  String get editTask => 'பணியைத் திருத்து';

  @override
  String get assignTo => 'ஒதுக்கு';

  @override
  String get mePersonalTask => 'நான் (தனிப்பட்ட பணி)';

  @override
  String get noSavedContactsAddFirst =>
      'இன்னும் தொடர்புகள் சேமிக்கப்படவில்லை. முதலில் ஒரு தொடர்பைச் சேர்க்கவும்.';

  @override
  String get titleLabel => 'தலைப்பு';

  @override
  String get taskTitleHint => 'பணியின் தலைப்பு';

  @override
  String get descriptionOptional => 'விளக்கம் (விருப்பம்)';

  @override
  String get addMoreDetails => 'மேலும் விவரங்களைச் சேர்';

  @override
  String get dueDateTime => 'நிலுவைத் தேதி மற்றும் நேரம்';

  @override
  String get reminderLabelText => 'நினைவூட்டல்';

  @override
  String reminderFor(String name) {
    return '$name க்கான நினைவூட்டல்';
  }

  @override
  String reminderGoesToThem(String name) {
    return '$name க்கு இந்த நினைவூட்டல் அவர்களின் தொலைபேசியில் வரும்.';
  }

  @override
  String get saveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get assignTask => 'பணியை ஒதுக்கு';

  @override
  String get saveTask => 'பணியைச் சேமி';

  @override
  String get couldNotSaveTask =>
      'பணியைச் சேமிக்க முடியவில்லை. உங்கள் இணையம் மற்றும் தரவுத்தள விதிகளைச் சரிபார்க்கவும்.';

  @override
  String assignedSuccess(String name) {
    return '$name க்கு ஒதுக்கப்பட்டது. இது அவர்களின் \'என் பணிகள்\' இல் தோன்றும்.';
  }

  @override
  String get taskSavedSuccess => 'உங்கள் பணி வெற்றிகரமாகச் சேமிக்கப்பட்டது.';

  @override
  String get taskUpdated => 'பணி புதுப்பிக்கப்பட்டது!';

  @override
  String get taskAssigned => 'பணி ஒதுக்கப்பட்டது!';

  @override
  String get taskCreated => 'பணி உருவாக்கப்பட்டது!';

  @override
  String get noReminderScheduled =>
      'நினைவூட்டல் திட்டமிடப்படவில்லை: நினைவூட்டல் நேரம் ஏற்கனவே கடந்துவிட்டது, அல்லது அறிவிப்புகள் முடக்கப்பட்டுள்ளன.';

  @override
  String get ok => 'சரி';

  @override
  String get enterTitle => 'தலைப்பை உள்ளிடவும்';

  @override
  String get titleTooLong => 'தலைப்பு மிகவும் நீளமானது';

  @override
  String get descTooLong => 'விளக்கம் மிகவும் நீளமானது';

  @override
  String get newTask => 'புதிய பணி';

  @override
  String get edit => 'திருத்து';

  @override
  String get deleteTaskTitle => 'பணியை நீக்கவா?';

  @override
  String get deleteTaskBody =>
      'இந்தப் பணியும் அதன் நினைவூட்டலும் நீக்கப்படும்.';

  @override
  String get taskDeleted => 'பணி நீக்கப்பட்டது';

  @override
  String get taskCompleted => 'முடிந்தது';

  @override
  String get noReminder => 'நினைவூட்டல் இல்லை';

  @override
  String get pleaseLogInTasks => 'உங்கள் பணிகளைப் பார்க்க உள்நுழையவும்.';

  @override
  String get couldNotLoadTasks =>
      'பணிகளை ஏற்ற முடியவில்லை. உங்கள் இணையம் மற்றும் தரவுத்தள விதிகளைச் சரிபார்க்கவும்.';

  @override
  String get emptyAssignedToMe =>
      'உங்களுக்கு இன்னும் எதுவும் ஒதுக்கப்படவில்லை.';

  @override
  String get emptyAssignedByMe =>
      'நீங்கள் இன்னும் எந்தப் பணியையும் ஒதுக்கவில்லை.\nஅரட்டைச் செய்தியை அழுத்திப் பிடித்து \'பணி உருவாக்கு\' என்பதைத் தட்டவும்.';

  @override
  String get emptyNoTasks =>
      'இன்னும் பணிகள் இல்லை.\nஅரட்டைச் செய்தியை அழுத்திப் பிடித்து \'பணி உருவாக்கு\' என்பதைத் தட்டவும்.';

  @override
  String get emptyList => 'இந்தப் பட்டியலில் பணிகள் இல்லை.';

  @override
  String filterAll(int count) {
    return 'அனைத்தும் ($count)';
  }

  @override
  String filterUpcoming(int count) {
    return 'வரவிருப்பவை ($count)';
  }

  @override
  String filterCompleted(int count) {
    return 'முடிந்தவை ($count)';
  }

  @override
  String filterAssignedToMe(int count) {
    return 'எனக்கு ஒதுக்கப்பட்டவை ($count)';
  }

  @override
  String filterAssignedByMe(int count) {
    return 'நான் ஒதுக்கியவை ($count)';
  }

  @override
  String doneBy(String name) {
    return '$name முடித்தார்';
  }

  @override
  String waitingFor(String name) {
    return '$name க்காகக் காத்திருக்கிறது';
  }

  @override
  String reminderPrefix(String label) {
    return 'நினைவூட்டல்: $label';
  }

  @override
  String assignedByLine(String name) {
    return '$name ஒதுக்கினார்';
  }

  @override
  String assignedToLine(String name) {
    return '$name க்கு ஒதுக்கப்பட்டது';
  }

  @override
  String fromLine(String name) {
    return 'அனுப்பியவர்: $name';
  }

  @override
  String deleteTaskAssignedBody(String name) {
    return 'இந்தப் பணி உங்களுக்கும் $name க்கும் நீக்கப்படும்.';
  }

  @override
  String get couldNotUpdateTask =>
      'பணியைப் புதுப்பிக்க முடியவில்லை. உங்கள் இணைய இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get couldNotDeleteTask =>
      'பணியை நீக்க முடியவில்லை. உங்கள் இணைய இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get reminderAtDue => 'குறிப்பிட்ட நேரத்தில்';

  @override
  String get reminder10Min => '10 நிமிடங்களுக்கு முன்';

  @override
  String get reminder1Hour => '1 மணி நேரத்திற்கு முன்';

  @override
  String get reminder2Hours => '2 மணி நேரத்திற்கு முன்';

  @override
  String get reminder1Day => '1 நாளுக்கு முன்';

  @override
  String get dueNow => 'இப்போது நேரம்';

  @override
  String dueOn(String date, String time) {
    return 'நேரம்: $date, $time';
  }

  @override
  String newTaskFrom(String who) {
    return '$who இடமிருந்து புதிய பணி';
  }

  @override
  String get aContact => 'ஒரு தொடர்பு';

  @override
  String get someone => 'யாரோ';

  @override
  String get save => 'சேமி';

  @override
  String get groupNameTitle => 'குழுவின் பெயர்';

  @override
  String get changeGroupName => 'குழுவின் பெயரை மாற்று';

  @override
  String get addMembers => 'உறுப்பினர்களைச் சேர்';

  @override
  String get groupAdminBadge => 'குழு நிர்வாகி';

  @override
  String get removeFromGroup => 'குழுவிலிருந்து நீக்கு';

  @override
  String get removeAction => 'நீக்கு';

  @override
  String get removeMemberBody =>
      'இந்தக் குழுவின் புதிய செய்திகளை அவர்கள் பெற மாட்டார்கள்.';

  @override
  String get exitGroup => 'குழுவிலிருந்து வெளியேறு';

  @override
  String get exitGroupTitle => 'குழுவிலிருந்து வெளியேறவா?';

  @override
  String get exitAction => 'வெளியேறு';

  @override
  String get exitGroupBody =>
      'இனி இந்தக் குழுவின் செய்திகளை நீங்கள் பெற மாட்டீர்கள்.';

  @override
  String get disappearingGroupHelp =>
      'இந்தக் குழுவின் புதிய செய்திகள் நீங்கள் தேர்ந்தெடுத்த நேரத்திற்குப் பிறகு மறைந்துவிடும்.';

  @override
  String removeMemberTitle(String name) {
    return '$name ஐ நீக்கவா?';
  }

  @override
  String groupMembersLine(int count) {
    return 'குழு · $count உறுப்பினர்கள்';
  }

  @override
  String get addGroupMembers => 'குழு உறுப்பினர்களைச் சேர்';

  @override
  String get noContactsToAdd =>
      'சேர்க்க தொடர்புகள் இல்லை. முதலில் ஒரு தொடர்பைச் சேமிக்கவும்.';

  @override
  String selectedOf(int selected, int total) {
    return '$total இல் $selected தேர்ந்தெடுக்கப்பட்டது';
  }

  @override
  String get addAName => 'பெயரைச் சேர்';

  @override
  String get groupNameHint => 'குழுவின் பெயர் (அவசியம்)';

  @override
  String get groupNameRequired => 'குழுவின் பெயரை தட்டச்சு செய்யவும்';

  @override
  String membersTitle(int count) {
    return 'உறுப்பினர்கள்: $count';
  }

  @override
  String get couldNotRenameGroup => 'குழுவின் பெயரை மாற்ற முடியவில்லை';

  @override
  String get couldNotAddMembers => 'உறுப்பினர்களைச் சேர்க்க முடியவில்லை';

  @override
  String get couldNotRemoveMember => 'இந்த உறுப்பினரை நீக்க முடியவில்லை';

  @override
  String get couldNotExitGroup => 'குழுவிலிருந்து வெளியேற முடியவில்லை';

  @override
  String get pleaseLogInAgain => 'மீண்டும் உள்நுழையவும்';

  @override
  String get noLongerInGroup => 'நீங்கள் இனி இந்தக் குழுவில் இல்லை';

  @override
  String get member => 'உறுப்பினர்';

  @override
  String get today => 'இன்று';

  @override
  String get forwarded => 'அனுப்பப்பட்டது';

  @override
  String disappearingNotice(String label) {
    return '⏱ மறையும் செய்திகள்: $label';
  }

  @override
  String get scheduleTitle => 'அனுப்புவதை திட்டமிடு';

  @override
  String get scheduleTypeFirst =>
      'முதலில் செய்தியை தட்டச்சு செய்யவும் அல்லது படத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get scheduleInvalid => 'எதிர்கால நேரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String tomorrowDay(String day) {
    return 'நாளை, $day';
  }

  @override
  String scheduleToday(String time) {
    return 'இன்று $time மணிக்கு';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'நாளை $time மணிக்கு';
  }

  @override
  String scheduleOn(String day, String time) {
    return '$day அன்று $time மணிக்கு';
  }

  @override
  String sendAt(String label) {
    return '$label அனுப்பு';
  }

  @override
  String scheduledFor(String label) {
    return 'செய்தி $label க்கு திட்டமிடப்பட்டது';
  }

  @override
  String get callsNotInGroups => 'குழுக்களில் அழைப்புகள் இன்னும் இல்லை';

  @override
  String get couldNotIdentifyContact =>
      'தொடர்பின் கணக்கை அடையாளம் காண முடியவில்லை';

  @override
  String get couldNotOpenDialer => 'தொலைபேசி டயலரைத் திறக்க முடியவில்லை';

  @override
  String noPhoneSaved(String name) {
    return '$name க்கு தொலைபேசி எண் சேமிக்கப்படவில்லை';
  }

  @override
  String get couldNotOpenCamera =>
      'கேமராவைத் திறக்க முடியவில்லை. கேமரா அனுமதியைச் சரிபார்க்கவும்.';

  @override
  String get couldNotOpenGallery => 'கேலரியைத் திறக்க முடியவில்லை';

  @override
  String get couldNotPickDocument => 'ஆவணத்தைத் தேர்ந்தெடுக்க முடியவில்லை';

  @override
  String get couldNotOpenFile => 'கோப்பைத் திறக்க முடியவில்லை';

  @override
  String get attachCamera => 'கேமரா';

  @override
  String get attachGallery => 'கேலரி';

  @override
  String get attachContact => 'தொடர்பு';

  @override
  String get attachLocation => 'இடம்';

  @override
  String get locationComingSoon => 'இடப் பகிர்வு விரைவில் வருகிறது';

  @override
  String get shareContactTitle => 'தொடர்பைப் பகிர்';

  @override
  String get forwardToTitle => 'இவர்களுக்கு அனுப்பு...';

  @override
  String get noSavedContacts => 'இன்னும் தொடர்புகள் சேமிக்கப்படவில்லை';

  @override
  String get searchNameOrNumber => 'பெயர் அல்லது எண்ணைத் தேடு';

  @override
  String get noContactFound => 'தொடர்பு எதுவும் இல்லை';

  @override
  String get selectContacts => 'தொடர்புகளைத் தேர்ந்தெடு';

  @override
  String sendToCount(int count) {
    return '$count பேருக்கு அனுப்பு';
  }

  @override
  String get cardMessage => 'செய்தி';

  @override
  String get alreadyInContacts => 'ஏற்கனவே உங்கள் தொடர்புகளில் உள்ளது';

  @override
  String get ownNumber => 'இது உங்கள் சொந்த எண்';

  @override
  String get contactSavedShort => 'தொடர்பு சேமிக்கப்பட்டது';

  @override
  String get couldNotSaveContact =>
      'தொடர்பைச் சேமிக்க முடியவில்லை. தரவுத்தள விதிகளைச் சரிபார்க்கவும்.';

  @override
  String get waitUntilSent => 'செய்தி அனுப்பப்படும் வரை காத்திருக்கவும்';

  @override
  String get messageForwarded => 'செய்தி அனுப்பப்பட்டது';

  @override
  String forwardedToCount(int done, int total) {
    return '$total தொடர்புகளில் $done பேருக்கு அனுப்பப்பட்டது';
  }

  @override
  String get voiceLanguageTitle => 'குரல் தட்டச்சு மொழி';

  @override
  String get voiceLanguageHelp =>
      'மைக் ஒரு நேரத்தில் ஒரு மொழியை மட்டுமே கேட்கும். நீங்கள் பேசும் மொழியைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get listening => 'கேட்கிறது...';

  @override
  String voiceLanguageChosen(String name) {
    return 'குரல் தட்டச்சு மொழி: $name';
  }

  @override
  String listeningIn(String name) {
    return '$name இல் கேட்கிறது...';
  }

  @override
  String get reply => 'பதிலளி';

  @override
  String get forward => 'அனுப்பு';

  @override
  String get tryAgain => 'மீண்டும் முயல்';

  @override
  String get copy => 'நகலெடு';

  @override
  String get copied => 'நகலெடுக்கப்பட்டது';

  @override
  String get messageDeleted => 'செய்தி நீக்கப்பட்டது';

  @override
  String get clearChatTitle => 'அரட்டையை அழிக்கவா?';

  @override
  String get clear => 'அழி';

  @override
  String clearGroupBody(String title) {
    return '$title இல் உள்ள அனைத்துச் செய்திகளும் அனைவருக்கும் நீக்கப்படும்.';
  }

  @override
  String clearChatBody(String name) {
    return '$name உடனான அனைத்துச் செய்திகளும் நீக்கப்படும்.';
  }

  @override
  String get couldNotLoadMessages =>
      'செய்திகளை ஏற்ற முடியவில்லை. உங்கள் Firebase Realtime Database விதிகளைச் சரிபார்க்கவும்.';

  @override
  String get noMessagesYet => 'இன்னும் செய்திகள் இல்லை\nஹாய் சொல்லுங்கள் 👋';

  @override
  String get messageHint => 'செய்தி';

  @override
  String get photoAttached => 'புகைப்படம் இணைக்கப்பட்டது';

  @override
  String get removePhoto => 'புகைப்படத்தை நீக்கு';

  @override
  String get groupInfo => 'குழுத் தகவல்';

  @override
  String get viewProfile => 'சுயவிவரத்தைப் பார்';

  @override
  String get searchHint => 'தேடு...';

  @override
  String get noResults => 'முடிவுகள் இல்லை';

  @override
  String matchOf(int current, int total) {
    return '$total இல் $current';
  }

  @override
  String get couldNotSendMessage =>
      'செய்தியை அனுப்ப முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get couldNotScheduleMessage =>
      'செய்தியைத் திட்டமிட முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get nothingToSend => 'அனுப்ப எதுவும் இல்லை';

  @override
  String get imageTooLarge =>
      'படம் மிகவும் பெரியது. சிறிய புகைப்படத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get couldNotShareContact =>
      'தொடர்பைப் பகிர முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get documentsOnlineOnly =>
      'நீங்கள் ஆன்லைனில் இருக்கும்போது மட்டுமே ஆவணங்களை அனுப்ப முடியும்.';

  @override
  String get couldNotSaveAttachment =>
      'இணைப்பைச் சேமிக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get couldNotDeleteMessage => 'செய்தியை நீக்க முடியவில்லை';

  @override
  String get couldNotClearChat => 'அரட்டையை அழிக்க முடியவில்லை';

  @override
  String get reactionFailed =>
      'எதிர்வினையைச் சேர்க்க முடியவில்லை. தரவுத்தள விதிகளைச் சரிபார்க்கவும்.';

  @override
  String voiceNoSpeech(String language) {
    return '$language இல் எதுவும் கேட்கவில்லை. மைக்கைத் தட்டி தெளிவாகப் பேசுங்கள், அல்லது மொழியை மாற்றுங்கள் (மைக்கை அழுத்திப் பிடிக்கவும்).';
  }

  @override
  String get micPermission => 'இந்த ஆப்பிற்கு மைக்ரோஃபோன் அனுமதியை வழங்கவும்';

  @override
  String voiceLangNotReady(String language) {
    return 'இந்தத் தொலைபேசியில் $language குரல் தட்டச்சு தயாராக இல்லை.\nஇணையத்துடன் இணையுங்கள், அல்லது தொலைபேசியின் Google குரல் தட்டச்சு அமைப்புகளில் $language ஐப் பதிவிறக்கவும்.';
  }

  @override
  String voiceNetworkError(String error, String language) {
    return 'குரல் பிழை: $error\nஉங்கள் இணையத்தைச் சரிபார்க்கவும், அல்லது ஆஃப்லைன் பயன்பாட்டிற்கு தொலைபேசி அமைப்புகளில் $language ஐப் பதிவிறக்கவும், அல்லது உங்கள் செய்தியை தட்டச்சு செய்யவும்.';
  }

  @override
  String speechError(String error) {
    return 'பேச்சுப் பிழை: $error';
  }

  @override
  String get micPermissionNeeded =>
      'மைக்ரோஃபோன் அனுமதி தேவை. ஆப் அமைப்புகளில் அனுமதிக்கவும்.';

  @override
  String get you => 'நீங்கள்';

  @override
  String get attachDocument => 'ஆவணம்';

  @override
  String get clearChat => 'அரட்டையை அழி';

  @override
  String get mediaLinksDocs => 'மீடியா, இணைப்புகள் மற்றும் ஆவணங்கள்';

  @override
  String get disappearingTitle => 'மறையும் செய்திகள்';

  @override
  String get disappearOff => 'முடக்கம்';

  @override
  String get disappear5Min => '5 நிமிடங்கள்';

  @override
  String get disappear1Day => '1 நாள்';

  @override
  String get disappear7Days => '7 நாட்கள்';

  @override
  String get contactInfoTitle => 'தொடர்புத் தகவல்';

  @override
  String get phoneUnavailable => 'தொலைபேசி எண் இல்லை';

  @override
  String get actionAudio => 'ஆடியோ';

  @override
  String get actionVideo => 'வீடியோ';

  @override
  String get mediaVisibility => 'மீடியா தெரிவுநிலை';

  @override
  String get encryption => 'மறையாக்கம்';

  @override
  String get encryptionSub =>
      'செய்திகளும் அழைப்புகளும் இன்னும் முழுமையாக மறையாக்கம் செய்யப்படவில்லை.';

  @override
  String get blockContact => 'தொடர்பைத் தடு';

  @override
  String get disappearingChatHelp =>
      'இந்த அரட்டையின் புதிய செய்திகள் நீங்கள் தேர்ந்தெடுத்த நேரத்திற்குப் பிறகு மறைந்துவிடும்.';

  @override
  String get couldNotChangeSetting =>
      'அமைப்பை மாற்ற முடியவில்லை. உங்கள் இணையத்தைச் சரிபார்க்கவும்.';

  @override
  String get notificationSettingsMsg => 'அறிவிப்பு அமைப்புகள்';

  @override
  String get mediaVisibilitySettingsMsg => 'மீடியா தெரிவுநிலை அமைப்புகள்';

  @override
  String get encryptionMsg =>
      'இந்த ஆப் தற்போது முழுமையான மறையாக்கத்தைச் செயல்படுத்தவில்லை.';

  @override
  String get blockingNotImplemented =>
      'தொடர்பைத் தடுக்கும் வசதி இன்னும் செயல்படுத்தப்படவில்லை.';

  @override
  String get calling => 'அழைக்கிறது...';

  @override
  String get videoCalling => 'வீடியோ அழைப்பு...';

  @override
  String get callSpeaker => 'ஸ்பீக்கர்';

  @override
  String get callMute => 'ஒலியடக்கு';

  @override
  String get callFlip => 'மாற்று';

  @override
  String get callMore => 'மேலும்';

  @override
  String get callShare => 'பகிர்';

  @override
  String get callEnd => 'முடி';

  @override
  String get addPeopleSoon => 'நபர்களைச் சேர்க்கும் வசதி விரைவில் வருகிறது';

  @override
  String get moreOptionsSoon => 'மேலும் விருப்பங்கள் விரைவில் வருகின்றன';

  @override
  String get sharingSoon => 'பகிர்வு விரைவில் வருகிறது';

  @override
  String get noCameraFound => 'இந்தச் சாதனத்தில் கேமரா இல்லை';

  @override
  String get cameraPermissionDenied =>
      'கேமரா அனுமதி மறுக்கப்பட்டது. ஆப் அமைப்புகளில் அனுமதிக்கவும்.';

  @override
  String get callCouldNotOpenCamera => 'கேமராவைத் திறக்க முடியவில்லை';

  @override
  String get nothingToOpen => 'இங்கே திறக்க எதுவும் இல்லை';

  @override
  String get couldNotOpenThis => 'இதைத் திறக்க முடியவில்லை';

  @override
  String get tabMedia => 'மீடியா';

  @override
  String get tabDocs => 'ஆவணங்கள்';

  @override
  String get tabLinks => 'இணைப்புகள்';

  @override
  String get noPhotosYet => 'இன்னும் புகைப்படங்கள் பகிரப்படவில்லை';

  @override
  String get noDocsYet => 'இன்னும் ஆவணங்கள் பகிரப்படவில்லை';

  @override
  String get noLinksYet => 'இன்னும் இணைப்புகள் பகிரப்படவில்லை';

  @override
  String get couldNotLoadMedia =>
      'ஏற்ற முடியவில்லை. உங்கள் Firebase Realtime Database விதிகளைச் சரிபார்க்கவும்.';

  @override
  String sharedBy(String who, String date) {
    return '$who  •  $date';
  }

  @override
  String linkSubtitle(String title, String who, String date) {
    return '$title\n$who  •  $date';
  }

  @override
  String get waitingOne => '1 செய்தி அனுப்பக் காத்திருக்கிறது.';

  @override
  String waitingMany(int count) {
    return '$count செய்திகள் அனுப்பக் காத்திருக்கின்றன.';
  }

  @override
  String offlineWithPending(String waiting) {
    return 'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள். $waiting';
  }

  @override
  String get offlineNoPending =>
      'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள். உங்கள் இணைய இணைப்பை இயக்கவும்.';

  @override
  String connectingWithPending(String waiting) {
    return 'இணைக்கிறது... $waiting';
  }

  @override
  String get connecting => 'இணைக்கிறது...';

  @override
  String get backOnlineSending =>
      'மீண்டும் ஆன்லைனில் உள்ளீர்கள். உங்கள் செய்திகள் அனுப்பப்படுகின்றன...';

  @override
  String get backOnline => 'நீங்கள் மீண்டும் ஆன்லைனில் உள்ளீர்கள்.';

  @override
  String get saveContact => 'தொடர்பைச் சேமி';

  @override
  String get addContactTitle => 'தொடர்பைச் சேர்';

  @override
  String get addContactSubtitle =>
      'பதிவு செய்த மின்னஞ்சலை உள்ளிடவும், மீதமுள்ளவை தானாக நிரப்பப்படும்.';

  @override
  String get contactNameLabel => 'பயனர் பெயர்';

  @override
  String get registeredEmailLabel => 'பதிவு செய்த மின்னஞ்சல் முகவரி';

  @override
  String get userFound => 'பதிவு செய்த பயனர் கிடைத்தார்';

  @override
  String get userFoundNoPhone =>
      'பதிவு செய்த பயனர் கிடைத்தார். அவர் தொலைபேசி எண்ணைச் சேர்க்கவில்லை, கீழே தட்டச்சு செய்யவும்.';

  @override
  String get userNotFound => 'இந்த மின்னஞ்சலுடன் பதிவு செய்த பயனர் இல்லை';

  @override
  String get cannotAddSelf => 'உங்கள் சொந்தக் கணக்கைச் சேர்க்க முடியாது.';

  @override
  String get lookupFailed => 'இந்த மின்னஞ்சலைத் தேட முடியவில்லை.';

  @override
  String get lookupFailedInternet =>
      'இந்த மின்னஞ்சலைத் தேட முடியவில்லை. உங்கள் இணைய இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String userFoundName(String name) {
    return 'பதிவு செய்த பயனர் கிடைத்தார்: $name';
  }

  @override
  String lookupFailedCode(String code) {
    return 'இந்த மின்னஞ்சலைத் தேட முடியவில்லை ($code).';
  }

  @override
  String get enterContactName => 'பயனர் பெயரை உள்ளிடவும்';

  @override
  String get nameTooShort => 'பெயர் குறைந்தது 4 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get nameTooLong => 'பெயர் அதிகபட்சம் 40 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get enterRegisteredEmail =>
      'பதிவு செய்த மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get enterValidEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get loginAgainToSave =>
      'தொடர்புகளைச் சேமிக்கும் முன் மீண்டும் உள்நுழையவும்.';

  @override
  String get userAlreadyInContacts =>
      'இந்தப் பயனர் ஏற்கனவே உங்கள் தொடர்புகளில் உள்ளார்.';

  @override
  String get firebaseDenied =>
      'Firebase அணுகலை மறுத்தது. உங்கள் தரவுத்தள விதிகளைச் சரிபார்க்கவும்.';

  @override
  String get unknownError => 'தெரியாத பிழை';

  @override
  String firebaseError(String code, String message) {
    return 'Firebase பிழை ($code): $message';
  }

  @override
  String get profileTitle => 'சுயவிவரம்';

  @override
  String get nameLabel => 'பெயர்';

  @override
  String get phoneLabel => 'தொலைபேசி';

  @override
  String get notAdded => 'சேர்க்கப்படவில்லை';

  @override
  String get saveName => 'பெயரைச் சேமி';

  @override
  String get profileNameUpdated => 'பெயர் புதுப்பிக்கப்பட்டது';

  @override
  String get nameSavedNote =>
      'உங்களைச் சேமித்தவர்கள் தாங்கள் தேர்ந்தெடுத்த பெயரையே வைத்திருப்பார்கள்.';

  @override
  String get enterYourName => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get pleaseLogInBeforePicture =>
      'படத்தை மாற்றும் முன் மீண்டும் உள்நுழையவும்.';

  @override
  String get pictureTooLarge =>
      'இந்தப் படம் மிகவும் பெரியது. சிறிய படத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get youAreOfflineTryAgain =>
      'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள். இணையத்தில் இணைந்து மீண்டும் முயலவும்.';

  @override
  String profileUpdateFailed(String error) {
    return 'சுயவிவரப் புதுப்பிப்பு தோல்வியடைந்தது: $error';
  }

  @override
  String get pleaseLogInBeforeName =>
      'பெயரை மாற்றும் முன் மீண்டும் உள்நுழையவும்.';

  @override
  String get serverNoAnswer =>
      'சர்வர் பதிலளிக்கவில்லை. உங்கள் இணைய இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String couldNotSaveNameCode(String code) {
    return 'உங்கள் பெயரைச் சேமிக்க முடியவில்லை ($code). மீண்டும் முயலவும்.';
  }

  @override
  String get couldNotSaveName =>
      'உங்கள் பெயரைச் சேமிக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get delete => 'நீக்கு';

  @override
  String get yesterday => 'நேற்று';

  @override
  String get videoCallNoAnswer => 'வீடியோ அழைப்பு · பதில் இல்லை';

  @override
  String get missedVideoCall => 'தவறிய வீடியோ அழைப்பு';

  @override
  String youPrefix(String text) {
    return 'நீங்கள்: $text';
  }

  @override
  String get deleteChatTitle => 'அரட்டையை நீக்கவா?';

  @override
  String deleteChatsTitle(int count) {
    return '$count அரட்டைகளை நீக்கவா?';
  }

  @override
  String get deleteChatBody =>
      'அரட்டை உங்கள் பட்டியலிலிருந்து மட்டுமே நீக்கப்படும். மற்றவர்கள் தங்கள் செய்திகளை வைத்திருப்பார்கள். புதிய செய்தி வந்தால் அரட்டை மீண்டும் தோன்றும்.';

  @override
  String get chatDeleted => 'அரட்டை நீக்கப்பட்டது';

  @override
  String chatsDeleted(int count) {
    return '$count அரட்டைகள் நீக்கப்பட்டன';
  }

  @override
  String get couldNotDelete =>
      'நீக்க முடியவில்லை. உங்கள் இணையத்தைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get newChat => 'புதிய அரட்டை';

  @override
  String get newGroup => 'புதிய குழு';

  @override
  String get newContact => 'புதிய தொடர்பு';

  @override
  String membersCount(int count) {
    return '$count உறுப்பினர்கள்';
  }

  @override
  String get tapToStartChatting => 'அரட்டையைத் தொடங்கத் தட்டவும்';

  @override
  String get offlineNoContacts =>
      'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள். இந்தச் சாதனத்தில் இன்னும் தொடர்புகள் சேமிக்கப்படவில்லை.';

  @override
  String get noChatsYet =>
      'இன்னும் அரட்டைகள் இல்லை. தொடர்பைச் சேர்க்க அல்லது குழுவை உருவாக்க + ஐத் தட்டவும்.';

  @override
  String get updates => 'புதுப்பிப்புகள்';

  @override
  String get chats => 'அரட்டைகள்';

  @override
  String get search => 'தேடு';

  @override
  String get closeSearch => 'தேடலை மூடு';

  @override
  String get myTasks => 'என் பணிகள்';

  @override
  String get pleaseLogIn => 'உங்கள் தொடர்புகளைப் பார்க்க உள்நுழையவும்.';

  @override
  String get contactSaved => 'தொடர்பு வெற்றிகரமாகச் சேமிக்கப்பட்டது.';

  @override
  String get searchSettings => 'அமைப்புகளைத் தேடு';

  @override
  String get noSettingsFound => 'அமைப்புகள் எதுவும் இல்லை';

  @override
  String get addNewContact => 'புதிய தொடர்பைச் சேர்';

  @override
  String get addNewContactSub => 'அரட்டையைத் தொடங்க தொடர்பைச் சேமிக்கவும்';

  @override
  String get settingsAccount => 'கணக்கு';

  @override
  String get settingsAccountSub => 'பாதுகாப்பு அறிவிப்புகள், கணக்குத் தகவல்';

  @override
  String get settingsPrivacy => 'தனியுரிமை';

  @override
  String get settingsPrivacySub => 'தடுக்கப்பட்ட தொடர்புகள், மறையும் செய்திகள்';

  @override
  String get settingsChatsSub => 'தீம், வால்பேப்பர், அரட்டை வரலாறு';

  @override
  String get settingsNotifications => 'அறிவிப்புகள்';

  @override
  String get settingsNotificationsSub => 'செய்தி, குழு மற்றும் அழைப்பு ஒலிகள்';

  @override
  String get settingsStorage => 'சேமிப்பகம் மற்றும் தரவு';

  @override
  String get settingsStorageSub => 'நெட்வொர்க் பயன்பாடு, தானியங்கி பதிவிறக்கம்';

  @override
  String get settingsHelp => 'உதவி மற்றும் கருத்து';

  @override
  String get settingsHelpSub =>
      'உதவி மையம், எங்களைத் தொடர்பு கொள்ளுங்கள், தனியுரிமைக் கொள்கை';

  @override
  String get logOut => 'வெளியேறு';

  @override
  String get logOutTitle => 'வெளியேறவா?';

  @override
  String get logOutBody => 'உங்கள் கணக்கிலிருந்து வெளியேற விரும்புகிறீர்களா?';

  @override
  String get profilePhotoUpdated =>
      'சுயவிவரப் படம் புதுப்பிக்கப்பட்டது. இப்போது உங்கள் தொடர்புகள் அதைப் பார்க்கலாம்.';

  @override
  String get createAccount => 'கணக்கை உருவாக்குங்கள்';

  @override
  String get signupSubtitle => 'தொடங்க உங்கள் மின்னஞ்சலுடன் பதிவு செய்யுங்கள்.';

  @override
  String get nickname => 'புனைப்பெயர்';

  @override
  String get code => 'குறியீடு';

  @override
  String get phoneNumber => 'தொலைபேசி எண்';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்துங்கள்';

  @override
  String get register => 'பதிவு செய்';

  @override
  String get haveAccount => 'ஏற்கனவே கணக்கு உள்ளதா?';

  @override
  String get logInLink => 'உள்நுழையுங்கள்';

  @override
  String get ruleLength => 'குறைந்தது 8 எழுத்துகள்';

  @override
  String get ruleCapital => '1 பெரிய எழுத்து (A-Z)';

  @override
  String get ruleSmall => '1 சிறிய எழுத்து (a-z)';

  @override
  String get ruleNumber => '1 எண் (0-9)';

  @override
  String get ruleSpecial => '1 சிறப்பு எழுத்து (! @ # \$ %)';

  @override
  String get enterNickname => 'புனைப்பெயரை உள்ளிடவும்';

  @override
  String get useAtLeast3 => 'குறைந்தது 3 எழுத்துகளைப் பயன்படுத்தவும்';

  @override
  String get useAtMost20 => 'அதிகபட்சம் 20 எழுத்துகளைப் பயன்படுத்தவும்';

  @override
  String get enterNewPassword => 'கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get useAtLeast8 => 'குறைந்தது 8 எழுத்துகளைப் பயன்படுத்தவும்';

  @override
  String get noSpaces => 'கடவுச்சொல்லில் இடைவெளிகள் இருக்கக் கூடாது';

  @override
  String get addCapital => '1 பெரிய எழுத்தைச் சேர்க்கவும் (A-Z)';

  @override
  String get addSmall => '1 சிறிய எழுத்தைச் சேர்க்கவும் (a-z)';

  @override
  String get addNumber => '1 எண்ணைச் சேர்க்கவும் (0-9)';

  @override
  String get addSpecial => '1 சிறப்பு எழுத்தைச் சேர்க்கவும் (! @ # \$ % & *)';

  @override
  String get confirmYourPassword => 'உங்கள் கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get passwordsDontMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get emailAlreadyRegistered =>
      'இந்த மின்னஞ்சல் ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது. உள்நுழையவும்.';

  @override
  String get weakPassword =>
      'இந்தக் கடவுச்சொல் மிகவும் பலவீனமானது. வேறொன்றைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get signupNotEnabled =>
      'Firebase கன்சோலில் மின்னஞ்சல்/கடவுச்சொல் பதிவு இயக்கப்படவில்லை.';

  @override
  String get signupFailed => 'கணக்கை உருவாக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get createAccountWentWrong =>
      'கணக்கை உருவாக்கும்போது ஏதோ தவறு நடந்தது. மீண்டும் முயலவும்.';

  @override
  String get accountNotCreated =>
      'கணக்கை உருவாக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get phoneAlreadyRegistered =>
      'இந்தத் தொலைபேசி எண் ஏற்கனவே வேறொரு கணக்கில் பதிவு செய்யப்பட்டுள்ளது. வேறு எண்ணைப் பயன்படுத்தவும்.';

  @override
  String get phoneCheckFailed =>
      'தொலைபேசி எண்ணைச் சரிபார்க்க முடியவில்லை. உங்கள் இணைய இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get phoneJustTaken =>
      'இந்தத் தொலைபேசி எண்ணை இப்போதுதான் வேறொரு கணக்கு பதிவு செய்தது. வேறு எண்ணைப் பயன்படுத்தவும்.';

  @override
  String get phoneSaveFailed =>
      'தொலைபேசி எண்ணைச் சேமிக்க முடியவில்லை. உங்கள் இணைய இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String phoneSaveFailedCode(String code) {
    return 'தொலைபேசி எண்ணைச் சேமிக்க முடியவில்லை ($code). மீண்டும் முயலவும்.';
  }

  @override
  String get verificationCancelled =>
      'சரிபார்ப்பு ரத்து செய்யப்பட்டது, எனவே கணக்கு எதுவும் உருவாக்கப்படவில்லை. மீண்டும் முயலவும்.';

  @override
  String get enterPhone => 'தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get digitsOnly => 'இலக்கங்களை மட்டும் பயன்படுத்தவும்';

  @override
  String get invalidPhone =>
      'சரியான தொலைபேசி எண்ணை உள்ளிடவும் (6–15 இலக்கங்கள்)';

  @override
  String get verifyYourEmail => 'உங்கள் மின்னஞ்சலைச் சரிபார்க்கவும்';

  @override
  String otpSentTo(String email) {
    return 'அனுப்பப்பட்ட 4 இலக்கக் குறியீட்டை உள்ளிடவும்\n$email';
  }

  @override
  String get enterAllDigits => '4 இலக்கங்களையும் உள்ளிடவும்';

  @override
  String get wrongOtp => 'தவறான OTP, மீண்டும் முயலவும்';

  @override
  String get messages => 'செய்திகள்';

  @override
  String get now => 'இப்போது';

  @override
  String otpMessage(String appName, String code) {
    return 'உங்கள் $appName சரிபார்ப்புக் குறியீடு $code. இதை யாருடனும் பகிர வேண்டாம்.';
  }

  @override
  String resendCodeIn(String time) {
    return '$time இல் குறியீட்டை மீண்டும் அனுப்பலாம்';
  }

  @override
  String get resendCode => 'குறியீட்டை மீண்டும் அனுப்பு';

  @override
  String get verify => 'சரிபார்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get backToLogin => 'உள்நுழைவுக்குத் திரும்பு';

  @override
  String get enterEmail => 'உங்கள் மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get invalidEmail =>
      'சரியான மின்னஞ்சலை உள்ளிடவும் (எடுத்துக்காட்டு: name@gmail.com)';

  @override
  String get invalidEmailAddress => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்.';

  @override
  String get tooManyAttempts => 'அதிக முயற்சிகள். பிறகு மீண்டும் முயலவும்.';

  @override
  String get networkError =>
      'நெட்வொர்க் பிழை. உங்கள் இணைய இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get somethingWentWrong => 'ஏதோ தவறு நடந்தது. மீண்டும் முயலவும்.';

  @override
  String get enterPassword => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get loginCredentials =>
      'மின்னஞ்சல் அல்லது கடவுச்சொல் தவறானது. நீங்கள் புதியவர் என்றால், கீழே பதிவு செய் என்பதை அழுத்தவும்.';

  @override
  String get accountDisabled => 'இந்தக் கணக்கு முடக்கப்பட்டுள்ளது.';

  @override
  String get loginFailed => 'உள்நுழைய முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get verifyEmailFirst =>
      'முதலில் உங்கள் மின்னஞ்சலைச் சரிபார்க்கவும். உங்கள் இன்பாக்ஸுக்கு அனுப்பிய இணைப்பைத் திறக்கவும் (ஸ்பாமையும் பார்க்கவும்), பிறகு மீண்டும் உள்நுழையவும்.';

  @override
  String get verificationSent =>
      'சரிபார்ப்பு மின்னஞ்சல் அனுப்பப்பட்டது. உங்கள் இன்பாக்ஸைப் பார்க்கவும்.';

  @override
  String get accountVerified => 'கணக்கு சரிபார்க்கப்பட்டது. உள்நுழையவும்.';

  @override
  String get welcomeBack => 'மீண்டும் வருக';

  @override
  String get loginSubtitle =>
      'உங்கள் மின்னஞ்சல் மற்றும் கடவுச்சொல்லுடன் உள்நுழையவும்.';

  @override
  String get forgotPassword => 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?';

  @override
  String get resendVerification => 'சரிபார்ப்பு மின்னஞ்சலை மீண்டும் அனுப்பு';

  @override
  String get login => 'உள்நுழை';

  @override
  String get noAccount => 'கணக்கு இல்லையா?';

  @override
  String get signUp => 'பதிவு செய்';

  @override
  String get noAccountFound =>
      'இந்த மின்னஞ்சலுடன் கணக்கு எதுவும் இல்லை. பதிவு செய்யவும்.';

  @override
  String get couldNotSendEmail =>
      'மின்னஞ்சலை அனுப்ப முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get forgotSubtitle =>
      'உங்கள் பதிவு செய்த மின்னஞ்சலை உள்ளிடவும், புதிய கடவுச்சொல்லைத் தேர்ந்தெடுக்க ஒரு இணைப்பை அனுப்புவோம்.';

  @override
  String get sendResetLink => 'மீட்டமைப்பு இணைப்பை அனுப்பு';

  @override
  String get checkInbox => 'உங்கள் இன்பாக்ஸைப் பார்க்கவும்';

  @override
  String get resendLink => 'இணைப்பை மீண்டும் அனுப்பு';

  @override
  String get changeEmail => 'மின்னஞ்சலை மாற்று';

  @override
  String resendIn(int seconds) {
    return '$seconds வினாடியில் மீண்டும் அனுப்பலாம்';
  }

  @override
  String resetLinkSent(String email) {
    return '$email க்கு மீட்டமைப்பு இணைப்பை அனுப்பியுள்ளோம். அதைத் திறந்து, புதிய கடவுச்சொல்லைத் தேர்ந்தெடுத்து, பிறகு அதைக் கொண்டு உள்நுழையவும்.\n\nதெரியவில்லையா? உங்கள் ஸ்பாம் கோப்புறையையும் பார்க்கவும்.';
  }

  @override
  String get tagline => 'செய்தி அனுப்புதல், அழகாக எளிமை.';

  @override
  String get premiumMessaging => 'பிரீமியம் மெசேஜிங்';

  @override
  String get welcomeBody =>
      'உங்களுக்கு முக்கியமானவர்களுக்கான தனிப்பட்ட அரட்டைகள், வேகமான விநியோகம் மற்றும் குழுக்கள்.';

  @override
  String get getStarted => 'தொடங்குங்கள்';

  @override
  String get newHere => 'புதியவரா?';

  @override
  String get createAnAccount => 'கணக்கை உருவாக்குங்கள்';

  @override
  String get perkPrivate => 'தனிப்பட்டது';

  @override
  String get perkFast => 'வேகம்';

  @override
  String get perkGroups => 'குழுக்கள்';

  @override
  String get accountCreated =>
      'கணக்கு உருவாக்கப்பட்டது. சரிபார்ப்பு இணைப்புக்கு உங்கள் மின்னஞ்சலைப் பார்த்து, பின்னர் உள்நுழையுங்கள்.';

  @override
  String get settingsLanguage => 'ஆப் மொழி';

  @override
  String get systemDefault => 'சிஸ்டம் இயல்புநிலை';

  @override
  String get chooseLanguageHelp =>
      'ஆப்பின் மொழியைத் தேர்ந்தெடுங்கள். உங்கள் அரட்டைச் செய்திகள் மொழிபெயர்க்கப்படாது.';

  @override
  String get settingsTheme => 'தீம்';

  @override
  String get chooseTheme => 'தீமைத் தேர்ந்தெடுக்கவும்';

  @override
  String get themeLight => 'லைட்';

  @override
  String get themeDark => 'டார்க்';
}
