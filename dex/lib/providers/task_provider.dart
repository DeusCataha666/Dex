import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  String? _userId;

  List<Task> get tasks => _tasks;

  void setUserId(String userId) {
    _userId = userId;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (_userId == null) return;

    _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      _tasks = snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addTask(Task task) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  Future<void> updateTask(Task task) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  List<Task> getTasksForDay(DateTime date) {
    return _tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }
} 