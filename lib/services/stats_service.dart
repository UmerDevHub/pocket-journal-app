import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking user engagement stats
class StatsService {
  static const String _streakKey = 'daily_streak';
  static const String _lastDateKey = 'last_journal_date';
  static const String _totalWordsKey = 'total_words';
  static const String _longestStreakKey = 'longest_streak';
  static const String _totalNotesCreatedKey = 'total_notes_created';
  static const String _userNameKey = 'user_name';

  /// Get current streak
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Get longest streak ever
  Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_longestStreakKey) ?? 0;
  }

  /// Get total words written
  Future<int> getTotalWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalWordsKey) ?? 0;
  }

  /// Get total notes ever created
  Future<int> getTotalNotesCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalNotesCreatedKey) ?? 0;
  }

  /// Get user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Set user name
  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Update streak when user journals
  Future<Map<String, dynamic>> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateString(DateTime.now());
    final lastDate = prefs.getString(_lastDateKey);
    
    int currentStreak = prefs.getInt(_streakKey) ?? 0;
    int longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    bool isNewStreak = false;
    
    if (lastDate == null) {
      // First time user
      currentStreak = 1;
      isNewStreak = true;
    } else if (lastDate == today) {
      // Already journaled today, no change
    } else {
      final yesterday = _getDateString(DateTime.now().subtract(const Duration(days: 1)));
      if (lastDate == yesterday) {
        // Continuing streak
        currentStreak++;
        isNewStreak = true;
      } else {
        // Streak broken, start new
        currentStreak = 1;
        isNewStreak = true;
      }
    }
    
    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
      await prefs.setInt(_longestStreakKey, longestStreak);
    }
    
    await prefs.setInt(_streakKey, currentStreak);
    await prefs.setString(_lastDateKey, today);
    
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'isNewStreak': isNewStreak,
      'isMilestone': _isMilestone(currentStreak),
    };
  }

  /// Add words to total count
  Future<void> addWords(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalWordsKey) ?? 0;
    await prefs.setInt(_totalWordsKey, current + count);
  }

  /// Increment total notes created
  Future<void> incrementNotesCreated() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalNotesCreatedKey) ?? 0;
    await prefs.setInt(_totalNotesCreatedKey, current + 1);
  }

  /// Check if streak is a milestone
  bool _isMilestone(int streak) {
    return streak == 3 || streak == 7 || streak == 14 || 
           streak == 30 || streak == 50 || streak == 100 ||
           streak % 100 == 0;
  }

  /// Get date string for comparison
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else if (hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  /// Get all stats
  Future<Map<String, dynamic>> getAllStats() async {
    return {
      'currentStreak': await getCurrentStreak(),
      'longestStreak': await getLongestStreak(),
      'totalWords': await getTotalWords(),
      'totalNotesCreated': await getTotalNotesCreated(),
      'userName': await getUserName(),
    };
  }
}
