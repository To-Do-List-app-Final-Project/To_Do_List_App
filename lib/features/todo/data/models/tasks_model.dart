// lib/features/todo/data/models/task_model.dart
class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String categoryId;
  final String scheduleDate;
  final DateTime? reminderDate;
  final String status;
  final String repeat;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.id = '',
    required this.title,
    required this.description,
    required this.priority,
    required this.categoryId,
    required this.scheduleDate,
    this.reminderDate,
    required this.status,
    required this.repeat,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Medium',
      categoryId: json['categoryId']['_id'] ?? '',
      scheduleDate: json['scheduleDate'],
      reminderDate: json['reminderDate'] != null
          ? _parseDateTime(json['reminderDate'])
          : null,
      status: json['status'] ?? 'Pending',
      repeat: json['repeat'] ?? 'None',
      isCompleted: json['isCompleted'] ?? false,
      createdAt:
          json['createdAt'] != null ? _parseDateTime(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
    );
  }

  // Helper method to parse different datetime formats
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();

    if (dateTime is String) {
      // Try parsing as ISO date first (includes just date like "2025-03-30")
      try {
        return DateTime.parse(dateTime);
      } catch (_) {
        // Try parsing custom format (e.g., "04/04/2025 19:03:49")
        try {
          final parts = dateTime.split(' ');
          if (parts.length == 2) {
            final dateParts = parts[0].split('/');
            final timeParts = parts[1].split(':');

            if (dateParts.length == 3 && timeParts.length == 3) {
              return DateTime(
                int.parse(dateParts[2]), // year
                int.parse(dateParts[1]), // month
                int.parse(dateParts[0]), // day
                int.parse(timeParts[0]), // hour
                int.parse(timeParts[1]), // minute
                int.parse(timeParts[2]), // second
              );
            }
          }
        } catch (_) {
          // If all parsing fails, return current time
        }
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'priority': priority,
      'categoryId': categoryId,
      'scheduleDate': scheduleDate,
      'status': status,
      'repeat': repeat,
    };

    // Add optional fields only if they're not null
    if (id.isNotEmpty) data['_id'] = id;
    if (reminderDate != null)
      data['reminderDate'] = reminderDate!.toIso8601String().split('T')[0];
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();

    return data;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? categoryId,
    String? scheduleDate,
    DateTime? reminderDate,
    String? status,
    String? repeat,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      reminderDate: reminderDate ?? this.reminderDate,
      status: status ?? this.status,
      repeat: repeat ?? this.repeat,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
