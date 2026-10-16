import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'task_service.dart';

// Used for two things:
//  - a NEW task (from a chat message, or empty)
//  - EDITING a task (pass `editing`)
class CreateTaskScreen extends StatefulWidget {
  final TaskItem? editing;
  final String initialTitle;
  final String sourceText; // the chat message
  final String fromName;
  final DateTime? sourceTime;
  final String chatId;
  final String messageId;

  // the person in the chat (can get this task)
  final String assigneeUid;
  final String assigneeName;
  // true = start with the chat contact selected (the message was mine)
  final bool assignByDefault;

  const CreateTaskScreen({
    super.key,
    this.editing,
    this.initialTitle = '',
    this.sourceText = '',
    this.fromName = '',
    this.sourceTime,
    this.chatId = '',
    this.messageId = '',
    this.assigneeUid = '',
    this.assigneeName = '',
    this.assignByDefault = false,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  static const Color _error = Color(0xFFD94B4B);
  static const Color _line = Color(0xFFE3DED2);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _due;
  late int _reminder;
  bool _saving = false;

  // who the task is for ('' = me)
  String _assignUid = '';
  String _assignName = '';

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.editing;
    final me = TaskService.myUid ?? '';

    _titleController =
        TextEditingController(text: t?.title ?? widget.initialTitle);

    // the description is the full message, unless it is the same as the title
    final desc = t?.description ??
        (widget.sourceText == widget.initialTitle ? '' : widget.sourceText);
    _descController = TextEditingController(text: desc);

    // default: tomorrow 9:00 AM, reminder 1 hour before
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _due = t?.due ??
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
    _reminder = t?.reminderMinutes ?? 60;

    // who is it for?
    if (t != null) {
      if (t.isAssignedByMe(me)) {
        _assignUid = t.assignedTo;
        _assignName = t.assignedToName;
      }
    } else if (widget.assignByDefault &&
        widget.assigneeUid.isNotEmpty &&
        widget.assigneeUid != me) {
      _assignUid = widget.assigneeUid;
      _assignName = widget.assigneeName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _assigned => _assignUid.isNotEmpty;

  // ---------- PICKERS ----------
  Future<void> _pickAssignee() async {
    FocusScope.of(context).unfocus();
    final contactsFuture = TaskService.loadContacts();

    final picked = await showModalBottomSheet<TaskContact>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Text(
                  'Assign to',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.emerald,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text(
                  'Me (personal task)',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: _assignUid.isEmpty
                    ? const Icon(Icons.check, color: AppColors.emerald)
                    : null,
                onTap: () => Navigator.pop(
                  sheetContext,
                  const TaskContact(uid: '', name: ''),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: FutureBuilder<List<TaskContact>>(
                  future: contactsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.emerald,
                          ),
                        ),
                      );
                    }

                    final list = snapshot.data ?? const <TaskContact>[];
                    if (list.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No saved contacts yet. Add a contact first.',
                          style: TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.gold,
                            child: Text(
                              c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: c.uid == _assignUid
                              ? const Icon(Icons.check, color: AppColors.emerald)
                              : null,
                          onTap: () => Navigator.pop(sheetContext, c),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _assignUid = picked.uid;
      _assignName = picked.name;
    });
  }

  Future<void> _pickDue() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _due.isBefore(now) ? now : _due,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due),
    );
    if (time == null || !mounted) return;

    setState(() {
      _due = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickReminder() async {
    FocusScope.of(context).unfocus();

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            for (final o in reminderOptions)
              ListTile(
                leading: Icon(
                  o.minutes < 0
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active_outlined,
                  color: AppColors.emerald,
                ),
                title: Text(o.label, style: const TextStyle(fontSize: 16)),
                trailing: o.minutes == _reminder
                    ? const Icon(Icons.check, color: AppColors.emerald)
                    : null,
                onTap: () => Navigator.pop(sheetContext, o.minutes),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (picked != null && mounted) setState(() => _reminder = picked);
  }

  // ---------- SAVE ----------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    try {
      final bool reminderSet;
      if (_isEditing) {
        reminderSet = await TaskService.update(
          widget.editing!,
          title: title,
          description: description,
          due: _due,
          reminderMinutes: _reminder,
        );
      } else {
        reminderSet = await TaskService.create(
          title: title,
          description: description,
          due: _due,
          reminderMinutes: _reminder,
          fromName: widget.fromName,
          chatId: widget.chatId,
          messageId: widget.messageId,
          assignedToUid: _assignUid,
          assignedToName: _assignName,
        );
      }

      if (!mounted) return;
      setState(() => _saving = false);

      await _showSuccess(reminderSet);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Save task failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save the task. Check your internet and the database rules.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSuccess(bool reminderSet) {
    final missedReminder = !_assigned && _reminder >= 0 && !reminderSet;

    final message = _assigned
        ? 'Assigned to $_assignName. It will appear in their My Tasks.'
        : 'Your task has been saved successfully.';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F1ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.emerald,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing
                    ? 'Task Updated!'
                    : (_assigned ? 'Task Assigned!' : 'Task Created!'),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 15,
                ),
              ),
              if (missedReminder) ...[
                const SizedBox(height: 8),
                const Text(
                  'No reminder was scheduled: the reminder time has already passed, or notifications are off.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI PIECES ----------
  InputDecoration _fieldDecoration(String hint) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.3),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSoft),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: border(_line),
      focusedBorder: border(AppColors.emerald),
      errorBorder: border(_error),
      focusedErrorBorder: border(_error),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // onTap == null -> the row is shown but cannot be changed
  Widget _pickerTile(IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line, width: 1.3),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }

  // the chat message this task was made from
  Widget _buildSourceBox() {
    if (widget.sourceText.isEmpty) return const SizedBox.shrink();

    final from = widget.fromName.isEmpty ? '' : 'From: ${widget.fromName}  ';
    final when =
    widget.sourceTime == null ? '' : formatTaskTime(widget.sourceTime!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F0EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            widget.sourceText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$from$when',
          style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
        ),
      ],
    );
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
        title: Text(
          _isEditing ? 'Edit Task' : 'Create Task',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSourceBox(),
                _label('Assign to'),
                _pickerTile(
                  _assigned ? Icons.person_add_alt_1 : Icons.person_outline,
                  _assigned ? _assignName : 'Me (personal task)',
                  // an assigned task keeps its person once it is saved
                  _isEditing ? null : _pickAssignee,
                ),
                _label('Title'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                  cursorColor: AppColors.emerald,
                  decoration: _fieldDecoration('Task title'),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Please enter a title';
                    if (v.length > 200) return 'Title is too long';
                    return null;
                  },
                ),
                _label('Description (optional)'),
                TextFormField(
                  controller: _descController,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                  ),
                  cursorColor: AppColors.emerald,
                  decoration: _fieldDecoration('Add more details'),
                  validator: (value) {
                    if ((value ?? '').length > 2000) {
                      return 'Description is too long';
                    }
                    return null;
                  },
                ),
                _label('Due Date & Time'),
                _pickerTile(
                  Icons.calendar_today_outlined,
                  '${formatTaskDate(_due)}   ${formatTaskTime(_due)}',
                  _pickDue,
                ),
                _label(_assigned ? 'Reminder for $_assignName' : 'Reminder'),
                _pickerTile(
                  Icons.notifications_none,
                  reminderLabel(_reminder),
                  _pickReminder,
                ),
                if (_assigned)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '$_assignName gets this reminder on their phone.',
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _isEditing
                          ? 'Save Changes'
                          : (_assigned ? 'Assign Task' : 'Save Task'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}