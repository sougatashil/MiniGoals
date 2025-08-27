import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
enum HabitCategory {
  @HiveField(0)
  health,
  @HiveField(1)
  productivity,
  @HiveField(2)
  learning,
  @HiveField(3)
  mindfulness,
  @HiveField(4)
  creative,
  @HiveField(5)
  finance,
  @HiveField(6)
  social,
}

extension HabitCategoryExtension on HabitCategory {
  String get name {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.creative:
        return 'Creative';
      case HabitCategory.finance:
        return 'Finance';
      case HabitCategory.social:
        return 'Social';
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.health:
        return '�';
      case HabitCategory.productivity:
        return '⚡';
      case HabitCategory.learning:
        return '�';
      case HabitCategory.mindfulness:
        return '�';
      case HabitCategory.creative:
        return '�';
      case HabitCategory.finance:
        return '�';
      case HabitCategory.social:
        return '�';
    }
  }

  String get displayName {
    switch (this) {
      case HabitCategory.health:
        return 'health';
      case HabitCategory.productivity:
        return 'productivity';
      case HabitCategory.learning:
        return 'learning';
      case HabitCategory.mindfulness:
        return 'mindfulness';
      case HabitCategory.creative:
        return 'creative';
      case HabitCategory.finance:
        return 'finance';
      case HabitCategory.social:
        return 'social';
    }
  }
}

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  HabitCategory category;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  List<bool> progress; // 7 days progress

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime? completedDate;

  @HiveField(7)
  int totalCycles; // How many 7-day cycles completed

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.startDate,
    List<bool>? progress,
    this.isCompleted = false,
    this.completedDate,
    this.totalCycles = 0,
  }) : progress = progress ?? List.filled(7, false);

  // Calculate current day (0-6) based on habit start date
  int get currentDay {
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    return daysSinceStart.clamp(0, 6);
  }

  // Get completed days count
  int get completedDaysCount {
    return progress.where((completed) => completed).length;
  }

  // Get completion percentage
  double get completionPercentage {
    return completedDaysCount / 7.0;
  }

  // Check if habit is active (within 7 days and not completed)
  bool get isActive {
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    return daysSinceStart >= 0 && daysSinceStart < 7 && !isCompleted;
  }

  // Check if today's task is completed
  bool get isTodayCompleted {
    final today = currentDay;
    return today < 7 && progress[today];
  }

  // Check if today's task can be marked
  bool get canMarkToday {
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    return daysSinceStart >= 0 && daysSinceStart < 7 && !isCompleted;
  }

  // Get progress status for display
  String get progressStatus {
    if (isCompleted) return '�';
    if (isTodayCompleted) return '✅';
    if (canMarkToday) return '⏳';
    return '❌';
  }

  // Mark/unmark a specific day
  void toggleDay(int dayIndex) {
    if (dayIndex >= 0 && dayIndex < 7) {
      progress[dayIndex] = !progress[dayIndex];
      
      // Check if habit is now completed
      if (completedDaysCount == 7 && !isCompleted) {
        isCompleted = true;
        completedDate = DateTime.now();
        totalCycles++;
      } else if (completedDaysCount < 7 && isCompleted) {
        isCompleted = false;
        completedDate = null;
      }
      
      save(); // Save to Hive
    }
  }

  // Reset habit for a new 7-day cycle
  void resetForNewCycle() {
    progress = List.filled(7, false);
    isCompleted = false;
    completedDate = null;
    startDate = DateTime.now();
    save();
  }

  // Continue habit for another 7-day cycle (keeps total cycles count)
  Habit continueHabit() {
    return Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      startDate: DateTime.now(),
      totalCycles: totalCycles,
    );
  }

  // Get days since start for display purposes
  int get daysSinceStart {
    return DateTime.now().difference(startDate).inDays;
  }

  // Check if a specific day was missed
  bool isDayMissed(int dayIndex) {
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    return dayIndex < daysSinceStart && !progress[dayIndex];
  }

  // Get total streak days (for badge calculations)
  int get totalStreakDays {
    return completedDaysCount + (totalCycles * 7);
  }

  @override
  String toString() {
    return 'Habit{id: $id, title: $title, category: $category, '
           'progress: $completedDaysCount/7, isCompleted: $isCompleted}';
  }

  // Copy method for updating habit
  Habit copyWith({
    String? id,
    String? title,
    HabitCategory? category,
    DateTime? startDate,
    List<bool>? progress,
    bool? isCompleted,
    DateTime? completedDate,
    int? totalCycles,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      progress: progress ?? List.from(this.progress),
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      totalCycles: totalCycles ?? this.totalCycles,
    );
  }
}