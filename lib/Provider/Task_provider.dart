import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notifications_tut/Provider/Task_model.dart';


class TaskProvider with ChangeNotifier {
  final Box _taskBox = Hive.box('shopping_box');
  final Box _completedBox = Hive.box('completed_box');

  List<Task> _tasks = [];
  List<Task> _completedTasks = [];

  List<Task> get tasks => _tasks;
  List<Task> get completedTasks => _completedTasks;

  TaskProvider() {
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _taskBox.keys.map((key) {
      return Task.fromMap(key, _taskBox.get(key));
    }).toList();

    _completedTasks = _completedBox.keys.map((key) {
      return Task.fromMap(key, _completedBox.get(key));
    }).toList();

    notifyListeners();
  }

  Future<void> addTask(String title, List<String> times) async {
    await _taskBox.add({"Title": title, "Times": times});
    _loadTasks();
  }

  Future<void> completeTask(int key) async {
    final task = _taskBox.get(key);
    if (task != null) {
      await _completedBox.add(task);
      await _taskBox.delete(key);
      _loadTasks();
    }
  }

  Future<void> deleteCompletedTask(int key) async {
    await _completedBox.delete(key);
    _loadTasks();
  }
}
