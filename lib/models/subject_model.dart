class Subject {
  final String id;
  final String userId;
  final String name;
  final double difficulty;    // 1.0–5.0
  int allocatedHours;

  Subject({
    required this.id,
    required this.userId,
    required this.name,
    required this.difficulty,
    this.allocatedHours = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'difficulty': difficulty,
    'allocatedHours': allocatedHours,
  };

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
    id: map['id'] as String,
    userId: map['userId'] as String,
    name: map['name'] as String,
    difficulty: (map['difficulty'] as num).toDouble(),
    allocatedHours: map['allocatedHours'] as int? ?? 0,
  );
}