import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../providers/habit_provider.dart';
import '../widgets/glassmorphism_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _dailyReminders = true;
  bool _morningMotivation = true;
  bool _eveningCheckin = true;
  bool _achievementAlerts = true;
  bool _animationsEnabled = true;
  String _weekStartDay = 'Monday';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(habitProvider),
                  _buildProfileSection(habitProvider),
                  _buildNotificationSection(),
                  _buildAppearanceSection(),
                  _buildDataSection(habitProvider),
                  _buildSupportSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(HabitProvider habitProvider) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Customize your experience',
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

  Widget _buildProfileSection(HabitProvider habitProvider) {
    final totalDays = habitProvider.getTotalStreakDays();
    final completedHabits = habitProvider.getCompletedHabitsCount();
    final earnedBadges = habitProvider.getEarnedBadges().length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassmorphismCard(
          backgroundColor: AppColors.primaryColor.withOpacity(0.05),
          borderColor: AppColors.primaryColor.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.primaryColorLight],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Habit Master',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Member since ${DateTime.now().year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat('Days', '$totalDays'),
                    _buildProfileStat('Habits', '$completedHabits'),
                    _buildProfileStat('Badges', '$earnedBadges'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphismCard(
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.notifications_rounded,
                    title: 'Daily Reminders',
                    subtitle: 'Get reminded to complete your habits',
                    value: _dailyReminders,
                    onChanged: (value) => setState(() => _dailyReminders = value),
                  ),
                  _buildDivider(),
                  _buildToggleItem(
                    icon: Icons.wb_sunny_rounded,
                    title: 'Morning Motivation',
                    subtitle: 'Start your day with encouragement',
                    value: _morningMotivation,
                    onChanged: (value) => setState(() => _morningMotivation = value),
                  ),
                  _buildDivider(),
                  _buildToggleItem(
                    icon: Icons.bedtime_rounded,
                    title: 'Evening Check-in',
                    subtitle: 'Review your progress before bed',
                    value: _eveningCheckin,
                    onChanged: (value) => setState(() => _eveningCheckin = value),
                  ),
                  _buildDivider(),
                  _buildToggleItem(
                    icon: Icons.celebration_rounded,
                    title: 'Achievement Alerts',
                    subtitle: 'Celebrate when you earn badges',
                    value: _achievementAlerts,
                    onChanged: (value) => setState(() => _achievementAlerts = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphismCard(
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.animation_rounded,
                    title: 'Animations',
                    subtitle: 'Enable smooth animations',
                    value: _animationsEnabled,
                    onChanged: (value) => setState(() => _animationsEnabled = value),
                  ),
                  _buildDivider(),
                  _buildDropdownItem(
                    icon: Icons.calendar_today_rounded,
                    title: 'Week Start Day',
                    subtitle: 'First day of the week',
                    value: _weekStartDay,
                    items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
                    onChanged: (value) => setState(() => _weekStartDay = value ?? 'Monday'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(HabitProvider habitProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphismCard(
              child: Column(
                children: [
                  _buildActionItem(
                    icon: Icons.download_rounded,
                    title: 'Export Data',
                    subtitle: 'Download your habits and progress',
                    onTap: () => _exportData(habitProvider),
                  ),
                  _buildDivider(),
                  _buildActionItem(
                    icon: Icons.upload_rounded,
                    title: 'Import Data',
                    subtitle: 'Restore from a backup file',
                    onTap: () => _importData(habitProvider),
                  ),
                  _buildDivider(),
                  _buildActionItem(
                    icon: Icons.delete_forever_rounded,
                    title: 'Reset All Data',
                    subtitle: 'Clear all habits and progress',
                    color: AppColors.errorColor,
                    onTap: () => _showResetDialog(habitProvider),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphismCard(
              child: Column(
                children: [
                  _buildActionItem(
                    icon: Icons.feedback_rounded,
                    title: 'Send Feedback',
                    subtitle: 'Help us improve the app',
                    onTap: () => _showComingSoon('Feedback'),
                  ),
                  _buildDivider(),
                  _buildActionItem(
                    icon: Icons.star_rounded,
                    title: 'Rate App',
                    subtitle: 'Share your experience',
                    onTap: () => _showComingSoon('Rating'),
                  ),
                  _buildDivider(),
                  _buildActionItem(
                    icon: Icons.info_rounded,
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _showAboutDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: AppColors.surfaceColor,
        style: const TextStyle(color: AppColors.textPrimary),
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.textTertiary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.borderColor,
      height: 1,
      indent: 60,
    );
  }

  void _exportData(HabitProvider habitProvider) {
    try {
      final data = habitProvider.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // In a real app, you'd save this to a file or share it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data exported successfully! 📁'),
          backgroundColor: AppColors.successColor,
        ),
      );
      
      // Show the exported data in a dialog for demo purposes
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Exported Data', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Text(
              jsonString,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export failed. Please try again.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _importData(HabitProvider habitProvider) {
    // In a real app, you'd use file_picker to select a JSON file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import feature coming soon!'),
        backgroundColor: AppColors.infoColor,
      ),
    );
  }

  void _showResetDialog(HabitProvider habitProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset All Data',
          style: TextStyle(color: AppColors.errorColor),
        ),
        content: const Text(
          'This will permanently delete all your habits, progress, and achievements. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await habitProvider.resetAllData();
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'All data reset' : 'Reset failed'),
                  backgroundColor: success ? AppColors.successColor : AppColors.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppColors.infoColor,
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'MiniGoals',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, AppColors.primaryColorLight],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.track_changes,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}