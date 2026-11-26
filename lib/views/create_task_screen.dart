import 'package:flutter/material.dart';

import '../core/app_icons.dart';
import '../core/app_localization.dart';
import '../core/app_theme.dart';
import '../services/task_service.dart';

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
    final l = context.l10n;
    final p = context.palette;
    final contactsFuture = TaskService.loadContacts();

    final picked = await showModalBottomSheet<TaskContact>(
      context: context,
      backgroundColor: p.card,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Text(
                  l.assignTo,
                  style: TextStyle(
                    color: p.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.emerald,
                  child: Icon(AppIcons.attachContact, color: Colors.white),
                ),
                title: Text(
                  l.mePersonalTask,
                  style: TextStyle(fontSize: 16, color: p.textDark),
                ),
                trailing: _assignUid.isEmpty
                    ? Icon(AppIcons.confirm, color: p.accent)
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
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: p.accent,
                          ),
                        ),
                      );
                    }

                    final list = snapshot.data ?? const <TaskContact>[];
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l.noSavedContactsAddFirst,
                          style: TextStyle(
                            color: p.textSoft,
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
                            style: TextStyle(fontSize: 16, color: p.textDark),
                          ),
                          trailing: c.uid == _assignUid
                              ? Icon(
                            AppIcons.confirm,
                            color: p.accent,
                          )
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
    final p = context.palette;

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: p.card,
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
                  o.minutes < 0 ? AppIcons.reminderOff : AppIcons.reminderOn,
                  color: p.accent,
                ),
                title: Text(
                  o.label,
                  style: TextStyle(fontSize: 16, color: p.textDark),
                ),
                trailing: o.minutes == _reminder
                    ? Icon(AppIcons.confirm, color: p.accent)
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

    final l = context.l10n; // read before any "await"

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
        SnackBar(
          content: Text(l.couldNotSaveTask),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSuccess(bool reminderSet) {
    final l = context.l10n;
    final p = context.palette;
    final missedReminder = !_assigned && _reminder >= 0 && !reminderSet;

    final message = _assigned
        ? l.assignedSuccess(_assignName)
        : l.taskSavedSuccess;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: p.softGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.confirm,
                  color: p.accent,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing
                    ? l.taskUpdated
                    : (_assigned ? l.taskAssigned : l.taskCreated),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.textSoft,
                  fontSize: 15,
                ),
              ),
              if (missedReminder) ...[
                const SizedBox(height: 8),
                Text(
                  l.noReminderScheduled,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
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
                  child: Text(
                    l.ok,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
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
    final p = context.palette;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.3),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: p.textSoft),
      filled: true,
      fillColor: p.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: border(p.border),
      focusedBorder: border(p.accent),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.palette.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // onTap == null -> the row is shown but cannot be changed
  Widget _pickerTile(IconData icon, String text, VoidCallback? onTap) {
    final p = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.border, width: 1.3),
        ),
        child: Row(
          children: [
            Icon(icon, color: p.textSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: p.textDark,
                  fontSize: 16,
                ),
              ),
            ),
            if (onTap != null)
              Icon(AppIcons.chevronRight, color: p.textSoft),
          ],
        ),
      ),
    );
  }

  // the chat message this task was made from
  Widget _buildSourceBox() {
    if (widget.sourceText.isEmpty) return const SizedBox.shrink();

    final l = context.l10n;
    final p = context.palette;
    final from = widget.fromName.isEmpty ? '' : '${l.fromLine(widget.fromName)}  ';
    final when =
    widget.sourceTime == null ? '' : formatTaskTime(widget.sourceTime!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.taskSourceBox,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            widget.sourceText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.textDark,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$from$when',
          style: TextStyle(color: p.textSoft, fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _isEditing ? l.editTask : l.createTask,
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
                _label(l.assignTo),
                _pickerTile(
                  _assigned ? AppIcons.addContact : AppIcons.person,
                  _assigned ? _assignName : l.mePersonalTask,
                  // an assigned task keeps its person once it is saved
                  _isEditing ? null : _pickAssignee,
                ),
                _label(l.titleLabel),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: p.textDark,
                    fontSize: 16,
                  ),
                  cursorColor: p.accent,
                  decoration: _fieldDecoration(l.taskTitleHint),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return context.l10n.enterTitle;
                    if (v.length > 200) return context.l10n.titleTooLong;
                    return null;
                  },
                ),
                _label(l.descriptionOptional),
                TextFormField(
                  controller: _descController,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: p.textDark,
                    fontSize: 16,
                  ),
                  cursorColor: p.accent,
                  decoration: _fieldDecoration(l.addMoreDetails),
                  validator: (value) {
                    if ((value ?? '').length > 2000) {
                      return context.l10n.descTooLong;
                    }
                    return null;
                  },
                ),
                _label(l.dueDateTime),
                _pickerTile(
                  AppIcons.calendar,
                  '${formatTaskDate(_due)}   ${formatTaskTime(_due)}',
                  _pickDue,
                ),
                _label(
                  _assigned ? l.reminderFor(_assignName) : l.reminderLabelText,
                ),
                _pickerTile(
                  AppIcons.reminder,
                  reminderLabel(_reminder),
                  _pickReminder,
                ),
                if (_assigned)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l.reminderGoesToThem(_assignName),
                      style: TextStyle(
                        color: p.textSoft,
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
                          ? l.saveChanges
                          : (_assigned ? l.assignTask : l.saveTask),
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