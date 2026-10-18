import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { assignment, exam, project, revision }
enum PriorityLevel { low, medium, high, critical }

class Task {
  final String id;
  final String userId;
  final String title;
  final String subject;
  final DateTime deadline;
  final int difficulty;   // 1–5
  final int importance;   // 1–5
  final TaskCategory category;
  double priorityScore;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.deadline,
    required this.difficulty,
    required this.importance,
    this.category = TaskCategory.assignment,
    this.priorityScore = 0.0,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PriorityLevel get priorityLevel => switch (priorityScore) {
    >= 80 => PriorityLevel.critical,
    >= 60 => PriorityLevel.high,
    >= 40 => PriorityLevel.medium,
    _     => PriorityLevel.low,
  };

  String get priorityLabel => switch (priorityLevel) {
    PriorityLevel.critical => 'Critical',
    PriorityLevel.high     => 'High',
    PriorityLevel.medium   => 'Medium',
    PriorityLevel.low      => 'Low',
  };

  int get daysUntilDeadline =>
      deadline.difference(DateTime.now()).inDays;

  Task copyWith({
    String? title,
    String? subject,
    DateTime? deadline,
    int? difficulty,
    int? importance,
    TaskCategory? category,
    double? priorityScore,
    bool? isCompleted,
  }) => Task(
    id: id,
    userId: userId,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    deadline: deadline ?? this.deadline,
    difficulty: difficulty ?? this.difficulty,
    importance: importance ?? this.importance,
    category: category ?? this.category,
    priorityScore: priorityScore ?? this.priorityScore,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'subject': subject,
    'deadline': Timestamp.fromDate(deadline),
    'difficulty': difficulty,
    'importance': importance,
    'category': category.name,
    'priorityScore': priorityScore,
    'isCompleted': isCompleted,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    userId: map['userId'] as String,
    title: map['title'] as String,
    subject: map['subject'] as String,
    deadline: (map['deadline'] as Timestamp).toDate(),
    difficulty: map['difficulty'] as int,
    importance: map['importance'] as int,
    category: TaskCategory.values.byName(
      map['category'] as String? ?? 'assignment',
    ),
    priorityScore: (map['priorityScore'] as num).toDouble(),
    isCompleted: map['isCompleted'] as bool,
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );
}