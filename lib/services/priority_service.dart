import '../models/task_model.dart';

/// AI Priority Algorithm
/// Score Formula (0–100):
///   score = (urgency × 0.40) + (importance × 0.35) + (difficulty × 0.25)
/// All components are normalized to 0–100.
/// Document this formula in your academic report.
class PriorityService {
  static double calculateScore(Task task) {
    final daysLeft = task.deadline.difference(DateTime.now()).inDays;

    // Dart 3 switch expression — cleaner than if/else chains
    final urgencyScore = switch (daysLeft) {
      <= 0  => 100.0,
      <= 1  => 95.0,
      <= 3  => 80.0,
      <= 7  => 60.0,
      <= 14 => 40.0,
      _     => 20.0,
    };

    final importanceScore = task.importance * 20.0;  // 1–5 → 20–100
    final difficultyScore = task.difficulty * 20.0;

    return (urgencyScore * 0.40) +
           (importanceScore * 0.35) +
           (difficultyScore * 0.25);
  }

  static List<Task> sortByPriority(List<Task> tasks) {
    return tasks
        .map((t) => t.copyWith(priorityScore: calculateScore(t)))
        .toList()
      ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
  }
}