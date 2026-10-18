import '../models/task_model.dart';
import '../models/subject_model.dart';

class StudySession {
  final String subject;
  final int hours;
  final String reason;

  const StudySession({
    required this.subject,
    required this.hours,
    required this.reason,
  });
}

/// Study Time Allocation Algorithm
/// Allocates daily study hours across subjects, weighted by:
///   - urgency of tasks due in that subject
///   - subject difficulty
/// Total hours are capped at maxDailyHours (default: 8).
class StudyPlannerService {
  static List<StudySession> generatePlan({
    required List<Task> tasks,
    required List<Subject> subjects,
    int maxDailyHours = 8,
  }) {
    if (subjects.isEmpty) return [];

    // Calculate urgency weight per subject
    final Map<String, double> weights = {};
    for (final subject in subjects) {
      final relatedTasks = tasks.where(
        (t) => t.subject == subject.name && !t.isCompleted,
      );
      if (relatedTasks.isEmpty) {
        weights[subject.name] = 0;
        continue;
      }
      final avgScore = relatedTasks
          .map((t) => t.priorityScore)
          .reduce((a, b) => a + b) / relatedTasks.length;

      // Combine task urgency with subject difficulty
      weights[subject.name] = avgScore * 0.7 + (subject.difficulty * 20) * 0.3;
    }

    final totalWeight = weights.values.fold(0.0, (a, b) => a + b);
    if (totalWeight == 0) return [];

    return subjects
        .where((s) => (weights[s.name] ?? 0) > 0)
        .map((s) {
          final ratio = weights[s.name]! / totalWeight;
          final hours = (ratio * maxDailyHours).round().clamp(1, maxDailyHours);
          return StudySession(
            subject: s.name,
            hours: hours,
            reason: _reason(weights[s.name]!),
          );
        })
        .toList()
      ..sort((a, b) => b.hours.compareTo(a.hours));
  }

  static String _reason(double weight) => switch (weight) {
    >= 70 => 'Critical — urgent tasks pending',
    >= 50 => 'High priority this week',
    >= 30 => 'Moderate workload',
    _     => 'Maintenance review',
  };
}