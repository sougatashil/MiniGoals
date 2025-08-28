import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/habit.dart';
import '../../data/models/badge.dart' as models;
import '../providers/habit_provider.dart';
import '../widgets/glassmorphism_card.dart';
import '../widgets/progress_ring.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Consumer<HabitProvider>(
            builder: (context, habitProvider, child) {
              return RefreshIndicator(
                onRefresh: habitProvider.refresh,
                color: AppColors.primaryColor,
                backgroundColor: AppColors.surfaceColor,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeader(),
                    _buildAchievementSummary(habitProvider),
                    _buildStatsGrid(habitProvider),
                    _buildBadgesSection(habitProvider),
                    _buildCategoryProgress(habitProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Track your progress and achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementSummary(HabitProvider habitProvider) {
    final totalStreakDays = habitProvider.getTotalStreakDays();
    final earnedBadges = habitProvider.getEarnedBadges();
    final nextBadge = habitProvider.getNextBadge();
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassmorphismCard(
          backgroundColor: AppColors.primaryColor.withOpacity(0.05),
          borderColor: AppColors.primaryColor.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$totalStreakDays',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Text(
                  'TOTAL STREAK DAYS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                if (nextBadge != null && earnedBadges.length < models.Badge.allBadges.length) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Next: ${nextBadge.name} in ${nextBadge.requiredDays - totalStreakDays} days',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warningColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(HabitProvider habitProvider) {
    final stats = [
      _StatItem('Completed Habits', '${habitProvider.getCompletedHabitsCount()}', AppColors.successColor),
      _StatItem('Perfect Weeks', '${habitProvider.getPerfectWeeksCount()}', AppColors.warningColor),
      _StatItem('Current Streak', '${habitProvider.getCurrentStreak()}', AppColors.infoColor),
      _StatItem('Longest Streak', '${habitProvider.getLongestStreak()}', AppColors.creativeColor),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return GlassmorphismCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      _getStatIcon(index),
                      color: stat.color,
                      size: 28,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: stat.color,
                          ),
                        ),
                        Text(
                          stat.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getStatIcon(int index) {
    switch (index) {
      case 0: return Icons.verified_rounded;
      case 1: return Icons.star_rounded;
      case 2: return Icons.trending_up_rounded;
      case 3: return Icons.timeline_rounded;
      default: return Icons.analytics_rounded;
    }
  }

  Widget _buildBadgesSection(HabitProvider habitProvider) {
    final totalDays = habitProvider.getTotalStreakDays();
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Collect badges by maintaining streaks',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: models.Badge.allBadges.length,
              itemBuilder: (context, index) {
                final badge = models.Badge.allBadges[index];
                final isEarned = totalDays >= badge.requiredDays;
                
                return _buildBadgeCard(badge, isEarned);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(models.Badge badge, bool isEarned) {
    return GlassmorphismCard(
      backgroundColor: isEarned
          ? AppColors.warningColor.withOpacity(0.1)
          : AppColors.cardColor,
      borderColor: isEarned
          ? AppColors.warningColor.withOpacity(0.3)
          : AppColors.borderColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.icon,
              style: TextStyle(
                fontSize: 32,
                color: isEarned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isEarned ? AppColors.warningColor : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${badge.requiredDays}d',
              style: TextStyle(
                fontSize: 9,
                color: isEarned ? AppColors.warningColor.withOpacity(0.8) : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(HabitProvider habitProvider) {
    final categoryData = habitProvider.getHabitsGroupedByCategory();
    final categoriesWithHabits = categoryData.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (categoriesWithHabits.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...categoriesWithHabits.map((entry) {
              final category = entry.key;
              final habits = entry.value;
              final completedHabits = habits.where((h) => h.isPerfect).length;
              final progress = habits.isEmpty ? 0.0 : completedHabits / habits.length;
              final categoryColor = AppColors.getCategoryColor(category.name);
              final categoryIcon = AppColors.getCategoryIcon(category.name);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassmorphismCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
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
                                category.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$completedHabits of ${habits.length} completed',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: ProgressRing(
                            progress: progress,
                            size: 40,
                            strokeWidth: 4,
                            backgroundColor: AppColors.borderColor,
                            progressColor: categoryColor,
                            child: Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);
}