import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../services/priority_service.dart';
import '../../utils/constants.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;
  const AddTaskScreen({super.key, this.existingTask});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  int _difficulty = 3;
  int _importance = 3;
  TaskCategory _category = TaskCategory.assignment;
  bool _loading = false;
  double _previewScore = 0;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.existingTask!;
      _titleCtrl.text = t.title;
      _subjectCtrl.text = t.subject;
      _deadline = t.deadline;
      _difficulty = t.difficulty;
      _importance = t.importance;
      _category = t.category;
    }
    _updatePreview();
  }

  void _updatePreview() {
    final fake = Task(
      id: '', userId: '',
      title: 'preview',
      subject: 'preview',
      deadline: _deadline,
      difficulty: _difficulty,
      importance: _importance,
    );
    setState(() => _previewScore = PriorityService.calculateScore(fake));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
      _updatePreview();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final task = Task(
      id: _isEditing ? widget.existingTask!.id : const Uuid().v4(),
      userId: uid,
      title: _titleCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      deadline: _deadline,
      difficulty: _difficulty,
      importance: _importance,
      category: _category,
    );
    final provider = context.read<TaskProvider>();
    _isEditing ? await provider.updateTask(task) : await provider.addTask(task);
    if (mounted) Navigator.pop(context);
  }

  Color get _scoreColor {
    if (_previewScore >= 80) return AppColors.danger;
    if (_previewScore >= 60) return AppColors.warning;
    if (_previewScore >= 40) return AppColors.primary;
    return AppColors.success;
  }

  Color get _scoreBg {
    if (_previewScore >= 80) return AppColors.dangerLight;
    if (_previewScore >= 60) return AppColors.warningLight;
    if (_previewScore >= 40) return AppColors.primaryLight;
    return AppColors.successLight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit task' : 'New task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Priority Score Preview ──────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _scoreBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Priority score',
                            style: TextStyle(
                                fontSize: 12, color: _scoreColor.withValues(alpha: 0.8))),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _previewScore.toStringAsFixed(0),
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                  color: _scoreColor),
                            ),
                            Text(' / 100',
                                style: TextStyle(
                                    fontSize: 14, color: _scoreColor)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _scoreColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _previewScore >= 80 ? 'Critical' :
                        _previewScore >= 60 ? 'High' :
                        _previewScore >= 40 ? 'Medium' : 'Low',
                        style: TextStyle(
                            color: _scoreColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Title ───────────────────────────────────────────────
              _Label('Task title'),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    hintText: 'e.g. Prepare for algorithms exam'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),

              // ─── Subject ─────────────────────────────────────────────
              _Label('Subject'),
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(
                    hintText: 'e.g. Algorithms'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Subject is required' : null,
              ),
              const SizedBox(height: 14),

              // ─── Category ────────────────────────────────────────────
              _Label('Category'),
              DropdownButtonFormField<TaskCategory>(
                value: _category,
                decoration: const InputDecoration(),
                items: TaskCategory.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                )).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),

              // ─── Deadline ────────────────────────────────────────────
              _Label('Deadline'),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppColors.gray),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_deadline),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      Text(
                        '${_deadline.difference(DateTime.now()).inDays} days left',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.gray),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Importance ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Label('Importance'),
                  Text('$_importance / 5',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                ],
              ),
              _RatingBar(
                value: _importance,
                color: AppColors.primary,
                onChanged: (v) {
                  setState(() => _importance = v);
                  _updatePreview();
                },
              ),
              const SizedBox(height: 20),

              // ─── Difficulty ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Label('Difficulty'),
                  Text('$_difficulty / 5',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning)),
                ],
              ),
              _RatingBar(
                value: _difficulty,
                color: AppColors.warning,
                onChanged: (v) {
                  setState(() => _difficulty = v);
                  _updatePreview();
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Save changes' : 'Add task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w500, color: AppColors.gray)),
  );
}

class _RatingBar extends StatelessWidget {
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;
  const _RatingBar({
    required this.value,
    required this.color,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final active = i < value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i + 1),
            child: Container(
              margin: EdgeInsets.only(right: i < 4 ? 5 : 0),
              height: 8,
              decoration: BoxDecoration(
                color: active ? color : AppColors.grayLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}