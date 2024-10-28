class ToDo {
  final String id;
  final String task;
  final bool completed;
  final DateTime createdAt;

  ToDo({
    required this.id,
    required this.task,
    required this.completed,
    required this.createdAt,
  });

  // Factory constructor to create ToDo from JSON
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['_id'] as String? ?? '', // Provide a default value if null
      task: json['task'] as String? ??
          'No task specified', // Default task description
      completed:
          json['completed'] as bool? ?? false, // Default completion status
      createdAt: DateTime.parse(json['createdAt']), // Parse the createdAt field
    );
  }

  // Method to convert ToDo to JSON for sending to the server
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'task': task,
      'completed': completed,
      'createdAt':
          createdAt.toIso8601String(), // Convert createdAt to ISO format
    };
  }
}
