import 'package:flutter/material.dart';

// The icons used by the screens, in one place.
// To change an icon, change it here and every screen updates.
class AppIcons {
  AppIcons._();

  // ---------- FORM FIELDS ----------
  static const IconData email = Icons.email_outlined;
  static const IconData password = Icons.lock_outline;
  static const IconData confirmPassword = Icons.lock_reset;
  static const IconData person = Icons.person_outline;
  static const IconData phone = Icons.phone_outlined;
  static const IconData showPassword = Icons.visibility;
  static const IconData hidePassword = Icons.visibility_off;

  // ---------- START FLOW ----------
  static const IconData logo = Icons.chat_bubble_rounded;
  static const IconData perkPrivate = Icons.lock_rounded;
  static const IconData perkFast = Icons.bolt_rounded;
  static const IconData perkGroups = Icons.groups_rounded;
  static const IconData loginHeader = Icons.lock_rounded;
  static const IconData signupHeader = Icons.person_add_alt_1_rounded;
  static const IconData otpHeader = Icons.mark_email_read_rounded;
  static const IconData forgotHeader = Icons.lock_reset;
  static const IconData inboxHeader = Icons.mark_email_read_outlined;
  static const IconData sms = Icons.sms_rounded;

  // ---------- STATUS ----------
  static const IconData error = Icons.error_outline;
  static const IconData ruleDone = Icons.check_circle;
  static const IconData ruleTodo = Icons.radio_button_unchecked;

  // ---------- HOME ----------
  static const IconData back = Icons.arrow_back;
  static const IconData search = Icons.search;
  static const IconData close = Icons.close;
  static const IconData tasks = Icons.task_alt;
  static const IconData deleteChat = Icons.delete_outline;
  static const IconData newChat = Icons.add_comment;
  static const IconData group = Icons.group;
  static const IconData addGroup = Icons.group_add;
  static const IconData addContact = Icons.person_add_alt_1;
  static const IconData chatsTab = Icons.chat_bubble_outline;
  static const IconData chatsTabSelected = Icons.chat_bubble;
  static const IconData updatesTab = Icons.donut_large_outlined;
  static const IconData updatesTabSelected = Icons.donut_large;

  // message ticks and call lines in the chat list
  static const IconData tickSent = Icons.done;
  static const IconData tickDelivered = Icons.done_all;
  static const IconData videoCall = Icons.videocam;
  static const IconData missedCall = Icons.videocam_off;
}