import 'package:flutter/foundation.dart';
import '../../data/models/habit.dart';
import '../../data/models/badge.dart' as models;
import '../../data/services/hive_service.dart';

class HabitProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService.instance;
  
  // State variables
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;
  Habit? _selectedHabit;
  
  // Getters
  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Habit? get selectedHabit => _selectedHabit;
  
  // Filtered habit lists
  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();
  List<Habit> get completedHabits => _habits.where((h) => h.isCompleted).toList();
  List<Habit> get todayHabits => _habits.where((h) => h.canMarkToday).toList();
  
  // Statistics
  int get activeHabitsCount => activeHabits.length;
  int get completedHabitsCount => completedHabits.length;
  int get totalHabitsCount => _habits.length;
  
  /// Calculate today's completion rate
  int get todayCompletionRate {
    if (todayHabits.isEmpty) return 0;
    final completedToday = todayHabits.where((h) => h.isTodayCompleted).length;
    return ((completedToday / todayHabits.length) * 100).round();
  }
  
  /// Get habits by category
  List<Habit> getHabitsByCategory(HabitCategory category) {
    return _habits.where((h) => h.category == category).toList();
  }
  
  /// Get habits that need attention (missed days or pending today)
  List<Habit> get habitsNeedingAttention {
    return activeHabits.where((h) {
      // Check if today is pending or if there are missed days
      return !h.isTodayCompleted || h.progress.asMap().entries.any((entry) {
        final dayIndex = entry.key;
        final isCompleted = entry.value;
        return dayIndex < h.currentDay && !isCompleted;
      });
    }).toList();
  }

  /// Load all habits from storage
  Future<void> loadHabits() async {
    try {
      _setLoading(true);
      _clearError();
      
      _habits = _hiveService.getAllHabits();
      
      // Sort habits by start date (newest first)
      _habits.sort((a, b) => b.startDate.compareTo(a.startDate));
      
      debugPrint('Loaded ${_habits.length} habits');
      
    } catch (e) {
      _setError('Failed to load habits: $e');
      debugPrint('Error loading habits: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new habit
  Future<bool> createHabit({
    required String title,
    required HabitCategory category,
  }) async {
    try {
      _clearError();
      
      // Validate input
      if (title.trim().isEmpty) {
        _setError('Habit title cannot be empty');
        return false;
      }
      
      if (title.length > 100) {
        _setError('Habit title must be less than 100 characters');
        return false;
      }
      
      // Create new habit
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        category: category,
        startDate: DateTime.now(),
      );
      
      // Save to storage
      await _hiveService.saveHabit(habit);
      
      // Update local list
      _habits.insert(0, habit);
      
      debugPrint('Created new habit: ${habit.title}');
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('Failed to create habit: $e');
      debugPrint('Error creating habit: $e');
      return false;
    }
  }

  /// Update an existing habit
  Future<bool> updateHabit(Habit updatedHabit) async {
    try {
      _clearError();
      
      await _hiveService.saveHabit(updatedHabit);
      
      // Update local list
      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
        
        // Update selected habit if it's the same one
        if (_selectedHabit?.id == updatedHabit.id) {
          _selectedHabit = updatedHabit;
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
      
    } catch (e) {
      _setError('Failed to update habit: $e');
      debugPrint('Error updating habit: $e');
      return false;
    }
  }

  /// Delete a habit
  Future<bool> deleteHabit(String habitId) async {
    try {
      _clearError();
      
      await _hiveService.deleteHabit(habitId);
      
      // Remove from local list
      _habits.removeWhere((h) => h.id == habitId);
      
      // Clear selected habit if it was deleted
      if (_selectedHabit?.id == habitId) {
        _selectedHabit = null;
      }
      
      debugPrint('Deleted habit: $habitId');
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('Failed to delete habit: $e');
      debugPrint('Error deleting habit: $e');
      return false;
    }
  }

  /// Toggle completion status for a specific day of a habit
  Future<bool> toggleHabitDay(String habitId, int dayIndex) async {
    try {
      _clearError();
      
      final habit = _habits.firstWhere((h) => h.id == habitId);
      
      // Validate day index
      if (dayIndex < 0 || dayIndex >= 7) {
        _setError('Invalid day index');
        return false;
      }
      
      // Check if day can be toggled
      final daysSinceStart = DateTime.now().difference(habit.startDate).inDays;
      if (dayIndex > daysSinceStart) {
        _setError('Cannot mark future days');
        return false;
      }
      
      // Toggle the day
      habit.toggleDay(dayIndex);
      
      // Update in storage
      await _hiveService.saveHabit(habit);
      
      // Update selected habit if it's the same one
      if (_selectedHabit?.id == habitId) {
        _selectedHabit = habit;
      }
      
      debugPrint('Toggled day $dayIndex for habit: ${habit.title}');
      notifyListeners();
      
      // Check if habit is now completed
      if (habit.isCompleted && habit.completedDaysCount == 7) {
        debugPrint('Habit completed: ${habit.title}');
        // This will trigger celebration UI in the widgets
      }
      
      return true;
      
    } catch (e) {
      _setError('Failed to toggle habit day: $e');
      debugPrint('Error toggling habit day: $e');
      return false;
    }
  }

  /// Mark today's habit as completed
  Future<bool> markTodayCompleted(String habitId) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      return await toggleHabitDay(habitId, habit.currentDay);
    } catch (e) {
      _setError('Failed to mark today completed: $e');
      return false;
    }
  }

  /// Reset habit progress (start new 7-day cycle)
  Future<bool> resetHabit(String habitId) async {
    try {
      _clearError();
      
      final habit = _habits.firstWhere((h) => h.id == habitId);
      habit.resetForNewCycle();
      
      await _hiveService.saveHabit(habit);
      
      // Update selected habit if it's the same one
      if (_selectedHabit?.id == habitId) {
        _selectedHabit = habit;
      }
      
      debugPrint('Reset habit: ${habit.title}');
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('Failed to reset habit: $e');
      debugPrint('Error resetting habit: $e');
      return false;
    }
  }

  /// Continue habit for another 7-day cycle
  Future<bool> continueHabit(String habitId) async {
    try {
      _clearError();
      
      final oldHabit = _habits.firstWhere((h) => h.id == habitId);
      final newHabit = oldHabit.continueHabit();
      
      await _hiveService.saveHabit(newHabit);
      
      // Add to local list
      _habits.insert(0, newHabit);
      
      debugPrint('Continued habit: ${newHabit.title}');
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('Failed to continue habit: $e');
      debugPrint('Error continuing habit: $e');
      return false;
    }
  }

  /// Select a habit for detailed view
  void selectHabit(String habitId) {
    try {
      _selectedHabit = _habits.firstWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      debugPrint('Habit not found: $habitId');
    }
  }

  /// Clear selected habit
  void clearSelectedHabit() {
    _selectedHabit = null;
    notifyListeners();
  }

  /// Get habit by ID
  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh habits from storage
  Future<void> refreshHabits() async {
    await loadHabits();
  }

  /// Clear all data (for reset functionality)
  Future<bool> clearAllData() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _hiveService.clearAllData();
      
      _habits.clear();
      _selectedHabit = null;
      
      debugPrint('All habit data cleared');
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('Failed to clear data: $e');
      debugPrint('Error clearing data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Export habits data
  Map<String, dynamic> exportData() {
    try {
      return _hiveService.exportData();
    } catch (e) {
      _setError('Failed to export data: $e');
      return {};
    }
  }

  /// Get daily progress for chart visualization
  Map<DateTime, double> getDailyProgressData({int days = 30}) {
    final progressData = <DateTime, double>{};
    final today = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final dayHabits = _habits.where((habit) {
        final daysDiff = date.difference(habit.startDate).inDays;
        return daysDiff >= 0 && daysDiff < 7;
      }).toList();
      
      if (dayHabits.isNotEmpty) {
        final completed = dayHabits.where((habit) {
          final dayIndex = date.difference(habit.startDate).inDays;
          return dayIndex >= 0 && dayIndex < 7 && habit.progress[dayIndex];
        }).length;
        
        progressData[date] = completed / dayHabits.length;
      } else {
        progressData[date] = 0.0;
      }
    }
    
    return progressData;
  }

  // Private helper methods
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    debugPrint('HabitProvider Error: $error');
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  // Method aliases for UI compatibility
  Future<void> refresh() => refreshHabits();
  
  Future<bool> addHabit({
    required String title,
    required HabitCategory category,
  }) {
    return createHabit(title: title, category: category);
  }
  
  double getTodayCompletionRate() {
    return todayCompletionRate.toDouble();
  }
  
  int getTotalStreakDays() {
    return _habits.fold(0, (sum, habit) => sum + habit.totalStreakDays);
  }
  
  int getCompletedHabitsCount() {
    return completedHabitsCount;
  }
  
  int getPerfectWeeksCount() {
    return _habits.where((h) => h.isPerfect).length;
  }
  
  int getCurrentStreak() {
    // Simple implementation - could be enhanced
    return _habits.fold(0, (maxStreak, habit) {
      final currentStreak = habit.completedDaysCount;
      return currentStreak > maxStreak ? currentStreak : maxStreak;
    });
  }
  
  int getLongestStreak() {
    return getCurrentStreak(); // Simplified for now
  }
  
  List<models.Badge> getEarnedBadges() {
    final totalDays = getTotalStreakDays();
    return models.Badge.allBadges.where((badge) => totalDays >= badge.requiredDays).toList();
  }
  
  models.Badge? getNextBadge() {
    final totalDays = getTotalStreakDays();
    return models.Badge.getNextBadge(totalDays);
  }
  
  Map<HabitCategory, List<Habit>> getHabitsGroupedByCategory() {
    final Map<HabitCategory, List<Habit>> grouped = {};
    for (final category in HabitCategory.values) {
      grouped[category] = getHabitsByCategory(category);
    }
    return grouped;
  }
  
  Future<bool> resetAllData() {
    return clearAllData();
  }
  
  @override
  void dispose() {
    debugPrint('HabitProvider disposed');
    super.dispose();
  }
}