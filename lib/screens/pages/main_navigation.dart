// lib/screens/pages/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/page_transition_wrapper.dart';
import 'home_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';
import 'add_habit_page.dart';
import 'habit_detail_page.dart';
import 'reward_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return PopScope(
          canPop: false, // Handle back button manually
          onPopInvoked: (didPop) {
            if (didPop) return;
            _handleBackButton(navigationProvider);
          },
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: PageTransitionWrapper(
                child: _buildCurrentPage(navigationProvider.currentPage),
              ),
            ),
            bottomNavigationBar: navigationProvider.isOnBottomNavPage
                ? const CustomBottomNavigation()
                : null,
            extendBody: true,
          ),
        );
      },
    );
  }

  /// Handle hardware/software back button
  void _handleBackButton(NavigationProvider navigationProvider) {
    // Try to go back in navigation history
    if (navigationProvider.canGoBack) {
      navigationProvider.goBack();
    } else {
      // If can't go back, show exit confirmation
      _showExitConfirmation();
    }
  }

  /// Show exit confirmation dialog
  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        title: const Text(
          'Exit MiniGoals?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  /// Build the current page based on navigation state
  Widget _buildCurrentPage(AppPage currentPage) {
    switch (currentPage) {
      case AppPage.home:
        return const HomePage();
      case AppPage.stats:
        return const StatsPage();
      case AppPage.settings:
        return const SettingsPage();
      case AppPage.addHabit:
        return const AddHabitPage();
      case AppPage.habitDetail:
        return const HabitDetailPage();
      case AppPage.reward:
        return const RewardPage();
    }
  }
}