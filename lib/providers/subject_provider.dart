import 'package:flutter/foundation.dart';
import '../models/subject_model.dart';
import '../services/firestore_service.dart';

class SubjectProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Subject> _subjects = [];

  List<Subject> get subjects => _subjects;

  void listenToSubjects(String userId) {
    _service.subjectsStream(userId).listen((subjects) {
      _subjects = subjects;
      notifyListeners();
    });
  }

  Future<void> addSubject(Subject subject) => _service.addSubject(subject);
  Future<void> deleteSubject(String userId, String id) =>
      _service.deleteSubject(userId, id);
}