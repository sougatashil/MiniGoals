# � MiniGoals

**A beautiful, cross-platform micro-habit tracker built with Flutter**

*Build better habits, one week at a time.*
---

## ✨ Overview

MiniGoals is a modern, cross-platform habit tracking app built with Flutter that breaks the overwhelming cycle of indefinite habit building. Instead of focusing on endless streaks, MiniGoals helps you commit to achievable **7-day micro-challenges** that build momentum without burnout.

Available for both **Android** and **iOS** devices with native performance and beautiful platform-specific design adaptations.

### � Core Philosophy
- **7-Day Focus**: Perfect duration for building momentum without overwhelm
- **Multiple Habits**: Track different habit categories simultaneously  
- **Beautiful Rewards**: Earn badges and celebrate achievements
- **Smart Analytics**: Detailed progress tracking and insights
- **Cross-Platform**: Seamless experience on Android and iOS

---

## � Features

### � **Dashboard Experience**
- **Personalized Welcome**: Dynamic greetings based on time of day
- **Today's Progress Ring**: Visual completion tracking for daily habits
- **Quick Stats**: Active habits count and total badges earned
- **Smart Habit Cards**: Color-coded by category with mini-timelines

### � **Comprehensive Analytics** 
- **Achievement Badges**: 8 milestone badges from 7 days to 3+ years
- **Streak Tracking**: Current streak, longest streak, and perfect weeks
- **Category Progress**: Visual completion rates for each habit type
- **Total Statistics**: Lifetime habit completion analytics

### � **Multi-Category System**
- � **Health** - Physical wellness and fitness goals
- ⚡ **Productivity** - Work efficiency and focus habits
- � **Learning** - Educational and skill-building activities
- � **Mindfulness** - Mental health and meditation practices
- � **Creative** - Artistic and creative expression goals
- � **Finance** - Money management and financial habits

### � **Reward & Badge System**
- � **First Steps** (7 days)
- � **Building Momentum** (14 days)
- � **Habit Builder** (30 days)
- �️ **Centurion** (100 days)
- ⚔️ **Warrior** (200 days)
- � **Legend** (365 days)
- � **Master** (730 days)
- ✨ **Immortal** (1095 days)

### ⚙️ **Customization & Settings**
- **Notification Controls**: Daily reminders and achievement alerts
- **Data Management**: Export/import functionality with JSON backups
- **Theme Options**: Beautiful dark theme with glassmorphism design
- **Privacy Controls**: Local storage with user data control

---

## � Design Features

### **Modern Mobile UI/UX**
- **Material Design 3**: Android design system with dynamic theming
- **Cupertino Design**: iOS-native components and interactions
- **Adaptive Layouts**: Platform-specific navigation and transitions
- **Dark/Light Themes**: System-aware theme switching
- **Custom Animations**: Flutter's powerful animation framework

### **Performance Features**
- **Native Performance**: Compiled to native ARM code for speed
- **Smooth 60fps**: Flutter's optimized rendering engine
- **Memory Efficient**: Optimized widget tree and state management
- **Fast App Launch**: Quick cold start and warm resume times

### **Color System**
```dart
// Primary Colors
static const Color primaryColor = Color(0xFF00D4AA);
static const Color primaryColorDark = Color(0xFF00A693);
static const Color primaryColorLight = Color(0xFF4DFFDA);

// Background Colors  
static const Color backgroundColor = Color(0xFF0A0F14);
static const Color backgroundColorLight = Color(0xFF0D1117);

// Surface Colors
static const Color surfaceColor = Color(0xFF1C2128);
static const Color cardColor = Color(0x0DFFFFFF); // 5% white opacity

// Status Colors
static const Color successColor = Color(0xFF00D4AA);
static const Color errorColor = Color(0xFFFF4757);
static const Color warningColor = Color(0xFFFF9800);
static const Color infoColor = Color(0xFF4FC3F7);
```

### **Interactive Elements**
- **Hero Animations**: Smooth page transitions with shared elements
- **Physics-Based**: Realistic scrolling and gesture interactions
- **Haptic Feedback**: Tactile responses for user actions
- **Platform Gestures**: Native swipe, pinch, and tap behaviors

---

## �️ Technical Stack

### **Framework & Language**
- **Flutter**: Google's UI toolkit for cross-platform development
- **Dart**: Modern, type-safe programming language
- **Material 3**: Latest Material Design components
- **Cupertino**: iOS-native design widgets

### **Architecture & Patterns**
- **MVVM Pattern**: Model-View-ViewModel architecture
- **Provider/Riverpod**: State management solution
- **Repository Pattern**: Clean data layer abstraction
- **Dependency Injection**: Service locator pattern

### **Data & Storage**
- **Hive**: Fast, lightweight local database
- **SharedPreferences**: User settings and preferences
- **Path Provider**: Cross-platform file system access
- **Secure Storage**: Encrypted local data storage

### **Platform Features**
- **Local Notifications**: Scheduled reminder system
- **Biometric Auth**: Fingerprint/Face ID app protection
- **Share Plugin**: Export and share progress data
- **Device Info**: Platform-specific optimizations

---

## � Platform Support

### **Android**
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 33 (Android 13)
- **Architecture**: ARM64, ARMv7, x86_64
- **Play Store**: Available for download
- **Material You**: Dynamic color theming support

### **iOS**
- **Minimum Version**: iOS 12.0+
- **Architecture**: ARM64 (iPhone 5s and newer)
- **App Store**: Available for download  
- **iOS Features**: Native navigation, haptics, system fonts

---

## � Usage Guide

### **Getting Started**
1. **Create Your First Habit**: Click the "+" button on the dashboard
2. **Choose Category**: Select from 6 different habit categories
3. **Set Your Goal**: Write a specific, measurable 7-day challenge
4. **Track Daily**: Mark each day as complete when you achieve your goal
5. **Celebrate Success**: Earn badges and continue with new challenges

### **Daily Workflow**
1. **Morning Check-in**: Review your active habits on the dashboard
2. **Progress Tracking**: Mark habits complete throughout the day
3. **Evening Review**: Check your completion ring and prepare for tomorrow

### **Long-term Growth**
1. **Complete 7-Day Cycles**: Focus on one week at a time
2. **Earn Badges**: Celebrate milestones and achievements
3. **Analyze Progress**: Use stats page to identify patterns
4. **Continue or Pivot**: Start new habits or extend successful ones

---

## � Key Benefits

### **Psychology-Based Design**
- **Achievable Goals**: 7-day cycles prevent overwhelming commitments
- **Visual Feedback**: Progress rings and badges provide instant gratification
- **Celebration Focus**: Reward achievements to build positive associations
- **Category Variety**: Support different aspects of personal development

### **Practical Advantages** 
- **No Installation Required**: Works directly in any modern web browser
- **Offline Capable**: All data stored locally for privacy and reliability
- **Cross-Platform**: Responsive design works on desktop, tablet, and mobile
- **Fast Performance**: Lightweight vanilla JavaScript for quick interactions

---

## � Data Management

### **Privacy First**
- **Local Storage**: All data stays on your device using Hive database
- **No Account Required**: Start using immediately without registration  
- **Export Control**: Export data as JSON or CSV formats
- **Cloud Sync**: Optional Google Drive/iCloud backup (coming soon)

### **Data Structure**
```dart
class Habit {
  final String id;
  final String title;
  final HabitCategory category;
  final DateTime startDate;
  final List<bool> progress;
  final bool isCompleted;
  
  Habit({
    required this.id,
    required this.title, 
    required this.category,
    required this.startDate,
    required this.progress,
    this.isCompleted = false,
  });
}

enum HabitCategory {
  health,
  productivity, 
  learning,
  mindfulness,
  creative,
  finance,
}
```

### **Local Database Schema**
```dart
// Hive Database Structure
@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1) 
  String title;
  
  @HiveField(2)
  int category; // enum index
  
  @HiveField(3)
  DateTime startDate;
  
  @HiveField(4)
  List<bool> progress;
}
```

---

## � Achievement Examples

### **Real Habit Ideas**
- **Health**: "Walk 10,000 steps daily", "Drink 8 glasses of water"
- **Productivity**: "No social media during work hours", "Complete daily planning"
- **Learning**: "Read for 30 minutes", "Practice Spanish for 15 minutes"  
- **Mindfulness**: "Meditate for 10 minutes", "Journal before bed"
- **Creative**: "Write 300 words daily", "Take one creative photo"
- **Finance**: "Track all expenses", "Save $10 daily"

---

## � Browser Support

### **Minimum Requirements**
- **Chrome/Edge**: Version 60+
- **Firefox**: Version 55+
- **Safari**: Version 12+
- **Mobile Browsers**: iOS Safari 12+, Chrome Mobile 60+

### **Recommended Features**
- **backdrop-filter**: For glassmorphism effects
- **CSS Custom Properties**: For dynamic theming
- **localStorage**: For data persistence
- **Flexbox/Grid**: For responsive layouts

---

## � Getting Started

### **For Users**

#### **Download**
- **Android**: Download from Google Play Store
- **iOS**: Download from Apple App Store
- **APK**: Direct download from GitHub releases

#### **System Requirements**
- **Android**: 5.0+ (API 21), 100MB storage
- **iOS**: 12.0+, 100MB storage  
- **RAM**: 2GB minimum, 4GB recommended

### **For Developers**

#### **Prerequisites**
```bash
# Install Flutter SDK
flutter --version
# Should be Flutter 3.0.0 or higher

# Install dependencies
flutter doctor
# Ensure Android Studio/Xcode are properly configured
```

#### **Setup**
```bash
# Clone the repository
git clone https://github.com/yourusername/minigoals.git
cd minigoals

# Install dependencies  
flutter pub get

# Generate code (if using build_runner)
flutter packages pub run build_runner build

# Run on Android
flutter run -d android

# Run on iOS  
flutter run -d ios
```

#### **Project Structure**
```
lib/
├── main.dart                 # App entry point
├── core/                     # Core utilities
│   ├── constants/           # App constants
│   ├── theme/              # App theming
│   └── utils/              # Helper functions
├── data/                    # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Data repositories
│   └── services/           # Local services
├── screens/            # UI layer
│   ├── pages/              # App screens
│   ├── widgets/            # Reusable widgets
│   └── providers/          # State management
└── assets/                 # Images, fonts, etc.
```

---

## � Contributing

We welcome contributions to make MiniGoals even better!

### **Development Setup**
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Follow the existing code style and patterns
4. Test on both Android and iOS platforms
5. Submit a pull request with detailed description

### **Areas for Enhancement**
- **Push Notifications**: Advanced scheduling with Flutter Local Notifications
- **Data Visualization**: Charts using FL Chart package
- **Social Features**: Share achievements with friends
- **Habit Templates**: Pre-built popular habit suggestions
- **Widget Support**: Home screen widgets for quick habit tracking
- **Apple Watch/Wear OS**: Companion apps for wearables

### **Code Style**
```dart
// Follow Dart/Flutter conventions
// Use meaningful variable names
// Add documentation for public APIs

/// Creates a new habit with the specified parameters
/// 
/// Returns the created [Habit] instance or null if validation fails
Habit? createHabit({
  required String title,
  required HabitCategory category,
}) {
  // Implementation
}
```

### **Testing**
```bash
# Run unit tests
flutter test

# Run integration tests  
flutter drive --target=test_driver/app.dart

# Check code coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### **Bug Reports**
If you find any issues, please report them with:
- Device model and OS version
- Flutter version used
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots or screen recordings

---

### **Feature Requests**
We love hearing about new ideas! Create an issue with the `enhancement` label to suggest new features.

---

## �️ Build & Release

### **Android Release**
```bash
# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Sign with your keystore
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore app-release.apk alias_name
```

### **iOS Release**  
```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode
# Upload to App Store Connect
# Submit for review
```

---

<div align="center">

**� Start your habit journey today with MiniGoals!**

*Small goals. Big wins. Just 7 days at a time.*

[⬆️ Back to Top](#-minigoals)

</div>