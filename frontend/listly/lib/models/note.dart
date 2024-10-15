class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'] ?? '', // Fallback to empty string if id is null
      title:
          json['title'] ?? 'Untitled', // Default to 'Untitled' if title is null
      content:
          json['content'] ?? '[]', // Default to empty array if content is null
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id.isEmpty ? '' : id, // Ensure '_id' is a string
      'title': title.isEmpty ? 'Untitled' : title, // Handle empty or null title
      'content':
          content.isEmpty ? '[]' : content, // Handle empty or null content
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
