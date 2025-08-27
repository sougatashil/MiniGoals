import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HabitDetailPage extends StatelessWidget {
  const HabitDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_list_rounded,
              size: 64,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Habit Detail Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '7-day progress grid coming soon...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

