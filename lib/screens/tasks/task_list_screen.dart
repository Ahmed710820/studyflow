import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../utils/constants.dart';
import '../../widgets/task_card.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    List<Task> filtered(List<Task> tasks) {
      if (_searchQuery.isEmpty) return tasks;
      return tasks.where((t) =>
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.subject.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 8),
                TabBar(
                  controller: _tabCtrl,
                  tabs: [
                    Tab(text: 'Pending (${taskProvider.pendingTasks.length})'),
                    Tab(text: 'Done (${taskProvider.completedTasks.length})'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: taskProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _TaskListView(
                    tasks: filtered(taskProvider.pendingTasks)),
                _TaskListView(
                    tasks: filtered(taskProvider.completedTasks)),
              ],
            ),
    );
  }
}

class _TaskListView extends StatelessWidget {
  final List<Task> tasks;
  const _TaskListView({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, color: AppColors.gray, size: 48),
            const SizedBox(height: 12),
            const Text('No tasks here',
                style: TextStyle(color: AppColors.gray, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => TaskCard(
        task: tasks[i],
        onEdit: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => AddTaskScreen(existingTask: tasks[i]))),
      ),
    );
  }
}