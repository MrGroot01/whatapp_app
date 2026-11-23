// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get firebaseCouldNotStart => 'Firebase शुरू नहीं हो सका';

  @override
  String get newMessage => 'नया संदेश';

  @override
  String get newGroupMessage => 'नया ग्रुप संदेश';

  @override
  String get photoWord => 'फ़ोटो';

  @override
  String get chatWord => 'चैट';

  @override
  String get notifTaskChannel => 'कार्य रिमाइंडर';

  @override
  String get notifTaskChannelDesc => 'आपके कार्यों के लिए रिमाइंडर';

  @override
  String get notifMessagesChannel => 'संदेश';

  @override
  String get notifMessagesChannelDesc => 'आपके संपर्कों से नए संदेश';

  @override
  String get notifStatusChannel => 'संदेश की स्थिति';

  @override
  String get notifStatusChannelDesc => 'सफलतापूर्वक भेजे गए संदेशों की सूचनाएँ';

  @override
  String get sentPhoto => 'फ़ोटो सफलतापूर्वक भेजी गई';

  @override
  String get sentDocument => 'दस्तावेज़ सफलतापूर्वक भेजा गया';

  @override
  String get sentContact => 'संपर्क सफलतापूर्वक भेजा गया';

  @override
  String get sentMessage => 'संदेश सफलतापूर्वक भेजा गया';

  @override
  String get justNow => 'अभी-अभी';

  @override
  String minutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String get photoTooLarge => 'फ़ोटो बहुत बड़ी है। कृपया छोटी फ़ोटो चुनें।';

  @override
  String get statusText => 'टेक्स्ट';

  @override
  String get addStatusTitle => 'स्टेटस जोड़ें';

  @override
  String get myStatus => 'मेरा स्टेटस';

  @override
  String get tapToAddStatus => 'स्टेटस अपडेट जोड़ने के लिए टैप करें';

  @override
  String get recentUpdates => 'हाल के अपडेट';

  @override
  String get viewedUpdates => 'देखे गए अपडेट';

  @override
  String get noRecentUpdates =>
      'कोई हाल का अपडेट नहीं।\nआपके संपर्कों के स्टेटस यहाँ दिखेंगे और कुछ समय बाद गायब हो जाएँगे।';

  @override
  String get addStatusTooltip => 'स्टेटस जोड़ें';

  @override
  String get textStatusTooltip => 'टेक्स्ट स्टेटस';

  @override
  String get photoStatusTooltip => 'फ़ोटो स्टेटस';

  @override
  String get couldNotOpenCameraOrGallery => 'कैमरा या गैलरी नहीं खुल सकी';

  @override
  String statusUpdatesLine(int count, String timeAgo) {
    return '$count अपडेट · $timeAgo';
  }

  @override
  String get typeSomethingFirst => 'पहले कुछ लिखें';

  @override
  String get statusOfflineQueued =>
      'इंटरनेट नहीं है। ऑनलाइन होने पर आपका स्टेटस पोस्ट हो जाएगा।';

  @override
  String get addCaption => 'कैप्शन जोड़ें...';

  @override
  String get typeAStatus => 'स्टेटस लिखें';

  @override
  String get changeColour => 'रंग बदलें';

  @override
  String get deleteStatus => 'स्टेटस हटाएँ';

  @override
  String get noViewsYet => 'अभी किसी ने नहीं देखा';

  @override
  String get couldNotLoadPhoto => 'यह फ़ोटो लोड नहीं हो सकी';

  @override
  String viewedBy(int count) {
    return '$count ने देखा';
  }

  @override
  String get createTask => 'कार्य बनाएँ';

  @override
  String get editTask => 'कार्य बदलें';

  @override
  String get assignTo => 'किसे सौंपें';

  @override
  String get mePersonalTask => 'मैं (निजी कार्य)';

  @override
  String get noSavedContactsAddFirst =>
      'अभी कोई संपर्क सेव नहीं है। पहले एक संपर्क जोड़ें।';

  @override
  String get titleLabel => 'शीर्षक';

  @override
  String get taskTitleHint => 'कार्य का शीर्षक';

  @override
  String get descriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get addMoreDetails => 'और जानकारी जोड़ें';

  @override
  String get dueDateTime => 'नियत तारीख और समय';

  @override
  String get reminderLabelText => 'रिमाइंडर';

  @override
  String reminderFor(String name) {
    return '$name के लिए रिमाइंडर';
  }

  @override
  String reminderGoesToThem(String name) {
    return '$name को यह रिमाइंडर उनके फ़ोन पर मिलेगा।';
  }

  @override
  String get saveChanges => 'बदलाव सेव करें';

  @override
  String get assignTask => 'कार्य सौंपें';

  @override
  String get saveTask => 'कार्य सेव करें';

  @override
  String get couldNotSaveTask =>
      'कार्य सेव नहीं हो सका। अपना इंटरनेट और डेटाबेस नियम जाँचें।';

  @override
  String assignedSuccess(String name) {
    return '$name को सौंपा गया। यह उनके \'मेरे कार्य\' में दिखेगा।';
  }

  @override
  String get taskSavedSuccess => 'आपका कार्य सफलतापूर्वक सेव हो गया।';

  @override
  String get taskUpdated => 'कार्य अपडेट हो गया!';

  @override
  String get taskAssigned => 'कार्य सौंप दिया गया!';

  @override
  String get taskCreated => 'कार्य बन गया!';

  @override
  String get noReminderScheduled =>
      'कोई रिमाइंडर सेट नहीं हुआ: रिमाइंडर का समय निकल चुका है, या सूचनाएँ बंद हैं।';

  @override
  String get ok => 'ठीक है';

  @override
  String get enterTitle => 'कृपया शीर्षक दर्ज करें';

  @override
  String get titleTooLong => 'शीर्षक बहुत लंबा है';

  @override
  String get descTooLong => 'विवरण बहुत लंबा है';

  @override
  String get newTask => 'नया कार्य';

  @override
  String get edit => 'बदलें';

  @override
  String get deleteTaskTitle => 'कार्य हटाएँ?';

  @override
  String get deleteTaskBody => 'यह कार्य और इसका रिमाइंडर हटा दिया जाएगा।';

  @override
  String get taskDeleted => 'कार्य हटा दिया गया';

  @override
  String get taskCompleted => 'पूरा हुआ';

  @override
  String get noReminder => 'कोई रिमाइंडर नहीं';

  @override
  String get pleaseLogInTasks => 'अपने कार्य देखने के लिए कृपया लॉग इन करें।';

  @override
  String get couldNotLoadTasks =>
      'कार्य लोड नहीं हो सके। अपना इंटरनेट और डेटाबेस नियम जाँचें।';

  @override
  String get emptyAssignedToMe => 'अभी आपको कुछ नहीं सौंपा गया है।';

  @override
  String get emptyAssignedByMe =>
      'आपने अभी कोई कार्य नहीं सौंपा है।\nचैट संदेश को दबाकर रखें और \'कार्य बनाएँ\' पर टैप करें।';

  @override
  String get emptyNoTasks =>
      'अभी कोई कार्य नहीं है।\nचैट संदेश को दबाकर रखें और \'कार्य बनाएँ\' पर टैप करें।';

  @override
  String get emptyList => 'इस सूची में कोई कार्य नहीं है।';

  @override
  String filterAll(int count) {
    return 'सभी ($count)';
  }

  @override
  String filterUpcoming(int count) {
    return 'आने वाले ($count)';
  }

  @override
  String filterCompleted(int count) {
    return 'पूरे हुए ($count)';
  }

  @override
  String filterAssignedToMe(int count) {
    return 'मुझे सौंपे गए ($count)';
  }

  @override
  String filterAssignedByMe(int count) {
    return 'मेरे सौंपे हुए ($count)';
  }

  @override
  String doneBy(String name) {
    return '$name ने पूरा किया';
  }

  @override
  String waitingFor(String name) {
    return '$name का इंतज़ार';
  }

  @override
  String reminderPrefix(String label) {
    return 'रिमाइंडर: $label';
  }

  @override
  String assignedByLine(String name) {
    return '$name ने सौंपा';
  }

  @override
  String assignedToLine(String name) {
    return '$name को सौंपा गया';
  }

  @override
  String fromLine(String name) {
    return 'से: $name';
  }

  @override
  String deleteTaskAssignedBody(String name) {
    return 'यह कार्य आपके और $name के लिए हटा दिया जाएगा।';
  }

  @override
  String get couldNotUpdateTask =>
      'कार्य अपडेट नहीं हो सका। अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String get couldNotDeleteTask =>
      'कार्य हटाया नहीं जा सका। अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String get reminderAtDue => 'नियत समय पर';

  @override
  String get reminder10Min => '10 मिनट पहले';

  @override
  String get reminder1Hour => '1 घंटा पहले';

  @override
  String get reminder2Hours => '2 घंटे पहले';

  @override
  String get reminder1Day => '1 दिन पहले';

  @override
  String get dueNow => 'अभी नियत है';

  @override
  String dueOn(String date, String time) {
    return 'नियत: $date, $time';
  }

  @override
  String newTaskFrom(String who) {
    return '$who की ओर से नया कार्य';
  }

  @override
  String get aContact => 'एक संपर्क';

  @override
  String get someone => 'कोई';

  @override
  String get save => 'सेव करें';

  @override
  String get groupNameTitle => 'ग्रुप का नाम';

  @override
  String get changeGroupName => 'ग्रुप का नाम बदलें';

  @override
  String get addMembers => 'सदस्य जोड़ें';

  @override
  String get groupAdminBadge => 'ग्रुप एडमिन';

  @override
  String get removeFromGroup => 'ग्रुप से हटाएँ';

  @override
  String get removeAction => 'हटाएँ';

  @override
  String get removeMemberBody => 'उन्हें इस ग्रुप के नए संदेश नहीं मिलेंगे।';

  @override
  String get exitGroup => 'ग्रुप छोड़ें';

  @override
  String get exitGroupTitle => 'ग्रुप छोड़ें?';

  @override
  String get exitAction => 'छोड़ें';

  @override
  String get exitGroupBody => 'आपको इस ग्रुप के संदेश नहीं मिलेंगे।';

  @override
  String get disappearingGroupHelp =>
      'इस ग्रुप के नए संदेश आपके चुने हुए समय के बाद गायब हो जाएँगे।';

  @override
  String removeMemberTitle(String name) {
    return '$name को हटाएँ?';
  }

  @override
  String groupMembersLine(int count) {
    return 'ग्रुप · $count सदस्य';
  }

  @override
  String get addGroupMembers => 'ग्रुप के सदस्य जोड़ें';

  @override
  String get noContactsToAdd =>
      'जोड़ने के लिए कोई संपर्क नहीं है। पहले एक संपर्क सेव करें।';

  @override
  String selectedOf(int selected, int total) {
    return '$total में से $selected चुने गए';
  }

  @override
  String get addAName => 'नाम जोड़ें';

  @override
  String get groupNameHint => 'ग्रुप का नाम (ज़रूरी)';

  @override
  String get groupNameRequired => 'कृपया ग्रुप का नाम लिखें';

  @override
  String membersTitle(int count) {
    return 'सदस्य: $count';
  }

  @override
  String get couldNotRenameGroup => 'ग्रुप का नाम नहीं बदला जा सका';

  @override
  String get couldNotAddMembers => 'सदस्य नहीं जोड़े जा सके';

  @override
  String get couldNotRemoveMember => 'इस सदस्य को नहीं हटाया जा सका';

  @override
  String get couldNotExitGroup => 'ग्रुप नहीं छोड़ा जा सका';

  @override
  String get pleaseLogInAgain => 'कृपया दोबारा लॉग इन करें';

  @override
  String get noLongerInGroup => 'अब आप इस ग्रुप में नहीं हैं';

  @override
  String get member => 'सदस्य';

  @override
  String get today => 'आज';

  @override
  String get forwarded => 'फ़ॉरवर्ड किया गया';

  @override
  String disappearingNotice(String label) {
    return '⏱ गायब होने वाले संदेश: $label';
  }

  @override
  String get scheduleTitle => 'भेजने का समय तय करें';

  @override
  String get scheduleTypeFirst => 'पहले संदेश लिखें या कोई फ़ोटो चुनें';

  @override
  String get scheduleInvalid => 'भविष्य का समय चुनें';

  @override
  String tomorrowDay(String day) {
    return 'कल, $day';
  }

  @override
  String scheduleToday(String time) {
    return 'आज $time बजे';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'कल $time बजे';
  }

  @override
  String scheduleOn(String day, String time) {
    return '$day को $time बजे';
  }

  @override
  String sendAt(String label) {
    return '$label भेजें';
  }

  @override
  String scheduledFor(String label) {
    return 'संदेश $label के लिए तय किया गया';
  }

  @override
  String get callsNotInGroups => 'ग्रुप में कॉल अभी उपलब्ध नहीं है';

  @override
  String get couldNotIdentifyContact => 'संपर्क का खाता पहचाना नहीं जा सका';

  @override
  String get couldNotOpenDialer => 'फ़ोन डायलर नहीं खुल सका';

  @override
  String noPhoneSaved(String name) {
    return '$name का फ़ोन नंबर सेव नहीं है';
  }

  @override
  String get couldNotOpenCamera =>
      'कैमरा नहीं खुल सका। कैमरे की अनुमति जाँचें।';

  @override
  String get couldNotOpenGallery => 'गैलरी नहीं खुल सकी';

  @override
  String get couldNotPickDocument => 'दस्तावेज़ नहीं चुना जा सका';

  @override
  String get couldNotOpenFile => 'फ़ाइल नहीं खुल सकी';

  @override
  String get attachCamera => 'कैमरा';

  @override
  String get attachGallery => 'गैलरी';

  @override
  String get attachContact => 'संपर्क';

  @override
  String get attachLocation => 'स्थान';

  @override
  String get locationComingSoon => 'लोकेशन शेयरिंग जल्द आ रही है';

  @override
  String get shareContactTitle => 'संपर्क शेयर करें';

  @override
  String get forwardToTitle => 'इन्हें फ़ॉरवर्ड करें...';

  @override
  String get noSavedContacts => 'अभी कोई संपर्क सेव नहीं है';

  @override
  String get searchNameOrNumber => 'नाम या नंबर खोजें';

  @override
  String get noContactFound => 'कोई संपर्क नहीं मिला';

  @override
  String get selectContacts => 'संपर्क चुनें';

  @override
  String sendToCount(int count) {
    return '$count को भेजें';
  }

  @override
  String get cardMessage => 'संदेश';

  @override
  String get alreadyInContacts => 'पहले से आपके संपर्कों में है';

  @override
  String get ownNumber => 'यह आपका अपना नंबर है';

  @override
  String get contactSavedShort => 'संपर्क सेव हो गया';

  @override
  String get couldNotSaveContact =>
      'संपर्क सेव नहीं हो सका। डेटाबेस नियम जाँचें।';

  @override
  String get waitUntilSent => 'संदेश भेजे जाने तक प्रतीक्षा करें';

  @override
  String get messageForwarded => 'संदेश फ़ॉरवर्ड हो गया';

  @override
  String forwardedToCount(int done, int total) {
    return '$total में से $done संपर्कों को फ़ॉरवर्ड किया गया';
  }

  @override
  String get voiceLanguageTitle => 'वॉइस टाइपिंग की भाषा';

  @override
  String get voiceLanguageHelp =>
      'माइक एक समय में एक ही भाषा सुनता है। वह भाषा चुनें जिसमें आप बोलेंगे।';

  @override
  String get listening => 'सुन रहा है...';

  @override
  String voiceLanguageChosen(String name) {
    return 'वॉइस टाइपिंग की भाषा: $name';
  }

  @override
  String listeningIn(String name) {
    return '$name में सुन रहा है...';
  }

  @override
  String get reply => 'जवाब दें';

  @override
  String get forward => 'फ़ॉरवर्ड';

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get copied => 'कॉपी हो गया';

  @override
  String get messageDeleted => 'संदेश हटा दिया गया';

  @override
  String get clearChatTitle => 'चैट साफ़ करें?';

  @override
  String get clear => 'साफ़ करें';

  @override
  String clearGroupBody(String title) {
    return '$title के सभी संदेश सभी के लिए हटा दिए जाएँगे।';
  }

  @override
  String clearChatBody(String name) {
    return '$name के साथ के सभी संदेश हटा दिए जाएँगे।';
  }

  @override
  String get couldNotLoadMessages =>
      'संदेश लोड नहीं हो सके। अपने Firebase Realtime Database के नियम जाँचें।';

  @override
  String get noMessagesYet => 'अभी कोई संदेश नहीं\nहाय कहें 👋';

  @override
  String get messageHint => 'संदेश';

  @override
  String get photoAttached => 'फ़ोटो जुड़ी है';

  @override
  String get removePhoto => 'फ़ोटो हटाएँ';

  @override
  String get groupInfo => 'ग्रुप की जानकारी';

  @override
  String get viewProfile => 'प्रोफ़ाइल देखें';

  @override
  String get searchHint => 'खोजें...';

  @override
  String get noResults => 'कोई परिणाम नहीं';

  @override
  String matchOf(int current, int total) {
    return '$total में से $current';
  }

  @override
  String get couldNotSendMessage =>
      'संदेश नहीं भेजा जा सका। कृपया फिर कोशिश करें।';

  @override
  String get couldNotScheduleMessage =>
      'संदेश का समय तय नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get nothingToSend => 'भेजने के लिए कुछ नहीं है';

  @override
  String get imageTooLarge => 'फ़ोटो बहुत बड़ी है। कृपया छोटी फ़ोटो चुनें।';

  @override
  String get couldNotShareContact =>
      'संपर्क शेयर नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get documentsOnlineOnly =>
      'दस्तावेज़ केवल ऑनलाइन होने पर भेजे जा सकते हैं।';

  @override
  String get couldNotSaveAttachment =>
      'अटैचमेंट सेव नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get couldNotDeleteMessage => 'संदेश हटाया नहीं जा सका';

  @override
  String get couldNotClearChat => 'चैट साफ़ नहीं हो सकी';

  @override
  String get reactionFailed =>
      'प्रतिक्रिया नहीं जोड़ी जा सकी। डेटाबेस नियम जाँचें।';

  @override
  String voiceNoSpeech(String language) {
    return 'मुझे $language में कुछ सुनाई नहीं दिया। माइक पर टैप करके साफ़ बोलें, या भाषा बदलें (माइक को दबाकर रखें)।';
  }

  @override
  String get micPermission => 'कृपया इस ऐप को माइक्रोफ़ोन की अनुमति दें';

  @override
  String voiceLangNotReady(String language) {
    return 'इस फ़ोन पर $language वॉइस टाइपिंग तैयार नहीं है।\nइंटरनेट से जुड़ें, या फ़ोन की Google वॉइस टाइपिंग सेटिंग में $language डाउनलोड करें।';
  }

  @override
  String voiceNetworkError(String error, String language) {
    return 'वॉइस त्रुटि: $error\nअपना इंटरनेट जाँचें, या ऑफ़लाइन उपयोग के लिए फ़ोन सेटिंग में $language डाउनलोड करें, या अपना संदेश टाइप करें।';
  }

  @override
  String speechError(String error) {
    return 'स्पीच त्रुटि: $error';
  }

  @override
  String get micPermissionNeeded =>
      'माइक्रोफ़ोन की अनुमति चाहिए। ऐप सेटिंग में अनुमति दें।';

  @override
  String get you => 'आप';

  @override
  String get attachDocument => 'दस्तावेज़';

  @override
  String get clearChat => 'चैट साफ़ करें';

  @override
  String get mediaLinksDocs => 'मीडिया, लिंक और दस्तावेज़';

  @override
  String get disappearingTitle => 'गायब होने वाले संदेश';

  @override
  String get disappearOff => 'बंद';

  @override
  String get disappear5Min => '5 मिनट';

  @override
  String get disappear1Day => '1 दिन';

  @override
  String get disappear7Days => '7 दिन';

  @override
  String get contactInfoTitle => 'संपर्क की जानकारी';

  @override
  String get phoneUnavailable => 'फ़ोन नंबर उपलब्ध नहीं है';

  @override
  String get actionAudio => 'ऑडियो';

  @override
  String get actionVideo => 'वीडियो';

  @override
  String get mediaVisibility => 'मीडिया की दृश्यता';

  @override
  String get encryption => 'एन्क्रिप्शन';

  @override
  String get encryptionSub =>
      'संदेश और कॉल अभी एंड-टू-एंड एन्क्रिप्टेड नहीं हैं।';

  @override
  String get blockContact => 'संपर्क ब्लॉक करें';

  @override
  String get disappearingChatHelp =>
      'इस चैट के नए संदेश आपके चुने हुए समय के बाद गायब हो जाएँगे।';

  @override
  String get couldNotChangeSetting =>
      'सेटिंग नहीं बदली जा सकी। अपना इंटरनेट जाँचें।';

  @override
  String get notificationSettingsMsg => 'सूचना सेटिंग';

  @override
  String get mediaVisibilitySettingsMsg => 'मीडिया दृश्यता सेटिंग';

  @override
  String get encryptionMsg =>
      'यह ऐप अभी एंड-टू-एंड एन्क्रिप्शन लागू नहीं करता।';

  @override
  String get blockingNotImplemented => 'संपर्क ब्लॉक करना अभी उपलब्ध नहीं है।';

  @override
  String get calling => 'कॉल हो रही है...';

  @override
  String get videoCalling => 'वीडियो कॉल हो रही है...';

  @override
  String get callSpeaker => 'स्पीकर';

  @override
  String get callMute => 'म्यूट';

  @override
  String get callFlip => 'पलटें';

  @override
  String get callMore => 'और';

  @override
  String get callShare => 'शेयर';

  @override
  String get callEnd => 'समाप्त';

  @override
  String get addPeopleSoon => 'लोगों को जोड़ना जल्द आ रहा है';

  @override
  String get moreOptionsSoon => 'और विकल्प जल्द आ रहे हैं';

  @override
  String get sharingSoon => 'शेयरिंग जल्द आ रही है';

  @override
  String get noCameraFound => 'इस डिवाइस पर कोई कैमरा नहीं मिला';

  @override
  String get cameraPermissionDenied =>
      'कैमरे की अनुमति नहीं मिली। ऐप सेटिंग में अनुमति दें।';

  @override
  String get callCouldNotOpenCamera => 'कैमरा नहीं खुल सका';

  @override
  String get nothingToOpen => 'यहाँ खोलने के लिए कुछ नहीं है';

  @override
  String get couldNotOpenThis => 'इसे खोला नहीं जा सका';

  @override
  String get tabMedia => 'मीडिया';

  @override
  String get tabDocs => 'दस्तावेज़';

  @override
  String get tabLinks => 'लिंक';

  @override
  String get noPhotosYet => 'अभी कोई फ़ोटो शेयर नहीं की गई';

  @override
  String get noDocsYet => 'अभी कोई दस्तावेज़ शेयर नहीं किया गया';

  @override
  String get noLinksYet => 'अभी कोई लिंक शेयर नहीं किया गया';

  @override
  String get couldNotLoadMedia =>
      'लोड नहीं हो सका। अपने Firebase Realtime Database के नियम जाँचें।';

  @override
  String sharedBy(String who, String date) {
    return '$who  •  $date';
  }

  @override
  String linkSubtitle(String title, String who, String date) {
    return '$title\n$who  •  $date';
  }

  @override
  String get waitingOne => '1 संदेश भेजे जाने की प्रतीक्षा में है।';

  @override
  String waitingMany(int count) {
    return '$count संदेश भेजे जाने की प्रतीक्षा में हैं।';
  }

  @override
  String offlineWithPending(String waiting) {
    return 'आप ऑफ़लाइन हैं। $waiting';
  }

  @override
  String get offlineNoPending =>
      'आप ऑफ़लाइन हैं। कृपया अपना इंटरनेट कनेक्शन चालू करें।';

  @override
  String connectingWithPending(String waiting) {
    return 'कनेक्ट हो रहा है... $waiting';
  }

  @override
  String get connecting => 'कनेक्ट हो रहा है...';

  @override
  String get backOnlineSending => 'वापस ऑनलाइन। आपके संदेश भेजे जा रहे हैं...';

  @override
  String get backOnline => 'आप वापस ऑनलाइन हैं।';

  @override
  String get saveContact => 'संपर्क सेव करें';

  @override
  String get addContactTitle => 'संपर्क जोड़ें';

  @override
  String get addContactSubtitle =>
      'रजिस्टर्ड ईमेल दर्ज करें, बाकी जानकारी अपने-आप भर जाएगी।';

  @override
  String get contactNameLabel => 'उपयोगकर्ता का नाम';

  @override
  String get registeredEmailLabel => 'रजिस्टर्ड ईमेल पता';

  @override
  String get userFound => 'रजिस्टर्ड उपयोगकर्ता मिल गया';

  @override
  String get userFoundNoPhone =>
      'रजिस्टर्ड उपयोगकर्ता मिल गया। उन्होंने फ़ोन नंबर नहीं जोड़ा है, कृपया नीचे टाइप करें।';

  @override
  String get userNotFound => 'इस ईमेल से कोई रजिस्टर्ड उपयोगकर्ता नहीं मिला';

  @override
  String get cannotAddSelf => 'आप अपना खुद का खाता नहीं जोड़ सकते।';

  @override
  String get lookupFailed => 'इस ईमेल को खोजा नहीं जा सका।';

  @override
  String get lookupFailedInternet =>
      'इस ईमेल को खोजा नहीं जा सका। अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String userFoundName(String name) {
    return 'रजिस्टर्ड उपयोगकर्ता मिल गया: $name';
  }

  @override
  String lookupFailedCode(String code) {
    return 'इस ईमेल को खोजा नहीं जा सका ($code)।';
  }

  @override
  String get enterContactName => 'उपयोगकर्ता का नाम दर्ज करें';

  @override
  String get nameTooShort => 'नाम कम से कम 4 अक्षरों का होना चाहिए';

  @override
  String get nameTooLong => 'नाम अधिकतम 40 अक्षरों का होना चाहिए';

  @override
  String get enterRegisteredEmail => 'रजिस्टर्ड ईमेल पता दर्ज करें';

  @override
  String get enterValidEmail => 'सही ईमेल पता दर्ज करें';

  @override
  String get loginAgainToSave =>
      'संपर्क सेव करने से पहले कृपया दोबारा लॉग इन करें।';

  @override
  String get userAlreadyInContacts =>
      'यह उपयोगकर्ता पहले से आपके संपर्कों में है।';

  @override
  String get firebaseDenied =>
      'Firebase ने एक्सेस देने से मना कर दिया। अपने डेटाबेस नियम जाँचें।';

  @override
  String get unknownError => 'अज्ञात त्रुटि';

  @override
  String firebaseError(String code, String message) {
    return 'Firebase त्रुटि ($code): $message';
  }

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get nameLabel => 'नाम';

  @override
  String get phoneLabel => 'फ़ोन';

  @override
  String get notAdded => 'जोड़ा नहीं गया';

  @override
  String get saveName => 'नाम सेव करें';

  @override
  String get profileNameUpdated => 'नाम अपडेट हो गया';

  @override
  String get nameSavedNote =>
      'जिन्होंने आपको सेव किया है, उनके पास वही नाम रहेगा जो उन्होंने चुना है।';

  @override
  String get enterYourName => 'कृपया अपना नाम दर्ज करें';

  @override
  String get pleaseLogInBeforePicture =>
      'फ़ोटो बदलने से पहले कृपया दोबारा लॉग इन करें।';

  @override
  String get pictureTooLarge =>
      'यह फ़ोटो बहुत बड़ी है। कृपया छोटी फ़ोटो चुनें।';

  @override
  String get youAreOfflineTryAgain =>
      'आप ऑफ़लाइन हैं। इंटरनेट से जुड़ें और फिर कोशिश करें।';

  @override
  String profileUpdateFailed(String error) {
    return 'प्रोफ़ाइल अपडेट नहीं हो सकी: $error';
  }

  @override
  String get pleaseLogInBeforeName =>
      'नाम बदलने से पहले कृपया दोबारा लॉग इन करें।';

  @override
  String get serverNoAnswer =>
      'सर्वर ने जवाब नहीं दिया। अपना इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String couldNotSaveNameCode(String code) {
    return 'आपका नाम सेव नहीं हो सका ($code)। कृपया फिर कोशिश करें।';
  }

  @override
  String get couldNotSaveName =>
      'आपका नाम सेव नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get yesterday => 'कल';

  @override
  String get videoCallNoAnswer => 'वीडियो कॉल · जवाब नहीं मिला';

  @override
  String get missedVideoCall => 'छूटी हुई वीडियो कॉल';

  @override
  String youPrefix(String text) {
    return 'आप: $text';
  }

  @override
  String get deleteChatTitle => 'चैट हटाएँ?';

  @override
  String deleteChatsTitle(int count) {
    return '$count चैट हटाएँ?';
  }

  @override
  String get deleteChatBody =>
      'चैट केवल आपकी सूची से हटाई जाएगी। दूसरे लोगों के पास उनके संदेश रहेंगे। नया संदेश आने पर चैट वापस आ जाएगी।';

  @override
  String get chatDeleted => 'चैट हटा दी गई';

  @override
  String chatsDeleted(int count) {
    return '$count चैट हटा दी गईं';
  }

  @override
  String get couldNotDelete =>
      'हटाया नहीं जा सका। अपना इंटरनेट जाँचें और फिर कोशिश करें।';

  @override
  String get newChat => 'नई चैट';

  @override
  String get newGroup => 'नया ग्रुप';

  @override
  String get newContact => 'नया संपर्क';

  @override
  String membersCount(int count) {
    return '$count सदस्य';
  }

  @override
  String get tapToStartChatting => 'चैट शुरू करने के लिए टैप करें';

  @override
  String get offlineNoContacts =>
      'आप ऑफ़लाइन हैं। इस डिवाइस पर अभी कोई संपर्क सेव नहीं है।';

  @override
  String get noChatsYet =>
      'अभी कोई चैट नहीं है। संपर्क जोड़ने या ग्रुप बनाने के लिए + पर टैप करें।';

  @override
  String get updates => 'अपडेट';

  @override
  String get chats => 'चैट';

  @override
  String get search => 'खोजें';

  @override
  String get closeSearch => 'खोज बंद करें';

  @override
  String get myTasks => 'मेरे कार्य';

  @override
  String get pleaseLogIn => 'अपने संपर्क देखने के लिए कृपया लॉग इन करें।';

  @override
  String get contactSaved => 'संपर्क सफलतापूर्वक सेव हो गया।';

  @override
  String get searchSettings => 'सेटिंग खोजें';

  @override
  String get noSettingsFound => 'कोई सेटिंग नहीं मिली';

  @override
  String get addNewContact => 'नया संपर्क जोड़ें';

  @override
  String get addNewContactSub => 'चैट शुरू करने के लिए संपर्क सेव करें';

  @override
  String get settingsAccount => 'खाता';

  @override
  String get settingsAccountSub => 'सुरक्षा सूचनाएँ, खाते की जानकारी';

  @override
  String get settingsPrivacy => 'गोपनीयता';

  @override
  String get settingsPrivacySub => 'ब्लॉक किए गए संपर्क, गायब होने वाले संदेश';

  @override
  String get settingsChatsSub => 'थीम, वॉलपेपर, चैट इतिहास';

  @override
  String get settingsNotifications => 'सूचनाएँ';

  @override
  String get settingsNotificationsSub => 'संदेश, ग्रुप और कॉल की टोन';

  @override
  String get settingsStorage => 'स्टोरेज और डेटा';

  @override
  String get settingsStorageSub => 'नेटवर्क उपयोग, ऑटो-डाउनलोड';

  @override
  String get settingsHelp => 'सहायता और फ़ीडबैक';

  @override
  String get settingsHelpSub =>
      'सहायता केंद्र, हमसे संपर्क करें, गोपनीयता नीति';

  @override
  String get logOut => 'लॉग आउट';

  @override
  String get logOutTitle => 'लॉग आउट करें?';

  @override
  String get logOutBody => 'क्या आप वाकई अपने खाते से लॉग आउट करना चाहते हैं?';

  @override
  String get profilePhotoUpdated =>
      'प्रोफ़ाइल फ़ोटो अपडेट हो गई। अब आपके संपर्क इसे देख सकते हैं।';

  @override
  String get createAccount => 'खाता बनाएँ';

  @override
  String get signupSubtitle => 'शुरू करने के लिए अपने ईमेल से साइन अप करें।';

  @override
  String get nickname => 'उपनाम';

  @override
  String get code => 'कोड';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get register => 'रजिस्टर करें';

  @override
  String get haveAccount => 'पहले से खाता है?';

  @override
  String get logInLink => 'लॉग इन करें';

  @override
  String get ruleLength => 'कम से कम 8 अक्षर';

  @override
  String get ruleCapital => '1 बड़ा अक्षर (A-Z)';

  @override
  String get ruleSmall => '1 छोटा अक्षर (a-z)';

  @override
  String get ruleNumber => '1 अंक (0-9)';

  @override
  String get ruleSpecial => '1 विशेष चिह्न (! @ # \$ %)';

  @override
  String get enterNickname => 'कृपया उपनाम दर्ज करें';

  @override
  String get useAtLeast3 => 'कम से कम 3 अक्षर रखें';

  @override
  String get useAtMost20 => 'अधिकतम 20 अक्षर रखें';

  @override
  String get enterNewPassword => 'कृपया पासवर्ड दर्ज करें';

  @override
  String get useAtLeast8 => 'कम से कम 8 अक्षर रखें';

  @override
  String get noSpaces => 'पासवर्ड में खाली जगह नहीं हो सकती';

  @override
  String get addCapital => '1 बड़ा अक्षर जोड़ें (A-Z)';

  @override
  String get addSmall => '1 छोटा अक्षर जोड़ें (a-z)';

  @override
  String get addNumber => '1 अंक जोड़ें (0-9)';

  @override
  String get addSpecial => '1 विशेष चिह्न जोड़ें (! @ # \$ % & *)';

  @override
  String get confirmYourPassword => 'कृपया अपने पासवर्ड की पुष्टि करें';

  @override
  String get passwordsDontMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get emailAlreadyRegistered =>
      'यह ईमेल पहले से रजिस्टर है। कृपया लॉग इन करें।';

  @override
  String get weakPassword => 'यह पासवर्ड बहुत कमज़ोर है। कृपया दूसरा चुनें।';

  @override
  String get signupNotEnabled =>
      'Firebase कंसोल में ईमेल/पासवर्ड साइन अप चालू नहीं है।';

  @override
  String get signupFailed => 'खाता नहीं बन सका। कृपया फिर कोशिश करें।';

  @override
  String get createAccountWentWrong =>
      'खाता बनाते समय कुछ गलत हो गया। कृपया फिर कोशिश करें।';

  @override
  String get accountNotCreated => 'खाता नहीं बन सका। कृपया फिर कोशिश करें।';

  @override
  String get phoneAlreadyRegistered =>
      'यह फ़ोन नंबर पहले से किसी दूसरे खाते से रजिस्टर है। कृपया दूसरा नंबर इस्तेमाल करें।';

  @override
  String get phoneCheckFailed =>
      'फ़ोन नंबर की जाँच नहीं हो सकी। अपना इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get phoneJustTaken =>
      'इस फ़ोन नंबर को अभी-अभी किसी दूसरे खाते ने रजिस्टर किया है। कृपया दूसरा नंबर इस्तेमाल करें।';

  @override
  String get phoneSaveFailed =>
      'फ़ोन नंबर सेव नहीं हो सका। अपना इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String phoneSaveFailedCode(String code) {
    return 'फ़ोन नंबर सेव नहीं हो सका ($code)। कृपया फिर कोशिश करें।';
  }

  @override
  String get verificationCancelled =>
      'सत्यापन रद्द हो गया, इसलिए कोई खाता नहीं बना। कृपया फिर कोशिश करें।';

  @override
  String get enterPhone => 'फ़ोन नंबर दर्ज करें';

  @override
  String get digitsOnly => 'केवल अंकों का उपयोग करें';

  @override
  String get invalidPhone => 'सही फ़ोन नंबर दर्ज करें (6–15 अंक)';

  @override
  String get verifyYourEmail => 'अपना ईमेल सत्यापित करें';

  @override
  String otpSentTo(String email) {
    return 'इस पर भेजा गया 4 अंकों का कोड दर्ज करें\n$email';
  }

  @override
  String get enterAllDigits => 'सभी 4 अंक दर्ज करें';

  @override
  String get wrongOtp => 'गलत OTP, फिर कोशिश करें';

  @override
  String get messages => 'संदेश';

  @override
  String get now => 'अभी';

  @override
  String otpMessage(String appName, String code) {
    return 'आपका $appName सत्यापन कोड $code है। इसे किसी के साथ साझा न करें।';
  }

  @override
  String resendCodeIn(String time) {
    return '$time में कोड दोबारा भेजें';
  }

  @override
  String get resendCode => 'कोड दोबारा भेजें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get backToLogin => 'लॉगिन पर वापस जाएँ';

  @override
  String get enterEmail => 'कृपया अपना ईमेल दर्ज करें';

  @override
  String get invalidEmail => 'सही ईमेल दर्ज करें (उदाहरण: name@gmail.com)';

  @override
  String get invalidEmailAddress => 'कृपया सही ईमेल पता दर्ज करें।';

  @override
  String get tooManyAttempts =>
      'बहुत ज़्यादा प्रयास। कृपया बाद में फिर कोशिश करें।';

  @override
  String get networkError => 'नेटवर्क त्रुटि। अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया। कृपया फिर कोशिश करें।';

  @override
  String get enterPassword => 'कृपया अपना पासवर्ड दर्ज करें';

  @override
  String get loginCredentials =>
      'ईमेल या पासवर्ड गलत है। अगर आप नए हैं, तो नीचे साइन अप पर टैप करें।';

  @override
  String get accountDisabled => 'यह खाता बंद कर दिया गया है।';

  @override
  String get loginFailed => 'लॉग इन नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get verifyEmailFirst =>
      'कृपया पहले अपना ईमेल सत्यापित करें। अपने इनबॉक्स में भेजा गया लिंक खोलें (स्पैम भी देखें), फिर दोबारा लॉग इन करें।';

  @override
  String get verificationSent =>
      'सत्यापन ईमेल भेज दिया गया है। अपना इनबॉक्स देखें।';

  @override
  String get accountVerified => 'खाता सत्यापित हो गया। कृपया लॉग इन करें।';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get loginSubtitle => 'अपने ईमेल और पासवर्ड से लॉग इन करें।';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get resendVerification => 'सत्यापन ईमेल दोबारा भेजें';

  @override
  String get login => 'लॉगिन';

  @override
  String get noAccount => 'खाता नहीं है?';

  @override
  String get signUp => 'साइन अप';

  @override
  String get noAccountFound =>
      'इस ईमेल से कोई खाता नहीं मिला। कृपया साइन अप करें।';

  @override
  String get couldNotSendEmail =>
      'ईमेल नहीं भेजा जा सका। कृपया फिर कोशिश करें।';

  @override
  String get forgotSubtitle =>
      'अपना रजिस्टर्ड ईमेल दर्ज करें, हम आपको नया पासवर्ड चुनने के लिए एक लिंक भेजेंगे।';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get checkInbox => 'अपना इनबॉक्स देखें';

  @override
  String get resendLink => 'लिंक दोबारा भेजें';

  @override
  String get changeEmail => 'ईमेल बदलें';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंड में दोबारा भेजें';
  }

  @override
  String resetLinkSent(String email) {
    return 'हमने $email पर रीसेट लिंक भेजा है। उसे खोलें, नया पासवर्ड चुनें, फिर उसी से लॉग इन करें।\n\nदिख नहीं रहा? अपना स्पैम फ़ोल्डर भी देखें।';
  }

  @override
  String get tagline => 'संदेश भेजना, खूबसूरती से आसान।';

  @override
  String get premiumMessaging => 'प्रीमियम मैसेजिंग';

  @override
  String get welcomeBody =>
      'आपके अपनों के लिए निजी चैट, तेज़ डिलीवरी और ग्रुप।';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get newHere => 'यहाँ नए हैं?';

  @override
  String get createAnAccount => 'खाता बनाएँ';

  @override
  String get perkPrivate => 'निजी';

  @override
  String get perkFast => 'तेज़';

  @override
  String get perkGroups => 'ग्रुप';

  @override
  String get accountCreated =>
      'खाता बन गया है। सत्यापन लिंक के लिए अपना ईमेल देखें, फिर लॉग इन करें।';

  @override
  String get settingsLanguage => 'ऐप की भाषा';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get chooseLanguageHelp =>
      'ऐप की भाषा चुनें। आपके चैट संदेशों का अनुवाद नहीं किया जाता।';
}
