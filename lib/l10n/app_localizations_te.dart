// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get firebaseCouldNotStart => 'Firebase ప్రారంభం కాలేదు';

  @override
  String get newMessage => 'కొత్త సందేశం';

  @override
  String get newGroupMessage => 'కొత్త గ్రూప్ సందేశం';

  @override
  String get photoWord => 'ఫోటో';

  @override
  String get chatWord => 'చాట్';

  @override
  String get notifTaskChannel => 'పని రిమైండర్‌లు';

  @override
  String get notifTaskChannelDesc => 'మీ పనుల కోసం రిమైండర్‌లు';

  @override
  String get notifMessagesChannel => 'సందేశాలు';

  @override
  String get notifMessagesChannelDesc => 'మీ కాంటాక్ట్‌ల నుండి కొత్త సందేశాలు';

  @override
  String get notifStatusChannel => 'సందేశ స్థితి';

  @override
  String get notifStatusChannelDesc =>
      'విజయవంతంగా పంపిన సందేశాల నోటిఫికేషన్‌లు';

  @override
  String get sentPhoto => 'ఫోటో విజయవంతంగా పంపబడింది';

  @override
  String get sentDocument => 'పత్రం విజయవంతంగా పంపబడింది';

  @override
  String get sentContact => 'కాంటాక్ట్ విజయవంతంగా పంపబడింది';

  @override
  String get sentMessage => 'సందేశం విజయవంతంగా పంపబడింది';

  @override
  String get justNow => 'ఇప్పుడే';

  @override
  String minutesAgo(int minutes) {
    return '$minutes నిమిషాల క్రితం';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours గంటల క్రితం';
  }

  @override
  String get photoTooLarge =>
      'ఫోటో చాలా పెద్దది. దయచేసి చిన్నదాన్ని ఎంచుకోండి.';

  @override
  String get statusText => 'టెక్స్ట్';

  @override
  String get addStatusTitle => 'స్టేటస్ జోడించండి';

  @override
  String get myStatus => 'నా స్టేటస్';

  @override
  String get tapToAddStatus => 'స్టేటస్ అప్‌డేట్ జోడించడానికి నొక్కండి';

  @override
  String get recentUpdates => 'ఇటీవలి అప్‌డేట్‌లు';

  @override
  String get viewedUpdates => 'చూసిన అప్‌డేట్‌లు';

  @override
  String get noRecentUpdates =>
      'ఇటీవలి అప్‌డేట్‌లు లేవు.\nమీ కాంటాక్ట్‌ల స్టేటస్‌లు ఇక్కడ కనిపిస్తాయి మరియు కొద్ది సమయం తర్వాత అదృశ్యమవుతాయి.';

  @override
  String get addStatusTooltip => 'స్టేటస్ జోడించండి';

  @override
  String get textStatusTooltip => 'టెక్స్ట్ స్టేటస్';

  @override
  String get photoStatusTooltip => 'ఫోటో స్టేటస్';

  @override
  String get couldNotOpenCameraOrGallery =>
      'కెమెరా లేదా గ్యాలరీని తెరవడం సాధ్యం కాలేదు';

  @override
  String statusUpdatesLine(int count, String timeAgo) {
    return '$count అప్‌డేట్‌లు · $timeAgo';
  }

  @override
  String get typeSomethingFirst => 'ముందుగా ఏదైనా టైప్ చేయండి';

  @override
  String get statusOfflineQueued =>
      'ఇంటర్నెట్ లేదు. మీరు ఆన్‌లైన్‌లోకి వచ్చాక మీ స్టేటస్ పోస్ట్ అవుతుంది.';

  @override
  String get addCaption => 'క్యాప్షన్ జోడించండి...';

  @override
  String get typeAStatus => 'స్టేటస్ టైప్ చేయండి';

  @override
  String get changeColour => 'రంగు మార్చండి';

  @override
  String get deleteStatus => 'స్టేటస్‌ను తొలగించండి';

  @override
  String get noViewsYet => 'ఇంకా వీక్షణలు లేవు';

  @override
  String get couldNotLoadPhoto => 'ఈ ఫోటోను లోడ్ చేయడం సాధ్యం కాలేదు';

  @override
  String viewedBy(int count) {
    return '$count మంది చూశారు';
  }

  @override
  String get createTask => 'పని సృష్టించండి';

  @override
  String get editTask => 'పనిని సవరించండి';

  @override
  String get assignTo => 'కేటాయించండి';

  @override
  String get mePersonalTask => 'నేను (వ్యక్తిగత పని)';

  @override
  String get noSavedContactsAddFirst =>
      'ఇంకా కాంటాక్ట్‌లు సేవ్ చేయలేదు. ముందుగా ఒక కాంటాక్ట్‌ను జోడించండి.';

  @override
  String get titleLabel => 'శీర్షిక';

  @override
  String get taskTitleHint => 'పని శీర్షిక';

  @override
  String get descriptionOptional => 'వివరణ (ఐచ్ఛికం)';

  @override
  String get addMoreDetails => 'మరిన్ని వివరాలను జోడించండి';

  @override
  String get dueDateTime => 'గడువు తేదీ మరియు సమయం';

  @override
  String get reminderLabelText => 'రిమైండర్';

  @override
  String reminderFor(String name) {
    return '$name కోసం రిమైండర్';
  }

  @override
  String reminderGoesToThem(String name) {
    return '$name కు ఈ రిమైండర్ వారి ఫోన్‌లో వస్తుంది.';
  }

  @override
  String get saveChanges => 'మార్పులను సేవ్ చేయండి';

  @override
  String get assignTask => 'పనిని కేటాయించండి';

  @override
  String get saveTask => 'పనిని సేవ్ చేయండి';

  @override
  String get couldNotSaveTask =>
      'పనిని సేవ్ చేయడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్ మరియు డేటాబేస్ నియమాలను తనిఖీ చేయండి.';

  @override
  String assignedSuccess(String name) {
    return '$name కు కేటాయించబడింది. ఇది వారి \'నా పనులు\' లో కనిపిస్తుంది.';
  }

  @override
  String get taskSavedSuccess => 'మీ పని విజయవంతంగా సేవ్ చేయబడింది.';

  @override
  String get taskUpdated => 'పని అప్‌డేట్ అయింది!';

  @override
  String get taskAssigned => 'పని కేటాయించబడింది!';

  @override
  String get taskCreated => 'పని సృష్టించబడింది!';

  @override
  String get noReminderScheduled =>
      'రిమైండర్ షెడ్యూల్ కాలేదు: రిమైండర్ సమయం ఇప్పటికే గడిచింది, లేదా నోటిఫికేషన్‌లు ఆఫ్‌లో ఉన్నాయి.';

  @override
  String get ok => 'సరే';

  @override
  String get enterTitle => 'దయచేసి శీర్షికను నమోదు చేయండి';

  @override
  String get titleTooLong => 'శీర్షిక చాలా పొడవుగా ఉంది';

  @override
  String get descTooLong => 'వివరణ చాలా పొడవుగా ఉంది';

  @override
  String get newTask => 'కొత్త పని';

  @override
  String get edit => 'సవరించండి';

  @override
  String get deleteTaskTitle => 'పనిని తొలగించాలా?';

  @override
  String get deleteTaskBody => 'ఈ పని మరియు దాని రిమైండర్ తొలగించబడతాయి.';

  @override
  String get taskDeleted => 'పని తొలగించబడింది';

  @override
  String get taskCompleted => 'పూర్తయింది';

  @override
  String get noReminder => 'రిమైండర్ లేదు';

  @override
  String get pleaseLogInTasks => 'మీ పనులను చూడటానికి దయచేసి లాగిన్ చేయండి.';

  @override
  String get couldNotLoadTasks =>
      'పనులను లోడ్ చేయడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్ మరియు డేటాబేస్ నియమాలను తనిఖీ చేయండి.';

  @override
  String get emptyAssignedToMe => 'మీకు ఇంకా ఏదీ కేటాయించబడలేదు.';

  @override
  String get emptyAssignedByMe =>
      'మీరు ఇంకా ఏ పనినీ కేటాయించలేదు.\nచాట్ సందేశాన్ని నొక్కి పట్టుకుని \'పని సృష్టించండి\' నొక్కండి.';

  @override
  String get emptyNoTasks =>
      'ఇంకా పనులు లేవు.\nచాట్ సందేశాన్ని నొక్కి పట్టుకుని \'పని సృష్టించండి\' నొక్కండి.';

  @override
  String get emptyList => 'ఈ జాబితాలో పనులు లేవు.';

  @override
  String filterAll(int count) {
    return 'అన్నీ ($count)';
  }

  @override
  String filterUpcoming(int count) {
    return 'రాబోయేవి ($count)';
  }

  @override
  String filterCompleted(int count) {
    return 'పూర్తయినవి ($count)';
  }

  @override
  String filterAssignedToMe(int count) {
    return 'నాకు కేటాయించినవి ($count)';
  }

  @override
  String filterAssignedByMe(int count) {
    return 'నేను కేటాయించినవి ($count)';
  }

  @override
  String doneBy(String name) {
    return '$name పూర్తి చేశారు';
  }

  @override
  String waitingFor(String name) {
    return '$name కోసం వేచి ఉంది';
  }

  @override
  String reminderPrefix(String label) {
    return 'రిమైండర్: $label';
  }

  @override
  String assignedByLine(String name) {
    return '$name కేటాయించారు';
  }

  @override
  String assignedToLine(String name) {
    return '$name కు కేటాయించబడింది';
  }

  @override
  String fromLine(String name) {
    return 'నుండి: $name';
  }

  @override
  String deleteTaskAssignedBody(String name) {
    return 'ఈ పని మీకు మరియు $name కు తొలగించబడుతుంది.';
  }

  @override
  String get couldNotUpdateTask =>
      'పనిని అప్‌డేట్ చేయడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేయండి.';

  @override
  String get couldNotDeleteTask =>
      'పనిని తొలగించడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేయండి.';

  @override
  String get reminderAtDue => 'గడువు సమయానికి';

  @override
  String get reminder10Min => '10 నిమిషాల ముందు';

  @override
  String get reminder1Hour => '1 గంట ముందు';

  @override
  String get reminder2Hours => '2 గంటల ముందు';

  @override
  String get reminder1Day => '1 రోజు ముందు';

  @override
  String get dueNow => 'ఇప్పుడే గడువు';

  @override
  String dueOn(String date, String time) {
    return 'గడువు: $date, $time';
  }

  @override
  String newTaskFrom(String who) {
    return '$who నుండి కొత్త పని';
  }

  @override
  String get aContact => 'ఒక కాంటాక్ట్';

  @override
  String get someone => 'ఎవరో';

  @override
  String get save => 'సేవ్ చేయండి';

  @override
  String get groupNameTitle => 'గ్రూప్ పేరు';

  @override
  String get changeGroupName => 'గ్రూప్ పేరును మార్చండి';

  @override
  String get addMembers => 'సభ్యులను జోడించండి';

  @override
  String get groupAdminBadge => 'గ్రూప్ అడ్మిన్';

  @override
  String get removeFromGroup => 'గ్రూప్ నుండి తొలగించండి';

  @override
  String get removeAction => 'తొలగించండి';

  @override
  String get removeMemberBody =>
      'వారు ఈ గ్రూప్ నుండి కొత్త సందేశాలను అందుకోరు.';

  @override
  String get exitGroup => 'గ్రూప్ నుండి నిష్క్రమించండి';

  @override
  String get exitGroupTitle => 'గ్రూప్ నుండి నిష్క్రమించాలా?';

  @override
  String get exitAction => 'నిష్క్రమించండి';

  @override
  String get exitGroupBody => 'మీరు ఇకపై ఈ గ్రూప్ నుండి సందేశాలను అందుకోరు.';

  @override
  String get disappearingGroupHelp =>
      'ఈ గ్రూప్‌లోని కొత్త సందేశాలు మీరు ఎంచుకున్న సమయం తర్వాత అదృశ్యమవుతాయి.';

  @override
  String removeMemberTitle(String name) {
    return '$name ను తొలగించాలా?';
  }

  @override
  String groupMembersLine(int count) {
    return 'గ్రూప్ · $count సభ్యులు';
  }

  @override
  String get addGroupMembers => 'గ్రూప్ సభ్యులను జోడించండి';

  @override
  String get noContactsToAdd =>
      'జోడించడానికి కాంటాక్ట్‌లు లేవు. ముందుగా ఒక కాంటాక్ట్‌ను సేవ్ చేయండి.';

  @override
  String selectedOf(int selected, int total) {
    return '$total లో $selected ఎంచుకోబడ్డాయి';
  }

  @override
  String get addAName => 'పేరును జోడించండి';

  @override
  String get groupNameHint => 'గ్రూప్ పేరు (తప్పనిసరి)';

  @override
  String get groupNameRequired => 'దయచేసి గ్రూప్ పేరును టైప్ చేయండి';

  @override
  String membersTitle(int count) {
    return 'సభ్యులు: $count';
  }

  @override
  String get couldNotRenameGroup => 'గ్రూప్ పేరును మార్చడం సాధ్యం కాలేదు';

  @override
  String get couldNotAddMembers => 'సభ్యులను జోడించడం సాధ్యం కాలేదు';

  @override
  String get couldNotRemoveMember => 'ఈ సభ్యుడిని తొలగించడం సాధ్యం కాలేదు';

  @override
  String get couldNotExitGroup => 'గ్రూప్ నుండి నిష్క్రమించడం సాధ్యం కాలేదు';

  @override
  String get pleaseLogInAgain => 'దయచేసి మళ్లీ లాగిన్ చేయండి';

  @override
  String get noLongerInGroup => 'మీరు ఇకపై ఈ గ్రూప్‌లో లేరు';

  @override
  String get member => 'సభ్యుడు';

  @override
  String get today => 'ఈ రోజు';

  @override
  String get forwarded => 'ఫార్వార్డ్ చేయబడింది';

  @override
  String disappearingNotice(String label) {
    return '⏱ అదృశ్యమయ్యే సందేశాలు: $label';
  }

  @override
  String get scheduleTitle => 'పంపడాన్ని షెడ్యూల్ చేయండి';

  @override
  String get scheduleTypeFirst =>
      'ముందుగా సందేశాన్ని టైప్ చేయండి లేదా చిత్రాన్ని ఎంచుకోండి';

  @override
  String get scheduleInvalid => 'భవిష్యత్తులోని సమయాన్ని ఎంచుకోండి';

  @override
  String tomorrowDay(String day) {
    return 'రేపు, $day';
  }

  @override
  String scheduleToday(String time) {
    return 'ఈ రోజు $time కి';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'రేపు $time కి';
  }

  @override
  String scheduleOn(String day, String time) {
    return '$day న $time కి';
  }

  @override
  String sendAt(String label) {
    return '$label పంపండి';
  }

  @override
  String scheduledFor(String label) {
    return 'సందేశం $label కి షెడ్యూల్ చేయబడింది';
  }

  @override
  String get callsNotInGroups => 'గ్రూపులలో కాల్స్ ఇంకా అందుబాటులో లేవు';

  @override
  String get couldNotIdentifyContact =>
      'కాంటాక్ట్ ఖాతాను గుర్తించడం సాధ్యం కాలేదు';

  @override
  String get couldNotOpenDialer => 'ఫోన్ డయలర్‌ను తెరవడం సాధ్యం కాలేదు';

  @override
  String noPhoneSaved(String name) {
    return '$name కి ఫోన్ నంబర్ సేవ్ చేయబడలేదు';
  }

  @override
  String get couldNotOpenCamera =>
      'కెమెరాను తెరవడం సాధ్యం కాలేదు. కెమెరా అనుమతిని తనిఖీ చేయండి.';

  @override
  String get couldNotOpenGallery => 'గ్యాలరీని తెరవడం సాధ్యం కాలేదు';

  @override
  String get couldNotPickDocument => 'పత్రాన్ని ఎంచుకోవడం సాధ్యం కాలేదు';

  @override
  String get couldNotOpenFile => 'ఫైల్‌ను తెరవడం సాధ్యం కాలేదు';

  @override
  String get attachCamera => 'కెమెరా';

  @override
  String get attachGallery => 'గ్యాలరీ';

  @override
  String get attachContact => 'కాంటాక్ట్';

  @override
  String get attachLocation => 'లొకేషన్';

  @override
  String get locationComingSoon => 'లొకేషన్ షేరింగ్ త్వరలో వస్తోంది';

  @override
  String get shareContactTitle => 'కాంటాక్ట్‌ను షేర్ చేయండి';

  @override
  String get forwardToTitle => 'వీరికి ఫార్వార్డ్ చేయండి...';

  @override
  String get noSavedContacts => 'ఇంకా కాంటాక్ట్‌లు సేవ్ చేయలేదు';

  @override
  String get searchNameOrNumber => 'పేరు లేదా నంబర్ వెతకండి';

  @override
  String get noContactFound => 'కాంటాక్ట్ కనుగొనబడలేదు';

  @override
  String get selectContacts => 'కాంటాక్ట్‌లను ఎంచుకోండి';

  @override
  String sendToCount(int count) {
    return '$count మందికి పంపండి';
  }

  @override
  String get cardMessage => 'సందేశం';

  @override
  String get alreadyInContacts => 'ఇప్పటికే మీ కాంటాక్ట్‌లలో ఉంది';

  @override
  String get ownNumber => 'ఇది మీ స్వంత నంబర్';

  @override
  String get contactSavedShort => 'కాంటాక్ట్ సేవ్ చేయబడింది';

  @override
  String get couldNotSaveContact =>
      'కాంటాక్ట్‌ను సేవ్ చేయడం సాధ్యం కాలేదు. డేటాబేస్ నియమాలను తనిఖీ చేయండి.';

  @override
  String get waitUntilSent => 'సందేశం పంపబడే వరకు వేచి ఉండండి';

  @override
  String get messageForwarded => 'సందేశం ఫార్వార్డ్ చేయబడింది';

  @override
  String forwardedToCount(int done, int total) {
    return '$total కాంటాక్ట్‌లలో $done మందికి ఫార్వార్డ్ చేయబడింది';
  }

  @override
  String get voiceLanguageTitle => 'వాయిస్ టైపింగ్ భాష';

  @override
  String get voiceLanguageHelp =>
      'మైక్ ఒకేసారి ఒక భాషను మాత్రమే వింటుంది. మీరు మాట్లాడే భాషను ఎంచుకోండి.';

  @override
  String get listening => 'వింటోంది...';

  @override
  String voiceLanguageChosen(String name) {
    return 'వాయిస్ టైపింగ్ భాష: $name';
  }

  @override
  String listeningIn(String name) {
    return '$name లో వింటోంది...';
  }

  @override
  String get reply => 'సమాధానం';

  @override
  String get forward => 'ఫార్వార్డ్';

  @override
  String get tryAgain => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get copy => 'కాపీ';

  @override
  String get copied => 'కాపీ చేయబడింది';

  @override
  String get messageDeleted => 'సందేశం తొలగించబడింది';

  @override
  String get clearChatTitle => 'చాట్‌ను క్లియర్ చేయాలా?';

  @override
  String get clear => 'క్లియర్';

  @override
  String clearGroupBody(String title) {
    return '$title లోని అన్ని సందేశాలు అందరికీ తొలగించబడతాయి.';
  }

  @override
  String clearChatBody(String name) {
    return '$name తో ఉన్న అన్ని సందేశాలు తొలగించబడతాయి.';
  }

  @override
  String get couldNotLoadMessages =>
      'సందేశాలను లోడ్ చేయడం సాధ్యం కాలేదు. మీ Firebase Realtime Database నియమాలను తనిఖీ చేయండి.';

  @override
  String get noMessagesYet => 'ఇంకా సందేశాలు లేవు\nహాయ్ చెప్పండి 👋';

  @override
  String get messageHint => 'సందేశం';

  @override
  String get photoAttached => 'ఫోటో జోడించబడింది';

  @override
  String get removePhoto => 'ఫోటోను తొలగించండి';

  @override
  String get groupInfo => 'గ్రూప్ సమాచారం';

  @override
  String get viewProfile => 'ప్రొఫైల్ చూడండి';

  @override
  String get searchHint => 'వెతకండి...';

  @override
  String get noResults => 'ఫలితాలు లేవు';

  @override
  String matchOf(int current, int total) {
    return '$total లో $current';
  }

  @override
  String get couldNotSendMessage =>
      'సందేశాన్ని పంపడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get couldNotScheduleMessage =>
      'సందేశాన్ని షెడ్యూల్ చేయడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get nothingToSend => 'పంపడానికి ఏమీ లేదు';

  @override
  String get imageTooLarge =>
      'చిత్రం చాలా పెద్దది. దయచేసి చిన్న ఫోటోను ఎంచుకోండి.';

  @override
  String get couldNotShareContact =>
      'కాంటాక్ట్‌ను షేర్ చేయడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get documentsOnlineOnly =>
      'మీరు ఆన్‌లైన్‌లో ఉన్నప్పుడు మాత్రమే పత్రాలను పంపగలరు.';

  @override
  String get couldNotSaveAttachment =>
      'అటాచ్‌మెంట్‌ను సేవ్ చేయడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get couldNotDeleteMessage => 'సందేశాన్ని తొలగించడం సాధ్యం కాలేదు';

  @override
  String get couldNotClearChat => 'చాట్‌ను క్లియర్ చేయడం సాధ్యం కాలేదు';

  @override
  String get reactionFailed =>
      'ప్రతిస్పందనను జోడించడం సాధ్యం కాలేదు. డేటాబేస్ నియమాలను తనిఖీ చేయండి.';

  @override
  String voiceNoSpeech(String language) {
    return 'నాకు $language లో ఏమీ వినిపించలేదు. మైక్‌ను నొక్కి స్పష్టంగా మాట్లాడండి, లేదా భాషను మార్చండి (మైక్‌ను నొక్కి పట్టుకోండి).';
  }

  @override
  String get micPermission => 'దయచేసి ఈ యాప్‌కు మైక్రోఫోన్ అనుమతిని ఇవ్వండి';

  @override
  String voiceLangNotReady(String language) {
    return 'ఈ ఫోన్‌లో $language వాయిస్ టైపింగ్ సిద్ధంగా లేదు.\nఇంటర్నెట్‌కు కనెక్ట్ అవ్వండి, లేదా ఫోన్ Google వాయిస్ టైపింగ్ సెట్టింగ్‌లలో $language డౌన్‌లోడ్ చేయండి.';
  }

  @override
  String voiceNetworkError(String error, String language) {
    return 'వాయిస్ లోపం: $error\nమీ ఇంటర్నెట్‌ను తనిఖీ చేయండి, లేదా ఆఫ్‌లైన్ ఉపయోగం కోసం ఫోన్ సెట్టింగ్‌లలో $language డౌన్‌లోడ్ చేయండి, లేదా మీ సందేశాన్ని టైప్ చేయండి.';
  }

  @override
  String speechError(String error) {
    return 'స్పీచ్ లోపం: $error';
  }

  @override
  String get micPermissionNeeded =>
      'మైక్రోఫోన్ అనుమతి అవసరం. యాప్ సెట్టింగ్‌లలో అనుమతించండి.';

  @override
  String get you => 'మీరు';

  @override
  String get attachDocument => 'పత్రం';

  @override
  String get clearChat => 'చాట్‌ను క్లియర్ చేయండి';

  @override
  String get mediaLinksDocs => 'మీడియా, లింక్‌లు మరియు పత్రాలు';

  @override
  String get disappearingTitle => 'అదృశ్యమయ్యే సందేశాలు';

  @override
  String get disappearOff => 'ఆఫ్';

  @override
  String get disappear5Min => '5 నిమిషాలు';

  @override
  String get disappear1Day => '1 రోజు';

  @override
  String get disappear7Days => '7 రోజులు';

  @override
  String get contactInfoTitle => 'కాంటాక్ట్ సమాచారం';

  @override
  String get phoneUnavailable => 'ఫోన్ నంబర్ అందుబాటులో లేదు';

  @override
  String get actionAudio => 'ఆడియో';

  @override
  String get actionVideo => 'వీడియో';

  @override
  String get mediaVisibility => 'మీడియా కనిపించడం';

  @override
  String get encryption => 'ఎన్‌క్రిప్షన్';

  @override
  String get encryptionSub =>
      'సందేశాలు మరియు కాల్స్ ఇంకా ఎండ్-టు-ఎండ్ ఎన్‌క్రిప్ట్ కాలేదు.';

  @override
  String get blockContact => 'కాంటాక్ట్‌ను బ్లాక్ చేయండి';

  @override
  String get disappearingChatHelp =>
      'ఈ చాట్‌లోని కొత్త సందేశాలు మీరు ఎంచుకున్న సమయం తర్వాత అదృశ్యమవుతాయి.';

  @override
  String get couldNotChangeSetting =>
      'సెట్టింగ్‌ను మార్చడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్‌ను తనిఖీ చేయండి.';

  @override
  String get notificationSettingsMsg => 'నోటిఫికేషన్ సెట్టింగ్‌లు';

  @override
  String get mediaVisibilitySettingsMsg => 'మీడియా కనిపించే సెట్టింగ్‌లు';

  @override
  String get encryptionMsg =>
      'ఈ యాప్ ప్రస్తుతం ఎండ్-టు-ఎండ్ ఎన్‌క్రిప్షన్‌ను అమలు చేయడం లేదు.';

  @override
  String get blockingNotImplemented => 'కాంటాక్ట్ బ్లాకింగ్ ఇంకా అమలు కాలేదు.';

  @override
  String get calling => 'కాల్ చేస్తోంది...';

  @override
  String get videoCalling => 'వీడియో కాల్ చేస్తోంది...';

  @override
  String get callSpeaker => 'స్పీకర్';

  @override
  String get callMute => 'మ్యూట్';

  @override
  String get callFlip => 'తిప్పండి';

  @override
  String get callMore => 'మరిన్ని';

  @override
  String get callShare => 'షేర్';

  @override
  String get callEnd => 'ముగించు';

  @override
  String get addPeopleSoon => 'వ్యక్తులను జోడించడం త్వరలో వస్తోంది';

  @override
  String get moreOptionsSoon => 'మరిన్ని ఎంపికలు త్వరలో వస్తున్నాయి';

  @override
  String get sharingSoon => 'షేరింగ్ త్వరలో వస్తోంది';

  @override
  String get noCameraFound => 'ఈ పరికరంలో కెమెరా కనుగొనబడలేదు';

  @override
  String get cameraPermissionDenied =>
      'కెమెరా అనుమతి నిరాకరించబడింది. యాప్ సెట్టింగ్‌లలో అనుమతించండి.';

  @override
  String get callCouldNotOpenCamera => 'కెమెరాను తెరవడం సాధ్యం కాలేదు';

  @override
  String get nothingToOpen => 'ఇక్కడ తెరవడానికి ఏమీ లేదు';

  @override
  String get couldNotOpenThis => 'దీన్ని తెరవడం సాధ్యం కాలేదు';

  @override
  String get tabMedia => 'మీడియా';

  @override
  String get tabDocs => 'పత్రాలు';

  @override
  String get tabLinks => 'లింక్‌లు';

  @override
  String get noPhotosYet => 'ఇంకా ఫోటోలు షేర్ చేయలేదు';

  @override
  String get noDocsYet => 'ఇంకా పత్రాలు షేర్ చేయలేదు';

  @override
  String get noLinksYet => 'ఇంకా లింక్‌లు షేర్ చేయలేదు';

  @override
  String get couldNotLoadMedia =>
      'లోడ్ చేయడం సాధ్యం కాలేదు. మీ Firebase Realtime Database నియమాలను తనిఖీ చేయండి.';

  @override
  String sharedBy(String who, String date) {
    return '$who  •  $date';
  }

  @override
  String linkSubtitle(String title, String who, String date) {
    return '$title\n$who  •  $date';
  }

  @override
  String get waitingOne => '1 సందేశం పంపబడటానికి వేచి ఉంది.';

  @override
  String waitingMany(int count) {
    return '$count సందేశాలు పంపబడటానికి వేచి ఉన్నాయి.';
  }

  @override
  String offlineWithPending(String waiting) {
    return 'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు. $waiting';
  }

  @override
  String get offlineNoPending =>
      'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు. దయచేసి మీ ఇంటర్నెట్ కనెక్షన్‌ను ఆన్ చేయండి.';

  @override
  String connectingWithPending(String waiting) {
    return 'కనెక్ట్ అవుతోంది... $waiting';
  }

  @override
  String get connecting => 'కనెక్ట్ అవుతోంది...';

  @override
  String get backOnlineSending =>
      'తిరిగి ఆన్‌లైన్‌లో ఉన్నారు. మీ సందేశాలు పంపబడుతున్నాయి...';

  @override
  String get backOnline => 'మీరు తిరిగి ఆన్‌లైన్‌లో ఉన్నారు.';

  @override
  String get saveContact => 'కాంటాక్ట్‌ను సేవ్ చేయండి';

  @override
  String get addContactTitle => 'కాంటాక్ట్‌ను జోడించండి';

  @override
  String get addContactSubtitle =>
      'నమోదిత ఇమెయిల్‌ను నమోదు చేయండి, మిగిలినది ఆటోమేటిక్‌గా నిండుతుంది.';

  @override
  String get contactNameLabel => 'వినియోగదారు పేరు';

  @override
  String get registeredEmailLabel => 'నమోదిత ఇమెయిల్ చిరునామా';

  @override
  String get userFound => 'నమోదిత వినియోగదారు కనుగొనబడ్డారు';

  @override
  String get userFoundNoPhone =>
      'నమోదిత వినియోగదారు కనుగొనబడ్డారు. వారు ఫోన్ నంబర్‌ను జోడించలేదు, దయచేసి కింద టైప్ చేయండి.';

  @override
  String get userNotFound => 'ఈ ఇమెయిల్‌తో నమోదిత వినియోగదారు కనుగొనబడలేదు';

  @override
  String get cannotAddSelf => 'మీరు మీ స్వంత ఖాతాను జోడించలేరు.';

  @override
  String get lookupFailed => 'ఈ ఇమెయిల్‌ను వెతకడం సాధ్యం కాలేదు.';

  @override
  String get lookupFailedInternet =>
      'ఈ ఇమెయిల్‌ను వెతకడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేయండి.';

  @override
  String userFoundName(String name) {
    return 'నమోదిత వినియోగదారు కనుగొనబడ్డారు: $name';
  }

  @override
  String lookupFailedCode(String code) {
    return 'ఈ ఇమెయిల్‌ను వెతకడం సాధ్యం కాలేదు ($code).';
  }

  @override
  String get enterContactName => 'వినియోగదారు పేరును నమోదు చేయండి';

  @override
  String get nameTooShort => 'పేరు కనీసం 4 అక్షరాలు ఉండాలి';

  @override
  String get nameTooLong => 'పేరు గరిష్టంగా 40 అక్షరాలు ఉండాలి';

  @override
  String get enterRegisteredEmail => 'నమోదిత ఇమెయిల్ చిరునామాను నమోదు చేయండి';

  @override
  String get enterValidEmail =>
      'చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామాను నమోదు చేయండి';

  @override
  String get loginAgainToSave =>
      'కాంటాక్ట్‌లను సేవ్ చేసే ముందు దయచేసి మళ్లీ లాగిన్ చేయండి.';

  @override
  String get userAlreadyInContacts =>
      'ఈ వినియోగదారు ఇప్పటికే మీ కాంటాక్ట్‌లలో ఉన్నారు.';

  @override
  String get firebaseDenied =>
      'Firebase యాక్సెస్‌ను నిరాకరించింది. మీ డేటాబేస్ నియమాలను తనిఖీ చేయండి.';

  @override
  String get unknownError => 'తెలియని లోపం';

  @override
  String firebaseError(String code, String message) {
    return 'Firebase లోపం ($code): $message';
  }

  @override
  String get profileTitle => 'ప్రొఫైల్';

  @override
  String get nameLabel => 'పేరు';

  @override
  String get phoneLabel => 'ఫోన్';

  @override
  String get notAdded => 'జోడించలేదు';

  @override
  String get saveName => 'పేరును సేవ్ చేయండి';

  @override
  String get profileNameUpdated => 'పేరు అప్‌డేట్ చేయబడింది';

  @override
  String get nameSavedNote =>
      'మిమ్మల్ని సేవ్ చేసిన వారు తాము ఎంచుకున్న పేరునే ఉంచుకుంటారు.';

  @override
  String get enterYourName => 'దయచేసి మీ పేరును నమోదు చేయండి';

  @override
  String get pleaseLogInBeforePicture =>
      'చిత్రాన్ని మార్చే ముందు దయచేసి మళ్లీ లాగిన్ చేయండి.';

  @override
  String get pictureTooLarge =>
      'ఈ చిత్రం చాలా పెద్దది. దయచేసి చిన్న చిత్రాన్ని ఎంచుకోండి.';

  @override
  String get youAreOfflineTryAgain =>
      'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు. ఇంటర్నెట్‌కు కనెక్ట్ అయి మళ్లీ ప్రయత్నించండి.';

  @override
  String profileUpdateFailed(String error) {
    return 'ప్రొఫైల్ అప్‌డేట్ విఫలమైంది: $error';
  }

  @override
  String get pleaseLogInBeforeName =>
      'పేరును మార్చే ముందు దయచేసి మళ్లీ లాగిన్ చేయండి.';

  @override
  String get serverNoAnswer =>
      'సర్వర్ స్పందించలేదు. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String couldNotSaveNameCode(String code) {
    return 'మీ పేరును సేవ్ చేయడం సాధ్యం కాలేదు ($code). దయచేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get couldNotSaveName =>
      'మీ పేరును సేవ్ చేయడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get cancel => 'రద్దు చేయండి';

  @override
  String get delete => 'తొలగించండి';

  @override
  String get yesterday => 'నిన్న';

  @override
  String get videoCallNoAnswer => 'వీడియో కాల్ · సమాధానం లేదు';

  @override
  String get missedVideoCall => 'మిస్డ్ వీడియో కాల్';

  @override
  String youPrefix(String text) {
    return 'మీరు: $text';
  }

  @override
  String get deleteChatTitle => 'చాట్‌ను తొలగించాలా?';

  @override
  String deleteChatsTitle(int count) {
    return '$count చాట్‌లను తొలగించాలా?';
  }

  @override
  String get deleteChatBody =>
      'చాట్ మీ జాబితా నుండి మాత్రమే తొలగించబడుతుంది. ఇతరుల వద్ద వారి సందేశాలు ఉంటాయి. కొత్త సందేశం వస్తే చాట్ తిరిగి వస్తుంది.';

  @override
  String get chatDeleted => 'చాట్ తొలగించబడింది';

  @override
  String chatsDeleted(int count) {
    return '$count చాట్‌లు తొలగించబడ్డాయి';
  }

  @override
  String get couldNotDelete =>
      'తొలగించడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get newChat => 'కొత్త చాట్';

  @override
  String get newGroup => 'కొత్త గ్రూప్';

  @override
  String get newContact => 'కొత్త కాంటాక్ట్';

  @override
  String membersCount(int count) {
    return '$count సభ్యులు';
  }

  @override
  String get tapToStartChatting => 'చాట్ ప్రారంభించడానికి నొక్కండి';

  @override
  String get offlineNoContacts =>
      'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు. ఈ పరికరంలో ఇంకా కాంటాక్ట్‌లు సేవ్ చేయబడలేదు.';

  @override
  String get noChatsYet =>
      'ఇంకా చాట్‌లు లేవు. కాంటాక్ట్‌ను జోడించడానికి లేదా గ్రూప్‌ను సృష్టించడానికి + నొక్కండి.';

  @override
  String get updates => 'అప్‌డేట్‌లు';

  @override
  String get chats => 'చాట్‌లు';

  @override
  String get search => 'వెతకండి';

  @override
  String get closeSearch => 'శోధనను మూసివేయండి';

  @override
  String get myTasks => 'నా పనులు';

  @override
  String get pleaseLogIn => 'మీ కాంటాక్ట్‌లను చూడటానికి దయచేసి లాగిన్ చేయండి.';

  @override
  String get contactSaved => 'కాంటాక్ట్ విజయవంతంగా సేవ్ చేయబడింది.';

  @override
  String get searchSettings => 'సెట్టింగ్‌లను వెతకండి';

  @override
  String get noSettingsFound => 'సెట్టింగ్‌లు ఏవీ కనుగొనబడలేదు';

  @override
  String get addNewContact => 'కొత్త కాంటాక్ట్‌ను జోడించండి';

  @override
  String get addNewContactSub =>
      'చాట్ ప్రారంభించడానికి కాంటాక్ట్‌ను సేవ్ చేయండి';

  @override
  String get settingsAccount => 'ఖాతా';

  @override
  String get settingsAccountSub => 'భద్రతా నోటిఫికేషన్‌లు, ఖాతా సమాచారం';

  @override
  String get settingsPrivacy => 'గోప్యత';

  @override
  String get settingsPrivacySub =>
      'బ్లాక్ చేసిన కాంటాక్ట్‌లు, అదృశ్యమయ్యే సందేశాలు';

  @override
  String get settingsChatsSub => 'థీమ్, వాల్‌పేపర్, చాట్ చరిత్ర';

  @override
  String get settingsNotifications => 'నోటిఫికేషన్‌లు';

  @override
  String get settingsNotificationsSub => 'సందేశం, గ్రూప్ మరియు కాల్ టోన్‌లు';

  @override
  String get settingsStorage => 'నిల్వ మరియు డేటా';

  @override
  String get settingsStorageSub => 'నెట్‌వర్క్ వినియోగం, ఆటో-డౌన్‌లోడ్';

  @override
  String get settingsHelp => 'సహాయం మరియు అభిప్రాయం';

  @override
  String get settingsHelpSub =>
      'సహాయ కేంద్రం, మమ్మల్ని సంప్రదించండి, గోప్యతా విధానం';

  @override
  String get logOut => 'లాగ్ అవుట్';

  @override
  String get logOutTitle => 'లాగ్ అవుట్ చేయాలా?';

  @override
  String get logOutBody => 'మీరు మీ ఖాతా నుండి లాగ్ అవుట్ చేయాలనుకుంటున్నారా?';

  @override
  String get profilePhotoUpdated =>
      'ప్రొఫైల్ చిత్రం అప్‌డేట్ చేయబడింది. ఇప్పుడు మీ కాంటాక్ట్‌లు దాన్ని చూడగలరు.';

  @override
  String get createAccount => 'ఖాతా సృష్టించండి';

  @override
  String get signupSubtitle =>
      'ప్రారంభించడానికి మీ ఇమెయిల్‌తో సైన్ అప్ చేయండి.';

  @override
  String get nickname => 'మారుపేరు';

  @override
  String get code => 'కోడ్';

  @override
  String get phoneNumber => 'ఫోన్ నంబర్';

  @override
  String get confirmPassword => 'పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get register => 'నమోదు చేయండి';

  @override
  String get haveAccount => 'ఇప్పటికే ఖాతా ఉందా?';

  @override
  String get logInLink => 'లాగిన్ చేయండి';

  @override
  String get ruleLength => 'కనీసం 8 అక్షరాలు';

  @override
  String get ruleCapital => '1 పెద్ద అక్షరం (A-Z)';

  @override
  String get ruleSmall => '1 చిన్న అక్షరం (a-z)';

  @override
  String get ruleNumber => '1 సంఖ్య (0-9)';

  @override
  String get ruleSpecial => '1 ప్రత్యేక అక్షరం (! @ # \$ %)';

  @override
  String get enterNickname => 'దయచేసి మారుపేరును నమోదు చేయండి';

  @override
  String get useAtLeast3 => 'కనీసం 3 అక్షరాలను ఉపయోగించండి';

  @override
  String get useAtMost20 => 'గరిష్టంగా 20 అక్షరాలను ఉపయోగించండి';

  @override
  String get enterNewPassword => 'దయచేసి పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String get useAtLeast8 => 'కనీసం 8 అక్షరాలను ఉపయోగించండి';

  @override
  String get noSpaces => 'పాస్‌వర్డ్‌లో ఖాళీలు ఉండకూడదు';

  @override
  String get addCapital => '1 పెద్ద అక్షరాన్ని జోడించండి (A-Z)';

  @override
  String get addSmall => '1 చిన్న అక్షరాన్ని జోడించండి (a-z)';

  @override
  String get addNumber => '1 సంఖ్యను జోడించండి (0-9)';

  @override
  String get addSpecial => '1 ప్రత్యేక అక్షరాన్ని జోడించండి (! @ # \$ % & *)';

  @override
  String get confirmYourPassword => 'దయచేసి మీ పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get passwordsDontMatch => 'పాస్‌వర్డ్‌లు సరిపోలడం లేదు';

  @override
  String get emailAlreadyRegistered =>
      'ఈ ఇమెయిల్ ఇప్పటికే నమోదు చేయబడింది. దయచేసి లాగిన్ చేయండి.';

  @override
  String get weakPassword =>
      'ఈ పాస్‌వర్డ్ చాలా బలహీనంగా ఉంది. దయచేసి మరొకటి ఎంచుకోండి.';

  @override
  String get signupNotEnabled =>
      'Firebase కన్సోల్‌లో ఇమెయిల్/పాస్‌వర్డ్ సైన్ అప్ ప్రారంభించబడలేదు.';

  @override
  String get signupFailed =>
      'ఖాతాను సృష్టించడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get createAccountWentWrong =>
      'ఖాతాను సృష్టిస్తున్నప్పుడు ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get accountNotCreated =>
      'ఖాతా సృష్టించబడలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get phoneAlreadyRegistered =>
      'ఈ ఫోన్ నంబర్ ఇప్పటికే మరో ఖాతాతో నమోదు చేయబడింది. దయచేసి వేరే నంబర్‌ను ఉపయోగించండి.';

  @override
  String get phoneCheckFailed =>
      'ఫోన్ నంబర్‌ను తనిఖీ చేయడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get phoneJustTaken =>
      'ఈ ఫోన్ నంబర్‌ను ఇప్పుడే మరో ఖాతా నమోదు చేసింది. దయచేసి వేరే నంబర్‌ను ఉపయోగించండి.';

  @override
  String get phoneSaveFailed =>
      'ఫోన్ నంబర్‌ను సేవ్ చేయడం సాధ్యం కాలేదు. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String phoneSaveFailedCode(String code) {
    return 'ఫోన్ నంబర్‌ను సేవ్ చేయడం సాధ్యం కాలేదు ($code). దయచేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get verificationCancelled =>
      'ధృవీకరణ రద్దు చేయబడింది, కాబట్టి ఖాతా సృష్టించబడలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get enterPhone => 'ఫోన్ నంబర్‌ను నమోదు చేయండి';

  @override
  String get digitsOnly => 'అంకెలను మాత్రమే ఉపయోగించండి';

  @override
  String get invalidPhone =>
      'చెల్లుబాటు అయ్యే ఫోన్ నంబర్‌ను నమోదు చేయండి (6–15 అంకెలు)';

  @override
  String get verifyYourEmail => 'మీ ఇమెయిల్‌ను ధృవీకరించండి';

  @override
  String otpSentTo(String email) {
    return 'పంపిన 4 అంకెల కోడ్‌ను నమోదు చేయండి\n$email';
  }

  @override
  String get enterAllDigits => 'మొత్తం 4 అంకెలను నమోదు చేయండి';

  @override
  String get wrongOtp => 'తప్పు OTP, మళ్లీ ప్రయత్నించండి';

  @override
  String get messages => 'సందేశాలు';

  @override
  String get now => 'ఇప్పుడు';

  @override
  String otpMessage(String appName, String code) {
    return 'మీ $appName ధృవీకరణ కోడ్ $code. దీన్ని ఎవరితోనూ పంచుకోవద్దు.';
  }

  @override
  String resendCodeIn(String time) {
    return '$time లో కోడ్‌ను మళ్లీ పంపండి';
  }

  @override
  String get resendCode => 'కోడ్‌ను మళ్లీ పంపండి';

  @override
  String get verify => 'ధృవీకరించండి';

  @override
  String get email => 'ఇమెయిల్';

  @override
  String get password => 'పాస్‌వర్డ్';

  @override
  String get backToLogin => 'లాగిన్‌కు తిరిగి వెళ్ళండి';

  @override
  String get enterEmail => 'దయచేసి మీ ఇమెయిల్‌ను నమోదు చేయండి';

  @override
  String get invalidEmail =>
      'చెల్లుబాటు అయ్యే ఇమెయిల్‌ను నమోదు చేయండి (ఉదాహరణ: name@gmail.com)';

  @override
  String get invalidEmailAddress =>
      'దయచేసి చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామాను నమోదు చేయండి.';

  @override
  String get tooManyAttempts =>
      'చాలా ఎక్కువ ప్రయత్నాలు. దయచేసి కొంత సేపటి తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String get networkError =>
      'నెట్‌వర్క్ లోపం. మీ ఇంటర్నెట్ కనెక్షన్‌ను తనిఖీ చేయండి.';

  @override
  String get somethingWentWrong =>
      'ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get enterPassword => 'దయచేసి మీ పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String get loginCredentials =>
      'ఇమెయిల్ లేదా పాస్‌వర్డ్ తప్పుగా ఉంది. మీరు కొత్తవారైతే, కింద సైన్ అప్‌ను నొక్కండి.';

  @override
  String get accountDisabled => 'ఈ ఖాతా నిలిపివేయబడింది.';

  @override
  String get loginFailed =>
      'లాగిన్ చేయడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get verifyEmailFirst =>
      'దయచేసి ముందుగా మీ ఇమెయిల్‌ను ధృవీకరించండి. మీ ఇన్‌బాక్స్‌కు పంపిన లింక్‌ను తెరవండి (స్పామ్‌ను కూడా చూడండి), ఆపై మళ్లీ లాగిన్ చేయండి.';

  @override
  String get verificationSent =>
      'ధృవీకరణ ఇమెయిల్ పంపబడింది. మీ ఇన్‌బాక్స్‌ను తనిఖీ చేయండి.';

  @override
  String get accountVerified => 'ఖాతా ధృవీకరించబడింది. దయచేసి లాగిన్ చేయండి.';

  @override
  String get welcomeBack => 'తిరిగి స్వాగతం';

  @override
  String get loginSubtitle => 'మీ ఇమెయిల్ మరియు పాస్‌వర్డ్‌తో లాగిన్ చేయండి.';

  @override
  String get forgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get resendVerification => 'ధృవీకరణ ఇమెయిల్‌ను మళ్లీ పంపండి';

  @override
  String get login => 'లాగిన్';

  @override
  String get noAccount => 'ఖాతా లేదా?';

  @override
  String get signUp => 'సైన్ అప్';

  @override
  String get noAccountFound =>
      'ఈ ఇమెయిల్‌తో ఖాతా కనుగొనబడలేదు. దయచేసి సైన్ అప్ చేయండి.';

  @override
  String get couldNotSendEmail =>
      'ఇమెయిల్ పంపడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get forgotSubtitle =>
      'మీ నమోదిత ఇమెయిల్‌ను నమోదు చేయండి, కొత్త పాస్‌వర్డ్‌ను ఎంచుకోవడానికి మేము మీకు లింక్ పంపుతాము.';

  @override
  String get sendResetLink => 'రీసెట్ లింక్ పంపండి';

  @override
  String get checkInbox => 'మీ ఇన్‌బాక్స్‌ను తనిఖీ చేయండి';

  @override
  String get resendLink => 'లింక్‌ను మళ్లీ పంపండి';

  @override
  String get changeEmail => 'ఇమెయిల్ మార్చండి';

  @override
  String resendIn(int seconds) {
    return '$seconds సెకన్లలో మళ్లీ పంపండి';
  }

  @override
  String resetLinkSent(String email) {
    return 'మేము $email కు రీసెట్ లింక్ పంపాము. దాన్ని తెరిచి, కొత్త పాస్‌వర్డ్‌ను ఎంచుకుని, ఆపై దానితో లాగిన్ చేయండి.\n\nకనిపించడం లేదా? మీ స్పామ్ ఫోల్డర్‌ను కూడా తనిఖీ చేయండి.';
  }

  @override
  String get tagline => 'సందేశాలు పంపడం, అందంగా సులభం.';

  @override
  String get premiumMessaging => 'ప్రీమియం మెసేజింగ్';

  @override
  String get welcomeBody =>
      'మీకు ముఖ్యమైన వారి కోసం ప్రైవేట్ చాట్‌లు, వేగవంతమైన డెలివరీ మరియు గ్రూపులు.';

  @override
  String get getStarted => 'ప్రారంభించండి';

  @override
  String get newHere => 'ఇక్కడ కొత్తవారా?';

  @override
  String get createAnAccount => 'ఖాతా సృష్టించండి';

  @override
  String get perkPrivate => 'ప్రైవేట్';

  @override
  String get perkFast => 'వేగం';

  @override
  String get perkGroups => 'గ్రూపులు';

  @override
  String get accountCreated =>
      'ఖాతా సృష్టించబడింది. ధృవీకరణ లింక్ కోసం మీ ఇమెయిల్‌ను తనిఖీ చేసి, ఆపై లాగిన్ అవ్వండి.';

  @override
  String get settingsLanguage => 'యాప్ భాష';

  @override
  String get systemDefault => 'సిస్టమ్ డిఫాల్ట్';

  @override
  String get chooseLanguageHelp =>
      'యాప్ భాషను ఎంచుకోండి. మీ చాట్ సందేశాలు అనువదించబడవు.';
}
