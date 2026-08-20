class ShoppingItem {
  final String id;
  final String title;
  final String? notes;
  final bool isBought;
  final DateTime? boughtAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingItem({
    required this.id,
    required this.title,
    this.notes,
    this.isBought = false,
    this.boughtAt,
    required this.createdAt,
    required this.updatedAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? title,
    String? notes,
    bool? isBought,
    DateTime? boughtAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isBought: isBought ?? this.isBought,
      boughtAt: boughtAt ?? this.boughtAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'isBought': isBought ? 1 : 0,
      'boughtAt': boughtAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: map['notes'] as String?,
      isBought: (map['isBought'] as int? ?? 0) == 1,
      boughtAt: map['boughtAt'] != null ? DateTime.tryParse(map['boughtAt'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          isBought == other.isBought;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isBought.hashCode;
}
