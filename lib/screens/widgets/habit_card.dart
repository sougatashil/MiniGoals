import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/habit.dart';
import 'glassmorphism_card.dart';
import 'progress_ring.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final Function(int)? onToggleDay;
  final bool showProgressRing;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleDay,
    this.showProgressRing = false,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get categoryColor => AppColors.getCategoryColor(widget.habit.category.name);
  String get categoryIcon => AppColors.getCategoryIcon(widget.habit.category.name);

  String get statusEmoji {
    if (widget.habit.isPerfect) return '🏆';
    if (widget.habit.isTodayCompleted) return '✅';
    if (widget.habit.currentDay < widget.habit.daysSinceStart) return '❌';
    return '⏳';
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: AnimatedGlassmorphismCard(
        onTap: widget.onTap,
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
                _buildHeader(),
                const SizedBox(height: 16),
                if (widget.showProgressRing) _buildProgressRing(),
                _buildDaysGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: categoryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              categoryIcon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.habit.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.habit.category.displayName.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              statusEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: ProgressRing(
          progress: widget.habit.completionPercentage,
          size: 80,
          strokeWidth: 6,
          backgroundColor: AppColors.borderColor,
          progressColor: categoryColor,
          child: Text(
            '${widget.habit.completionCount}/7',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid() {
    return Row(
      children: List.generate(7, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == 6 ? 0 : 4,
            ),
            child: _buildDayItem(index),
          ),
        );
      }),
    );
  }

  Widget _buildDayItem(int dayIndex) {
    final isCompleted = widget.habit.progress[dayIndex];
    final isCurrent = dayIndex == widget.habit.currentDay;
    final isPast = dayIndex < widget.habit.daysSinceStart;
    final isFuture = dayIndex > widget.habit.currentDay;

    Color backgroundColor;
    Color borderColor;
    Widget content;

    if (isCompleted) {
      backgroundColor = categoryColor;
      borderColor = categoryColor;
      content = const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      );
    } else if (isCurrent) {
      backgroundColor = AppColors.cardColor;
      borderColor = categoryColor;
      content = Text(
        '${dayIndex + 1}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: categoryColor,
        ),
      );
    } else if (isPast) {
      backgroundColor = AppColors.errorColor.withOpacity(0.1);
      borderColor = AppColors.errorColor;
      content = const Icon(
        Icons.close,
        color: AppColors.errorColor,
        size: 16,
      );
    } else {
      backgroundColor = AppColors.cardColor;
      borderColor = AppColors.borderColor;
      content = Text(
        '${dayIndex + 1}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!isFuture && widget.onToggleDay != null) {
          HapticFeedback.lightImpact();
          widget.onToggleDay!(dayIndex);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(child: content),
      ),
    );
  }
}

class HabitCardShimmer extends StatefulWidget {
  const HabitCardShimmer({super.key});

  @override
  State<HabitCardShimmer> createState() => _HabitCardShimmerState();
}

class _HabitCardShimmerState extends State<HabitCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmerBox(48, 48, BorderRadius.circular(12)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(120, 16, BorderRadius.circular(8)),
                      const SizedBox(height: 8),
                      _buildShimmerBox(80, 12, BorderRadius.circular(6)),
                    ],
                  ),
                ),
                _buildShimmerBox(40, 40, BorderRadius.circular(20)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(7, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == 6 ? 0 : 4,
                    ),
                    child: _buildShimmerBox(36, 36, BorderRadius.circular(8)),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, BorderRadius borderRadius) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: [
                AppColors.borderColor,
                AppColors.borderColor.withOpacity(0.5),
                AppColors.borderColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_shimmerController.value * 2 * 3.14159),
            ),
          ),
        );
      },
    );
  }
}