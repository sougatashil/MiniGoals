// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/models/habit.dart';
import 'data/services/hive_service.dart';
import 'screens/providers/habit_provider.dart';
import 'screens/providers/statistics_provider.dart';
import 'screens/providers/settings_provider.dart' as settings_provider;
import 'screens/providers/navigation_provider.dart';
import 'screens/pages/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitCategoryAdapter());
  
  // Initialize Hive Service
  await HiveService.instance.init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MiniGoalsApp());
}

class MiniGoalsApp extends StatelessWidget {
  const MiniGoalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Navigation Provider
        ChangeNotifierProvider(
          create: (context) => NavigationProvider(),
        ),
        
        // Settings Provider
        ChangeNotifierProvider(
          create: (context) => settings_provider.SettingsProvider()..loadSettings(),
        ),
        
        // Main Habit Provider
        ChangeNotifierProvider(
          create: (context) => HabitProvider()..loadHabits(),
        ),
        
        // Statistics Provider (depends on HabitProvider)
        ChangeNotifierProxyProvider<HabitProvider, StatisticsProvider>(
          create: (context) => StatisticsProvider(),
          update: (context, habitProvider, statisticsProvider) {
            statisticsProvider!.updateHabits(habitProvider.habits);
            return statisticsProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'MiniGoals',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigation(),
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0F14),
                  Color(0xFF0D1117),
                  Color(0xFF1C2128),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}