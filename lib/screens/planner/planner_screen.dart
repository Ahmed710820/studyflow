import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../providers/task_provider.dart';
import '../../providers/subject_provider.dart';
import '../../models/subject_model.dart';
import '../../services/study_planner_service.dart';
import '../../utils/constants.dart';

const _subjectColors = [
  AppColors.primary, Color(0xFFEF9F27), Color(0xFF639922),
  Color(0xFFD4537E), Color(0xFF534AB7), Color(0xFFD85A30),
];

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().pendingTasks;
    final subjectProvider = context.watch<SubjectProvider>();
    final subjects = subjectProvider.subjects;
    final plan = StudyPlannerService.generatePlan(
        tasks: tasks, subjects: subjects);
    final totalHours = plan.fold(0, (s, e) => s + e.hours);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSubjectDialog(context, subjectProvider),
          ),
        ],
      ),
      body: subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_outlined, color: AppColors.gray, size: 48),
                  const SizedBox(height: 12),
                  const Text('No subjects yet',
                      style: TextStyle(color: AppColors.gray, fontSize: 15)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add subject'),
                    onPressed: () =>
                        _showAddSubjectDialog(context, subjectProvider),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 44)),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Pie Chart ────────────────────────────────────────
                if (plan.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Daily allocation — ${totalHours}h total',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 48,
                                sections: plan.asMap().entries.map((e) {
                                  final color = _subjectColors[
                                      e.key % _subjectColors.length];
                                  return PieChartSectionData(
                                    color: color,
                                    value: e.value.hours.toDouble(),
                                    title: '${e.value.hours}h',
                                    radius: 52,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Legend
                          Wrap(
                            spacing: 16, runSpacing: 8,
                            children: plan.asMap().entries.map((e) {
                              final color = _subjectColors[
                                  e.key % _subjectColors.length];
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10, height: 10,
                                    decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(e.value.subject,
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── Session List ─────────────────────────────────────
                const Text('This week\'s plan',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 15)),
                const SizedBox(height: 10),
                ...plan.asMap().entries.map((e) {
                  final color =
                      _subjectColors[e.key % _subjectColors.length];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('${e.value.hours}h',
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.value.subject,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14)),
                                Text(e.value.reason,
                                    style: const TextStyle(
                                        color: AppColors.gray, fontSize: 12)),
                              ],
                            ),
                          ),
                          // Progress bar
                          SizedBox(
                            width: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: e.value.hours / totalHours,
                                    backgroundColor:
                                        color.withValues(alpha: 0.15),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(e.value.hours / totalHours * 100).round()}%',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.gray),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),
                // ─── Subjects Management ──────────────────────────────
                const Text('Your subjects',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 15)),
                const SizedBox(height: 10),
                ...subjects.asMap().entries.map((e) {
                  final color =
                      _subjectColors[e.key % _subjectColors.length];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Text(
                          e.value.name[0].toUpperCase(),
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.w600),
                        ),
                      ),
                      title: Text(e.value.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          'Difficulty: ${e.value.difficulty.toStringAsFixed(1)}/5',
                          style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.gray, size: 20),
                        onPressed: () {
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          subjectProvider.deleteSubject(uid, e.value.id);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  void _showAddSubjectDialog(
      BuildContext context, SubjectProvider provider) {
    final nameCtrl = TextEditingController();
    double difficulty = 3.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Subject name',
                    hintText: 'e.g. Algorithms'),
              ),
              const SizedBox(height: 20),
              Text('Difficulty: ${difficulty.toStringAsFixed(1)} / 5',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.gray)),
              Slider(
                value: difficulty,
                min: 1, max: 5, divisions: 8,
                onChanged: (v) => setState(() => difficulty = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36)),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final uid = FirebaseAuth.instance.currentUser!.uid;
                provider.addSubject(Subject(
                  id: const Uuid().v4(),
                  userId: uid,
                  name: nameCtrl.text.trim(),
                  difficulty: difficulty,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}