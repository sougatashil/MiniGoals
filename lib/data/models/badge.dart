import 'package:flutter/material.dart';

class Badge {
  final String name;
  final String icon;
  final int requiredDays;
  final String description;
  final Color color;

  const Badge({
    required this.name,
    required this.icon,
    required this.requiredDays,
    required this.description,
    required this.color,
  });

  static const List<Badge> allBadges = [
    Badge(
      name: 'First Step',
      icon: '🌱',
      requiredDays: 1,
      description: 'Complete your first day',
      color: Color(0xFF4CAF50),
    ),
    Badge(
      name: 'Getting Started',
      icon: '🚀',
      requiredDays: 3,
      description: 'Complete 3 consecutive days',
      color: Color(0xFF2196F3),
    ),
    Badge(
      name: 'One Week',
      icon: '⭐',
      requiredDays: 7,
      description: 'Complete a full week',
      color: Color(0xFFFF9800),
    ),
    Badge(
      name: 'Two Weeks',
      icon: '💎',
      requiredDays: 14,
      description: 'Complete two weeks',
      color: Color(0xFF9C27B0),
    ),
    Badge(
      name: 'One Month',
      icon: '🏆',
      requiredDays: 30,
      description: 'Complete 30 days',
      color: Color(0xFFFFD700),
    ),
    Badge(
      name: 'Habit Master',
      icon: '👑',
      requiredDays: 60,
      description: 'Complete 60 days',
      color: Color(0xFFFF6B35),
    ),
    Badge(
      name: 'Legend',
      icon: '🌟',
      requiredDays: 100,
      description: 'Complete 100 days',
      color: Color(0xFFE91E63),
    ),
  ];

  static Badge? getBadgeForDays(int days) {
    Badge? earned;
    for (final badge in allBadges) {
      if (days >= badge.requiredDays) {
        earned = badge;
      } else {
        break;
      }
    }
    return earned;
  }

  static Badge? getNextBadge(int currentDays) {
    for (final badge in allBadges) {
      if (currentDays < badge.requiredDays) {
        return badge;
      }
    }
    return null; // All badges earned
  }
}
