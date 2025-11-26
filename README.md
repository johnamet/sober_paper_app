# Freedom Path - Catholic Recovery App

A Flutter-based mobile application designed to support individuals in their journey to overcome pornography addiction through Catholic spirituality, community support, and daily accountability.

## 🙏 Overview

Freedom Path combines the timeless wisdom of Catholic spirituality with modern recovery support tools. The app features a "sacred journal" aesthetic with paper/parchment colors, handwritten fonts, and spiritual themes to create a contemplative, supportive environment.

### Core Features
- **Daily Sobriety Tracking**: Calendar-based logging with mood and trigger tracking
- **Panic Button System**: Instant connection to sponsors or volunteers during moments of temptation
- **Daily Reflections**: Curated spiritual content with Scripture, prayers, and meditations
- **Community Support**: Chat with sponsors, join prayer groups, and find accountability partners
- **Progress Analytics**: Streak tracking, insights, and milestone celebrations
- **Resource Library**: Catholic prayers, Scripture passages, and recovery resources

## 🎨 Design System

### Sacred Journal Aesthetic
- **Color Palette**: Cream paper (#F4ECD8), parchment white (#FFFEF9), ink black (#2C2416)
- **Spiritual Accents**: Holy blue (#7B9DB4), grace green (#7A9E7E), cross gold (#B8956A)
- **Typography**: 
  - Handwritten headings: Caveat, Kalam
  - Body text: Crimson Text (serif)
- **Visual Elements**: Soft paper shadows, rounded corners, subtle borders

## 🏗️ Architecture

### Technology Stack
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod 2.4+
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging, Storage, Functions)
- **Local Storage**: Hive, SharedPreferences
- **Key Packages**: google_fonts, table_calendar, uuid, url_launcher

### Project Structure
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       # Color palette
│   │   ├── app_text_styles.dart  # Typography system
│   │   ├── app_spacing.dart      # Spacing values
│   │   ├── app_shadows.dart      # Shadow effects
│   │   └── app_strings.dart      # App strings & quotes
│   └── widgets/
│       ├── paper_card.dart       # Reusable card component
│       └── custom_button.dart    # Themed button
├── models/
│   ├── user_model.dart           # User entity
│   ├── sobriety_log_model.dart   # Daily log entry
│   ├── panic_request_model.dart  # Emergency support request
│   └── reflection_model.dart     # Daily reflection
├── screens/
│   ├── home_screen.dart          # Main dashboard
│   ├── panic_modal.dart          # Emergency support modal
│   ├── chat_screen.dart          # Community messaging
│   └── reflections_screen.dart   # Spiritual content
├── services/
│   └── storage_service.dart      # Local storage wrapper
└── main.dart                     # App entry point
```

## 🚀 Getting Started

### Prerequisites
1. **Flutter SDK** (3.0 or higher)
   ```bash
   # Verify installation
   flutter --version
   
   # If not installed, follow: https://flutter.dev/docs/get-started/install
   ```

2. **Firebase Project** (for backend services)
   - Create a project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Create Cloud Firestore database
   - Enable Cloud Messaging for notifications

### Installation

1. **Clone and setup**
   ```bash
   cd /home/johnny/Downloads/sober_paper_app
   flutter pub get
   ```

2. **Configure Firebase**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```
   This will generate `lib/firebase_options.dart` with your project configuration.

3. **Uncomment Firebase initialization in main.dart**
   ```dart
   // In lib/main.dart, uncomment these lines:
   // await Firebase.initializeApp(
   //   options: DefaultFirebaseOptions.currentPlatform,
   // );
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For iOS (requires macOS)
   flutter run
   
   # For specific device
   flutter devices  # List available devices
   flutter run -d <device-id>
   ```

## 📱 Current Implementation Status

### ✅ Completed
- [x] Project structure and organization
- [x] Complete design system (colors, typography, spacing, shadows)
- [x] Core reusable widgets (PaperCard, CustomButton)
- [x] Data models (User, SobrietyLog, PanicRequest, Reflection)
- [x] Main.dart with theme and routing
- [x] Home screen with sobriety counter, daily reflection, quick actions
- [x] Panic modal with breathing exercises and crisis hotline
- [x] pubspec.yaml with all dependencies

### 🚧 In Progress
- [ ] Firebase configuration (firebase_options.dart)
- [ ] Authentication screens (login, register, onboarding)
- [ ] Calendar screen with sobriety tracking
- [ ] Chat/messaging functionality
- [ ] Reflections library screen

### 📋 Planned
- [ ] Community features (sponsors, groups)
- [ ] User profile and settings
- [ ] Repository and service layer implementations
- [ ] Push notifications for daily reflections
- [ ] Milestone celebrations
- [ ] Analytics dashboard
- [ ] Content moderation (Cloud Functions)

## 🔧 Development

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

### Code Quality
```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

## 📚 Key Features Details

### 1. Home Dashboard
- **Sobriety Counter**: Large day counter with encouraging quotes
- **Daily Reflection**: Expandable card with Scripture verse and meditation
- **Quick Actions**: Morning Prayer, Message Sponsor, Journal Entry buttons
- **Streak Summary**: Current streak, longest streak, total clean days
- **Panic Button**: Floating action button for instant support

### 2. Panic Button System
- **Instant Support**: Connect with sponsor or volunteer immediately
- **Breathing Exercises**: Guided breathing with visual timer
- **Jesus Prayer**: Short contemplative prayer for moments of crisis
- **Crisis Hotline**: Direct access to National Suicide Prevention Lifeline
- **Response Time**: Shows wait time for available support

### 3. Sobriety Calendar
- **Daily Logging**: Mark each day as clean or relapse
- **Mood Tracking**: Record emotional state and triggers
- **Visual Streaks**: Green highlights for clean days, visual streak patterns
- **Monthly Insights**: Summary of progress, patterns, and growth areas

### 4. Daily Reflections
- **Scripture**: Daily Bible verses with context
- **Meditation**: Catholic-focused reflections on purity and virtue
- **Prayer**: Guided prayers for strength and healing
- **Saints' Wisdom**: Quotes from saints on chastity and holiness

### 5. Community Features
- **Sponsor Chat**: Direct messaging with assigned sponsor
- **Prayer Groups**: Join groups for prayer intentions and support
- **Volunteer System**: Certified volunteers available for panic requests
- **Anonymous Option**: Option for anonymous participation

## 🛡️ Privacy & Security

- **End-to-End Encryption**: All messages encrypted in transit
- **Anonymous Mode**: Optional anonymous participation
- **Content Moderation**: Cloud Functions for automatic content filtering
- **Data Privacy**: User data stored securely in Firebase with strict access rules
- **Crisis Protocols**: Automatic escalation for high-risk situations

## 📖 Resources

### Catholic Resources
- **Prayers**: Morning offering, Rosary, Divine Mercy Chaplet
- **Scripture**: Curated passages on purity, strength, and redemption
- **Saints**: Lives and wisdom of saints who practiced heroic chastity
- **Sacraments**: Guidance on Confession and Eucharist for healing

### Recovery Resources
- **Integrity Restored**: Catholic pornography recovery program
- **Covenant Eyes**: Accountability software integration
- **Theology of the Body**: St. John Paul II's teaching on human sexuality
- **Crisis Hotlines**: National and Catholic-specific support lines

## 🤝 Contributing

This app is built according to specifications in `build.md`. When contributing:
1. Follow the existing design system and architecture patterns
2. Maintain the sacred journal aesthetic
3. Ensure all new features align with Catholic teaching
4. Test thoroughly on both Android and iOS
5. Update documentation for new features

## 📞 Crisis Support

If you or someone you know is in crisis:
- **National Suicide Prevention Lifeline**: 1-800-273-8255 (24/7)
- **Crisis Text Line**: Text "HELLO" to 741741
- **SAMHSA National Helpline**: 1-800-662-4357

## 📄 License

This project is developed as part of a Catholic recovery initiative. See `build.md` for complete specifications and requirements.

## 🙏 Acknowledgments

Built with inspiration from:
- Catholic teaching on human dignity and sexuality
- 12-step recovery principles
- Modern mental health best practices
- The lives of saints who practiced heroic virtue

---

**Note**: This app is a spiritual tool to support recovery, but it is not a replacement for professional counseling, therapy, or medical treatment. Always seek qualified professional help when needed.

## Next steps (suggested)
- Replace local Hive chat with Firebase for real-time messaging and auth.
- Add moderation & reporting flows.
- Add onboarding, emergency contacts, and notification scheduling.
