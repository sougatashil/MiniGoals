import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  static HiveService get instance => _instance;
  HiveService._internal();

  // Box names
  static const String _habitsBoxName = 'habits';
  static const String _settingsBoxName = 'settings';
  static const String _statsBoxName = 'stats';

  // Boxes
  Box<Habit>? _habitsBox;
  Box? _settingsBox;
  Box? _statsBox;

  // Getters for boxes
  Box<Habit> get habitsBox {
    if (_habitsBox == null || !_habitsBox!.isOpen) {
      throw Exception('Habits box is not initialized');
    }
    return _habitsBox!;
  }

  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not initialized');
    }
    return _settingsBox!;
  }

  Box get statsBox {
    if (_statsBox == null || !_statsBox!.isOpen) {
      throw Exception('Stats box is not initialized');
    }
    return _statsBox!;
  }

  /// Initialize all Hive boxes
  Future<void> init() async {
    try {
      // Open boxes
      _habitsBox = await Hive.openBox<Habit>(_habitsBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      _statsBox = await Hive.openBox(_statsBoxName);

      // Initialize default settings if not exists
      await _initializeDefaultSettings();
      
      print('Hive service initialized successfully');
    } catch (e) {
      print('Error initializing Hive service: $e');
      rethrow;
    }
  }

  /// Initialize default settings
  Future<void> _initializeDefaultSettings() async {
    if (!settingsBox.containsKey('firstLaunch')) {
      await settingsBox.put('firstLaunch', false);
      await settingsBox.put('memberSince', DateTime.now().millisecondsSinceEpoch);
      await settingsBox.put('notificationsEnabled', true);
      await settingsBox.put('morningReminder', true);
      await settingsBox.put('eveningCheckIn', true);
      await settingsBox.put('achievementAlerts', true);
      await settingsBox.put('animationsEnabled', true);
      await settingsBox.put('weekStartDay', 1); // Monday
      await settingsBox.put('appTheme', 'dark');
    }
  }

  // HABIT OPERATIONS
  
  /// Get all habits
  List<Habit> getAllHabits() {
    return habitsBox.values.toList();
  }

  /// Get habit by ID
  Habit? getHabit(String id) {
    return habitsBox.values.firstWhere(
      (habit) => habit.id == id,
      orElse: () => throw Exception('Habit not found'),
    );
  }

  /// Add or update habit
  Future<void> saveHabit(Habit habit) async {
    try {
      await habitsBox.put(habit.id, habit);
    } catch (e) {
      print('Error saving habit: $e');
      rethrow;
    }
  }

  /// Delete habit
  Future<void> deleteHabit(String id) async {
    try {
      await habitsBox.delete(id);
    } catch (e) {
      print('Error deleting habit: $e');
      rethrow;
    }
  }

  /// Get active habits (not completed and within 7 days)
  List<Habit> getActiveHabits() {
    return habitsBox.values.where((habit) => habit.isActive).toList();
  }

  /// Get completed habits
  List<Habit> getCompletedHabits() {
    return habitsBox.values.where((habit) => habit.isCompleted).toList();
  }

  /// Get habits by category
  List<Habit> getHabitsByCategory(HabitCategory category) {
    return habitsBox.values.where((habit) => habit.category == category).toList();
  }

  // SETTINGS OPERATIONS

  /// Get setting value
  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Set setting value
  Future<void> setSetting<T>(String key, T value) async {
    try {
      await settingsBox.put(key, value);
    } catch (e) {
      print('Error setting $key: $e');
      rethrow;
    }
  }

  /// Get member since date
  DateTime getMemberSinceDate() {
    final timestamp = settingsBox.get('memberSince', defaultValue: DateTime.now().millisecondsSinceEpoch);
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // STATISTICS OPERATIONS

  /// Get total streak days across all habits
  int getTotalStreakDays() {
    return habitsBox.values.fold(0, (total, habit) => total + habit.totalStreakDays);
  }

  /// Get completed habits count
  int getCompletedHabitsCount() {
    return habitsBox.values.where((habit) => habit.isCompleted).length;
  }

  /// Get perfect weeks count (habits completed with 7/7 days)
  int getPerfectWeeksCount() {
    return habitsBox.values.where((habit) => habit.completedDaysCount == 7).length;
  }

  /// Get current streak (consecutive days with at least one habit completion)
  int getCurrentStreak() {
    final habits = getAllHabits();
    if (habits.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    // Check each day going backwards
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      bool hasProgressThisDay = false;

      for (final habit in habits) {
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

  /// Get longest streak from stored statistics
  int getLongestStreak() {
    return statsBox.get('longestStreak', defaultValue: getCurrentStreak());
  }

  /// Update longest streak if current is higher
  Future<void> updateLongestStreak() async {
    final currentStreak = getCurrentStreak();
    final longestStreak = getLongestStreak();
    
    if (currentStreak > longestStreak) {
      await statsBox.put('longestStreak', currentStreak);
    }
  }

  /// Get average completion rate
  double getAverageCompletionRate() {
    final habits = getAllHabits();
    if (habits.isEmpty) return 0.0;
    
    final totalCompletion = habits.fold(0.0, (sum, habit) => sum + habit.completionPercentage);
    return totalCompletion / habits.length;
  }

  /// Get category statistics
  Map<HabitCategory, Map<String, int>> getCategoryStats() {
    final stats = <HabitCategory, Map<String, int>>{};
    
    for (final category in HabitCategory.values) {
      final categoryHabits = getHabitsByCategory(category);
      final completed = categoryHabits.where((h) => h.isCompleted).length;
      
      stats[category] = {
        'total': categoryHabits.length,
        'completed': completed,
        'active': categoryHabits.where((h) => h.isActive).length,
      };
    }
    
    return stats;
  }

  // DATA EXPORT/IMPORT

  /// Export all data as JSON
  Map<String, dynamic> exportData() {
    final habits = getAllHabits();
    final settings = settingsBox.toMap();
    final stats = statsBox.toMap();

    return {
      'habits': habits.map((h) => {
        'id': h.id,
        'title': h.title,
        'category': h.category.name,
        'startDate': h.startDate.toIso8601String(),
        'progress': h.progress,
        'isCompleted': h.isCompleted,
        'completedDate': h.completedDate?.toIso8601String(),
        'totalCycles': h.totalCycles,
      }).toList(),
      'settings': settings,
      'stats': stats,
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// Clear all data (for reset functionality)
  Future<void> clearAllData() async {
    try {
      await habitsBox.clear();
      await statsBox.clear();
      // Keep some settings but reset others
      await settingsBox.put('firstLaunch', true);
      print('All data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
      rethrow;
    }
  }

  /// Close all boxes (call on app dispose)
  Future<void> close() async {
    try {
      await _habitsBox?.close();
      await _settingsBox?.close();
      await _statsBox?.close();
      print('Hive service closed successfully');
    } catch (e) {
      print('Error closing Hive service: $e');
    }
  }

  /// Check if boxes are initialized and open
  bool get isInitialized {
    return _habitsBox?.isOpen == true && 
           _settingsBox?.isOpen == true && 
           _statsBox?.isOpen == true;
  }
}