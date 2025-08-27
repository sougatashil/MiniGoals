import 'package:flutter/foundation.dart';
import '../../data/models/habit.dart';
import '../../data/services/hive_service.dart';

/// Badge definitions for achievement system
class Badge {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int requiredDays;
  final bool isEarned;

  const Badge({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.requiredDays,
    this.isEarned = false,
  });

  Badge copyWith({bool? isEarned}) {
    return Badge(
      id: id,
      name: name,
      emoji: emoji,
      description: description,
      requiredDays: requiredDays,
      isEarned: isEarned ?? this.isEarned,
    );
  }
}

class StatisticsProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService.instance;
  
  // Badge definitions
  static const List<Badge> _allBadges = [
    Badge(
      id: 'first_steps',
      name: 'First Steps',
      emoji: '�',
      description: '7 days',
      requiredDays: 7,
    ),
    Badge(
      id: 'building_momentum',
      name: 'Building Momentum',
      emoji: '�',
      description: '14 days',
      requiredDays: 14,
    ),
    Badge(
      id: 'habit_builder',
      name: 'Habit Builder',
      emoji: '�',
      description: '30 days',
      requiredDays: 30,
    ),
    Badge(
      id: 'centurion',
      name: 'Centurion',
      emoji: '�️',
      description: '100 days',
      requiredDays: 100,
    ),
    Badge(
      id: 'warrior',
      name: 'Warrior',
      emoji: '⚔️',
      description: '200 days',
      requiredDays: 200,
    ),
    Badge(
      id: 'legend',
      name: 'Legend',
      emoji: '�',
      description: '365 days',
      requiredDays: 365,
    ),
    Badge(
      id: 'master',
      name: 'Master',
      emoji: '�',
      description: '730 days',
      requiredDays: 730,
    ),
    Badge(
      id: 'immortal',
      name: 'Immortal',
      emoji: '✨',
      description: '1095 days',
      requiredDays: 1095,
    ),
  ];

  // State variables
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Update habits data (called from HabitProvider)
  void updateHabits(List<Habit> habits) {
    _habits = habits;
    notifyListeners();
  }

  // Core Statistics

  /// Get total streak days across all habits
  int get totalStreakDays {
    return _habits.fold(0, (total, habit) => total + habit.totalStreakDays);
  }

  /// Get completed habits count
  int get completedHabitsCount {
    return _habits.where((habit) => habit.isCompleted).length;
  }

  /// Get perfect weeks count (7/7 completed habits)
  int get perfectWeeksCount {
    return _habits.where((habit) => habit.completedDaysCount == 7).length;
  }

  /// Get current streak (consecutive days with at least one habit completion)
  int get currentStreak {
    if (_habits.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      bool hasProgressThisDay = false;

      for (final habit in _habits) {
        final daysDiff = checkDate.difference(habit.startDate).inDays;
        if (daysDiff >= 0 && daysDiff < 7 && habit.progress[daysDiff]) {
          hasProgressThisDay = true;
          break;
        }
      }

      if (hasProgressThisDay) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get longest streak from stored data or current streak
  int get longestStreak {
    final stored = _hiveService.getLongestStreak();
    final current = currentStreak;
    return stored > current ? stored : current;
  }

  /// Get average completion rate
  double get averageCompletionRate {
    if (_habits.isEmpty) return 0.0;
    
    final totalCompletion = _habits.fold(0.0, (sum, habit) => sum + habit.completionPercentage);
    return totalCompletion / _habits.length;
  }

  /// Get member since date
  DateTime get memberSinceDate {
    return _hiveService.getMemberSinceDate();
  }

  // Badge System

  /// Get all badges with earned status
  List<Badge> get allBadges {
    final totalDays = totalStreakDays;
    return _allBadges.map((badge) {
      return badge.copyWith(isEarned: totalDays >= badge.requiredDays);
    }).toList();
  }

  /// Get earned badges only
  List<Badge> get earnedBadges {
    return allBadges.where((badge) => badge.isEarned).toList();
  }

  /// Get next badge to earn
  Badge? get nextBadge {
    final totalDays = totalStreakDays;
    final unearned = _allBadges.where((badge) => totalDays < badge.requiredDays).toList();
    
    if (unearned.isEmpty) return null;
    
    unearned.sort((a, b) => a.requiredDays.compareTo(b.requiredDays));
    return unearned.first;
  }

  /// Get progress to next badge (0.0 to 1.0)
  double get nextBadgeProgress {
    final next = nextBadge;
    if (next == null) return 1.0;
    
    final totalDays = totalStreakDays;
    final previousBadgeLevel = earnedBadges.isNotEmpty 
        ? earnedBadges.last.requiredDays 
        : 0;
    
    final progressRange = next.requiredDays - previousBadgeLevel;
    final currentProgress = totalDays - previousBadgeLevel;
    
    return (currentProgress / progressRange).clamp(0.0, 1.0);
  }

  /// Check if a new badge was earned with recent progress
  Badge? checkForNewBadge(int previousTotalDays) {
    final currentTotalDays = totalStreakDays;
    
    for (final badge in _allBadges) {
      if (previousTotalDays < badge.requiredDays && currentTotalDays >= badge.requiredDays) {
        return badge;
      }
    }
    
    return null;
  }

  // Category Statistics

  /// Get statistics by category
  Map<HabitCategory, CategoryStats> get categoryStats {
    final stats = <HabitCategory, CategoryStats>{};
    
    for (final category in HabitCategory.values) {
      final categoryHabits = _habits.where((h) => h.category == category).toList();
      
      if (categoryHabits.isNotEmpty) {
        final completed = categoryHabits.where((h) => h.isCompleted).length;
        final active = categoryHabits.where((h) => h.isActive).length;
        final totalProgress = categoryHabits.fold(0.0, (sum, h) => sum + h.completionPercentage);
        
        stats[category] = CategoryStats(
          category: category,
          totalHabits: categoryHabits.length,
          completedHabits: completed,
          activeHabits: active,
          averageCompletion: categoryHabits.isNotEmpty ? totalProgress / categoryHabits.length : 0.0,
        );
      }
    }
    
    return stats;
  }

  /// Get categories that have habits
  List<HabitCategory> get activeCategoriesWithHabits {
    return HabitCategory.values.where((category) {
      return _habits.any((habit) => habit.category == category);
    }).toList();
  }

  // Trend Analysis

  /// Get weekly progress data for charts
  List<WeeklyProgress> getWeeklyProgressData({int weeks = 12}) {
    final weeklyData = <WeeklyProgress>[];
    final today = DateTime.now();
    
    for (int i = 0; i < weeks; i++) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      int totalPossible = 0;
      int totalCompleted = 0;
      
      // Check each habit for this week
      for (final habit in _habits) {
        for (int day = 0; day < 7; day++) {
          final checkDate = weekStart.add(Duration(days: day));
          final daysDiff = checkDate.difference(habit.startDate).inDays;
          
          if (daysDiff >= 0 && daysDiff < 7) {
            totalPossible++;
            if (habit.progress[daysDiff]) {
              totalCompleted++;
            }
          }
        }
      }
      
      final completionRate = totalPossible > 0 ? totalCompleted / totalPossible : 0.0;
      
      weeklyData.add(WeeklyProgress(
        weekStart: weekStart,
        weekEnd: weekEnd,
        completionRate: completionRate,
        habitsCount: _habits.length,
      ));
    }
    
    return weeklyData.reversed.toList(); // Most recent first
  }

  /// Get monthly summary
  MonthlySummary get monthlySummary {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    int daysInMonth = monthEnd.day;
    int daysCompleted = 0;
    int totalPossibleDays = 0;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final checkDate = DateTime(now.year, now.month, day);
      
      // Skip future dates
      if (checkDate.isAfter(now)) continue;
      
      bool hasProgressThisDay = false;
      int habitsThisDay = 0;
      
      for (final habit in _habits) {
        final daysDiff = checkDate.difference(habit.startDate).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          habitsThisDay++;
          if (habit.progress[daysDiff]) {
            hasProgressThisDay = true;
          }
        }
      }
      
      if (habitsThisDay > 0) {
        totalPossibleDays++;
        if (hasProgressThisDay) {
          daysCompleted++;
        }
      }
    }
    
    return MonthlySummary(
      month: monthStart,
      daysInMonth: daysInMonth,
      daysCompleted: daysCompleted,
      totalPossibleDays: totalPossibleDays,
      completionRate: totalPossibleDays > 0 ? daysCompleted / totalPossibleDays : 0.0,
    );
  }

  /// Update longest streak if current is higher
  Future<void> updateLongestStreak() async {
    try {
      await _hiveService.updateLongestStreak();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update longest streak: $e');
    }
  }

  // Data export
  Map<String, dynamic> getStatisticsExport() {
    return {
      'totalStreakDays': totalStreakDays,
      'completedHabits': completedHabitsCount,
      'perfectWeeks': perfectWeeksCount,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'averageCompletionRate': averageCompletionRate,
      'earnedBadges': earnedBadges.map((b) => b.id).toList(),
      'memberSince': memberSinceDate.toIso8601String(),
      'categoryStats': categoryStats.map((key, value) => 
        MapEntry(key.name, value.toMap())),
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Error handling
  void _setError(String error) {
    _error = error;
    debugPrint('StatisticsProvider Error: $error');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('StatisticsProvider disposed');
    super.dispose();
  }
}

/// Category statistics model
class CategoryStats {
  final HabitCategory category;
  final int totalHabits;
  final int completedHabits;
  final int activeHabits;
  final double averageCompletion;

  CategoryStats({
    required this.category,
    required this.totalHabits,
    required this.completedHabits,
    required this.activeHabits,
    required this.averageCompletion,
  });

  double get completionRate {
    return totalHabits > 0 ? completedHabits / totalHabits : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.name,
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'activeHabits': activeHabits,
      'averageCompletion': averageCompletion,
      'completionRate': completionRate,
    };
  }
}

/// Weekly progress model for charts
class WeeklyProgress {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double completionRate;
  final int habitsCount;

  WeeklyProgress({
    required this.weekStart,
    required this.weekEnd,
    required this.completionRate,
    required this.habitsCount,
  });
}

/// Monthly summary model
class MonthlySummary {
  final DateTime month;
  final int daysInMonth;
  final int daysCompleted;
  final int totalPossibleDays;
  final double completionRate;

  MonthlySummary({
    required this.month,
    required this.daysInMonth,
    required this.daysCompleted,
    required this.totalPossibleDays,
    required this.completionRate,
  });
}