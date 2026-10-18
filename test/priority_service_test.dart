import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/models/task_model.dart';
import 'package:studyflow/services/priority_service.dart';

void main() {
  group('PriorityService', () {
    test('overdue task gets maximum urgency score', () {
      final task = Task(
        id: '1', userId: 'u1', title: 'test', subject: 'Math',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        difficulty: 5, importance: 5,
      );
      final score = PriorityService.calculateScore(task);
      expect(score, greaterThanOrEqualTo(95));
    });

    test('far-future task gets lower urgency score', () {
      final task = Task(
        id: '2', userId: 'u1', title: 'test', subject: 'Math',
        deadline: DateTime.now().add(const Duration(days: 30)),
        difficulty: 1, importance: 1,
      );
      final score = PriorityService.calculateScore(task);
      expect(score, lessThan(50));
    });

    test('sortByPriority returns highest score first', () {
      final tasks = [
        Task(id: '1', userId: 'u', title: 'low', subject: 'A',
            deadline: DateTime.now().add(const Duration(days: 30)),
            difficulty: 1, importance: 1),
        Task(id: '2', userId: 'u', title: 'high', subject: 'B',
            deadline: DateTime.now().add(const Duration(days: 1)),
            difficulty: 5, importance: 5),
      ];
      final sorted = PriorityService.sortByPriority(tasks);
      expect(sorted.first.title, 'high');
    });
  });
}