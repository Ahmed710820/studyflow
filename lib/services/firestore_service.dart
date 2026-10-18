import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/subject_model.dart';
import '../services/priority_service.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Tasks ────────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) =>
      _db.collection('users').doc(userId).collection('tasks');

  Stream<List<Task>> tasksStream(String userId) {
    return _tasksRef(userId)
        .orderBy('deadline')
        .snapshots()
        .map((snap) {
          final tasks = snap.docs.map((d) => Task.fromMap(d.data())).toList();
          return PriorityService.sortByPriority(tasks);
        });
  }

  Future<void> addTask(Task task) async {
    final scored = task.copyWith(
      priorityScore: PriorityService.calculateScore(task),
    );
    await _tasksRef(task.userId).doc(task.id).set(scored.toMap());
  }

  Future<void> updateTask(Task task) async {
    final scored = task.copyWith(
      priorityScore: PriorityService.calculateScore(task),
    );
    await _tasksRef(task.userId).doc(task.id).update(scored.toMap());
  }

  Future<void> deleteTask(String userId, String taskId) =>
      _tasksRef(userId).doc(taskId).delete();

  Future<void> toggleComplete(Task task) =>
      _tasksRef(task.userId)
          .doc(task.id)
          .update({'isCompleted': !task.isCompleted});

  // ─── Subjects ─────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _subjectsRef(String userId) =>
      _db.collection('users').doc(userId).collection('subjects');

  Stream<List<Subject>> subjectsStream(String userId) {
    return _subjectsRef(userId).snapshots().map(
      (snap) => snap.docs.map((d) => Subject.fromMap(d.data())).toList(),
    );
  }

  Future<void> addSubject(Subject subject) =>
      _subjectsRef(subject.userId).doc(subject.id).set(subject.toMap());

  Future<void> deleteSubject(String userId, String subjectId) =>
      _subjectsRef(userId).doc(subjectId).delete();
}