import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/habit_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),
            
            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshData(context),
                color: AppColors.primaryColor,
                backgroundColor: AppColors.surfaceColor,
                child: CustomScrollView(
                  slivers: [
                    // Today's Progress Section
                    SliverToBoxAdapter(
                      child: _buildTodayProgress(context),
                    ),
                    
                    // Quick Stats Section
                    SliverToBoxAdapter(
                      child: _buildQuickStats(context),
                    ),
                    
                    // Habits Section
                    SliverToBoxAdapter(
                      child: _buildHabitsSection(context),
                    ),
                    
                    // Habits List
                    _buildHabitsList(context),
                    
                    // Bottom spacing for FAB
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<NavigationProvider>(
                    builder: (context, nav, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          nav.getCurrentGreeting(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Profile/Settings quick access
              GestureDetector(
                onTap: () => context.read<NavigationProvider>().navigateToSettings(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final completionRate = habitProvider.todayCompletionRate;
          final activeCount = habitProvider.activeHabitsCount;
          
          return GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ProgressRing(
                          progress: completionRate / 100.0,
                          size: 80,
                          strokeWidth: 6,
                          color: AppColors.primaryColor,
                          backgroundColor: AppColors.borderColor,
                          child: Text(
                            '$completionRate%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Progress Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Today\'s Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getProgressMessage(completionRate),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$activeCount active habit${activeCount != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (activeCount > 0 && completionRate < 100) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates_rounded,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap on habits below to mark them complete',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active',
                  habitProvider.activeHabitsCount.toString(),
                  Icons.play_circle_outline_rounded,
                  AppColors.infoColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  habitProvider.completedHabitsCount.toString(),
                  Icons.check_circle_outline_rounded,
                  AppColors.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  habitProvider.totalHabitsCount.toString(),
                  Icons.analytics_outlined,
                  AppColors.primaryColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Habits',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Consumer<HabitProvider>(
            builder: (context, habitProvider, child) {
              final needsAttention = habitProvider.habitsNeedingAttention.length;
              if (needsAttention > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warningColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$needsAttention need attention',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        if (habitProvider.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          );
        }

        if (habitProvider.error != null) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.errorColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Something went wrong',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habitProvider.error!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => habitProvider.refreshHabits(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (habitProvider.habits.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(context),
          );
        }

        // Group habits: active first, then completed
        final activeHabits = habitProvider.activeHabits;
        final completedHabits = habitProvider.completedHabits;
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final allHabits = [...activeHabits, ...completedHabits];
              final habit = allHabits[index];
              
              return Container(
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                child: HabitCard(
                  habit: habit,
                  onTap: () => _handleHabitTap(context, habit),
                  onToggleToday: () => _handleToggleToday(context, habit),
                ),
              );
            },
            childCount: activeHabits.length + completedHabits.length,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ready to Start?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your first 7-day habit challenge to begin building better routines',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.read<NavigationProvider>().navigateToAddHabit(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create Your First Habit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return FloatingActionButton(
          onPressed: () => context.read<NavigationProvider>().navigateToAddHabit(),
          tooltip: 'Add new habit',
          child: const Icon(
            Icons.add_rounded,
            size: 28,
          ),
        );
      },
    );
  }

  // Helper Methods

  void _handleHabitTap(BuildContext context, Habit habit) {
    context.read<NavigationProvider>().navigateToHabitDetail(habit.id);
  }

  void _handleToggleToday(BuildContext context, Habit habit) {
    final habitProvider = context.read<HabitProvider>();
    habitProvider.markTodayCompleted(habit.id);
  }

  Future<void> _refreshData(BuildContext context) async {
    await context.read<HabitProvider>().refreshHabits();
  }

  String _getProgressMessage(int completionRate) {
    if (completionRate == 0) {
      return 'Start your day by completing a habit';
    } else if (completionRate < 50) {
      return 'Great start! Keep the momentum going';
    } else if (completionRate < 100) {
      return 'You\'re doing amazing! Almost there';
    } else {
      return 'Perfect day! All habits completed';
    }
  }
}
