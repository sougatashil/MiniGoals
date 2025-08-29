// lib/screens/widgets/custom_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/navigation_provider.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColorLight,
            border: const Border(
              top: BorderSide(
                color: AppColors.borderColor,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              // Reduced height from 80 to 70
              height: 70,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                // Reduced vertical padding from 8 to 4
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive: navigationProvider.selectedBottomNavIndex == 0,
                    onTap: () => navigationProvider.navigateToHome(),
                  ),
                  _NavItem(
                    icon: Icons.analytics_rounded,
                    label: 'Stats',
                    isActive: navigationProvider.selectedBottomNavIndex == 1,
                    onTap: () => navigationProvider.navigateToStats(),
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isActive: navigationProvider.selectedBottomNavIndex == 2,
                    onTap: () => navigationProvider.navigateToSettings(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 12, // Reduced from 16
          vertical: 6,    // Reduced from 8
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive 
              ? Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(4), // Reduced from 6
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 22, // Reduced from 24
                color: isActive
                    ? AppColors.primaryColor
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2), // Reduced from 4
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 11, // Reduced from 12
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.primaryColor
                    : AppColors.textTertiary,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}