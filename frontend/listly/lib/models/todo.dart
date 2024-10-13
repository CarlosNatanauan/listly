class ToDo {
  final String id; // Unique identifier for the task
  final String task; // Task description
  final bool completed; // Indicates if the task is completed

  ToDo({
    required this.id,
    required this.task,
    required this.completed,
  });

  // Factory constructor to create ToDo from JSON
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['_id'] as String? ?? '', // Provide a default value if null
      task: json['task'] as String? ??
          'No task specified', // Default task description
      completed:
          json['completed'] as bool? ?? false, // Default completion status
    );
  }

  // Method to convert ToDo to JSON for sending to the server
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'task': task,
      'completed': completed,
    };
  }
}
