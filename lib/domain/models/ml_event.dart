import 'dart:convert';

enum MLEventType {
  itemCreated,
  itemEdited,
  itemCompleted,
  itemDeleted,
  itemRestored,
  itemReopened,
  itemTypeChanged,
  categorySuggestionOverridden,
  searchPerformed,
  quickAddUsed,
  projectOpened,
  workoutOpened,
  contentOpened,
  noteOpened,
}

class MLEvent {
  final String id;
  final MLEventType eventType;
  final String? itemType;
  final String? itemId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const MLEvent({
    required this.id,
    required this.eventType,
    this.itemType,
    this.itemId,
    this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventType': eventType.name,
      'itemType': itemType,
      'itemId': itemId,
      'metadataJson': metadata != null ? jsonEncode(metadata) : null,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MLEvent.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? meta;
    if (map['metadataJson'] != null) {
      try {
        meta = jsonDecode(map['metadataJson'] as String) as Map<String, dynamic>?;
      } catch (_) {
        meta = null;
      }
    }

    return MLEvent(
      id: map['id'] as String,
      eventType: MLEventType.values.firstWhere(
        (e) => e.name == map['eventType'],
        orElse: () => MLEventType.itemCreated,
      ),
      itemType: map['itemType'] as String?,
      itemId: map['itemId'] as String?,
      metadata: meta,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
