import 'package:flutter/material.dart';

import '../models/sub_task.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../utils/date_label.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titleC;
  late TextEditingController _descC;
  late TextEditingController _categoryC;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _date;
  bool _reminder = false;
  final List<SubTask> _subTasks = [];
  final TextEditingController _subTaskC = TextEditingController();

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleC = TextEditingController(text: t?.title ?? '');
    _descC = TextEditingController(text: t?.description ?? '');
    _categoryC = TextEditingController(text: t?.category ?? '');
    _priority = t?.priority ?? TaskPriority.medium;
    _date = t?.deadline;
    _reminder = t?.reminder ?? false;
    _subTasks.addAll(t?.subTasks ?? []);
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _categoryC.dispose();
    _subTaskC.dispose();
    super.dispose();
  }

  String get _deadlineLabel =>
      _date == null ? 'Pilih tanggal' : formatDate(_date!);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (d != null && mounted) setState(() => _date = d);
  }

  void _clearDate() {
    if (_date == null) return;
    setState(() {
      _date = null;
      _reminder = false;
    });
  }

  void _addSubTask() {
    final text = _subTaskC.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subTasks.add(SubTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: text,
      ));
      _subTaskC.clear();
    });
  }

  void _removeSubTask(int index) {
    setState(() => _subTasks.removeAt(index));
  }

  void _toggleSubTask(int index) {
    setState(() {
      _subTasks[index] = _subTasks[index].copyWith(
        isDone: !_subTasks[index].isDone,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleC.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas wajib diisi')),
      );
      return;
    }

    if (_reminder) {
      final granted = await NotificationService.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin notifikasi diperlukan untuk reminder')),
        );
        setState(() => _reminder = false);
      }
    }

    final id = widget.task?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final task = Task(
      id: id,
      title: title,
      description: _descC.text.trim(),
      deadline: _date,
      priority: _priority,
      category: Task.normalizeCategory(_categoryC.text),
      isDone: widget.task?.isDone ?? false,
      reminder: _reminder,
      subTasks: _subTasks,
    );

    if (_reminder && _date != null) {
      await NotificationService.scheduleReminder(task);
    } else {
      await NotificationService.cancelReminder(id);
    }

    if (!mounted) return;
    Navigator.pop(context, task);
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Judul'),
          TextField(
              controller: _titleC,
              textInputAction: TextInputAction.next,
              decoration: _input('cth: Kerjakan laporan metopen')),
          const SizedBox(height: 14),
          _label('Deskripsi'),
          TextField(
              controller: _descC,
              maxLines: 3,
              decoration: _input('Detail tugas (opsional)')),
          const SizedBox(height: 14),
          _label('Sub-tugas (opsional)'),
          if (_subTasks.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  for (int i = 0; i < _subTasks.length; i++)
                    CheckboxListTile(
                      value: _subTasks[i].isDone,
                      onChanged: (_) => _toggleSubTask(i),
                      title: Text(_subTasks[i].title),
                      secondary: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeSubTask(i),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subTaskC,
                  decoration: _input('Tambah checklist'),
                  onSubmitted: (_) => _addSubTask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addSubTask,
                tooltip: 'Tambah',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _label('Deadline'),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: _input(''),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: Color(0xFF8A8A9E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_deadlineLabel,
                        style: const TextStyle(fontSize: 14)),
                  ),
                  if (_date != null)
                    GestureDetector(
                      onTap: _clearDate,
                      child: const Icon(Icons.close,
                          size: 18, color: Color(0xFF8A8A9E)),
                    ),
                ],
              ),
            ),
          ),
          if (_date != null) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
              title: const Text('Ingatkan saya'),
              subtitle: Text(
                _reminder ? 'Notifikasi H-1 & hari-H pukul 08.00' : 'Tidak ada reminder',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9E)),
              ),
              activeThumbColor: const Color(0xFF6C63FF),
              contentPadding: EdgeInsets.zero,
            ),
          ],
          const SizedBox(height: 14),
          _label('Prioritas'),
          Wrap(
            spacing: 8,
            children: [
              _priorityChip(TaskPriority.high, const Color(0xFFFF6B6B)),
              _priorityChip(TaskPriority.medium, const Color(0xFFFFA726)),
              _priorityChip(TaskPriority.low, const Color(0xFF4FC3F7)),
            ],
          ),
          const SizedBox(height: 14),
          _label('Kategori'),
          TextField(
              controller: _categoryC,
              textCapitalization: TextCapitalization.words,
              decoration: _input('cth: Kuliah, Belanja')),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _save,
              child: Text(
                isEdit ? 'Simpan Perubahan' : 'Tambah Tugas',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(TaskPriority value, Color color) {
    final selected = _priority == value;
    return ChoiceChip(
      label: Text(value.label),
      selected: selected,
      selectedColor: color.withValues(alpha: 0.25),
      avatar: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      onSelected: (_) => setState(() => _priority = value),
    );
  }
}
