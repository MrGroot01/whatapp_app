import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'create_task_screen.dart';
import '../providers/tasks_provider.dart';
import '../task_service.dart';

// The provider is created here, inside the screen, so it stops when the
// screen closes and never shows an old account's tasks after a new login.
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasksProvider(),
      child: const _MyTasksView(),
    );
  }
}

class _MyTasksView extends StatefulWidget {
  const _MyTasksView();

  @override
  State<_MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends State<_MyTasksView> {
  static const Color _error = Color(0xFFD94B4B);

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

  // the list updates by itself when a task is saved (live from Firebase)
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
    final error = await context.read<TasksProvider>().setDone(task, done);
    if (error != null) _snack(error);
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

    if (ok != true || !mounted) return;

    final error = await context.read<TasksProvider>().delete(task);
    _snack(error ?? 'Task deleted');
  }

  // ---------- UI PIECES ----------
  Widget _chip(String label, TaskFilter value, TasksProvider tasks) {
    final selected = tasks.filter == value;
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
        onSelected: (_) => tasks.setFilter(value),
      ),
    );
  }

  Widget _buildFilters(TasksProvider tasks) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          _chip('All (${tasks.allCount})', TaskFilter.all, tasks),
          _chip('Upcoming (${tasks.upcomingCount})', TaskFilter.upcoming, tasks),
          _chip(
            'Completed (${tasks.completedCount})',
            TaskFilter.completed,
            tasks,
          ),
          _chip(
            'Assigned to me (${tasks.toMeCount})',
            TaskFilter.assignedToMe,
            tasks,
          ),
          _chip(
            'Assigned by me (${tasks.byMeCount})',
            TaskFilter.assignedByMe,
            tasks,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(TaskItem t, String me) {
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

  String _emptyText(TasksProvider tasks) {
    if (tasks.filter == TaskFilter.assignedToMe) {
      return 'Nothing is assigned to you yet.';
    }
    if (tasks.filter == TaskFilter.assignedByMe) {
      return 'You have not assigned any task yet.\nLong-press a chat message and tap Create Task.';
    }
    if (tasks.allCount == 0) {
      return 'No tasks yet.\nLong-press a chat message and tap Create Task.';
    }
    return 'No tasks in this list.';
  }

  Widget _buildBody(TasksProvider tasks) {
    if (!tasks.loggedIn) {
      return _centerText('Please log in to see your tasks.');
    }

    if (tasks.loadError) {
      return _centerText(
        'Unable to load tasks. Check your internet and the database rules.',
      );
    }

    if (tasks.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      );
    }

    final shown = tasks.shown;
    final me = tasks.me;

    return Column(
      children: [
        _buildFilters(tasks),
        Expanded(
          child: shown.isEmpty
              ? _centerText(_emptyText(tasks))
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: shown.length,
            itemBuilder: (context, index) => _buildCard(shown[index], me),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // rebuilds whenever the provider changes (new data, filter...)
    final tasks = context.watch<TasksProvider>();

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
      body: _buildBody(tasks),
    );
  }
}