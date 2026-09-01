import '../../domain/models/task.dart';
import '../../domain/models/project.dart';
import '../../presentation/state/workspace_controller.dart';

enum RelationType {
  potentialDuplicate,
  similar,
  sameProject,
}

class RelatedItemMatch {
  final String id;
  final DetailType type;
  final String title;
  final double similarity;
  final RelationType relationType;
  final String description;

  const RelatedItemMatch({
    required this.id,
    required this.type,
    required this.title,
    required this.similarity,
    required this.relationType,
    required this.description,
  });
}

class RelatedItemsDetector {
  /// Stop words to ignore during similarity checks
  static const _stopWords = {
    'the', 'is', 'at', 'which', 'on', 'a', 'an', 'and', 'or', 'in', 'to', 'for',
    'of', 'with', 'about', 'some', 'that', 'this', 'it', 'my', 'your',
  };

  /// Find related existing items given an input title / text
  List<RelatedItemMatch> findRelated({
    required String candidateTitle,
    String? candidateProjectId,
    String? currentItemId, // ignore self when editing
    required List<Task> tasks,
    required List<Project> projects,
    required List<dynamic> otherItems,
    double minSimilarityThreshold = 0.4,
  }) {
    final title = candidateTitle.trim().toLowerCase();
    if (title.length < 3) return [];

    final candidateTokens = _extractSignificantTokens(title);
    if (candidateTokens.isEmpty) return [];

    final matches = <RelatedItemMatch>[];

    // 1. Check Tasks
    for (final task in tasks) {
      if (task.id == currentItemId) continue;
      final taskTitle = task.title.toLowerCase();

      // Check same project relationship
      if (candidateProjectId != null && task.projectId == candidateProjectId) {
        // Project companion item
      }

      final sim = _calculateSimilarity(candidateTokens, taskTitle);
      if (sim >= minSimilarityThreshold) {
        matches.add(RelatedItemMatch(
          id: task.id,
          type: DetailType.task,
          title: task.title,
          similarity: sim,
          relationType: sim > 0.8 ? RelationType.potentialDuplicate : RelationType.similar,
          description: sim > 0.8 ? 'Potential duplicate task' : 'Similar active task',
        ));
      }
    }

    // 2. Check Projects
    for (final project in projects) {
      if (project.id == currentItemId) continue;
      final projectTitle = project.title.toLowerCase();

      final sim = _calculateSimilarity(candidateTokens, projectTitle);
      if (sim >= minSimilarityThreshold) {
        matches.add(RelatedItemMatch(
          id: project.id,
          type: DetailType.project,
          title: project.title,
          similarity: sim,
          relationType: sim > 0.8 ? RelationType.potentialDuplicate : RelationType.similar,
          description: sim > 0.8 ? 'Potential duplicate project' : 'Related active project',
        ));
      }
    }

    // Sort by highest similarity first
    matches.sort((a, b) => b.similarity.compareTo(a.similarity));
    return matches.take(3).toList();
  }

  Set<String> _extractSignificantTokens(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((s) => s.length > 2 && !_stopWords.contains(s))
        .toSet();
  }

  double _calculateSimilarity(Set<String> candidateTokens, String targetText) {
    final targetTokens = _extractSignificantTokens(targetText);
    if (candidateTokens.isEmpty || targetTokens.isEmpty) return 0.0;

    final intersection = candidateTokens.intersection(targetTokens).length;
    final union = candidateTokens.union(targetTokens).length;

    final jaccard = union > 0 ? (intersection / union) : 0.0;

    // Check substring overlap
    double substringBonus = 0.0;
    for (final ct in candidateTokens) {
      if (targetText.contains(ct)) {
        substringBonus += 0.15;
      }
    }

    return (jaccard * 0.7 + substringBonus.clamp(0.0, 0.3)).clamp(0.0, 1.0);
  }
}
