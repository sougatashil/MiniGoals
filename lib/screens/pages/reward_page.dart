import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../data/models/habit.dart';
import '../../data/models/badge.dart' as models;
import '../providers/habit_provider.dart';
import '../widgets/glassmorphism_card.dart';

class RewardPage extends StatefulWidget {
  final String habitId;

  const RewardPage({super.key, required this.habitId});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _trophyController;
  late AnimationController _badgeController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _trophyBounceAnimation;
  late Animation<double> _badgeSpinAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _trophyBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.elasticOut),
    );

    _badgeSpinAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.linear),
    );

    _trophyController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _trophyController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habit = habitProvider.getHabitById(widget.habitId);
        
        if (habit == null) {
          Navigator.of(context).pop();
          return const SizedBox.shrink();
        }

        final totalStreakDays = habitProvider.getTotalStreakDays();
        final earnedBadges = habitProvider.getEarnedBadges();
        final newBadge = _getNewBadge(totalStreakDays, earnedBadges);

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              _buildAnimatedBackground(),
              _buildParticleEffect(),
              _buildContent(habit, totalStreakDays, newBadge, habitProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundColor,
                Color.lerp(
                  AppColors.backgroundColor,
                  AppColors.warningColor.withOpacity(0.1),
                  math.sin(_backgroundAnimation.value * math.pi) * 0.3,
                )!,
                Color.lerp(
                  AppColors.backgroundColor,
                  AppColors.primaryColor.withOpacity(0.1),
                  math.cos(_backgroundAnimation.value * math.pi) * 0.2,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(_backgroundAnimation.value),
          );
        },
      ),
    );
  }

  Widget _buildContent(Habit habit, int totalStreakDays, models.Badge? newBadge, HabitProvider habitProvider) {
    final categoryColor = AppColors.getCategoryColor(habit.category.name);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _trophyBounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _trophyBounceAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warningColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 64)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Habit Mastered!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.warningColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Congratulations! You\'ve completed your "${habit.title}" challenge with perfect consistency!',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (newBadge != null) ...[
              const SizedBox(height: 32),
              _buildNewBadgeShowcase(newBadge),
            ],
            const SizedBox(height: 32),
            _buildStatsCard(habit, totalStreakDays),
            const SizedBox(height: 40),
            _buildActionButtons(habit, habitProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildNewBadgeShowcase(models.Badge badge) {
    return GlassmorphismCard(
      backgroundColor: AppColors.warningColor.withOpacity(0.1),
      borderColor: AppColors.warningColor.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _badgeSpinAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _badgeSpinAnimation.value,
                  child: Text(
                    badge.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'New Badge Unlocked!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.warningColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${badge.name} - ${badge.requiredDays} days',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Habit habit, int totalStreakDays) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatRow('Habit completed:', habit.title),
            _buildStatRow('Perfect days:', '${habit.completionCount}/7'),
            _buildStatRow('Total streak:', '$totalStreakDays days'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Habit habit, HabitProvider habitProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _continueHabit(habitProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.healthColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: const Text(
              'Continue for 7 More Days 🔥',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Dashboard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to stats page
                },
                child: const Text('View Achievements'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _continueHabit(HabitProvider habitProvider) async {
    final newHabitId = await habitProvider.continueHabit(widget.habitId);
    if (newHabitId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New 7-day challenge started! 🚀'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  models.Badge? _getNewBadge(int totalDays, List<models.Badge> earnedBadges) {
    // Check if user just earned a new badge
    return models.Badge.allBadges.firstWhere(
      (badge) => totalDays >= badge.requiredDays && 
                 !earnedBadges.contains(badge),
      orElse: () => null as models.Badge,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double animationValue;
  final int particleCount = 20;

  _ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.warningColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final progress = (animationValue + i / particleCount) % 1.0;
      final x = (i / particleCount) * size.width;
      final y = size.height * (1 - progress);
      
      final radius = 2 + math.sin(progress * math.pi * 2) * 2;
      final opacity = math.sin(progress * math.pi);
      
      paint.color = AppColors.warningColor.withOpacity(opacity * 0.6);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}