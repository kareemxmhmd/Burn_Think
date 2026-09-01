class IntelligenceSettings {
  final bool enableSmartCategorization;
  final bool enablePriorityPrediction;
  final bool enableRelatedItemDetection;
  final bool enableSemanticSearch;

  const IntelligenceSettings({
    this.enableSmartCategorization = true,
    this.enablePriorityPrediction = true,
    this.enableRelatedItemDetection = true,
    this.enableSemanticSearch = true,
  });

  IntelligenceSettings copyWith({
    bool? enableSmartCategorization,
    bool? enablePriorityPrediction,
    bool? enableRelatedItemDetection,
    bool? enableSemanticSearch,
  }) {
    return IntelligenceSettings(
      enableSmartCategorization: enableSmartCategorization ?? this.enableSmartCategorization,
      enablePriorityPrediction: enablePriorityPrediction ?? this.enablePriorityPrediction,
      enableRelatedItemDetection: enableRelatedItemDetection ?? this.enableRelatedItemDetection,
      enableSemanticSearch: enableSemanticSearch ?? this.enableSemanticSearch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableSmartCategorization': enableSmartCategorization ? 1 : 0,
      'enablePriorityPrediction': enablePriorityPrediction ? 1 : 0,
      'enableRelatedItemDetection': enableRelatedItemDetection ? 1 : 0,
      'enableSemanticSearch': enableSemanticSearch ? 1 : 0,
    };
  }

  factory IntelligenceSettings.fromMap(Map<String, dynamic> map) {
    return IntelligenceSettings(
      enableSmartCategorization: (map['enableSmartCategorization'] ?? 1) == 1,
      enablePriorityPrediction: (map['enablePriorityPrediction'] ?? 1) == 1,
      enableRelatedItemDetection: (map['enableRelatedItemDetection'] ?? 1) == 1,
      enableSemanticSearch: (map['enableSemanticSearch'] ?? 1) == 1,
    );
  }
}
