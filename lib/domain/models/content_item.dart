class ContentItem {
  final String id;
  final String title;
  final String? description;
  final String? contentType; // e.g. "Video", "Post", "Article", "Short"
  final String? duration; // e.g. "45 mins"
  final String? thumbnailUrl;
  final String? notes;
  final String? status; // e.g. "Idea", "Draft", "Published"
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentItem({
    required this.id,
    required this.title,
    this.description,
    this.contentType,
    this.duration,
    this.thumbnailUrl,
    this.notes,
    this.status = 'Idea',
    required this.createdAt,
    required this.updatedAt,
  });

  ContentItem copyWith({
    String? id,
    String? title,
    String? description,
    String? contentType,
    String? duration,
    String? thumbnailUrl,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contentType': contentType,
      'duration': duration,
      'thumbnailUrl': thumbnailUrl,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ContentItem.fromMap(Map<String, dynamic> map) {
    return ContentItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      contentType: map['contentType'] as String?,
      duration: map['duration'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'Idea',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem.fromMap(json);
}
