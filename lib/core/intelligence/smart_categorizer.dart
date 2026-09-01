import '../../presentation/state/workspace_controller.dart';

class CategorizationResult {
  final DetailType type;
  final double confidence;
  final String? matchedReason;

  const CategorizationResult({
    required this.type,
    required this.confidence,
    this.matchedReason,
  });
}

class SmartCategorizer {
  // Keyword dictionaries
  static const _shoppingKeywords = {
    'buy', 'purchase', 'groceries', 'supermarket', 'store', 'milk', 'coffee',
    'eggs', 'bread', 'butter', 'cheese', 'apples', 'bananas', 'vegetables',
    'shampoo', 'soap', 'toothpaste', 'mouse', 'keyboard', 'cable', 'charger',
    'monitor', 'order', 'cart', 'amazon', 'shop', 'get some', 'pick up', 'costco',
  };

  static const _workoutKeywords = {
    'workout', 'gym', 'training', 'bench press', 'incline', 'squat', 'deadlift',
    'pullup', 'pushup', 'biceps', 'triceps', 'chest', 'legs', 'shoulders',
    'abs', 'cardio', 'running', 'hiit', 'reps', 'sets', 'warmup', 'cooldown',
    'stretching', 'upper body', 'lower body', 'dumbbells', 'barbell',
  };

  static const _contentKeywords = {
    'content', 'video', 'youtube', 'tiktok', 'reel', 'post', 'blog', 'article',
    'script', 'newsletter', 'linkedin', 'twitter', 'tweet', 'record', 'film',
    'thumbnail', 'publish', 'draft', 'episode', 'podcast', 'roadmap video',
  };

  static const _projectKeywords = {
    'project', 'architecture', 'redesign', 'roadmap', 'system', 'refactor',
    'overhaul', 'platform', 'app build', 'milestone', 'infrastructure',
    'dataset pipeline', 'module', 'v1 release',
  };

  static const _noteKeywords = {
    'remember', 'concept', 'summary', 'definition', 'idea:', 'thought:',
    'reference', 'notes:', 'quote', 'learn', 'read about', 'research topic',
    'insight', 'meeting notes', 'takeaway',
  };

  static const _taskKeywords = {
    'finish', 'complete', 'send', 'email', 'review', 'fix', 'bug', 'deploy',
    'submit', 'call', 'update', 'test', 'prepare', 'organize', 'clean',
    'schedule', 'check', 'verify', 'debug', 'implement', 'write code',
  };

  /// User override history feedback (inputText -> DetailType)
  final Map<String, String> _userOverrideFeedback;

  SmartCategorizer({Map<String, String>? userOverrideFeedback})
      : _userOverrideFeedback = userOverrideFeedback ?? {};

  void updateFeedback(Map<String, String> feedback) {
    _userOverrideFeedback.clear();
    _userOverrideFeedback.addAll(feedback);
  }

  void addSingleFeedback(String input, DetailType chosenType) {
    _userOverrideFeedback[input.trim().toLowerCase()] = chosenType.name;
  }

  CategorizationResult categorize(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) {
      return const CategorizationResult(
        type: DetailType.task,
        confidence: 0.2,
        matchedReason: 'Default fallback',
      );
    }

    // 1. Check exact user feedback override memory
    for (final entry in _userOverrideFeedback.entries) {
      if (text == entry.key || text.contains(entry.key)) {
        final type = _parseDetailType(entry.value);
        if (type != null) {
          return CategorizationResult(
            type: type,
            confidence: 0.95,
            matchedReason: 'Learned from past corrections',
          );
        }
      }
    }

    int shoppingScore = 0;
    int workoutScore = 0;
    int contentScore = 0;
    int projectScore = 0;
    int noteScore = 0;
    int taskScore = 0;

    String? topReason;

    // Check direct substring matches for multi-word keywords
    for (final kw in _shoppingKeywords) {
      if (text.contains(kw)) {
        shoppingScore += kw.contains(' ') ? 4 : 2;
        topReason ??= 'Matched shopping keyword "$kw"';
      }
    }
    for (final kw in _workoutKeywords) {
      if (text.contains(kw)) {
        workoutScore += kw.contains(' ') ? 4 : 2;
        topReason ??= 'Matched workout keyword "$kw"';
      }
    }
    for (final kw in _contentKeywords) {
      if (text.contains(kw)) {
        contentScore += kw.contains(' ') ? 4 : 2;
        topReason ??= 'Matched content keyword "$kw"';
      }
    }
    for (final kw in _projectKeywords) {
      if (text.contains(kw)) {
        projectScore += kw.contains(' ') ? 4 : 2;
        topReason ??= 'Matched project keyword "$kw"';
      }
    }
    for (final kw in _noteKeywords) {
      if (text.contains(kw)) {
        noteScore += kw.contains(' ') ? 4 : 2;
        topReason ??= 'Matched note keyword "$kw"';
      }
    }
    for (final kw in _taskKeywords) {
      if (text.contains(kw)) {
        taskScore += kw.contains(' ') ? 4 : 2;
        topReason ??= 'Matched task keyword "$kw"';
      }
    }

    // Sentence structure heuristics
    if (text.startsWith('buy ') || text.startsWith('get ') || text.startsWith('order ')) {
      shoppingScore += 5;
      topReason = 'Action verb: purchase';
    } else if (text.startsWith('workout:') || text.startsWith('gym:') || text.startsWith('train ')) {
      workoutScore += 5;
      topReason = 'Workout routine phrasing';
    } else if (text.startsWith('video:') || text.startsWith('post:') || text.startsWith('idea:') || text.startsWith('draft ') || text.startsWith('write ') || text.startsWith('youtube ')) {
      contentScore += 5;
      topReason = 'Content creation phrasing';
    } else if (text.startsWith('project:') || text.endsWith(' project')) {
      projectScore += 5;
      topReason = 'Project phrasing';
    } else if (text.startsWith('note:') || text.startsWith('remember ') || text.startsWith('read about ')) {
      noteScore += 5;
      topReason = 'Knowledge capture phrasing';
    }

    final scores = <DetailType, int>{
      DetailType.shopping: shoppingScore,
      DetailType.workout: workoutScore,
      DetailType.content: contentScore,
      DetailType.project: projectScore,
      DetailType.note: noteScore,
      DetailType.task: taskScore,
    };

    var bestType = DetailType.task;
    var maxScore = 0;

    scores.forEach((type, score) {
      if (score > maxScore) {
        maxScore = score;
        bestType = type;
      }
    });

    if (maxScore == 0) {
      // Default to task if contains action-oriented tokens, else task
      return const CategorizationResult(
        type: DetailType.task,
        confidence: 0.5,
        matchedReason: 'Default recommendation',
      );
    }

    final confidence = (0.5 + (maxScore * 0.1)).clamp(0.5, 0.95);

    return CategorizationResult(
      type: bestType,
      confidence: confidence,
      matchedReason: topReason,
    );
  }

  DetailType? _parseDetailType(String name) {
    for (final t in DetailType.values) {
      if (t.name.toLowerCase() == name.toLowerCase()) return t;
    }
    return null;
  }
}
