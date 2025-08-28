import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/glassmorphism_card.dart';
import '../widgets/progress_ring.dart';
import 'reward_page.dart';

class HabitDetailPage extends StatefulWidget {
  final String habitId;

  const HabitDetailPage({
    super.key,
    required this.habitId,
  });

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habit = habitProvider.getHabitById(widget.habitId);
        
        if (habit == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(title: const Text('Habit Not Found')),
            body: const Center(
              child: Text(
                'This habit no longer exists.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(habit),
                _buildProgressSection(habit),
                _buildDaysGrid(habit, habitProvider),
                _buildActionButtons(habit, habitProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Habit habit) {
    final categoryColor = AppColors.getCategoryColor(habit.category.name);
    final categoryIcon = AppColors.getCategoryIcon(habit.category.name);

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.backgroundColor.withOpacity(0.9),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor.withOpacity(0.1),
                AppColors.backgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            categoryIcon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              habit.category.displayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Day ${habit.currentDay + 1} of 7 • ${(habit.completionPercentage * 100).round()}% complete',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(Habit habit) {
    final categoryColor = AppColors.getCategoryColor(habit.category.name);
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: GlassmorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  ProgressRing(
                    progress: habit.completionPercentage,
                    size: 140,
                    strokeWidth: 10,
                    backgroundColor: AppColors.borderColor,
                    progressColor: categoryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${habit.completionCount}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'of 7 days',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    habit.isPerfect 
                        ? 'Perfect habit! 🎉' 
                        : '${7 - habit.completionCount} days to go!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: habit.isPerfect ? AppColors.successColor : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid(Habit habit, HabitProvider habitProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassmorphismCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '7-Day Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    return _buildDayCard(habit, index, habitProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(Habit habit, int dayIndex, HabitProvider habitProvider) {
    final categoryColor = AppColors.getCategoryColor(habit.category.name);
    final isCompleted = habit.progress[dayIndex];
    final isCurrent = dayIndex == habit.currentDay;
    final isPast = dayIndex < habit.daysSinceStart;
    final isFuture = dayIndex > habit.currentDay;

    Color backgroundColor;
    Color borderColor;
    Widget content;
    bool canTap = false;

    if (isCompleted) {
      backgroundColor = categoryColor;
      borderColor = categoryColor;
      content = const Icon(Icons.check, color: Colors.white, size: 20);
      canTap = true;
    } else if (isCurrent) {
      backgroundColor = AppColors.cardColor;
      borderColor = categoryColor;
      content = Text(
        '${dayIndex + 1}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: categoryColor,
        ),
      );
      canTap = true;
    } else if (isPast) {
      backgroundColor = AppColors.errorColor.withOpacity(0.1);
      borderColor = AppColors.errorColor;
      content = const Icon(Icons.close, color: AppColors.errorColor, size: 18);
      canTap = true;
    } else {
      backgroundColor = AppColors.cardColor;
      borderColor = AppColors.borderColor;
      content = Text(
        '${dayIndex + 1}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      );
    }

    return GestureDetector(
      onTap: canTap && !isFuture
          ? () {
              HapticFeedback.lightImpact();
              habitProvider.toggleHabitDay(habit.id, dayIndex);
              
              // Check if habit just got completed and show reward
              final updatedHabit = habitProvider.getHabitById(habit.id);
              if (updatedHabit != null && 
                  updatedHabit.isPerfect && 
                  !habit.isPerfect) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showRewardPage(context, habit.id);
                });
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            content,
            const SizedBox(height: 4),
            Text(
              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dayIndex],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isCompleted 
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Habit habit, HabitProvider habitProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showResetDialog(context, habitProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset Progress'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(context, habitProvider),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorColor,
                      side: const BorderSide(color: AppColors.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, HabitProvider habitProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Reset Progress',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This will reset your progress and start a new 7-day cycle. Are you sure?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                habitProvider.resetHabit(widget.habitId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress reset successfully'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, HabitProvider habitProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Habit',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This will permanently delete this habit and all progress. This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                habitProvider.deleteHabit(widget.habitId);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to home
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Habit deleted'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showRewardPage(BuildContext context, String habitId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            RewardPage(habitId: habitId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}