import '../../presentation/state/search_controller.dart';

class ScoredSearchResult {
  final SearchResultItem item;
  final double score;
  final bool isSemanticMatch;

  const ScoredSearchResult({
    required this.item,
    required this.score,
    required this.isSemanticMatch,
  });
}

class SemanticSearchEngine {
  /// Stop words to reduce noise in semantic search
  static const _stopWords = {
    'the', 'is', 'at', 'which', 'on', 'a', 'an', 'and', 'or', 'in', 'to', 'for',
    'of', 'with', 'about', 'thing', 'some', 'that', 'this', 'it', 'from', 'by',
    'my', 'your', 'i', 'you', 'we', 'they', 'our', 'all',
  };

  /// Synonyms / Concept Clusters for local semantic matching
  static const Map<String, Set<String>> _conceptClusters = {
    'deploy': {'deployment', 'docker', 'cloud', 'server', 'release', 'production', 'api', 'endpoint'},
    'deployment': {'deploy', 'docker', 'cloud', 'server', 'release', 'production', 'api'},
    'model': {'ml', 'ai', 'machine learning', 'xgboost', 'neural', 'predict', 'churn', 'train', 'dataset'},
    'train': {'training', 'model', 'dataset', 'fit', 'learn', 'eda', 'ml'},
    'workout': {'exercise', 'fitness', 'gym', 'training', 'sets', 'reps', 'routine'},
    'buy': {'purchase', 'order', 'shop', 'groceries', 'store', 'cart'},
    'video': {'youtube', 'content', 'recording', 'film', 'thumbnail', 'tiktok', 'reel'},
    'idea': {'concept', 'thought', 'draft', 'note', 'brainstorm'},
    'bug': {'fix', 'issue', 'debug', 'error', 'problem', 'crash'},
    'code': {'dev', 'programming', 'dart', 'flutter', 'python', 'script'},
  };

  List<ScoredSearchResult> search(String query, List<SearchResultItem> allWorkspaceItems) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final queryTokens = _tokenize(cleanQuery);
    final significantTokens = queryTokens.where((t) => !_stopWords.contains(t)).toList();
    final tokensToUse = significantTokens.isNotEmpty ? significantTokens : queryTokens;

    // Expand query with synonyms
    final expandedConcepts = <String>{...tokensToUse};
    for (final token in tokensToUse) {
      if (_conceptClusters.containsKey(token)) {
        expandedConcepts.addAll(_conceptClusters[token]!);
      }
    }

    final scoredList = <ScoredSearchResult>[];

    for (final item in allWorkspaceItems) {
      final docText = '${item.title} ${item.subtitle ?? ""} ${item.category}'.toLowerCase();
      final docTokens = _tokenize(docText);

      // Exact substring match check (highest score)
      if (docText.contains(cleanQuery)) {
        scoredList.add(ScoredSearchResult(
          item: item,
          score: 1.0,
          isSemanticMatch: false,
        ));
        continue;
      }

      // Exact token overlap calculation
      int exactOverlap = 0;
      for (final t in tokensToUse) {
        if (docTokens.contains(t) || docText.contains(t)) {
          exactOverlap++;
        }
      }

      // Concept / Semantic cluster overlap
      int conceptOverlap = 0;
      for (final c in expandedConcepts) {
        if (docTokens.contains(c) || docText.contains(c)) {
          conceptOverlap++;
        }
      }

      // Character 3-gram fuzzy similarity
      final nGramSim = _calculateTrigramSimilarity(cleanQuery, docText);

      final tokenRatio = tokensToUse.isNotEmpty ? (exactOverlap / tokensToUse.length) : 0.0;
      final conceptRatio = expandedConcepts.isNotEmpty ? (conceptOverlap / expandedConcepts.length) : 0.0;

      final combinedScore = (tokenRatio * 0.5) + (conceptRatio * 0.3) + (nGramSim * 0.2);

      // Threshold for semantic relevancy
      if (combinedScore > 0.22 || exactOverlap > 0 || (conceptOverlap >= 2 && tokensToUse.length <= 4)) {
        scoredList.add(ScoredSearchResult(
          item: item,
          score: combinedScore.clamp(0.0, 0.99),
          isSemanticMatch: exactOverlap == 0,
        ));
      }
    }

    // Sort by relevance score descending
    scoredList.sort((a, b) => b.score.compareTo(a.score));
    return scoredList;
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Set<String> _getTrigrams(String text) {
    final trigrams = <String>{};
    final padded = '  $text ';
    for (int i = 0; i <= padded.length - 3; i++) {
      trigrams.add(padded.substring(i, i + 3));
    }
    return trigrams;
  }

  double _calculateTrigramSimilarity(String str1, String str2) {
    final tri1 = _getTrigrams(str1);
    final tri2 = _getTrigrams(str2);
    if (tri1.isEmpty || tri2.isEmpty) return 0.0;

    final intersection = tri1.intersection(tri2).length;
    final union = tri1.union(tri2).length;
    return union > 0 ? intersection / union : 0.0;
  }
}
