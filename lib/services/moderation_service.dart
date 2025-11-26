/// Service for content moderation and profanity filtering
class ModerationService {
  static ModerationService? _instance;
  static ModerationService get instance => _instance ??= ModerationService._();

  ModerationService._();

  // List of common profanity and inappropriate words (expandable)
  final Set<String> _profanityList = {
    // Add appropriate words to filter
    'damn',
    'hell',
    'crap',
    // This is a minimal list - expand based on requirements
  };

  // List of sensitive topics requiring moderation
  final Set<String> _sensitiveTopics = {
    'suicide',
    'self-harm',
    'violence',
    'abuse',
  };

  /// Check if text contains profanity
  bool containsProfanity(String text) {
    final lowerText = text.toLowerCase();
    
    for (final word in _profanityList) {
      if (lowerText.contains(word)) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if text contains sensitive content
  bool containsSensitiveContent(String text) {
    final lowerText = text.toLowerCase();
    
    for (final topic in _sensitiveTopics) {
      if (lowerText.contains(topic)) {
        return true;
      }
    }
    
    return false;
  }

  /// Filter profanity from text (replace with asterisks)
  String filterProfanity(String text) {
    String filtered = text;
    
    for (final word in _profanityList) {
      final regex = RegExp(word, caseSensitive: false);
      final replacement = '*' * word.length;
      filtered = filtered.replaceAll(regex, replacement);
    }
    
    return filtered;
  }

  /// Validate message content
  /// Returns null if valid, error message if invalid
  String? validateMessage(String content) {
    if (content.trim().isEmpty) {
      return 'Message cannot be empty';
    }

    if (content.length > 2000) {
      return 'Message is too long (max 2000 characters)';
    }

    if (containsProfanity(content)) {
      return 'Message contains inappropriate language';
    }

    if (containsSensitiveContent(content)) {
      return 'Message contains sensitive content that may require review';
    }

    return null;
  }

  /// Check if content should be flagged for review
  bool shouldFlagForReview(String content) {
    return containsSensitiveContent(content) || 
           _hasExcessiveProfanity(content);
  }

  /// Check if content has excessive profanity
  bool _hasExcessiveProfanity(String content) {
    final lowerText = content.toLowerCase();
    int profanityCount = 0;

    for (final word in _profanityList) {
      if (lowerText.contains(word)) {
        profanityCount++;
      }
    }

    // Flag if more than 3 profane words
    return profanityCount > 3;
  }

  /// Get moderation score (0-100, higher = more concerning)
  int getModerationScore(String content) {
    int score = 0;

    // Base score
    if (containsProfanity(content)) score += 30;
    if (containsSensitiveContent(content)) score += 50;
    if (_hasExcessiveProfanity(content)) score += 20;

    return score.clamp(0, 100);
  }

  /// Add word to profanity list
  void addProfanityWord(String word) {
    _profanityList.add(word.toLowerCase());
  }

  /// Add sensitive topic
  void addSensitiveTopic(String topic) {
    _sensitiveTopics.add(topic.toLowerCase());
  }

  /// Remove word from profanity list
  void removeProfanityWord(String word) {
    _profanityList.remove(word.toLowerCase());
  }

  /// Remove sensitive topic
  void removeSensitiveTopic(String topic) {
    _sensitiveTopics.remove(topic.toLowerCase());
  }

  /// Clear all custom filters
  void clearCustomFilters() {
    _profanityList.clear();
    _sensitiveTopics.clear();
  }
}
