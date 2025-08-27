import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/habit.dart';
import 'glass_card.dart';
import 'progress_ring.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onToggleToday;
  final bool showProgressRing;
  final bool showDayTimeline;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleToday,
    this.showProgressRing = true,
    this.showDayTimeline = true,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryColor(habit.category.displayName);
    
    return AnimatedGlassCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border(
            top: BorderSide(
              color: categoryColor,
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Habit Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              habit.category.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              habit.category.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress Ring or Status
                  if (showProgressRing) ...[
                    const SizedBox(width: 16),
                    _buildProgressSection(categoryColor),
                  ] else ...[
                    const SizedBox(width: 16),
                    _buildStatusIcon(),
                  ],
                ],
              ),
              
              if (showDayTimeline) ...[
                const SizedBox(height: 16),
                _buildDayTimeline(categoryColor),
              ],
              
              // Bottom info row
              const SizedBox(height: 12),
              _buildBottomInfo(categoryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(Color categoryColor) {
    return GestureDetector(
      onTap: () {
        if (habit.canMarkToday && onToggleToday != null) {
          HapticFeedback.lightImpact();
          onToggleToday!();
        }
      },
      child: Container(
        width: 64,
        height: 64,
        child: Stack(
          children: [
            ProgressRing(
              progress: habit.completionPercentage,
              size: 64,
              strokeWidth: 6,
              color: categoryColor,
              backgroundColor: AppColors.borderColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${habit.completedDaysCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '/7',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Today action indicator
            if (habit.canMarkToday)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: habit.isTodayCompleted 
                        ? AppColors.successColor 
                        : categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: habit.isTodayCompleted 
                          ? AppColors.successColor 
                          : categoryColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    habit.isTodayCompleted 
                        ? Icons.check_rounded 
                        : Icons.add_rounded,
                    size: 12,
                    color: habit.isTodayCompleted 
                        ? AppColors.backgroundColor 
                        : categoryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    Color iconColor;
    IconData iconData;
    
    if (habit.isCompleted) {
      iconColor = AppColors.successColor;
      iconData = Icons.emoji_events_rounded;
    } else if (habit.isTodayCompleted) {
      iconColor = AppColors.primaryColor;
      iconData = Icons.check_circle_rounded;
    } else if (habit.canMarkToday) {
      iconColor = AppColors.warningColor;
      iconData = Icons.schedule_rounded;
    } else {
      iconColor = AppColors.errorColor;
      iconData = Icons.close_rounded;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        size: 22,
        color: iconColor,
      ),
    );
  }

  Widget _buildDayTimeline(Color categoryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        return _buildDayIndicator(index, categoryColor);
      }),
    );
  }

  Widget _buildDayIndicator(int dayIndex, Color categoryColor) {
    final isCompleted = habit.progress[dayIndex];
    final isCurrent = dayIndex == habit.currentDay && habit.canMarkToday;
    final isMissed = habit.isDayMissed(dayIndex);
    final isFuture = dayIndex > habit.currentDay;
    
    Color backgroundColor;
    Color borderColor;
    Widget content;
    
    if (isCompleted) {
      backgroundColor = categoryColor;
      borderColor = categoryColor;
      content = Icon(
        Icons.check_rounded,
        size: 14,
        color: AppColors.backgroundColor,
      );
    } else if (isCurrent) {
      backgroundColor = Colors.transparent;
      borderColor = categoryColor;
      content = Text(
        '${dayIndex + 1}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: categoryColor,
        ),
      );
    } else if (isMissed) {
      backgroundColor = AppColors.errorColor.withOpacity(0.1);
      borderColor = AppColors.errorColor.withOpacity(0.5);
      content = Icon(
        Icons.close_rounded,
        size: 12,
        color: AppColors.errorColor,
      );
    } else if (isFuture) {
      backgroundColor = AppColors.borderColor.withOpacity(0.3);
      borderColor = AppColors.borderColor;
      content = Text(
        '${dayIndex + 1}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      );
    } else {
      backgroundColor = AppColors.borderColor.withOpacity(0.2);
      borderColor = AppColors.borderColor;
      content = Text(
        '${dayIndex + 1}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      );
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Center(child: content),
    );
  }

  Widget _buildBottomInfo(Color categoryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Progress text
        Text(
          _getProgressText(),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        // Days remaining or completion badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getStatusColor().withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  String _getProgressText() {
    if (habit.isCompleted) {
      return 'Completed! ${habit.completedDaysCount}/7 days';
    }
    
    final daysSinceStart = habit.daysSinceStart;
    final currentDay = habit.currentDay + 1;
    
    if (daysSinceStart < 7) {
      return 'Day $currentDay of 7 • ${habit.completedDaysCount} completed';
    }
    
    return '${habit.completedDaysCount}/7 days completed';
  }

  String _getStatusText() {
    if (habit.isCompleted) {
      return 'COMPLETE';
    } else if (habit.isTodayCompleted) {
      return 'DONE TODAY';
    } else if (habit.canMarkToday) {
      return 'PENDING';
    } else {
      final daysRemaining = 7 - habit.daysSinceStart;
      if (daysRemaining <= 0) {
        return 'EXPIRED';
      }
      return '${daysRemaining}D LEFT';
    }
  }

  Color _getStatusColor() {
    if (habit.isCompleted) {
      return AppColors.successColor;
    } else if (habit.isTodayCompleted) {
      return AppColors.primaryColor;
    } else if (habit.canMarkToday) {
      return AppColors.warningColor;
    } else {
      return AppColors.errorColor;
    }
  }
}