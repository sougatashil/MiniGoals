import 'package:flutter/foundation.dart';
import 'dart:ui';

enum AppPage {
  home,
  stats,
  settings,
  addHabit,
  habitDetail,
  reward,
}

class NavigationProvider extends ChangeNotifier {
  // State variables
  AppPage _currentPage = AppPage.home;
  int _selectedBottomNavIndex = 0;
  String? _selectedHabitId;
  String? _rewardHabitId;
  
  // Navigation history for back button handling
  final List<AppPage> _navigationHistory = [AppPage.home];
  final int _maxHistorySize = 10;

  // Getters
  AppPage get currentPage => _currentPage;
  int get selectedBottomNavIndex => _selectedBottomNavIndex;
  String? get selectedHabitId => _selectedHabitId;
  String? get rewardHabitId => _rewardHabitId;
  bool get canGoBack => _navigationHistory.length > 1;
  List<AppPage> get navigationHistory => List.unmodifiable(_navigationHistory);

  // Navigation methods

  /// Navigate to home page
  void navigateToHome() {
    _setCurrentPage(AppPage.home);
    _selectedBottomNavIndex = 0;
    _clearSelectedHabit();
    notifyListeners();
  }

  /// Navigate to statistics page
  void navigateToStats() {
    _setCurrentPage(AppPage.stats);
    _selectedBottomNavIndex = 1;
    _clearSelectedHabit();
    notifyListeners();
  }

  /// Navigate to settings page
  void navigateToSettings() {
    _setCurrentPage(AppPage.settings);
    _selectedBottomNavIndex = 2;
    _clearSelectedHabit();
    notifyListeners();
  }

  /// Navigate to add habit page
  void navigateToAddHabit() {
    _setCurrentPage(AppPage.addHabit);
    _selectedBottomNavIndex = -1; // No bottom nav selection
    _clearSelectedHabit();
    notifyListeners();
  }

  /// Navigate to habit detail page
  void navigateToHabitDetail(String habitId) {
    _selectedHabitId = habitId;
    _setCurrentPage(AppPage.habitDetail);
    _selectedBottomNavIndex = -1; // No bottom nav selection
    notifyListeners();
  }

  /// Navigate to reward/celebration page
  void navigateToReward(String habitId) {
    _rewardHabitId = habitId;
    _setCurrentPage(AppPage.reward);
    _selectedBottomNavIndex = -1; // No bottom nav selection
    notifyListeners();
  }

  /// Navigate to a specific bottom nav page by index
  void navigateToBottomNavPage(int index) {
    switch (index) {
      case 0:
        navigateToHome();
        break;
      case 1:
        navigateToStats();
        break;
      case 2:
        navigateToSettings();
        break;
      default:
        navigateToHome();
    }
  }

  /// Go back to previous page
  bool goBack() {
    if (!canGoBack) return false;

    // Remove current page from history
    _navigationHistory.removeLast();
    
    // Get previous page
    final previousPage = _navigationHistory.last;
    
    // Navigate to previous page without adding to history
    _currentPage = previousPage;
    
    // Update bottom nav index if applicable
    switch (previousPage) {
      case AppPage.home:
        _selectedBottomNavIndex = 0;
        break;
      case AppPage.stats:
        _selectedBottomNavIndex = 1;
        break;
      case AppPage.settings:
        _selectedBottomNavIndex = 2;
        break;
      default:
        _selectedBottomNavIndex = -1;
    }

    // Clear selections when going back
    if (previousPage != AppPage.habitDetail) {
      _clearSelectedHabit();
    }
    if (previousPage != AppPage.reward) {
      _rewardHabitId = null;
    }

    debugPrint('Navigated back to: ${previousPage.name}');
    notifyListeners();
    return true;
  }

  /// Reset navigation to home
  void resetToHome() {
    _navigationHistory.clear();
    _navigationHistory.add(AppPage.home);
    _currentPage = AppPage.home;
    _selectedBottomNavIndex = 0;
    _clearSelectedHabit();
    _rewardHabitId = null;
    
    debugPrint('Navigation reset to home');
    notifyListeners();
  }

  /// Clear navigation history (useful for app restart scenarios)
  void clearHistory() {
    _navigationHistory.clear();
    _navigationHistory.add(_currentPage);
    notifyListeners();
  }

  // Page state helpers

  /// Check if a specific page is currently active
  bool isPageActive(AppPage page) {
    return _currentPage == page;
  }

  /// Check if currently on a bottom navigation page
  bool get isOnBottomNavPage {
    return [AppPage.home, AppPage.stats, AppPage.settings].contains(_currentPage);
  }

  /// Check if currently on a modal/overlay page
  bool get isOnModalPage {
    return [AppPage.addHabit, AppPage.habitDetail, AppPage.reward].contains(_currentPage);
  }

  /// Get the title for the current page
  String getCurrentPageTitle() {
    switch (_currentPage) {
      case AppPage.home:
        return 'MiniGoals';
      case AppPage.stats:
        return 'Statistics';
      case AppPage.settings:
        return 'Settings';
      case AppPage.addHabit:
        return 'New Habit';
      case AppPage.habitDetail:
        return 'Habit Details';
      case AppPage.reward:
        return 'Congratulations!';
    }
  }

  /// Get the current greeting based on time of day
  String getCurrentGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Habit-specific navigation helpers

  /// Navigate to habit detail and store the habit ID
  void selectHabit(String habitId) {
    navigateToHabitDetail(habitId);
  }

  /// Clear selected habit (used when navigating away from detail page)
  void _clearSelectedHabit() {
    _selectedHabitId = null;
  }

  /// Clear reward habit ID
  void clearRewardHabit() {
    _rewardHabitId = null;
  }

  // Animation and transition helpers

  /// Get slide direction for page transitions
  SlideDirection getSlideDirection(AppPage from, AppPage to) {
    // Define page order for horizontal sliding
    const pageOrder = [
      AppPage.home,
      AppPage.stats,
      AppPage.settings,
    ];

    final fromIndex = pageOrder.indexOf(from);
    final toIndex = pageOrder.indexOf(to);

    // If either page is not in the main navigation, slide from bottom
    if (fromIndex == -1 || toIndex == -1) {
      // Modal pages slide from bottom
      if ([AppPage.addHabit, AppPage.habitDetail, AppPage.reward].contains(to)) {
        return SlideDirection.fromBottom;
      }
      return SlideDirection.fromTop;
    }

    // Horizontal sliding for main navigation
    return toIndex > fromIndex ? SlideDirection.fromRight : SlideDirection.fromLeft;
  }

  /// Check if page transition should be animated
  bool shouldAnimateTransition(AppPage from, AppPage to) {
    // Don't animate if going to the same page
    if (from == to) return false;
    
    // Always animate modal pages
    if ([AppPage.addHabit, AppPage.habitDetail, AppPage.reward].contains(to) ||
        [AppPage.addHabit, AppPage.habitDetail, AppPage.reward].contains(from)) {
      return true;
    }
    
    // Animate main navigation transitions
    return true;
  }

  // Private helper methods

  void _setCurrentPage(AppPage page) {
    if (_currentPage != page) {
      _currentPage = page;
      
      // Add to navigation history
      if (_navigationHistory.isEmpty || _navigationHistory.last != page) {
        _navigationHistory.add(page);
        
        // Limit history size
        if (_navigationHistory.length > _maxHistorySize) {
          _navigationHistory.removeAt(0);
        }
      }
      
      debugPrint('Navigated to: ${page.name}');
    }
  }

  @override
  void dispose() {
    debugPrint('NavigationProvider disposed');
    super.dispose();
  }
}

/// Direction for page slide transitions
enum SlideDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

/// Extension for converting slide direction to offset
extension SlideDirectionExtension on SlideDirection {
  Offset get offset {
    switch (this) {
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
    }
  }
}