import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../providers/subject_provider.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/study_planner_service.dart';
import '../../utils/constants.dart';
import '../../widgets/task_card.dart';
import '../../widgets/priority_badge.dart';
import '../tasks/task_list_screen.dart';
import '../tasks/add_task_screen.dart';
import '../planner/planner_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    TaskListScreen(),
    PlannerScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddTaskScreen())),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist_rounded),
              label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Icons.schedule_outlined),
              selectedIcon: Icon(Icons.schedule_rounded),
              label: 'Planner'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final taskProvider = context.watch<TaskProvider>();
    final subjectProvider = context.watch<SubjectProvider>();
    final pending = taskProvider.pendingTasks;
    final plan = StudyPlannerService.generatePlan(
      tasks: pending,
      subjects: subjectProvider.subjects,
    );
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final greeting = _greeting();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$greeting, ${_firstName(user?.email)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(today,
                style: const TextStyle(fontSize: 12, color: AppColors.gray)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: taskProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ─── Stat Cards ──────────────────────────────────────
                  Row(
                    children: [
                      _StatCard(
                        label: 'Due this week',
                        value: '${pending.where((t) => t.daysUntilDeadline <= 7).length}',
                        color: AppColors.dangerLight,
                        textColor: AppColors.danger,
                        icon: Icons.warning_amber_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Total tasks',
                        value: '${pending.length}',
                        color: AppColors.primaryLight,
                        textColor: AppColors.primary,
                        icon: Icons.task_alt_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Subjects',
                        value: '${subjectProvider.subjects.length}',
                        color: AppColors.successLight,
                        textColor: AppColors.success,
                        icon: Icons.book_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Priority Tasks ──────────────────────────────────
                  _SectionHeader(
                    title: 'Priority tasks',
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 10),
                  if (pending.isEmpty)
                    _EmptyState(
                      icon: Icons.task_alt_rounded,
                      message: 'No pending tasks. Add some to get started.',
                    )
                  else
                    ...pending.take(3).map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(task: task),
                        )),
                  const SizedBox(height: 24),

                  // ─── Today's Study Plan ──────────────────────────────
                  _SectionHeader(title: "Today's study plan"),
                  const SizedBox(height: 10),
                  if (plan.isEmpty)
                    _EmptyState(
                      icon: Icons.schedule_outlined,
                      message: 'Add subjects in the Planner tab.',
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: plan.map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('${session.hours}h',
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(session.subject,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14)),
                                      Text(session.reason,
                                          style: const TextStyle(
                                              color: AppColors.gray,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(String? email) {
    if (email == null) return 'Student';
    return email.split('@').first.split('.').first.capitalize();
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w600, color: textColor)),
            Text(label,
                style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        if (onSeeAll != null)
          TextButton(
              onPressed: onSeeAll,
              child: const Text('See all', style: TextStyle(fontSize: 13))),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gray, size: 32),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray, fontSize: 13)),
        ],
      ),
    );
  }
}