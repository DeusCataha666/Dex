import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String color;
  final List<String> labels;
  final bool isCompleted;
  final DateTime? reminderTime;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
    required this.labels,
    this.isCompleted = false,
    this.reminderTime,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? color,
    List<String>? labels,
    bool? isCompleted,
    DateTime? reminderTime,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      color: color ?? this.color,
      labels: labels ?? this.labels,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'color': color,
      'labels': labels,
      'isCompleted': isCompleted,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      color: json['color'],
      labels: List<String>.from(json['labels']),
      isCompleted: json['isCompleted'],
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
    );
  }
} 