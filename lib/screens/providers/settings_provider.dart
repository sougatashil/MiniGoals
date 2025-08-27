import 'package:flutter/foundation.dart';
import '../../data/services/hive_service.dart';

enum AppTheme { dark, light, system }
enum WeekStartDay { sunday, monday }

class NotificationSettings {
  final bool dailyReminders;
  final bool morningMotivation;
  final bool eveningCheckIn;
  final bool achievementAlerts;

  const NotificationSettings({
    required this.dailyReminders,
    required this.morningMotivation,
    required this.eveningCheckIn,
    required this.achievementAlerts,
  });

  NotificationSettings copyWith({
    bool? dailyReminders,
    bool? morningMotivation,
    bool? eveningCheckIn,
    bool? achievementAlerts,
  }) {
    return NotificationSettings(
      dailyReminders: dailyReminders ?? this.dailyReminders,
      morningMotivation: morningMotivation ?? this.morningMotivation,
      eveningCheckIn: eveningCheckIn ?? this.eveningCheckIn,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyReminders': dailyReminders,
      'morningMotivation': morningMotivation,
      'eveningCheckIn': eveningCheckIn,
      'achievementAlerts': achievementAlerts,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      dailyReminders: map['dailyReminders'] ?? true,
      morningMotivation: map['morningMotivation'] ?? true,
      eveningCheckIn: map['eveningCheckIn'] ?? true,
      achievementAlerts: map['achievementAlerts'] ?? true,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService.instance;
  
  // State variables
  bool _isLoading = false;
  String? _error;
  
  // Settings
  NotificationSettings _notificationSettings = const NotificationSettings(
    dailyReminders: true,
    morningMotivation: true,
    eveningCheckIn: true,
    achievementAlerts: true,
  );
  
  AppTheme _appTheme = AppTheme.dark;
  bool _animationsEnabled = true;
  WeekStartDay _weekStartDay = WeekStartDay.monday;
  DateTime? _memberSince;
  bool _isFirstLaunch = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  NotificationSettings get notificationSettings => _notificationSettings;
  AppTheme get appTheme => _appTheme;
  bool get animationsEnabled => _animationsEnabled;
  WeekStartDay get weekStartDay => _weekStartDay;
  DateTime? get memberSince => _memberSince;
  bool get isFirstLaunch => _isFirstLaunch;

  // Convenience getters for individual notification settings
  bool get dailyRemindersEnabled => _notificationSettings.dailyReminders;
  bool get morningMotivationEnabled => _notificationSettings.morningMotivation;
  bool get eveningCheckInEnabled => _notificationSettings.eveningCheckIn;
  bool get achievementAlertsEnabled => _notificationSettings.achievementAlerts;

  /// Initialize settings from storage
  Future<void> loadSettings() async {
    try {
      _setLoading(true);
      _clearError();

      // Load notification settings
      final notificationMap = _hiveService.getSetting('notificationSettings', defaultValue: <String, dynamic>{});
      if (notificationMap != null && notificationMap.isNotEmpty) {
        _notificationSettings = NotificationSettings.fromMap(Map<String, dynamic>.from(notificationMap));
      }

      // Load other settings
      _appTheme = _parseTheme(_hiveService.getSetting('appTheme', defaultValue: 'dark') ?? 'dark');
      _animationsEnabled = _hiveService.getSetting('animationsEnabled', defaultValue: true) ?? true;
      _weekStartDay = _parseWeekStartDay(_hiveService.getSetting('weekStartDay', defaultValue: 1) ?? 1);
      _isFirstLaunch = _hiveService.getSetting('firstLaunch', defaultValue: true) ?? true;
      
      // Load member since date
      final memberSinceTimestamp = _hiveService.getSetting('memberSince');
      if (memberSinceTimestamp != null) {
        _memberSince = DateTime.fromMillisecondsSinceEpoch(memberSinceTimestamp);
      }

      debugPrint('Settings loaded successfully');
      
    } catch (e) {
      _setError('Failed to load settings: $e');
      debugPrint('Error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Complete first launch setup
  Future<void> completeFirstLaunch() async {
    try {
      _isFirstLaunch = false;
      _memberSince = DateTime.now();
      
      await _hiveService.setSetting('firstLaunch', false);
      await _hiveService.setSetting('memberSince', _memberSince!.millisecondsSinceEpoch);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to complete first launch: $e');
    }
  }

  // Notification Settings

  /// Update daily reminders setting
  Future<void> setDailyReminders(bool enabled) async {
    try {
      _notificationSettings = _notificationSettings.copyWith(dailyReminders: enabled);
      await _saveNotificationSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update daily reminders: $e');
    }
  }

  /// Update morning motivation setting
  Future<void> setMorningMotivation(bool enabled) async {
    try {
      _notificationSettings = _notificationSettings.copyWith(morningMotivation: enabled);
      await _saveNotificationSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update morning motivation: $e');
    }
  }

  /// Update evening check-in setting
  Future<void> setEveningCheckIn(bool enabled) async {
    try {
      _notificationSettings = _notificationSettings.copyWith(eveningCheckIn: enabled);
      await _saveNotificationSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update evening check-in: $e');
    }
  }

  /// Update achievement alerts setting
  Future<void> setAchievementAlerts(bool enabled) async {
    try {
      _notificationSettings = _notificationSettings.copyWith(achievementAlerts: enabled);
      await _saveNotificationSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update achievement alerts: $e');
    }
  }

  /// Save notification settings to storage
  Future<void> _saveNotificationSettings() async {
    await _hiveService.setSetting('notificationSettings', _notificationSettings.toMap());
  }

  // Appearance Settings

  /// Update app theme
  Future<void> setAppTheme(AppTheme theme) async {
    try {
      _appTheme = theme;
      await _hiveService.setSetting('appTheme', theme.name);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update app theme: $e');
    }
  }

  /// Update animations enabled setting
  Future<void> setAnimationsEnabled(bool enabled) async {
    try {
      _animationsEnabled = enabled;
      await _hiveService.setSetting('animationsEnabled', enabled);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update animations setting: $e');
    }
  }

  /// Update week start day
  Future<void> setWeekStartDay(WeekStartDay day) async {
    try {
      _weekStartDay = day;
      await _hiveService.setSetting('weekStartDay', day == WeekStartDay.monday ? 1 : 0);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update week start day: $e');
    }
  }

  // Data Management

  /// Export user settings
  Map<String, dynamic> exportSettings() {
    return {
      'notificationSettings': _notificationSettings.toMap(),
      'appTheme': _appTheme.name,
      'animationsEnabled': _animationsEnabled,
      'weekStartDay': _weekStartDay.name,
      'memberSince': _memberSince?.toIso8601String(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import user settings
  Future<bool> importSettings(Map<String, dynamic> settingsData) async {
    try {
      _setLoading(true);
      _clearError();

      // Import notification settings
      if (settingsData.containsKey('notificationSettings')) {
        _notificationSettings = NotificationSettings.fromMap(
          Map<String, dynamic>.from(settingsData['notificationSettings'])
        );
        await _saveNotificationSettings();
      }

      // Import other settings
      if (settingsData.containsKey('appTheme')) {
        _appTheme = _parseTheme(settingsData['appTheme']);
        await _hiveService.setSetting('appTheme', _appTheme.name);
      }

      if (settingsData.containsKey('animationsEnabled')) {
        _animationsEnabled = settingsData['animationsEnabled'];
        await _hiveService.setSetting('animationsEnabled', _animationsEnabled);
      }

      if (settingsData.containsKey('weekStartDay')) {
        _weekStartDay = settingsData['weekStartDay'] == 'monday' 
            ? WeekStartDay.monday 
            : WeekStartDay.sunday;
        await _hiveService.setSetting('weekStartDay', _weekStartDay == WeekStartDay.monday ? 1 : 0);
      }

      // Import member since date
      if (settingsData.containsKey('memberSince') && settingsData['memberSince'] != null) {
        _memberSince = DateTime.parse(settingsData['memberSince']);
        await _hiveService.setSetting('memberSince', _memberSince!.millisecondsSinceEpoch);
      }

      debugPrint('Settings imported successfully');
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Failed to import settings: $e');
      debugPrint('Error importing settings: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset all settings to defaults
  Future<bool> resetSettings() async {
    try {
      _setLoading(true);
      _clearError();

      // Reset to defaults
      _notificationSettings = const NotificationSettings(
        dailyReminders: true,
        morningMotivation: true,
        eveningCheckIn: true,
        achievementAlerts: true,
      );
      _appTheme = AppTheme.dark;
      _animationsEnabled = true;
      _weekStartDay = WeekStartDay.monday;

      // Save to storage
      await _saveNotificationSettings();
      await _hiveService.setSetting('appTheme', _appTheme.name);
      await _hiveService.setSetting('animationsEnabled', _animationsEnabled);
      await _hiveService.setSetting('weekStartDay', 1);

      debugPrint('Settings reset to defaults');
      notifyListeners();
      return true;

    } catch (e) {
      _setError('Failed to reset settings: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utility Methods

  /// Get formatted member since text
  String getMemberSinceText() {
    if (_memberSince == null) return 'Member since today';
    
    final now = DateTime.now();
    final difference = now.difference(_memberSince!);
    
    if (difference.inDays < 1) {
      return 'Member since today';
    } else if (difference.inDays < 30) {
      return 'Member for ${difference.inDays} days';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Member for $months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingMonths = ((difference.inDays % 365) / 30).floor();
      
      String yearText = '$years year${years > 1 ? 's' : ''}';
      if (remainingMonths > 0) {
        yearText += ', $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
      }
      
      return 'Member for $yearText';
    }
  }

  /// Get week start day as integer (0 = Sunday, 1 = Monday)
  int getWeekStartDayInt() {
    return _weekStartDay == WeekStartDay.monday ? 1 : 0;
  }

  /// Check if dark mode is active
  bool get isDarkMode {
    // For now, always return true since we only have dark theme
    // In future, this would check system theme if AppTheme.system is selected
    return _appTheme == AppTheme.dark;
  }

  // Private helper methods

  AppTheme _parseTheme(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return AppTheme.light;
      case 'system':
        return AppTheme.system;
      case 'dark':
      default:
        return AppTheme.dark;
    }
  }

  WeekStartDay _parseWeekStartDay(int day) {
    return day == 1 ? WeekStartDay.monday : WeekStartDay.sunday;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    debugPrint('SettingsProvider Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    debugPrint('SettingsProvider disposed');
    super.dispose();
  }
}