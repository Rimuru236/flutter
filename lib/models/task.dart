/// Task model representing a single personal task.
/// Each task stores all relevant information for display and management.
class Task {
  String title;
  String description;
  String category;  // e.g. School, Personal, Health
  String priority;  // Low, Medium, High
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  /// Returns true if this task is past its due date and not yet completed.
  bool get isOverdue =>
      !isCompleted && dueDate.isBefore(DateTime.now());
}
