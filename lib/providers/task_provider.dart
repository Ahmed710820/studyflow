import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Task> _tasks = [];
  bool _loading = false;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<Task> get criticalTasks => pendingTasks
      .where((t) => t.priorityLevel == PriorityLevel.critical)
      .toList();

  void listenToTasks(String userId) {
    _loading = true;
    notifyListeners();
    _service.tasksStream(userId).listen((tasks) {
      _tasks = tasks;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> addTask(Task task) => _service.addTask(task);
  Future<void> updateTask(Task task) => _service.updateTask(task);
  Future<void> deleteTask(String userId, String taskId) =>
      _service.deleteTask(userId, taskId);
  Future<void> toggleComplete(Task task) => _service.toggleComplete(task);
}