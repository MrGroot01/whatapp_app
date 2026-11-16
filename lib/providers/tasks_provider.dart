import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../core/app_strings.dart';
import '../task_service.dart';

enum TaskFilter { all, upcoming, completed, assignedToMe, assignedByMe }

class TasksProvider extends ChangeNotifier {
  TasksProvider() {
    _start();
  }

  StreamSubscription<DatabaseEvent>? _sub;
  bool _disposed = false;

  bool _loggedIn = true;
  bool _loading = true; // waiting for the first answer from Firebase
  bool _loadError = false;
  TaskFilter _filter = TaskFilter.all;

  // the lists are built once per change, not on every redraw
  List<TaskItem> _all = const [];
  List<TaskItem> _upcoming = const [];
  List<TaskItem> _completed = const [];
  List<TaskItem> _toMe = const [];
  List<TaskItem> _byMe = const [];
  List<TaskItem> _shown = const [];

  // ---------- WHAT THE SCREEN READS ----------
  bool get loggedIn => _loggedIn;
  bool get loading => _loading;
  bool get loadError => _loadError;
  TaskFilter get filter => _filter;

  // my account id (the cards need it to know "to me" / "by me")
  String get me => TaskService.myUid ?? '';

  // the list for the chip that is selected: open tasks first, then completed
  List<TaskItem> get shown => _shown;

  int get allCount => _all.length;
  int get upcomingCount => _upcoming.length;
  int get completedCount => _completed.length;
  int get toMeCount => _toMe.length;
  int get byMeCount => _byMe.length;

  // ---------- LIVE TASKS ----------
  void _start() {
    final stream = TaskService.watch();
    if (stream == null) {
      _loggedIn = false;
      _loading = false;
      return;
    }

    _sub = stream.listen(
          (event) {
        _all = TaskService.parse(event.snapshot.value);
        _loading = false;
        _loadError = false;
        _recompute();
        _safeNotify();
      },
      onError: (Object e) {
        debugPrint('Task list error: $e');
        _loading = false;
        _loadError = true;
        _safeNotify();
      },
    );
  }

  // build the five lists, then pick and sort the one that is shown
  void _recompute() {
    final id = me;

    _upcoming = _all.where((t) => !t.done).toList();
    _completed = _all.where((t) => t.done).toList();
    _toMe = _all.where((t) => t.isAssignedToMe(id)).toList();
    _byMe = _all.where((t) => t.isAssignedByMe(id)).toList();

    final List<TaskItem> base;
    switch (_filter) {
      case TaskFilter.upcoming:
        base = _upcoming;
        break;
      case TaskFilter.completed:
        base = _completed;
        break;
      case TaskFilter.assignedToMe:
        base = _toMe;
        break;
      case TaskFilter.assignedByMe:
        base = _byMe;
        break;
      case TaskFilter.all:
        base = _all;
        break;
    }

    _shown = List<TaskItem>.of(base)
      ..sort((a, b) {
        // open tasks first (soonest due first), completed last
        if (a.done != b.done) return a.done ? 1 : -1;
        return a.done ? b.due.compareTo(a.due) : a.due.compareTo(b.due);
      });
  }

  void setFilter(TaskFilter value) {
    if (_filter == value) return;
    _filter = value;
    _recompute();
    _safeNotify();
  }

  // ---------- ACTIONS ----------
  // tick / untick a task
  Future<String?> setDone(TaskItem task, bool done) async {
    try {
      await TaskService.setDone(task, done);
      return null;
    } catch (e) {
      debugPrint('Update task failed: $e');
      return AppStrings.couldNotUpdateTask;
    }
  }

  // delete a task (a task I gave to someone is removed for both)
  Future<String?> delete(TaskItem task) async {
    try {
      await TaskService.delete(task);
      return null;
    } catch (e) {
      debugPrint('Delete task failed: $e');
      return AppStrings.couldNotDeleteTask;
    }
  }

  // ---------- HELPERS ----------
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}