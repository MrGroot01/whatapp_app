import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';

const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatTaskDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

String formatTaskTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour >= 12 ? 'PM' : 'AM'}';
}

// ---------- reminder choices ----------
class ReminderOption {
  final String label;
  final int minutes; // -1 = no reminder
  const ReminderOption(this.label, this.minutes);
}

const List<ReminderOption> reminderOptions = [
  ReminderOption('No reminder', -1),
  ReminderOption('At due time', 0),
  ReminderOption('10 minutes before', 10),
  ReminderOption('1 hour before', 60),
  ReminderOption('2 hours before', 120),
  ReminderOption('1 day before', 1440),
];

String reminderLabel(int minutes) {
  for (final o in reminderOptions) {
    if (o.minutes == minutes) return o.label;
  }
  return 'No reminder';
}

// ---------- one saved contact (for the "Assign to" list) ----------
class TaskContact {
  final String uid; // the contact's account id ('' = me)
  final String name;
  const TaskContact({required this.uid, required this.name});
}

// ---------- one task ----------
class TaskItem {
  final String id; // the Firebase key
  final String title;
  final String description;
  final DateTime due;
  final int reminderMinutes; // -1 = no reminder
  final bool done;
  final String fromName; // who wrote the chat message
  final int notificationId;

  // assigning
  final String createdBy; // account id of the person who made the task
  final String createdByName;
  final String assignedTo; // account id of the person who must do it ('' = personal)
  final String assignedToName;
  final bool seen; // the assignee's phone has already announced it

  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.due,
    required this.reminderMinutes,
    required this.done,
    required this.fromName,
    required this.notificationId,
    this.createdBy = '',
    this.createdByName = '',
    this.assignedTo = '',
    this.assignedToName = '',
    this.seen = false,
  });

  // somebody else gave me this task
  bool isAssignedToMe(String me) =>
      me.isNotEmpty && assignedTo == me && createdBy != me;

  // I gave this task to somebody else
  bool isAssignedByMe(String me) =>
      me.isNotEmpty &&
          createdBy == me &&
          assignedTo.isNotEmpty &&
          assignedTo != me;

  factory TaskItem.fromMap(String id, Map<dynamic, dynamic> m) {
    final due = m['dueMs'];
    final rem = m['reminderMinutes'];
    final nid = m['notificationId'];
    return TaskItem(
      id: id,
      title: (m['title'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      due: DateTime.fromMillisecondsSinceEpoch(
        due is num ? due.toInt() : DateTime.now().millisecondsSinceEpoch,
      ),
      reminderMinutes: rem is num ? rem.toInt() : -1,
      done: m['done'] == true,
      fromName: (m['fromName'] ?? '').toString(),
      notificationId: nid is num ? nid.toInt() : 0,
      createdBy: (m['createdBy'] ?? '').toString(),
      createdByName: (m['createdByName'] ?? '').toString(),
      assignedTo: (m['assignedTo'] ?? '').toString(),
      assignedToName: (m['assignedToName'] ?? '').toString(),
      seen: m['seen'] == true,
    );
  }
}

// ---------- Firebase: /users/{uid}/tasks/{taskId} ----------
// An assigned task has TWO copies with the same key:
//   1) in the creator's list   (shown as "Assigned by me")
//   2) in the assignee's list  (shown as "Assigned to me")
class TaskService {
  TaskService._();

  static const Duration _timeout = Duration(seconds: 10);

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  static String? get myUid => _uid;

  // my name, shown to the person I assign a task to
  static String get _myName {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final email = user?.email ?? '';
    return email.contains('@') ? email.split('@').first : 'Someone';
  }

  static DatabaseReference? get _tasksRef {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseDatabase.instance.ref('users/$uid/tasks');
  }

  static Stream<DatabaseEvent>? watch() => _tasksRef?.onValue;

  static List<TaskItem> parse(Object? value) {
    final list = <TaskItem>[];
    if (value is Map) {
      value.forEach((key, data) {
        if (data is Map) list.add(TaskItem.fromMap(key.toString(), data));
      });
    }
    return list;
  }

  // my saved contacts (the contact's key in Firebase is their account id)
  static Future<List<TaskContact>> loadContacts() async {
    final me = _uid;
    final list = <TaskContact>[];
    if (me == null) return list;

    try {
      final snap = await FirebaseDatabase.instance
          .ref('users/$me/contacts')
          .get()
          .timeout(_timeout);
      final value = snap.value;
      if (value is Map) {
        value.forEach((key, data) {
          if (data is Map && key.toString() != me) {
            list.add(
              TaskContact(
                uid: key.toString(),
                name: (data['name'] ?? 'Contact').toString(),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Could not load contacts: $e');
    }

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  // returns true when everything is fine about the reminder
  static Future<bool> create({
    required String title,
    required String description,
    required DateTime due,
    required int reminderMinutes,
    String fromName = '',
    String chatId = '',
    String messageId = '',
    String assignedToUid = '',
    String assignedToName = '',
  }) async {
    final me = _uid;
    final root = _tasksRef;
    if (me == null || root == null) throw StateError('Not logged in');

    final ref = root.push();
    final taskId = ref.key!;
    final notificationId = Random().nextInt(2000000000) + 1;

    final data = <String, Object?>{
      'title': title,
      'description': description,
      'dueMs': due.millisecondsSinceEpoch,
      'reminderMinutes': reminderMinutes,
      'done': false,
      'fromName': fromName,
      'notificationId': notificationId,
      'createdAt': ServerValue.timestamp,
    };
    if (chatId.isNotEmpty) data['chatId'] = chatId;
    if (messageId.isNotEmpty) data['messageId'] = messageId;

    final toSomeoneElse = assignedToUid.isNotEmpty && assignedToUid != me;

    // a personal task: only my own copy
    if (!toSomeoneElse) {
      await ref.set(data).timeout(_timeout);

      return _scheduleReminder(
        notificationId: notificationId,
        title: title,
        due: due,
        reminderMinutes: reminderMinutes,
      );
    }

    // an assigned task: my copy + their copy, written together
    data['createdBy'] = me;
    data['createdByName'] = _myName;
    data['assignedTo'] = assignedToUid;
    data['assignedToName'] = assignedToName;

    final theirCopy = Map<String, Object?>.from(data)..['seen'] = false;

    await FirebaseDatabase.instance.ref().update({
      'users/$me/tasks/$taskId': data,
      'users/$assignedToUid/tasks/$taskId': theirCopy,
    }).timeout(_timeout);

    // the reminder is set on THEIR phone, not mine
    return true;
  }

  static Future<bool> update(
      TaskItem old, {
        required String title,
        required String description,
        required DateTime due,
        required int reminderMinutes,
      }) async {
    final me = _uid;
    final root = _tasksRef;
    if (me == null || root == null) throw StateError('Not logged in');

    final fields = <String, Object?>{
      'title': title,
      'description': description,
      'dueMs': due.millisecondsSinceEpoch,
      'reminderMinutes': reminderMinutes,
    };

    // a task I gave to someone: change both copies
    if (old.isAssignedByMe(me)) {
      final updates = <String, Object?>{};
      fields.forEach((key, value) {
        updates['users/$me/tasks/${old.id}/$key'] = value;
        updates['users/${old.assignedTo}/tasks/${old.id}/$key'] = value;
      });
      await FirebaseDatabase.instance.ref().update(updates).timeout(_timeout);
      return true; // their phone sets the new reminder by itself
    }

    await root.child(old.id).update(fields).timeout(_timeout);

    // remove the old reminder, then set the new one
    await NotificationService.cancel(old.notificationId);
    if (old.done) return false;

    return _scheduleReminder(
      notificationId: old.notificationId,
      title: title,
      due: due,
      reminderMinutes: reminderMinutes,
    );
  }

  static Future<void> setDone(TaskItem task, bool done) async {
    final me = _uid;
    final root = _tasksRef;
    if (me == null || root == null) throw StateError('Not logged in');

    if (task.isAssignedToMe(me)) {
      // tell the person who gave me the task, in the same step
      await FirebaseDatabase.instance.ref().update({
        'users/$me/tasks/${task.id}/done': done,
        'users/${task.createdBy}/tasks/${task.id}/done': done,
      }).timeout(_timeout);
    } else {
      await root.child(task.id).update({'done': done}).timeout(_timeout);
    }

    if (done) {
      await NotificationService.cancel(task.notificationId);
    } else {
      await _scheduleReminder(
        notificationId: task.notificationId,
        title: task.title,
        due: task.due,
        reminderMinutes: task.reminderMinutes,
      );
    }
  }

  static Future<void> delete(TaskItem task) async {
    final me = _uid;
    final root = _tasksRef;
    if (me == null || root == null) throw StateError('Not logged in');

    // a task I gave to someone: remove both copies
    if (task.isAssignedByMe(me)) {
      await FirebaseDatabase.instance.ref().update({
        'users/$me/tasks/${task.id}': null,
        'users/${task.assignedTo}/tasks/${task.id}': null,
      }).timeout(_timeout);
      return;
    }

    await root.child(task.id).remove().timeout(_timeout);
    await NotificationService.cancel(task.notificationId);
  }

  static Future<bool> _scheduleReminder({
    required int notificationId,
    required String title,
    required DateTime due,
    required int reminderMinutes,
  }) {
    if (reminderMinutes < 0) return Future.value(false);

    return NotificationService.schedule(
      id: notificationId,
      title: title,
      body: reminderMinutes == 0
          ? 'Due now'
          : 'Due ${formatTaskDate(due)}, ${formatTaskTime(due)}',
      when: due.subtract(Duration(minutes: reminderMinutes)),
    );
  }

  // ---------- TASKS GIVEN TO ME: announce + set the reminder ----------
  // Started when the home screen opens. It watches my task list, and when a
  // new task from somebody else appears it shows "New task from ..." and sets
  // the reminder on THIS phone.
  static StreamSubscription<DatabaseEvent>? _sub;
  static Future<void> _chain = Future.value();
  static final Set<String> _announced = {};
  static final Map<String, String> _signatures = {};
  static final Map<String, int> _reminderIds = {};

  static void startListening() {
    if (_sub != null) return;
    final root = _tasksRef;
    if (root == null) return;

    _sub = root.onValue.listen(
          (event) {
        // handle one change at a time, in order
        _chain = _chain.then((_) => _handleTasks(event.snapshot.value));
      },
      onError: (Object e) => debugPrint('Task listener error: $e'),
    );
  }

  static void stopListening() {
    _sub?.cancel();
    _sub = null;

    // remove the reminders of tasks given by others from this phone
    for (final id in _reminderIds.values) {
      NotificationService.cancel(id);
    }
    _announced.clear();
    _signatures.clear();
    _reminderIds.clear();
  }

  static int _announceId(int id) => id >= 2000000000 ? 1 : id + 1;

  static Future<void> _handleTasks(Object? value) async {
    try {
      final me = _uid;
      if (me == null) return;

      final mine = parse(value).where((t) => t.isAssignedToMe(me)).toList();
      final ids = mine.map((t) => t.id).toSet();

      // the creator deleted a task: remove its reminder here
      for (final id in _reminderIds.keys.toList()) {
        if (!ids.contains(id)) {
          await NotificationService.cancel(_reminderIds[id]!);
          _reminderIds.remove(id);
          _signatures.remove(id);
        }
      }

      for (final t in mine) {
        _reminderIds[t.id] = t.notificationId;

        // a brand new task: tell me right away
        if (!t.seen && _announced.add(t.id)) {
          final who = t.createdByName.isEmpty ? 'a contact' : t.createdByName;
          await NotificationService.schedule(
            id: _announceId(t.notificationId),
            title: 'New task from $who',
            body: t.title,
            when: DateTime.now().add(const Duration(seconds: 2)),
          );
          await _tasksRef?.child(t.id).update({'seen': true});
        }

        // set (or reset) the reminder only when something changed
        final signature =
            '${t.due.millisecondsSinceEpoch}|${t.reminderMinutes}|${t.done}';
        if (_signatures[t.id] != signature) {
          _signatures[t.id] = signature;
          await NotificationService.cancel(t.notificationId);
          if (!t.done) {
            await _scheduleReminder(
              notificationId: t.notificationId,
              title: t.title,
              due: t.due,
              reminderMinutes: t.reminderMinutes,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Assigned tasks sync failed: $e');
    }
  }
}