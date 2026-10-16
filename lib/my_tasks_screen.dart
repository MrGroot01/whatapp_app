import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'create_task_screen.dart';
import 'task_service.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  static const Color _error = Color(0xFFD94B4B);

  // created once, so the list does not re-subscribe on every rebuild
  late final Stream<DatabaseEvent>? _stream = TaskService.watch();

  // 0 = All, 1 = Upcoming, 2 = Completed, 3 = Assigned to me, 4 = Assigned by me
  int _filter = 0;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _newTask() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
    );
  }

  Future<void> _edit(TaskItem task) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateTaskScreen(editing: task)),
    );
  }

  Future<void> _toggle(TaskItem task, bool done) async {
    try {
      await TaskService.setDone(task, done);
    } catch (e) {
      debugPrint('Update task failed: $e');
      _snack('Could not update the task. Check your internet connection.');
    }
  }

  Future<void> _confirmDelete(TaskItem task, {required bool assigned}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete task?',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          assigned
              ? 'This task will be removed for you and for ${task.assignedToName}.'
              : 'This task and its reminder will be removed.',
          style: const TextStyle(color: AppColors.textSoft, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSoft, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: _error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await TaskService.delete(task);
      _snack('Task deleted');
    } catch (e) {
      debugPrint('Delete task failed: $e');
      _snack('Could not delete the task. Check your internet connection.');
    }
  }

  // ---------- UI PIECES ----------
  Widget _chip(String label, int index) {
    final selected = _filter == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.emerald,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.emerald),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.emerald,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => setState(() => _filter = index),
      ),
    );
  }

  Widget _buildFilters(
      int all,
      int upcoming,
      int completed,
      int toMe,
      int byMe,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          _chip('All ($all)', 0),
          _chip('Upcoming ($upcoming)', 1),
          _chip('Completed ($completed)', 2),
          _chip('Assigned to me ($toMe)', 3),
          _chip('Assigned by me ($byMe)', 4),
        ],
      ),
    );
  }

  Widget _buildCard(TaskItem t) {
    final me = TaskService.myUid ?? '';
    final toMe = t.isAssignedToMe(me); // somebody gave it to me
    final byMe = t.isAssignedByMe(me); // I gave it to somebody

    final overdue = !t.done && t.due.isBefore(DateTime.now());
    final dueColor = overdue ? _error : AppColors.textSoft;

    // the line with the bell
    final String statusText;
    final IconData statusIcon;
    if (byMe) {
      statusText = t.done
          ? 'Done by ${t.assignedToName}'
          : 'Waiting for ${t.assignedToName}';
      statusIcon = t.done ? Icons.check_circle_outline : Icons.hourglass_empty;
    } else {
      statusText = t.done
          ? 'Completed'
          : (t.reminderMinutes < 0
          ? 'No reminder'
          : 'Reminder: ${reminderLabel(t.reminderMinutes)}');
      statusIcon = Icons.notifications_none;
    }

    // who gave / who got the task
    String? peopleLine;
    if (toMe) {
      peopleLine = 'Assigned by ${t.createdByName}';
    } else if (byMe) {
      peopleLine = 'Assigned to ${t.assignedToName}';
    } else if (t.fromName.isNotEmpty) {
      peopleLine = 'From: ${t.fromName}';
    }

    // the checkbox (the person who made the task cannot tick it for the other)
    final Widget leading = byMe
        ? Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Icon(
        t.done ? Icons.check_circle : Icons.hourglass_top_rounded,
        color: t.done ? AppColors.emerald : AppColors.textSoft,
      ),
    )
        : Checkbox(
      value: t.done,
      activeColor: AppColors.emerald,
      onChanged: (v) => _toggle(t, v ?? false),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // a task given to me cannot be edited
        onTap: toMe ? null : () => _edit(t),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: TextStyle(
                          color: t.done
                              ? AppColors.textSoft
                              : AppColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          decoration:
                          t.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (peopleLine != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          peopleLine,
                          style: TextStyle(
                            color: (toMe || byMe)
                                ? AppColors.emerald
                                : AppColors.textSoft,
                            fontSize: 14,
                            fontWeight: (toMe || byMe)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event, size: 17, color: dueColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${formatTaskDate(t.due)}  ${formatTaskTime(t.due)}',
                              style: TextStyle(color: dueColor, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: 17,
                            color: (byMe && t.done)
                                ? AppColors.emerald
                                : AppColors.textSoft,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: (byMe && t.done)
                                    ? AppColors.emerald
                                    : AppColors.textSoft,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (toMe)
                const SizedBox(width: 12)
              else
                PopupMenuButton<String>(
                  color: Colors.white,
                  icon: const Icon(Icons.more_vert, color: AppColors.textSoft),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') _edit(t);
                    if (value == 'delete') _confirmDelete(t, assigned: byMe);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: AppColors.emerald),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: _error),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerText(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 17,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  String _emptyText(int total) {
    if (_filter == 3) return 'Nothing is assigned to you yet.';
    if (_filter == 4) {
      return 'You have not assigned any task yet.\nLong-press a chat message and tap Create Task.';
    }
    if (total == 0) {
      return 'No tasks yet.\nLong-press a chat message and tap Create Task.';
    }
    return 'No tasks in this list.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'New task',
            icon: const Icon(Icons.add),
            onPressed: _newTask,
          ),
        ],
      ),
      body: _stream == null
          ? _centerText('Please log in to see your tasks.')
          : StreamBuilder<DatabaseEvent>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _centerText(
              'Unable to load tasks. Check your internet and the database rules.',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.emerald,
              ),
            );
          }

          final me = TaskService.myUid ?? '';
          final all = TaskService.parse(snapshot.data?.snapshot.value);
          final upcoming = all.where((t) => !t.done).toList();
          final completed = all.where((t) => t.done).toList();
          final toMe = all.where((t) => t.isAssignedToMe(me)).toList();
          final byMe = all.where((t) => t.isAssignedByMe(me)).toList();

          final List<TaskItem> base;
          switch (_filter) {
            case 1:
              base = upcoming;
              break;
            case 2:
              base = completed;
              break;
            case 3:
              base = toMe;
              break;
            case 4:
              base = byMe;
              break;
            default:
              base = all;
          }

          final shown = List<TaskItem>.of(base)
            ..sort((a, b) {
              // open tasks first (soonest due first), completed last
              if (a.done != b.done) return a.done ? 1 : -1;
              return a.done
                  ? b.due.compareTo(a.due)
                  : a.due.compareTo(b.due);
            });

          return Column(
            children: [
              _buildFilters(
                all.length,
                upcoming.length,
                completed.length,
                toMe.length,
                byMe.length,
              ),
              Expanded(
                child: shown.isEmpty
                    ? _centerText(_emptyText(all.length))
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: shown.length,
                  itemBuilder: (context, index) =>
                      _buildCard(shown[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}