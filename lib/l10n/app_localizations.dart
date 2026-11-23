import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @firebaseCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Firebase could not start'**
  String get firebaseCouldNotStart;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @newGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'New group message'**
  String get newGroupMessage;

  /// No description provided for @photoWord.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoWord;

  /// No description provided for @chatWord.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatWord;

  /// No description provided for @notifTaskChannel.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get notifTaskChannel;

  /// No description provided for @notifTaskChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders for your tasks'**
  String get notifTaskChannelDesc;

  /// No description provided for @notifMessagesChannel.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notifMessagesChannel;

  /// No description provided for @notifMessagesChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'New messages from your contacts'**
  String get notifMessagesChannelDesc;

  /// No description provided for @notifStatusChannel.
  ///
  /// In en, this message translates to:
  /// **'Message status'**
  String get notifStatusChannel;

  /// No description provided for @notifStatusChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for successfully sent messages'**
  String get notifStatusChannelDesc;

  /// No description provided for @sentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo sent successfully'**
  String get sentPhoto;

  /// No description provided for @sentDocument.
  ///
  /// In en, this message translates to:
  /// **'Document sent successfully'**
  String get sentDocument;

  /// No description provided for @sentContact.
  ///
  /// In en, this message translates to:
  /// **'Contact sent successfully'**
  String get sentContact;

  /// No description provided for @sentMessage.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully'**
  String get sentMessage;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String hoursAgo(int hours);

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Photo is too large. Please choose a smaller one.'**
  String get photoTooLarge;

  /// No description provided for @statusText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get statusText;

  /// No description provided for @addStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Add status'**
  String get addStatusTitle;

  /// No description provided for @myStatus.
  ///
  /// In en, this message translates to:
  /// **'My status'**
  String get myStatus;

  /// No description provided for @tapToAddStatus.
  ///
  /// In en, this message translates to:
  /// **'Tap to add status update'**
  String get tapToAddStatus;

  /// No description provided for @recentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent updates'**
  String get recentUpdates;

  /// No description provided for @viewedUpdates.
  ///
  /// In en, this message translates to:
  /// **'Viewed updates'**
  String get viewedUpdates;

  /// No description provided for @noRecentUpdates.
  ///
  /// In en, this message translates to:
  /// **'No recent updates.\nStatuses from your contacts appear here and disappear after a short time.'**
  String get noRecentUpdates;

  /// No description provided for @addStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add status'**
  String get addStatusTooltip;

  /// No description provided for @textStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text status'**
  String get textStatusTooltip;

  /// No description provided for @photoStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Photo status'**
  String get photoStatusTooltip;

  /// No description provided for @couldNotOpenCameraOrGallery.
  ///
  /// In en, this message translates to:
  /// **'Could not open the camera or gallery'**
  String get couldNotOpenCameraOrGallery;

  /// No description provided for @statusUpdatesLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 update · {timeAgo}} other{{count} updates · {timeAgo}}}'**
  String statusUpdatesLine(int count, String timeAgo);

  /// No description provided for @typeSomethingFirst.
  ///
  /// In en, this message translates to:
  /// **'Type something first'**
  String get typeSomethingFirst;

  /// No description provided for @statusOfflineQueued.
  ///
  /// In en, this message translates to:
  /// **'No internet. Your status will post when you are back online.'**
  String get statusOfflineQueued;

  /// No description provided for @addCaption.
  ///
  /// In en, this message translates to:
  /// **'Add a caption...'**
  String get addCaption;

  /// No description provided for @typeAStatus.
  ///
  /// In en, this message translates to:
  /// **'Type a status'**
  String get typeAStatus;

  /// No description provided for @changeColour.
  ///
  /// In en, this message translates to:
  /// **'Change colour'**
  String get changeColour;

  /// No description provided for @deleteStatus.
  ///
  /// In en, this message translates to:
  /// **'Delete status'**
  String get deleteStatus;

  /// No description provided for @noViewsYet.
  ///
  /// In en, this message translates to:
  /// **'No views yet'**
  String get noViewsYet;

  /// No description provided for @couldNotLoadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Could not load this photo'**
  String get couldNotLoadPhoto;

  /// No description provided for @viewedBy.
  ///
  /// In en, this message translates to:
  /// **'Viewed by {count}'**
  String viewedBy(int count);

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get assignTo;

  /// No description provided for @mePersonalTask.
  ///
  /// In en, this message translates to:
  /// **'Me (personal task)'**
  String get mePersonalTask;

  /// No description provided for @noSavedContactsAddFirst.
  ///
  /// In en, this message translates to:
  /// **'No saved contacts yet. Add a contact first.'**
  String get noSavedContactsAddFirst;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitleHint;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @addMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Add more details'**
  String get addMoreDetails;

  /// No description provided for @dueDateTime.
  ///
  /// In en, this message translates to:
  /// **'Due Date & Time'**
  String get dueDateTime;

  /// No description provided for @reminderLabelText.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderLabelText;

  /// No description provided for @reminderFor.
  ///
  /// In en, this message translates to:
  /// **'Reminder for {name}'**
  String reminderFor(String name);

  /// No description provided for @reminderGoesToThem.
  ///
  /// In en, this message translates to:
  /// **'{name} gets this reminder on their phone.'**
  String reminderGoesToThem(String name);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @assignTask.
  ///
  /// In en, this message translates to:
  /// **'Assign Task'**
  String get assignTask;

  /// No description provided for @saveTask.
  ///
  /// In en, this message translates to:
  /// **'Save Task'**
  String get saveTask;

  /// No description provided for @couldNotSaveTask.
  ///
  /// In en, this message translates to:
  /// **'Could not save the task. Check your internet and the database rules.'**
  String get couldNotSaveTask;

  /// No description provided for @assignedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}. It will appear in their My Tasks.'**
  String assignedSuccess(String name);

  /// No description provided for @taskSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your task has been saved successfully.'**
  String get taskSavedSuccess;

  /// No description provided for @taskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task Updated!'**
  String get taskUpdated;

  /// No description provided for @taskAssigned.
  ///
  /// In en, this message translates to:
  /// **'Task Assigned!'**
  String get taskAssigned;

  /// No description provided for @taskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task Created!'**
  String get taskCreated;

  /// No description provided for @noReminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'No reminder was scheduled: the reminder time has already passed, or notifications are off.'**
  String get noReminderScheduled;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// No description provided for @titleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Title is too long'**
  String get titleTooLong;

  /// No description provided for @descTooLong.
  ///
  /// In en, this message translates to:
  /// **'Description is too long'**
  String get descTooLong;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskBody.
  ///
  /// In en, this message translates to:
  /// **'This task and its reminder will be removed.'**
  String get deleteTaskBody;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get noReminder;

  /// No description provided for @pleaseLogInTasks.
  ///
  /// In en, this message translates to:
  /// **'Please log in to see your tasks.'**
  String get pleaseLogInTasks;

  /// No description provided for @couldNotLoadTasks.
  ///
  /// In en, this message translates to:
  /// **'Unable to load tasks. Check your internet and the database rules.'**
  String get couldNotLoadTasks;

  /// No description provided for @emptyAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Nothing is assigned to you yet.'**
  String get emptyAssignedToMe;

  /// No description provided for @emptyAssignedByMe.
  ///
  /// In en, this message translates to:
  /// **'You have not assigned any task yet.\nLong-press a chat message and tap Create Task.'**
  String get emptyAssignedByMe;

  /// No description provided for @emptyNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.\nLong-press a chat message and tap Create Task.'**
  String get emptyNoTasks;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this list.'**
  String get emptyList;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String filterAll(int count);

  /// No description provided for @filterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming ({count})'**
  String filterUpcoming(int count);

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed ({count})'**
  String filterCompleted(int count);

  /// No description provided for @filterAssignedToMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned to me ({count})'**
  String filterAssignedToMe(int count);

  /// No description provided for @filterAssignedByMe.
  ///
  /// In en, this message translates to:
  /// **'Assigned by me ({count})'**
  String filterAssignedByMe(int count);

  /// No description provided for @doneBy.
  ///
  /// In en, this message translates to:
  /// **'Done by {name}'**
  String doneBy(String name);

  /// No description provided for @waitingFor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}'**
  String waitingFor(String name);

  /// No description provided for @reminderPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {label}'**
  String reminderPrefix(String label);

  /// No description provided for @assignedByLine.
  ///
  /// In en, this message translates to:
  /// **'Assigned by {name}'**
  String assignedByLine(String name);

  /// No description provided for @assignedToLine.
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}'**
  String assignedToLine(String name);

  /// No description provided for @fromLine.
  ///
  /// In en, this message translates to:
  /// **'From: {name}'**
  String fromLine(String name);

  /// No description provided for @deleteTaskAssignedBody.
  ///
  /// In en, this message translates to:
  /// **'This task will be removed for you and for {name}.'**
  String deleteTaskAssignedBody(String name);

  /// No description provided for @couldNotUpdateTask.
  ///
  /// In en, this message translates to:
  /// **'Could not update the task. Check your internet connection.'**
  String get couldNotUpdateTask;

  /// No description provided for @couldNotDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the task. Check your internet connection.'**
  String get couldNotDeleteTask;

  /// No description provided for @reminderAtDue.
  ///
  /// In en, this message translates to:
  /// **'At due time'**
  String get reminderAtDue;

  /// No description provided for @reminder10Min.
  ///
  /// In en, this message translates to:
  /// **'10 minutes before'**
  String get reminder10Min;

  /// No description provided for @reminder1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminder1Hour;

  /// No description provided for @reminder2Hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours before'**
  String get reminder2Hours;

  /// No description provided for @reminder1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminder1Day;

  /// No description provided for @dueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get dueNow;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}, {time}'**
  String dueOn(String date, String time);

  /// No description provided for @newTaskFrom.
  ///
  /// In en, this message translates to:
  /// **'New task from {who}'**
  String newTaskFrom(String who);

  /// No description provided for @aContact.
  ///
  /// In en, this message translates to:
  /// **'a contact'**
  String get aContact;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @groupNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameTitle;

  /// No description provided for @changeGroupName.
  ///
  /// In en, this message translates to:
  /// **'Change group name'**
  String get changeGroupName;

  /// No description provided for @addMembers.
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get addMembers;

  /// No description provided for @groupAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'Group admin'**
  String get groupAdminBadge;

  /// No description provided for @removeFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get removeFromGroup;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @removeMemberBody.
  ///
  /// In en, this message translates to:
  /// **'They will not receive new messages from this group.'**
  String get removeMemberBody;

  /// No description provided for @exitGroup.
  ///
  /// In en, this message translates to:
  /// **'Exit group'**
  String get exitGroup;

  /// No description provided for @exitGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit group?'**
  String get exitGroupTitle;

  /// No description provided for @exitAction.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitAction;

  /// No description provided for @exitGroupBody.
  ///
  /// In en, this message translates to:
  /// **'You will no longer receive messages from this group.'**
  String get exitGroupBody;

  /// No description provided for @disappearingGroupHelp.
  ///
  /// In en, this message translates to:
  /// **'New messages in this group will disappear after the time you choose.'**
  String get disappearingGroupHelp;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeMemberTitle(String name);

  /// No description provided for @groupMembersLine.
  ///
  /// In en, this message translates to:
  /// **'Group · {count} members'**
  String groupMembersLine(int count);

  /// No description provided for @addGroupMembers.
  ///
  /// In en, this message translates to:
  /// **'Add group members'**
  String get addGroupMembers;

  /// No description provided for @noContactsToAdd.
  ///
  /// In en, this message translates to:
  /// **'No contacts to add. Save a contact first.'**
  String get noContactsToAdd;

  /// No description provided for @selectedOf.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String selectedOf(int selected, int total);

  /// No description provided for @addAName.
  ///
  /// In en, this message translates to:
  /// **'Add a name'**
  String get addAName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group name (required)'**
  String get groupNameHint;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please type a group name'**
  String get groupNameRequired;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members: {count}'**
  String membersTitle(int count);

  /// No description provided for @couldNotRenameGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not rename the group'**
  String get couldNotRenameGroup;

  /// No description provided for @couldNotAddMembers.
  ///
  /// In en, this message translates to:
  /// **'Could not add the members'**
  String get couldNotAddMembers;

  /// No description provided for @couldNotRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Could not remove this member'**
  String get couldNotRemoveMember;

  /// No description provided for @couldNotExitGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not exit the group'**
  String get couldNotExitGroup;

  /// No description provided for @pleaseLogInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please log in again'**
  String get pleaseLogInAgain;

  /// No description provided for @noLongerInGroup.
  ///
  /// In en, this message translates to:
  /// **'You are no longer in this group'**
  String get noLongerInGroup;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @forwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get forwarded;

  /// No description provided for @disappearingNotice.
  ///
  /// In en, this message translates to:
  /// **'⏱ Disappearing messages: {label}'**
  String disappearingNotice(String label);

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule sending'**
  String get scheduleTitle;

  /// No description provided for @scheduleTypeFirst.
  ///
  /// In en, this message translates to:
  /// **'Type a message or select an image first'**
  String get scheduleTypeFirst;

  /// No description provided for @scheduleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Pick a time in the future'**
  String get scheduleInvalid;

  /// No description provided for @tomorrowDay.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {day}'**
  String tomorrowDay(String day);

  /// No description provided for @scheduleToday.
  ///
  /// In en, this message translates to:
  /// **'today at {time}'**
  String scheduleToday(String time);

  /// No description provided for @scheduleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow at {time}'**
  String scheduleTomorrow(String time);

  /// No description provided for @scheduleOn.
  ///
  /// In en, this message translates to:
  /// **'on {day} at {time}'**
  String scheduleOn(String day, String time);

  /// No description provided for @sendAt.
  ///
  /// In en, this message translates to:
  /// **'Send {label}'**
  String sendAt(String label);

  /// No description provided for @scheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Message scheduled for {label}'**
  String scheduledFor(String label);

  /// No description provided for @callsNotInGroups.
  ///
  /// In en, this message translates to:
  /// **'Calls are not available in groups yet'**
  String get callsNotInGroups;

  /// No description provided for @couldNotIdentifyContact.
  ///
  /// In en, this message translates to:
  /// **'Could not identify the contact account'**
  String get couldNotIdentifyContact;

  /// No description provided for @couldNotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone dialer'**
  String get couldNotOpenDialer;

  /// No description provided for @noPhoneSaved.
  ///
  /// In en, this message translates to:
  /// **'No phone number saved for {name}'**
  String noPhoneSaved(String name);

  /// No description provided for @couldNotOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Could not open the camera. Check camera permission.'**
  String get couldNotOpenCamera;

  /// No description provided for @couldNotOpenGallery.
  ///
  /// In en, this message translates to:
  /// **'Could not open the gallery'**
  String get couldNotOpenGallery;

  /// No description provided for @couldNotPickDocument.
  ///
  /// In en, this message translates to:
  /// **'Could not pick the document'**
  String get couldNotPickDocument;

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file'**
  String get couldNotOpenFile;

  /// No description provided for @attachCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachCamera;

  /// No description provided for @attachGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get attachGallery;

  /// No description provided for @attachContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get attachContact;

  /// No description provided for @attachLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get attachLocation;

  /// No description provided for @locationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Location sharing is coming soon'**
  String get locationComingSoon;

  /// No description provided for @shareContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Share contact'**
  String get shareContactTitle;

  /// No description provided for @forwardToTitle.
  ///
  /// In en, this message translates to:
  /// **'Forward to...'**
  String get forwardToTitle;

  /// No description provided for @noSavedContacts.
  ///
  /// In en, this message translates to:
  /// **'No saved contacts yet'**
  String get noSavedContacts;

  /// No description provided for @searchNameOrNumber.
  ///
  /// In en, this message translates to:
  /// **'Search name or number'**
  String get searchNameOrNumber;

  /// No description provided for @noContactFound.
  ///
  /// In en, this message translates to:
  /// **'No contact found'**
  String get noContactFound;

  /// No description provided for @selectContacts.
  ///
  /// In en, this message translates to:
  /// **'Select contacts'**
  String get selectContacts;

  /// No description provided for @sendToCount.
  ///
  /// In en, this message translates to:
  /// **'Send to {count}'**
  String sendToCount(int count);

  /// No description provided for @cardMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get cardMessage;

  /// No description provided for @alreadyInContacts.
  ///
  /// In en, this message translates to:
  /// **'Already in your contacts'**
  String get alreadyInContacts;

  /// No description provided for @ownNumber.
  ///
  /// In en, this message translates to:
  /// **'This is your own number'**
  String get ownNumber;

  /// No description provided for @contactSavedShort.
  ///
  /// In en, this message translates to:
  /// **'Contact saved'**
  String get contactSavedShort;

  /// No description provided for @couldNotSaveContact.
  ///
  /// In en, this message translates to:
  /// **'Could not save the contact. Check the database rules.'**
  String get couldNotSaveContact;

  /// No description provided for @waitUntilSent.
  ///
  /// In en, this message translates to:
  /// **'Wait until the message is sent'**
  String get waitUntilSent;

  /// No description provided for @messageForwarded.
  ///
  /// In en, this message translates to:
  /// **'Message forwarded'**
  String get messageForwarded;

  /// No description provided for @forwardedToCount.
  ///
  /// In en, this message translates to:
  /// **'Forwarded to {done} of {total} contacts'**
  String forwardedToCount(int done, int total);

  /// No description provided for @voiceLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice typing language'**
  String get voiceLanguageTitle;

  /// No description provided for @voiceLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'The mic listens to one language at a time. Choose the language you will speak.'**
  String get voiceLanguageHelp;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @voiceLanguageChosen.
  ///
  /// In en, this message translates to:
  /// **'Voice typing language: {name}'**
  String voiceLanguageChosen(String name);

  /// No description provided for @listeningIn.
  ///
  /// In en, this message translates to:
  /// **'Listening in {name}...'**
  String listeningIn(String name);

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @clearChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear chat?'**
  String get clearChatTitle;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearGroupBody.
  ///
  /// In en, this message translates to:
  /// **'All messages in {title} will be deleted for everyone.'**
  String clearGroupBody(String title);

  /// No description provided for @clearChatBody.
  ///
  /// In en, this message translates to:
  /// **'All messages with {name} will be deleted.'**
  String clearChatBody(String name);

  /// No description provided for @couldNotLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Unable to load messages. Check your Firebase Realtime Database rules.'**
  String get couldNotLoadMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet\nSay hi 👋'**
  String get noMessagesYet;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageHint;

  /// No description provided for @photoAttached.
  ///
  /// In en, this message translates to:
  /// **'Photo attached'**
  String get photoAttached;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @groupInfo.
  ///
  /// In en, this message translates to:
  /// **'Group info'**
  String get groupInfo;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @matchOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String matchOf(int current, int total);

  /// No description provided for @couldNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not send the message. Please try again.'**
  String get couldNotSendMessage;

  /// No description provided for @couldNotScheduleMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule the message. Please try again.'**
  String get couldNotScheduleMessage;

  /// No description provided for @nothingToSend.
  ///
  /// In en, this message translates to:
  /// **'Nothing to send'**
  String get nothingToSend;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image is too large. Please choose a smaller photo.'**
  String get imageTooLarge;

  /// No description provided for @couldNotShareContact.
  ///
  /// In en, this message translates to:
  /// **'Could not share the contact. Please try again.'**
  String get couldNotShareContact;

  /// No description provided for @documentsOnlineOnly.
  ///
  /// In en, this message translates to:
  /// **'Documents can only be sent when you are online.'**
  String get documentsOnlineOnly;

  /// No description provided for @couldNotSaveAttachment.
  ///
  /// In en, this message translates to:
  /// **'Could not save the attachment. Please try again.'**
  String get couldNotSaveAttachment;

  /// No description provided for @couldNotDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the message'**
  String get couldNotDeleteMessage;

  /// No description provided for @couldNotClearChat.
  ///
  /// In en, this message translates to:
  /// **'Could not clear the chat'**
  String get couldNotClearChat;

  /// No description provided for @reactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the reaction. Check the database rules.'**
  String get reactionFailed;

  /// No description provided for @voiceNoSpeech.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t hear anything in {language}. Tap the mic and speak clearly, or change the language (long-press the mic).'**
  String voiceNoSpeech(String language);

  /// No description provided for @micPermission.
  ///
  /// In en, this message translates to:
  /// **'Please allow the microphone permission for this app'**
  String get micPermission;

  /// No description provided for @voiceLangNotReady.
  ///
  /// In en, this message translates to:
  /// **'{language} voice typing is not ready on this phone.\nConnect to the internet, or download {language} in the phone\'s Google voice typing settings.'**
  String voiceLangNotReady(String language);

  /// No description provided for @voiceNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Voice error: {error}\nCheck your internet, or download {language} for offline use in the phone settings, or type your message.'**
  String voiceNetworkError(String error, String language);

  /// No description provided for @speechError.
  ///
  /// In en, this message translates to:
  /// **'Speech error: {error}'**
  String speechError(String error);

  /// No description provided for @micPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed. Allow it in the app settings.'**
  String get micPermissionNeeded;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @attachDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get attachDocument;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @mediaLinksDocs.
  ///
  /// In en, this message translates to:
  /// **'Media, links, and docs'**
  String get mediaLinksDocs;

  /// No description provided for @disappearingTitle.
  ///
  /// In en, this message translates to:
  /// **'Disappearing messages'**
  String get disappearingTitle;

  /// No description provided for @disappearOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get disappearOff;

  /// No description provided for @disappear5Min.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get disappear5Min;

  /// No description provided for @disappear1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get disappear1Day;

  /// No description provided for @disappear7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get disappear7Days;

  /// No description provided for @contactInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get contactInfoTitle;

  /// No description provided for @phoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number unavailable'**
  String get phoneUnavailable;

  /// No description provided for @actionAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get actionAudio;

  /// No description provided for @actionVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get actionVideo;

  /// No description provided for @mediaVisibility.
  ///
  /// In en, this message translates to:
  /// **'Media visibility'**
  String get mediaVisibility;

  /// No description provided for @encryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get encryption;

  /// No description provided for @encryptionSub.
  ///
  /// In en, this message translates to:
  /// **'Messages and calls are not yet end-to-end encrypted.'**
  String get encryptionSub;

  /// No description provided for @blockContact.
  ///
  /// In en, this message translates to:
  /// **'Block contact'**
  String get blockContact;

  /// No description provided for @disappearingChatHelp.
  ///
  /// In en, this message translates to:
  /// **'New messages in this chat will disappear after the time you choose.'**
  String get disappearingChatHelp;

  /// No description provided for @couldNotChangeSetting.
  ///
  /// In en, this message translates to:
  /// **'Could not change the setting. Check your internet.'**
  String get couldNotChangeSetting;

  /// No description provided for @notificationSettingsMsg.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettingsMsg;

  /// No description provided for @mediaVisibilitySettingsMsg.
  ///
  /// In en, this message translates to:
  /// **'Media visibility settings'**
  String get mediaVisibilitySettingsMsg;

  /// No description provided for @encryptionMsg.
  ///
  /// In en, this message translates to:
  /// **'This app does not currently implement end-to-end encryption.'**
  String get encryptionMsg;

  /// No description provided for @blockingNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Contact blocking is not implemented yet.'**
  String get blockingNotImplemented;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get calling;

  /// No description provided for @videoCalling.
  ///
  /// In en, this message translates to:
  /// **'Video calling...'**
  String get videoCalling;

  /// No description provided for @callSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get callSpeaker;

  /// No description provided for @callMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get callMute;

  /// No description provided for @callFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get callFlip;

  /// No description provided for @callMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get callMore;

  /// No description provided for @callShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get callShare;

  /// No description provided for @callEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get callEnd;

  /// No description provided for @addPeopleSoon.
  ///
  /// In en, this message translates to:
  /// **'Adding people is coming soon'**
  String get addPeopleSoon;

  /// No description provided for @moreOptionsSoon.
  ///
  /// In en, this message translates to:
  /// **'More options are coming soon'**
  String get moreOptionsSoon;

  /// No description provided for @sharingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sharing is coming soon'**
  String get sharingSoon;

  /// No description provided for @noCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device'**
  String get noCameraFound;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied. Allow it in the app settings.'**
  String get cameraPermissionDenied;

  /// No description provided for @callCouldNotOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Could not open the camera'**
  String get callCouldNotOpenCamera;

  /// No description provided for @nothingToOpen.
  ///
  /// In en, this message translates to:
  /// **'Nothing to open here'**
  String get nothingToOpen;

  /// No description provided for @couldNotOpenThis.
  ///
  /// In en, this message translates to:
  /// **'Could not open this'**
  String get couldNotOpenThis;

  /// No description provided for @tabMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get tabMedia;

  /// No description provided for @tabDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get tabDocs;

  /// No description provided for @tabLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get tabLinks;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos shared yet'**
  String get noPhotosYet;

  /// No description provided for @noDocsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents shared yet'**
  String get noDocsYet;

  /// No description provided for @noLinksYet.
  ///
  /// In en, this message translates to:
  /// **'No links shared yet'**
  String get noLinksYet;

  /// No description provided for @couldNotLoadMedia.
  ///
  /// In en, this message translates to:
  /// **'Unable to load. Check your Firebase Realtime Database rules.'**
  String get couldNotLoadMedia;

  /// No description provided for @sharedBy.
  ///
  /// In en, this message translates to:
  /// **'{who}  •  {date}'**
  String sharedBy(String who, String date);

  /// No description provided for @linkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{title}\n{who}  •  {date}'**
  String linkSubtitle(String title, String who, String date);

  /// No description provided for @waitingOne.
  ///
  /// In en, this message translates to:
  /// **'1 message is waiting to be sent.'**
  String get waitingOne;

  /// No description provided for @waitingMany.
  ///
  /// In en, this message translates to:
  /// **'{count} messages are waiting to be sent.'**
  String waitingMany(int count);

  /// No description provided for @offlineWithPending.
  ///
  /// In en, this message translates to:
  /// **'You are offline. {waiting}'**
  String offlineWithPending(String waiting);

  /// No description provided for @offlineNoPending.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Please turn on your internet connection.'**
  String get offlineNoPending;

  /// No description provided for @connectingWithPending.
  ///
  /// In en, this message translates to:
  /// **'Connecting... {waiting}'**
  String connectingWithPending(String waiting);

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @backOnlineSending.
  ///
  /// In en, this message translates to:
  /// **'Back online. Sending your messages...'**
  String get backOnlineSending;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'You are back online.'**
  String get backOnline;

  /// No description provided for @saveContact.
  ///
  /// In en, this message translates to:
  /// **'Save contact'**
  String get saveContact;

  /// No description provided for @addContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContactTitle;

  /// No description provided for @addContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the registered email and the rest is filled in automatically.'**
  String get addContactSubtitle;

  /// No description provided for @contactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get contactNameLabel;

  /// No description provided for @registeredEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered email address'**
  String get registeredEmailLabel;

  /// No description provided for @userFound.
  ///
  /// In en, this message translates to:
  /// **'Registered user found'**
  String get userFound;

  /// No description provided for @userFoundNoPhone.
  ///
  /// In en, this message translates to:
  /// **'Registered user found. They have not added a phone number, so please type it below.'**
  String get userFoundNoPhone;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No registered user found with this email'**
  String get userNotFound;

  /// No description provided for @cannotAddSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot add your own account.'**
  String get cannotAddSelf;

  /// No description provided for @lookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not look up this email.'**
  String get lookupFailed;

  /// No description provided for @lookupFailedInternet.
  ///
  /// In en, this message translates to:
  /// **'Could not look up this email. Check your internet connection.'**
  String get lookupFailedInternet;

  /// No description provided for @userFoundName.
  ///
  /// In en, this message translates to:
  /// **'Registered user found: {name}'**
  String userFoundName(String name);

  /// No description provided for @lookupFailedCode.
  ///
  /// In en, this message translates to:
  /// **'Could not look up this email ({code}).'**
  String lookupFailedCode(String code);

  /// No description provided for @enterContactName.
  ///
  /// In en, this message translates to:
  /// **'Enter the user name'**
  String get enterContactName;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 4 characters'**
  String get nameTooShort;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be 40 characters or less'**
  String get nameTooLong;

  /// No description provided for @enterRegisteredEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the registered email address'**
  String get enterRegisteredEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @loginAgainToSave.
  ///
  /// In en, this message translates to:
  /// **'Please log in again before saving contacts.'**
  String get loginAgainToSave;

  /// No description provided for @userAlreadyInContacts.
  ///
  /// In en, this message translates to:
  /// **'This user is already in your contacts.'**
  String get userAlreadyInContacts;

  /// No description provided for @firebaseDenied.
  ///
  /// In en, this message translates to:
  /// **'Firebase denied access. Check your database rules.'**
  String get firebaseDenied;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @firebaseError.
  ///
  /// In en, this message translates to:
  /// **'Firebase error ({code}): {message}'**
  String firebaseError(String code, String message);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @notAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get notAdded;

  /// No description provided for @saveName.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get saveName;

  /// No description provided for @profileNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get profileNameUpdated;

  /// No description provided for @nameSavedNote.
  ///
  /// In en, this message translates to:
  /// **'People who saved you keep the name they chose for you.'**
  String get nameSavedNote;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterYourName;

  /// No description provided for @pleaseLogInBeforePicture.
  ///
  /// In en, this message translates to:
  /// **'Please log in again before changing your picture.'**
  String get pleaseLogInBeforePicture;

  /// No description provided for @pictureTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This picture is too large. Please choose a smaller image.'**
  String get pictureTooLarge;

  /// No description provided for @youAreOfflineTryAgain.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Connect to the internet and try again.'**
  String get youAreOfflineTryAgain;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed: {error}'**
  String profileUpdateFailed(String error);

  /// No description provided for @pleaseLogInBeforeName.
  ///
  /// In en, this message translates to:
  /// **'Please log in again before changing your name.'**
  String get pleaseLogInBeforeName;

  /// No description provided for @serverNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'The server did not answer. Check your internet connection and try again.'**
  String get serverNoAnswer;

  /// No description provided for @couldNotSaveNameCode.
  ///
  /// In en, this message translates to:
  /// **'Could not save your name ({code}). Please try again.'**
  String couldNotSaveNameCode(String code);

  /// No description provided for @couldNotSaveName.
  ///
  /// In en, this message translates to:
  /// **'Could not save your name. Please try again.'**
  String get couldNotSaveName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @videoCallNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'Video call · no answer'**
  String get videoCallNoAnswer;

  /// No description provided for @missedVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Missed video call'**
  String get missedVideoCall;

  /// No description provided for @youPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String youPrefix(String text);

  /// No description provided for @deleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get deleteChatTitle;

  /// No description provided for @deleteChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} chats?'**
  String deleteChatsTitle(int count);

  /// No description provided for @deleteChatBody.
  ///
  /// In en, this message translates to:
  /// **'The chat is removed from your list only. The other people keep their messages. A new message brings the chat back.'**
  String get deleteChatBody;

  /// No description provided for @chatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get chatDeleted;

  /// No description provided for @chatsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} chats deleted'**
  String chatsDeleted(int count);

  /// No description provided for @couldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Check your internet and try again.'**
  String get couldNotDelete;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @newContact.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get newContact;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// No description provided for @tapToStartChatting.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chatting'**
  String get tapToStartChatting;

  /// No description provided for @offlineNoContacts.
  ///
  /// In en, this message translates to:
  /// **'You are offline. No contacts are saved on this device yet.'**
  String get offlineNoContacts;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet. Tap + to add a contact or create a group.'**
  String get noChatsYet;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your contacts.'**
  String get pleaseLogIn;

  /// No description provided for @contactSaved.
  ///
  /// In en, this message translates to:
  /// **'Contact saved successfully.'**
  String get contactSaved;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get searchSettings;

  /// No description provided for @noSettingsFound.
  ///
  /// In en, this message translates to:
  /// **'No settings found'**
  String get noSettingsFound;

  /// No description provided for @addNewContact.
  ///
  /// In en, this message translates to:
  /// **'Add new contact'**
  String get addNewContact;

  /// No description provided for @addNewContactSub.
  ///
  /// In en, this message translates to:
  /// **'Save a contact to start chatting'**
  String get addNewContactSub;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Security notifications, account info'**
  String get settingsAccountSub;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySub.
  ///
  /// In en, this message translates to:
  /// **'Blocked contacts, disappearing messages'**
  String get settingsPrivacySub;

  /// No description provided for @settingsChatsSub.
  ///
  /// In en, this message translates to:
  /// **'Theme, wallpaper, chat history'**
  String get settingsChatsSub;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Message, group and call tones'**
  String get settingsNotificationsSub;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage and data'**
  String get settingsStorage;

  /// No description provided for @settingsStorageSub.
  ///
  /// In en, this message translates to:
  /// **'Network usage, auto-download'**
  String get settingsStorageSub;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help and feedback'**
  String get settingsHelp;

  /// No description provided for @settingsHelpSub.
  ///
  /// In en, this message translates to:
  /// **'Help centre, contact us, privacy policy'**
  String get settingsHelpSub;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutTitle;

  /// No description provided for @logOutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logOutBody;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated. Your contacts can now see it.'**
  String get profilePhotoUpdated;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with your email to get started.'**
  String get signupSubtitle;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @logInLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInLink;

  /// No description provided for @ruleLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get ruleLength;

  /// No description provided for @ruleCapital.
  ///
  /// In en, this message translates to:
  /// **'1 capital letter (A-Z)'**
  String get ruleCapital;

  /// No description provided for @ruleSmall.
  ///
  /// In en, this message translates to:
  /// **'1 small letter (a-z)'**
  String get ruleSmall;

  /// No description provided for @ruleNumber.
  ///
  /// In en, this message translates to:
  /// **'1 number (0-9)'**
  String get ruleNumber;

  /// No description provided for @ruleSpecial.
  ///
  /// In en, this message translates to:
  /// **'1 special character (! @ # \$ %)'**
  String get ruleSpecial;

  /// No description provided for @enterNickname.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname'**
  String get enterNickname;

  /// No description provided for @useAtLeast3.
  ///
  /// In en, this message translates to:
  /// **'Use at least 3 characters'**
  String get useAtLeast3;

  /// No description provided for @useAtMost20.
  ///
  /// In en, this message translates to:
  /// **'Use at most 20 characters'**
  String get useAtMost20;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterNewPassword;

  /// No description provided for @useAtLeast8.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get useAtLeast8;

  /// No description provided for @noSpaces.
  ///
  /// In en, this message translates to:
  /// **'Password cannot contain spaces'**
  String get noSpaces;

  /// No description provided for @addCapital.
  ///
  /// In en, this message translates to:
  /// **'Add 1 capital letter (A-Z)'**
  String get addCapital;

  /// No description provided for @addSmall.
  ///
  /// In en, this message translates to:
  /// **'Add 1 small letter (a-z)'**
  String get addSmall;

  /// No description provided for @addNumber.
  ///
  /// In en, this message translates to:
  /// **'Add 1 number (0-9)'**
  String get addNumber;

  /// No description provided for @addSpecial.
  ///
  /// In en, this message translates to:
  /// **'Add 1 special character (! @ # \$ % & *)'**
  String get addSpecial;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please log in.'**
  String get emailAlreadyRegistered;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Please choose another.'**
  String get weakPassword;

  /// No description provided for @signupNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Email/password sign-up is not enabled in Firebase Console.'**
  String get signupNotEnabled;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create account. Please try again.'**
  String get signupFailed;

  /// No description provided for @createAccountWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while creating the account. Please try again.'**
  String get createAccountWentWrong;

  /// No description provided for @accountNotCreated.
  ///
  /// In en, this message translates to:
  /// **'Account could not be created. Please try again.'**
  String get accountNotCreated;

  /// No description provided for @phoneAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered with another account. Please use a different number.'**
  String get phoneAlreadyRegistered;

  /// No description provided for @phoneCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check the phone number. Check your internet connection and try again.'**
  String get phoneCheckFailed;

  /// No description provided for @phoneJustTaken.
  ///
  /// In en, this message translates to:
  /// **'This phone number was just registered by another account. Please use a different number.'**
  String get phoneJustTaken;

  /// No description provided for @phoneSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the phone number. Check your internet connection and try again.'**
  String get phoneSaveFailed;

  /// No description provided for @phoneSaveFailedCode.
  ///
  /// In en, this message translates to:
  /// **'Could not save the phone number ({code}). Please try again.'**
  String phoneSaveFailedCode(String code);

  /// No description provided for @verificationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Verification was cancelled, so no account was created. Please try again.'**
  String get verificationCancelled;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number'**
  String get enterPhone;

  /// No description provided for @digitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Use digits only'**
  String get digitsOnly;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (6–15 digits)'**
  String get invalidPhone;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to\n{email}'**
  String otpSentTo(String email);

  /// No description provided for @enterAllDigits.
  ///
  /// In en, this message translates to:
  /// **'Enter all 4 digits'**
  String get enterAllDigits;

  /// No description provided for @wrongOtp.
  ///
  /// In en, this message translates to:
  /// **'Wrong OTP, try again'**
  String get wrongOtp;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @otpMessage.
  ///
  /// In en, this message translates to:
  /// **'Your {appName} verification code is {code}. Do not share it with anyone.'**
  String otpMessage(String appName, String code);

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String resendCodeIn(String time);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email (example: name@gmail.com)'**
  String get invalidEmail;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmailAddress;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyAttempts;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your internet connection.'**
  String get networkError;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @loginCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect. If you are new here, tap Sign up below.'**
  String get loginCredentials;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get accountDisabled;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to log in. Please try again.'**
  String get loginFailed;

  /// No description provided for @verifyEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email first. Open the link we sent to your inbox (check Spam too), then log in again.'**
  String get verifyEmailFirst;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox.'**
  String get verificationSent;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified. Please log in.'**
  String get accountVerified;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in with your email and password.'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerification;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @noAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Please sign up.'**
  String get noAccountFound;

  /// No description provided for @couldNotSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not send the email. Please try again.'**
  String get couldNotSendEmail;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and we will send you a link to choose a new password.'**
  String get forgotSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkInbox;

  /// No description provided for @resendLink.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get resendLink;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a reset link to {email}. Open it, choose a new password, then log in with it.\n\nCannot see it? Check your Spam folder too.'**
  String resetLinkSent(String email);

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Messaging, beautifully simple.'**
  String get tagline;

  /// No description provided for @premiumMessaging.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM MESSAGING'**
  String get premiumMessaging;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Private chats, fast delivery and groups for the people who matter.'**
  String get welcomeBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @perkPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get perkPrivate;

  /// No description provided for @perkFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get perkFast;

  /// No description provided for @perkGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get perkGroups;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email for the verification link, then log in.'**
  String get accountCreated;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @chooseLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose the language of the app. Your chat messages are not translated.'**
  String get chooseLanguageHelp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'hi',
    'kn',
    'ml',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
