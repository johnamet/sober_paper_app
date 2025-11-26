# Freedom Path - Complete Development Specification

> A Catholic-focused recovery app for overcoming pornography addiction with journal aesthetics

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technical Architecture](#technical-architecture)
3. [Design System](#design-system)
4. [Project Structure](#project-structure)
5. [Data Models](#data-models)
6. [Feature Specifications](#feature-specifications)
7. [Implementation Guide](#implementation-guide)
8. [Testing Strategy](#testing-strategy)
9. [Deployment Checklist](#deployment-checklist)

---

## Project Overview

### Purpose
An Android mobile application (with iOS/Web capability via Flutter) designed to help individuals overcome pornography addiction through:
- Sobriety tracking with visual calendar
- Emergency panic button with peer support
- Catholic prayers and daily reflections
- Community support (sponsors and groups)
- Resource library

### Target Users
- Individuals struggling with pornography addiction
- Catholic faith-based recovery community
- Sponsors and volunteers supporting recovery

### Core Values
- **Privacy First**: Anonymous options, secure data
- **Faith-Centered**: Catholic prayers, reflections, spiritual guidance
- **Community Support**: Peer accountability, sponsorship
- **Non-judgmental**: Compassionate approach to relapses
- **Accessible**: Free, always available

---

## Technical Architecture

### Tech Stack

#### Frontend
- **Framework**: Flutter 3.16+ (Dart)
- **State Management**: Riverpod 2.4+
- **Navigation**: Manual routing (or go_router for deep linking)
- **Local Storage**: SharedPreferences for settings, Hive for offline caching

#### Backend
- **Platform**: Firebase
  - **Authentication**: Firebase Auth (Email/Password + Anonymous)
  - **Database**: Cloud Firestore
  - **Storage**: Firebase Storage (for future profile pictures)
  - **Functions**: Cloud Functions for moderation
  - **Messaging**: Firebase Cloud Messaging (FCM)
  - **Realtime**: Firestore real-time listeners

#### Third-Party Services
- **Moderation**: Perspective API (Google) or Sift
- **Push Notifications**: FCM
- **Analytics**: Firebase Analytics (privacy-compliant)
- **Crash Reporting**: Firebase Crashlytics

### Architecture Pattern
**Clean Architecture** with three layers:

1. **Presentation Layer**: UI + State Management (Riverpod providers)
2. **Domain Layer**: Business logic, use cases, entities
3. **Data Layer**: Repositories, models, services (Firebase integration)

### Why This Stack?
- **Flutter**: Single codebase for Android, iOS, Web
- **Firebase**: Real-time capabilities, scalable, quick MVP
- **Riverpod**: Type-safe, testable state management
- **Clean Architecture**: Maintainable, testable, scalable

---

## Design System

### Visual Identity: "Sacred Journal"

The app should feel like a personal spiritual journal - warm, intimate, handwritten, peaceful.

### Color Palette

```dart
class AppColors {
  // Paper/Parchment Tones
  static const Color paperCream = Color(0xFFF4ECD8);      // Main background
  static const Color paperWhite = Color(0xFFFFFEF9);      // Card backgrounds
  static const Color paperEdge = Color(0xFFE8DCC4);       // Borders, dividers
  static const Color paperShadow = Color(0x14000000);     // Soft shadows
  
  // Ink Colors (Text)
  static const Color inkBlack = Color(0xFF2C2416);        // Primary text
  static const Color inkBrown = Color(0xFF5C4A3A);        // Secondary text
  static const Color inkFaded = Color(0xFF9B8B7E);        // Disabled, hints
  static const Color inkLight = Color(0xFFBFB5AA);        // Very subtle text
  
  // Catholic/Spiritual Accents
  static const Color holyBlue = Color(0xFF7B9DB4);        // Primary actions
  static const Color crossGold = Color(0xFFB8956A);       // Highlights, badges
  static const Color prayerPurple = Color(0xFF9B87A6);    // Liturgical accents
  static const Color maryBlue = Color(0xFF5B8FA3);        // Alternative blue
  
  // Functional Colors
  static const Color graceGreen = Color(0xFF7A9E7E);      // Success, clean days
  static const Color panicRed = Color(0xFFC65D4F);        // Urgent, panic button
  static const Color warningAmber = Color(0xFFD4A574);    // Warnings
  static const Color hopeYellow = Color(0xFFE8D4A0);      // Encouragement
  
  // Overlays
  static const Color scrimDark = Color(0x99000000);       // Modal backgrounds
  static const Color scrimLight = Color(0x33000000);      // Light overlays
}
```

**Color Usage Rules**:
- **Backgrounds**: Always use `paperCream` for scaffold, `paperWhite` for cards
- **Text**: `inkBlack` for primary, `inkBrown` for secondary, `inkFaded` for disabled
- **Accents**: Use sparingly - `holyBlue` for primary actions, `crossGold` for achievements
- **Functional**: Reserve `panicRed` only for panic button, `graceGreen` for positive feedback

### Typography

```dart
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Display - Handwritten (for headings, emphasis)
  static TextStyle display1 = GoogleFonts.caveat(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.1,
    letterSpacing: 0.5,
  );
  
  static TextStyle display2 = GoogleFonts.caveat(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.2,
  );
  
  static TextStyle display3 = GoogleFonts.kalam(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.3,
  );
  
  // Headings
  static TextStyle h1 = GoogleFonts.kalam(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.3,
  );
  
  static TextStyle h2 = GoogleFonts.kalam(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBrown,
    height: 1.4,
  );
  
  static TextStyle h3 = GoogleFonts.kalam(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.inkBrown,
    height: 1.4,
  );
  
  // Body - Readable serif (for content)
  static TextStyle bodyLarge = GoogleFonts.crimsonText(
    fontSize: 18,
    color: AppColors.inkBlack,
    height: 1.7,
    letterSpacing: 0.2,
  );
  
  static TextStyle bodyMedium = GoogleFonts.crimsonText(
    fontSize: 16,
    color: AppColors.inkBlack,
    height: 1.6,
    letterSpacing: 0.15,
  );
  
  static TextStyle bodySmall = GoogleFonts.crimsonText(
    fontSize: 14,
    color: AppColors.inkBrown,
    height: 1.5,
  );
  
  // Special Purpose
  static TextStyle prayer = GoogleFonts.crimsonText(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.inkBrown,
    height: 1.8,
    letterSpacing: 0.3,
  );
  
  static TextStyle counter = GoogleFonts.kalam(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.0,
  );
  
  static TextStyle caption = GoogleFonts.crimsonText(
    fontSize: 12,
    color: AppColors.inkFaded,
    height: 1.4,
  );
  
  static TextStyle button = GoogleFonts.kalam(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.paperWhite,
    letterSpacing: 0.5,
  );
}
```

**Typography Rules**:
- **Display/Headings**: Use handwritten fonts (Caveat, Kalam)
- **Body**: Use serif fonts (Crimson Text) for readability
- **Prayer/Quotes**: Always italic, increased line height
- **Counter**: Extra large, bold, handwritten
- **Buttons**: Handwritten for personal touch

### Spacing System

```dart
class AppSpacing {
  // Base unit: 4px
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Specific use cases
  static const double cardPadding = 16.0;
  static const double screenPadding = 20.0;
  static const double sectionSpacing = 24.0;
  static const double listItemSpacing = 12.0;
}
```

### Border Radius

```dart
class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double round = 999.0;  // Fully rounded
}
```

### Shadows

```dart
class AppShadows {
  // Soft paper shadow
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.paperShadow,
      blurRadius: 8,
      offset: Offset(2, 4),
    ),
  ];
  
  // Elevated paper
  static List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.paperShadow,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
  
  // Floating element
  static List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.paperShadow.withOpacity(0.15),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
```

### Icons

**Style**: Use minimal, line-based icons
- **Package**: `lucide_icons` (clean, consistent)
- **Alternative**: Font Awesome (hand-drawn variants)
- **Color**: Always `inkBrown` or `inkBlack`, never colorful unless functional

**Common Icons**:
- Home: `LucideIcons.home`
- Calendar: `LucideIcons.calendar`
- Panic: `LucideIcons.alertCircle` (but custom designed)
- Community: `LucideIcons.users`
- Resources: `LucideIcons.book`
- Profile: `LucideIcons.user`
- Prayer: ✟ (Unicode cross)
- Success: ✓ (hand-drawn check)

---

## Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   ├── app_shadows.dart
│   │   ├── app_strings.dart
│   │   ├── route_constants.dart
│   │   └── firebase_collections.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   ├── utils/
│   │   ├── date_helpers.dart
│   │   ├── validators.dart
│   │   ├── string_extensions.dart
│   │   └── logger.dart
│   │
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   │
│   └── widgets/
│       ├── paper_card.dart
│       ├── handwritten_divider.dart
│       ├── handdrawn_checkbox.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_indicator.dart
│       ├── error_view.dart
│       ├── empty_state.dart
│       └── corner_fold.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── sobriety_log_model.dart
│   │   ├── panic_request_model.dart
│   │   ├── reflection_model.dart
│   │   ├── group_model.dart
│   │   ├── message_model.dart
│   │   ├── sponsorship_model.dart
│   │   └── report_model.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── sobriety_repository.dart
│   │   ├── panic_repository.dart
│   │   ├── community_repository.dart
│   │   ├── reflection_repository.dart
│   │   └── moderation_repository.dart
│   │
│   └── services/
│       ├── firebase_auth_service.dart
│       ├── firestore_service.dart
│       ├── storage_service.dart
│       ├── notification_service.dart
│       ├── moderation_service.dart
│       └── realtime_service.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── sobriety_log.dart
│   │   ├── panic_request.dart
│   │   ├── reflection.dart
│   │   ├── group.dart
│   │   ├── message.dart
│   │   ├── sponsorship.dart
│   │   └── report.dart
│   │
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── register_usecase.dart
│       │   ├── login_anonymously_usecase.dart
│       │   └── logout_usecase.dart
│       │
│       ├── sobriety/
│       │   ├── log_day_usecase.dart
│       │   ├── get_streak_usecase.dart
│       │   ├── get_calendar_data_usecase.dart
│       │   ├── update_sobriety_date_usecase.dart
│       │   └── get_insights_usecase.dart
│       │
│       ├── panic/
│       │   ├── create_panic_request_usecase.dart
│       │   ├── respond_to_panic_usecase.dart
│       │   ├── cancel_panic_request_usecase.dart
│       │   ├── listen_for_panic_requests_usecase.dart
│       │   └── complete_panic_session_usecase.dart
│       │
│       ├── community/
│       │   ├── find_sponsor_usecase.dart
│       │   ├── request_sponsorship_usecase.dart
│       │   ├── accept_sponsorship_usecase.dart
│       │   ├── join_group_usecase.dart
│       │   ├── leave_group_usecase.dart
│       │   ├── send_message_usecase.dart
│       │   ├── get_messages_usecase.dart
│       │   └── report_content_usecase.dart
│       │
│       └── reflection/
│           ├── get_daily_reflection_usecase.dart
│           ├── get_prayers_usecase.dart
│           └── mark_reflection_read_usecase.dart
│
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   ├── sobriety_provider.dart
│   │   ├── panic_provider.dart
│   │   ├── community_provider.dart
│   │   ├── reflection_provider.dart
│   │   └── theme_provider.dart
│   │
│   └── screens/
│       ├── splash/
│       │   └── splash_screen.dart
│       │
│       ├── auth/
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   ├── onboarding_screen.dart
│       │   └── widgets/
│       │       ├── auth_text_field.dart
│       │       └── auth_button.dart
│       │
│       ├── home/
│       │   ├── home_screen.dart
│       │   └── widgets/
│       │       ├── sobriety_counter_card.dart
│       │       ├── daily_reflection_card.dart
│       │       ├── quick_actions_section.dart
│       │       └── streak_badge.dart
│       │
│       ├── calendar/
│       │   ├── calendar_screen.dart
│       │   └── widgets/
│       │       ├── calendar_grid.dart
│       │       ├── calendar_day_cell.dart
│       │       ├── day_detail_card.dart
│       │       ├── mood_selector.dart
│       │       ├── trigger_input.dart
│       │       └── insights_card.dart
│       │
│       ├── panic/
│       │   ├── panic_button_screen.dart
│       │   ├── panic_connecting_screen.dart
│       │   ├── panic_chat_screen.dart
│       │   ├── panic_call_screen.dart
│       │   └── widgets/
│       │       ├── panic_button_widget.dart
│       │       ├── breathing_exercise.dart
│       │       ├── emergency_prayer_card.dart
│       │       ├── connecting_animation.dart
│       │       └── hotline_button.dart
│       │
│       ├── community/
│       │   ├── community_screen.dart
│       │   ├── sponsor_detail_screen.dart
│       │   ├── find_sponsor_screen.dart
│       │   ├── group_list_screen.dart
│       │   ├── group_detail_screen.dart
│       │   ├── group_chat_screen.dart
│       │   ├── create_group_screen.dart
│       │   └── widgets/
│       │       ├── sponsor_card.dart
│       │       ├── group_card.dart
│       │       ├── message_bubble.dart
│       │       ├── celebration_card.dart
│       │       ├── user_list_item.dart
│       │       └── chat_input.dart
│       │
│       ├── resources/
│       │   ├── resources_screen.dart
│       │   ├── reflection_detail_screen.dart
│       │   ├── prayer_library_screen.dart
│       │   ├── prayer_detail_screen.dart
│       │   ├── education_screen.dart
│       │   └── widgets/
│       │       ├── book_spine_card.dart
│       │       ├── resource_card.dart
│       │       ├── prayer_card.dart
│       │       └── bookmark_button.dart
│       │
│       ├── profile/
│       │   ├── profile_screen.dart
│       │   ├── settings_screen.dart
│       │   ├── edit_profile_screen.dart
│       │   ├── privacy_settings_screen.dart
│       │   └── widgets/
│       │       ├── profile_header.dart
│       │       ├── stats_card.dart
│       │       └── settings_item.dart
│       │
│       └── shared/
│           ├── main_navigation.dart
│           └── widgets/
│               ├── custom_app_bar.dart
│               └── bottom_nav_bar.dart
│
└── config/
    ├── routes.dart
    └── firebase_options.dart
```

---

## Data Models

### Firestore Collections Structure

```
users/
  {userId}/
    - displayName: string
    - email: string | null
    - isAnonymous: boolean
    - sobrietyStartDate: timestamp | null
    - sponsorId: string | null
    - isVolunteer: boolean
    - isAvailable: boolean
    - lastActive: timestamp
    - createdAt: timestamp
    - preferences: map
      - notifications: boolean
      - dailyReminderTime: string
    - stats: map
      - longestStreak: number
      - currentStreak: number
      - totalCleanDays: number

sobriety_logs/
  {logId}/
    - userId: string
    - date: timestamp
    - status: string (clean | relapse)
    - mood: string | null
    - triggers: array<string>
    - notes: string | null
    - createdAt: timestamp

panic_requests/
  {requestId}/
    - requesterId: string
    - requesterName: string
    - requesterDayCount: number
    - timestamp: timestamp
    - status: string (pending | active | resolved | cancelled)
    - responderId: string | null
    - responderName: string | null
    - connectionType: string (chat | call)
    - resolvedAt: timestamp | null

sponsorships/
  {sponsorshipId}/
    - sponsorId: string
    - sponsoredUserId: string
    - requestedAt: timestamp
    - acceptedAt: timestamp | null
    - status: string (pending | active | ended)
    - endedAt: timestamp | null
    - endReason: string | null

groups/
  {groupId}/
    - name: string
    - description: string
    - createdBy: string
    - createdAt: timestamp
    - memberIds: array<string>
    - memberCount: number
    - isPrivate: boolean
    - maxMembers: number
    - category: string (support | prayer | discussion)

messages/
  {messageId}/
    - conversationId: string (groupId or userId1_userId2)
    - conversationType: string (group | direct)
    - senderId: string
    - senderName: string
    - content: string
    - timestamp: timestamp
    - flaggedForReview: boolean
    - reviewedAt: timestamp | null
    - deletedAt: timestamp | null

daily_reflections/
  {date}/  (format: YYYY-MM-DD)
    - date: timestamp
    - title: string
    - content: string
    - bibleVerse: string | null
    - verseReference: string | null
    - prayer: string
    - author: string | null
    - createdAt: timestamp

prayers/
  {prayerId}/
    - title: string
    - category: string (morning | evening | rosary | emergency)
    - content: string
    - latinVersion: string | null
    - notes: string | null
    - order: number

reports/
  {reportId}/
    - reportedBy: string
    - reportedUserId: string | null
    - reportedMessageId: string | null
    - reportedGroupId: string | null
    - reason: string
    - description: string
    - status: string (pending | reviewed | action_taken | dismissed)
    - reviewedBy: string | null
    - reviewedAt: timestamp | null
    - createdAt: timestamp
```

### Dart Entity Classes

#### User Entity
```dart
class User {
  final String uid;
  final String displayName;
  final String? email;
  final bool isAnonymous;
  final DateTime? sobrietyStartDate;
  final String? sponsorId;
  final bool isVolunteer;
  final bool isAvailable;
  final DateTime? lastActive;
  final DateTime createdAt;
  final UserPreferences preferences;
  final UserStats stats;

  User({
    required this.uid,
    required this.displayName,
    this.email,
    required this.isAnonymous,
    this.sobrietyStartDate,
    this.sponsorId,
    this.isVolunteer = false,
    this.isAvailable = false,
    this.lastActive,
    required this.createdAt,
    required this.preferences,
    required this.stats,
  });

  int get daysClean {
    if (sobrietyStartDate == null) return 0;
    return DateTime.now().difference(sobrietyStartDate!).inDays;
  }

  bool get hasSponsor => sponsorId != null;
}

class UserPreferences {
  final bool notifications;
  final String? dailyReminderTime;

  UserPreferences({
    this.notifications = true,
    this.dailyReminderTime,
  });
}

class UserStats {
  final int longestStreak;
  final int currentStreak;
  final int totalCleanDays;

  UserStats({
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalCleanDays = 0,
  });
}
```

#### SobrietyLog Entity
```dart
enum SobrietyStatus { clean, relapse }

class SobrietyLog {
  final String id;
  final String userId;
  final DateTime date;
  final SobrietyStatus status;
  final String? mood;
  final List<String> triggers;
  final String? notes;
  final DateTime createdAt;

  SobrietyLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.status,
    this.mood,
    this.triggers = const [],
    this.notes,
    required this.createdAt,
  });

  bool get isClean => status == SobrietyStatus.clean;
  bool get isRelapse => status == SobrietyStatus.relapse;
}
```

#### PanicRequest Entity
```dart
enum PanicStatus { pending, active, resolved, cancelled }
enum ConnectionType { chat, call }

class PanicRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final int requesterDayCount;
  final DateTime timestamp;
  final PanicStatus status;
  final String? responderId;
  final String? responderName;
  final ConnectionType connectionType;
  final DateTime? resolvedAt;

  PanicRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterDayCount,
    required this.timestamp,
    required this.status,
    this.responderId,
    this.responderName,
    required this.connectionType,
    this.resolvedAt,
  });

  bool get isPending => status == PanicStatus.pending;
  bool get isActive => status == PanicStatus.active;
  bool get isResolved => status == PanicStatus.resolved;
  
  Duration get waitTime => DateTime.now().difference(timestamp);
}
```

#### Sponsorship Entity
```dart
enum SponsorshipStatus { pending, active, ended }

class Sponsorship {
  final String id;
  final String sponsorId;
  final String sponsoredUserId;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final SponsorshipStatus status;
  final DateTime? endedAt;
  final String? endReason;

  Sponsorship({
    required this.id,
    required this.sponsorId,
    required this.sponsoredUserId,
    required this.requestedAt,
    this.acceptedAt,
    required this.status,
    this.endedAt,
    this.endReason,
  });

  bool get isPending => status == SponsorshipStatus.pending;
  bool get isActive => status == SponsorshipStatus.active;
  bool get isEnded => status == SponsorshipStatus.ended;
}
```

#### Group Entity
```dart
enum GroupCategory { support, prayer, discussion }

class Group {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final int memberCount;
  final bool isPrivate;
  final int maxMembers;
  final GroupCategory category;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
    required this.memberCount,
    this.isPrivate = false,
    this.maxMembers = 50,
    required this.category,
  });

  bool get isFull => memberCount >= maxMembers;
  bool isMember(String userId) => memberIds.contains(userId);
}
```

#### Message Entity
```dart
enum ConversationType { group, direct }

class Message {
  final String id;
  final String conversationId;
  final ConversationType conversationType;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool flaggedForReview;
  final DateTime? reviewedAt;
  final DateTime? deletedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.conversationType,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.flaggedForReview = false,
    this.reviewedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  bool get needsReview => flaggedForReview && reviewedAt == null;
  bool get isGroup => conversationType == ConversationType.group;
}
```

#### Reflection Entity
```dart
class DailyReflection {
  final String date; // YYYY-MM-DD
  final String title;
  final String content;
  final String? bibleVerse;
  final String? verseReference;
  final String prayer;
  final String? author;
  final DateTime createdAt;

  DailyReflection({
    required this.date,
    required this.title,
    required this.content,
    this.bibleVerse,
    this.verseReference,
    required this.prayer,
    this.author,
    required this.createdAt,
  });

  bool get hasVerseReference => verseReference != null;
}
```

#### Prayer Entity
```dart
enum PrayerCategory { morning, evening, rosary, emergency, liturgy }

class Prayer {
  final String id;
  final String title;
  final PrayerCategory category;
  final String content;
  final String? latinVersion;
  final String? notes;
  final int order;

  Prayer({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.latinVersion,
    this.notes,
    required this.order,
  });

  bool get hasLatinVersion => latinVersion != null;
}
```

---

## Feature Specifications

### 1. Authentication System

#### 1.1 User Registration (Full Profile)
**Screen**: `RegisterScreen`

**Requirements**:
- Email validation (must be valid email format)
- Password strength (min 8 chars, 1 uppercase, 1 number)
- Display name (3-30 characters, alphanumeric + spaces)
- Accept terms and conditions
- Option to set sobriety start date immediately

**Flow**:
1. User enters email, password, display name
2. Validate inputs (show errors inline)
3. Create Firebase Auth account
4. Create Firestore user document
5. Navigate to onboarding screen

**Validation Rules**:
```dart
// Email
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}).hasMatch(email);
}

// Password
bool isValidPassword(String password) {
  if (password.length < 8) return false;
  if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
  if (!RegExp(r'[0-9]').hasMatch(password)) return false;
  return true;
}

// Display Name
bool isValidDisplayName(String name) {
  if (name.trim().length < 3 || name.trim().length > 30) return false;
  return RegExp(r'^[a-zA-Z0-9\s]+).hasMatch(name);
}
```

**Error Messages**:
- "Please enter a valid email address"
- "Password must be at least 8 characters with 1 uppercase letter and 1 number"
- "Display name must be between 3-30 characters"

#### 1.2 Anonymous Login
**Screen**: `LoginScreen`

**Requirements**:
- One-tap anonymous login
- Generate random display name (e.g., "Anonymous_1234")
- Explain limitations (no cross-device sync until upgrade)
- Allow upgrade to full account later

**Flow**:
1. User taps "Continue Anonymously"
2. Show modal: "Anonymous accounts can't be recovered if you lose this device. Continue?"
3. Create Firebase anonymous auth
4. Create Firestore user document with `isAnonymous: true`
5. Navigate to onboarding

**Generated Display Name Format**:
```dart
String generateAnonymousName() {
  final random = Random();
  final number = random.nextInt(9999);
  return 'Anonymous_${number.toString().padLeft(4, '0')}';
}
```

#### 1.3 Login (Existing Users)
**Screen**: `LoginScreen`

**Requirements**:
- Email and password fields
- "Forgot password" link
- "Remember me" option (optional)
- Error handling for wrong credentials

**Flow**:
1. User enters email and password
2. Validate format (not empty)
3. Call Firebase Auth signIn
4. If successful, navigate to home
5. If error, show appropriate message

**Error Messages**:
- "Invalid email or password"
- "Account not found"
- "Too many attempts. Please try again later"

#### 1.4 Onboarding
**Screen**: `OnboardingScreen`

**Purpose**: Set up sobriety tracking and explain app features

**Steps**:
1. **Welcome**: "Welcome to Freedom Path. Let's begin your recovery journey."
2. **Set Sobriety Date**: 
   - "When did you last struggle?" (date picker)
   - Or "I'm starting today" button
   - Or "Skip for now" (can set later)
3. **Features Tour**:
   - Sobriety calendar
   - Panic button
   - Community support
   - Daily reflections
4. **Notifications Permission**: "Stay encouraged with daily reflections"
5. **Volunteer Option**: "Want to help others in crisis? Become a volunteer responder"

**Skip Logic**:
- Can skip sobriety date (set later in profile)
- Can skip volunteer signup
- Cannot skip notifications permission request (but can deny)

---

### 2. Home Dashboard

#### 2.1 Layout Structure
**Screen**: `HomeScreen`

**Components** (Top to Bottom):
1. App Bar (profile icon, notifications bell)
2. Sobriety Counter Card (large, centered)
3. Daily Reflection Card (expandable)
4. Quick Actions Section (3 buttons)
5. Streak Summary

#### 2.2 Sobriety Counter Card

**Design**:
```
╔═══════════════════════════╗
║                           ║
║       ✟ Day 47 ✟         ║  ← Handwritten font, large
║   "Stay strong in faith"  ║  ← Random encouraging quote
║                           ║
║   🔥 Current: 47 days     ║  ← Badge style
║   📿 Best: 62 days        ║  ← Badge style
║                           ║
╚═══════════════════════════╝
```

**Logic**:
- Calculate `daysClean` from `sobrietyStartDate`
- If no start date set, show "Set your sobriety date" button
- Show random encouraging quote from predefined list
- Display current streak and longest streak

**Encouraging Quotes** (rotate daily):
```dart
final List<String> encouragingQuotes = [
  "Stay strong in faith",
  "God is with you",
  "One day at a time",
  "You are not alone",
  "Progress, not perfection",
  "Christ strengthens me",
  "Grace upon grace",
  "Victory through prayer",
];
```

#### 2.3 Daily Reflection Card

**Design**:
```
┌────────────────────────────┐
│ Today's Reflection         │
│ ───────────────            │
│                            │
│ "The Lord is my shepherd;  │
│  I shall not want..."      │
│                            │
│ - Psalm 23:1               │
│                            │
│         [Read More ↓]      │
└────────────────────────────┘
```

**States**:
- **Collapsed**: Show title + first 2 lines + "Read More"
- **Expanded**: Show full reflection + prayer + "Close"

**Logic**:
- Fetch today's reflection on load (from Firestore or cache)
- If not available, show placeholder: "Today's reflection will be available soon"
- Cache for offline access

**Tap Behavior**:
- Tap card to expand/collapse
- Tap "Read More" to navigate to full screen with prayer included

#### 2.4 Quick Actions Section

**Buttons**:
1. **📖 Morning Prayer** → Navigate to prayer library (filtered: morning)
2. **💬 Message Sponsor** → Navigate to sponsor chat (if has sponsor) or "Find Sponsor" screen
3. **✍️ Journal Entry** → Navigate to calendar screen (today's log)

**Button Style**:
- Paper card style
- Handwritten font
- Icon + text horizontally arranged
- Subtle tap effect (scale down slightly)

#### 2.5 Streak Summary

**Design**:
```
Current Streak: 🔥 47 days
Longest Streak: 🏆 62 days
Total Clean Days: 🌟 156 days
```

**Display Rules**:
- Only show if sobriety date is set
- Animate numbers when updated
- Use emojis for visual interest

---

### 3. Calendar & Sobriety Tracking

#### 3.1 Calendar Screen Layout
**Screen**: `CalendarScreen`

**Components**:
1. Month navigation (← November 2025 →)
2. Calendar grid (7x5 or 7x6)
3. Selected day detail card
4. Monthly insights summary

#### 3.2 Calendar Grid

**Design**:
- Days of week header (Mo, Tu, We, Th, Fr, Sa, Su)
- Each cell shows:
  - Day number (handwritten font)
  - Status indicator: ✓ (clean), ✗ (relapse), ○ (no log)
- Current day has circle border
- Selected day has filled background

**Color Coding**:
- Clean day: `graceGreen` checkmark
- Relapse day: `panicRed` X
- No log: `inkFaded` circle
- Today: Border in `holyBlue`
- Selected: Background in `paperEdge`

**Interaction**:
- Tap any day to show detail card
- Future days: Show "You can't log future days"
- Past days: Show log or "No entry yet"

#### 3.3 Day Detail Card

**Design**:
```
┌──────────────────────────┐
│ November 19, 2025        │
│ ─────────────            │
│                          │
│ Status: ✓ Clean Day      │
│                          │
│ 🌤️ Mood: Peaceful        │
│                          │
│ Triggers: None           │
│                          │
│ Notes:                   │
│ "Had a good day. Prayed  │
│  the Rosary in morning." │
│                          │
│ [✏️ Edit] [🗑️ Delete]    │
└──────────────────────────┘
```

**States**:
- **No Log**: Show "Add Entry" form
- **Existing Log**: Show read-only details + Edit/Delete buttons
- **Editing**: Show form with pre-filled data

**Form Fields**:
1. **Status**: Toggle buttons (Clean / Relapse)
   - Default: Clean
   - Non-judgmental language for relapse
2. **Mood**: Dropdown or emoji picker
   - Options: Peaceful, Joyful, Grateful, Struggling, Tempted, Sad, Angry
3. **Triggers**: Multi-select chips
   - Common: Stress, Boredom, Loneliness, Anger, Fatigue, Social Media
   - Custom: "Add custom trigger"
4. **Notes**: Multi-line text field (optional)
   - Placeholder: "How are you feeling today? What helped you stay strong?"
   - Max 500 characters

**Validation**:
- Must select status
- Mood, triggers, notes are optional

**Save Logic**:
```dart
Future<void> saveSobrietyLog() async {
  final log = SobrietyLog(
    id: uuid.v4(),
    userId: currentUser.uid,
    date: selectedDate,
    status: selectedStatus,
    mood: selectedMood,
    triggers: selectedTriggers,
    notes: notesController.text.trim(),
    createdAt: DateTime.now(),
  );
  
  await sobrietyRepository.saveLog(log);
  
  // Update user stats if needed
  await updateStreakStats();
}
```

#### 3.4 Monthly Insights

**Design**:
```
📊 This Month:
• 27 clean days ✓
• 3 relapses noted
• Common trigger: Stress
• Best day streak: 12 days
```

**Calculations**:
- Count clean vs relapse days
- Identify most common triggers
- Calculate longest streak in month
- Show encouraging message based on progress

**Encouraging Messages**:
- 90%+ clean: "Outstanding month! Keep going!"
- 70-89% clean: "Great progress! You're doing well."
- 50-69% clean: "Keep fighting. Every day counts."
- <50% clean: "Don't give up. Reach out for support."

---

### 4. Panic Button System

#### 4.1 Panic Button Screen
**Screen**: `PanicButtonScreen`

**Design Philosophy**: 
- Immediate, single-screen access
- Large, obvious button
- Calming elements while waiting
- Clear fallback options

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  Need Support Right Now?    │  ← Empathetic header
│                             │
│      ┏━━━━━━━━━━━┓          │
│      ┃           ┃          │
│      ┃    🆘     ┃          │  ← Large button
│      ┃   PANIC   ┃          │  ← Wax seal aesthetic
│      ┃           ┃          │
│      ┗━━━━━━━━━━━┛          │
│                             │
│   ✍️ While you wait...       │
│                             │
│   • Breathe in... 1, 2, 3   │  ← Breathing guide
│   • Breathe out... 1, 2, 3  │
│                             │
│   ✟ Quick Prayer ✟          │
│                             │
│   "Lord Jesus Christ,       │  ← Short prayer
│    have mercy on me."       │
│                             │
│   ─────────────────         │
│   [☎️ Call Hotline Instead] │  ← Always visible
│                             │
└─────────────────────────────┘
```

**Button States**:
- **Default**: Red, pulsing glow animation
- **Pressed**: Scales down, haptic feedback
- **Connecting**: Disabled, shows spinner

#### 4.2 Panic Request Flow

**Step 1: User Presses Panic Button**

```dart
Future<void> onPanicButtonPressed() async {
  // Haptic feedback
  HapticFeedback.heavyImpact();
  
  // Create panic request
  final request = PanicRequest(
    id: uuid.v4(),
    requesterId: currentUser.uid,
    requesterName: currentUser.displayName,
    requesterDayCount: currentUser.daysClean,
    timestamp: DateTime.now(),
    status: PanicStatus.pending,
    connectionType: ConnectionType.chat, // Default
  );
  
  // Save to Firestore
  await panicRepository.createRequest(request);
  
  // Navigate to connecting screen
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => PanicConnectingScreen(requestId: request.id),
  ));
  
  // Send push notification to all available volunteers
  await notificationService.notifyAvailableVolunteers(request);
}
```

**Step 2: Connecting Screen**

**Screen**: `PanicConnectingScreen`

**Design**:
```
┌─────────────────────────────┐
│  🔄 Connecting you...        │
│                             │
│  Finding available support  │
│                             │
│  [Loading animation]        │
│                             │
│  🙏 Pray with me:           │
│  "Lord Jesus Christ,        │
│   have mercy on me,         │
│   a sinner."                │
│                             │
│  ───────────────            │
│                             │
│  No response yet?           │
│  [Call Crisis Hotline]      │
│  [Cancel Request]           │
│                             │
└─────────────────────────────┘
```

**Logic**:
```dart
class PanicConnectingScreen extends ConsumerWidget {
  final String requestId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to panic request status in real-time
    final requestStream = ref.watch(
      panicRequestStreamProvider(requestId)
    );
    
    return requestStream.when(
      data: (request) {
        if (request.status == PanicStatus.active) {
          // Someone responded! Navigate to chat
          return PanicChatScreen(
            requestId: requestId,
            responderId: request.responderId!,
          );
        } else if (request.status == PanicStatus.cancelled) {
          // User cancelled, go back
          Navigator.pop(context);
        }
        
        // Still pending, show connecting UI
        return _buildConnectingUI(request);
      },
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

**Timeout Logic**:
- After 30 seconds with no response:
  - Show more prominent "Call Hotline" button
  - Show message: "Our volunteers are currently busy. Please call the crisis hotline for immediate support."
- After 2 minutes:
  - Auto-cancel request
  - Show modal with hotline number
  - Log analytics event for monitoring

**Step 3: Volunteer Receives Notification**

**Notification**:
- **Title**: "Someone needs support right now"
- **Body**: "Anonymous (Day 47) is requesting help"
- **Actions**: "Respond" | "Dismiss"
- **Sound**: Urgent but not alarming
- **Priority**: High (bypass Do Not Disturb on Android)

**Volunteer Responding**:
```dart
Future<void> respondToPanicRequest(String requestId) async {
  // Check if request is still pending
  final request = await panicRepository.getRequest(requestId);
  
  if (request.status != PanicStatus.pending) {
    // Someone else already responded
    showSnackbar('This request has already been answered');
    return;
  }
  
  // Claim the request
  await panicRepository.updateRequest(requestId, {
    'status': PanicStatus.active,
    'responderId': currentUser.uid,
    'responderName': currentUser.displayName,
  });
  
  // Navigate to chat
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => PanicChatScreen(
      requestId: requestId,
      responderId: currentUser.uid,
    ),
  ));
  
  // Send notification to requester
  await notificationService.notifyRequester(request.requesterId);
}
```

#### 4.3 Panic Chat Screen

**Screen**: `PanicChatScreen`

**Design**: Standard chat interface with:
- Messages (bubbles)
- Text input at bottom
- "End Session" button (for both parties)
- Timer showing session duration

**Safety Features**:
1. **No Images/Files**: Text only
2. **Content Filtering**: Auto-flag inappropriate messages
3. **Emergency Exit**: "Report & Block" button
4. **Auto-end**: Session ends after 30 min of inactivity

**Message Structure**:
```dart
class PanicChatMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;
  
  // System messages for events
  final bool isSystemMessage;
}
```

**System Messages**:
- "John joined the conversation"
- "This session will end in 5 minutes due to inactivity"
- "Session ended. Take care!"

**End Session Logic**:
```dart
Future<void> endPanicSession(String requestId) async {
  await panicRepository.updateRequest(requestId, {
    'status': PanicStatus.resolved,
    'resolvedAt': FieldValue.serverTimestamp(),
  });
  
  // Show feedback modal
  showDialog(
    context: context,
    builder: (_) => ThankYouDialog(
      message: 'Thank you for reaching out. You are not alone.',
    ),
  );
  
  // Navigate back to home
  Navigator.popUntil(context, (route) => route.isFirst);
}
```

#### 4.4 Crisis Hotline Integration

**Always Available Button**: Links to crisis resources

**Content**:
```
Emergency Crisis Hotline
📞 1-800-XXX-XXXX (24/7)

Or text "HELP" to XXXXX

You can also:
• Call local emergency: 911
• Crisis text line: Text HOME to 741741
• Find confessor nearby
```

**Implementation**:
```dart
void callCrisisHotline() async {
  const phoneNumber = 'tel:1-800-XXX-XXXX';
  if (await canLaunchUrl(Uri.parse(phoneNumber))) {
    await launchUrl(Uri.parse(phoneNumber));
  } else {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Crisis Hotline'),
        content: Text('Please call: 1-800-XXX-XXXX'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

### 5. Community Features

#### 5.1 Community Screen Layout
**Screen**: `CommunityScreen`

**Sections** (scrollable):
1. My Sponsor Card
2. My Groups List
3. Community Feed (milestones/celebrations)
4. Find Sponsor Button
5. Browse Groups Button

#### 5.2 Sponsorship System

**Finding a Sponsor**:

**Screen**: `FindSponsorScreen`

**Design**:
```
┌─────────────────────────────┐
│  Find Your Sponsor          │
│  ═══════════════            │
│                             │
│  A sponsor is someone with  │
│  experience who will guide  │
│  and support your journey.  │
│                             │
│  ┌────────────────────────┐ │
│  │ 👤 Michael (Day 365)   │ │
│  │ Sponsor for 2 years    │ │
│  │ "Here to help..."      │ │
│  │ [Request Sponsorship]  │ │
│  └────────────────────────┘ │
│                             │
│  ┌────────────────────────┐ │
│  │ 👤 David (Day 500)     │ │
│  │ Sponsor for 1 year     │ │
│  │ "Walking with Christ"  │ │
│  │ [Request Sponsorship]  │ │
│  └────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

**Requirements to Become a Sponsor**:
- Minimum 90 days clean
- Opt-in as volunteer
- Complete brief training (read guidelines)

**Sponsor Matching Criteria**:
- Available sponsors (not at max sponsees)
- Active in last 7 days
- Similar age group (optional filter)
- Same timezone (optional filter)

**Request Flow**:
```dart
Future<void> requestSponsorship(String sponsorId) async {
  // Check if user already has pending/active sponsorship
  final existing = await communityRepository.getUserSponsorship(currentUser.uid);
  if (existing != null && existing.status != SponsorshipStatus.ended) {
    showSnackbar('You already have a sponsor request or active sponsor');
    return;
  }
  
  final sponsorship = Sponsorship(
    id: uuid.v4(),
    sponsorId: sponsorId,
    sponsoredUserId: currentUser.uid,
    requestedAt: DateTime.now(),
    status: SponsorshipStatus.pending,
  );
  
  await communityRepository.createSponsorship(sponsorship);
  
  // Notify sponsor
  await notificationService.notifySponsorRequest(sponsorId, currentUser);
  
  showDialog(
    context: context,
    builder: (_) => SuccessDialog(
      message: 'Request sent! You will be notified when they respond.',
    ),
  );
}
```

**Sponsor Accepting Request**:
```dart
Future<void> acceptSponsorshipRequest(String sponsorshipId) async {
  await communityRepository.updateSponsorship(sponsorshipId, {
    'status': SponsorshipStatus.active,
    'acceptedAt': FieldValue.serverTimestamp(),
  });
  
  // Notify sponsored user
  final sponsorship = await communityRepository.getSponsorship(sponsorshipId);
  await notificationService.notifySponsorshipAccepted(
    sponsorship.sponsoredUserId
  );
}
```

**My Sponsor Card** (on Community Screen):

**Design**:
```
┌──────────────────────────┐
│ 📨 My Sponsor            │
│                          │
│ Michael (Day 365)        │
│ "Keep going, brother!"   │
│                          │
│ [💬 Message] [📞 Call]   │
└──────────────────────────┘
```

**If No Sponsor**:
```
┌──────────────────────────┐
│ 📨 Sponsor               │
│                          │
│ You don't have a sponsor │
│ yet. A sponsor provides  │
│ guidance and support.    │
│                          │
│ [Find a Sponsor]         │
└──────────────────────────┘
```

#### 5.3 Group System

**Group Types**:
1. **Support Groups**: Daily check-ins, accountability
2. **Prayer Groups**: Rosary, liturgy of hours
3. **Discussion Groups**: Topics, questions, sharing

**Group List** (on Community Screen):

**Design**:
```
My Groups:
• Daily Check-ins (12) 💬 2
• Young Adults (24)
• Evening Rosary (8)

[+ Join a Group]
```

**Number badges**: Unread message count

**Browse Groups Screen**:

**Screen**: `GroupListScreen`

**Design**:
```
┌─────────────────────────────┐
│  Browse Groups              │
│  [Search groups...]         │
│                             │
│  ┌────────────────────────┐ │
│  │ 🙏 Daily Check-ins     │ │
│  │ Support • 12 members   │ │
│  │ "Share daily progress" │ │
│  │ [Join Group]           │ │
│  └────────────────────────┘ │
│                             │
│  ┌────────────────────────┐ │
│  │ 📿 Evening Rosary      │ │
│  │ Prayer • 8 members     │ │
│  │ "Pray together at 8PM" │ │
│  │ [Join Group]           │ │
│  └────────────────────────┘ │
│                             │
│  [+ Create New Group]       │
└─────────────────────────────┘
```

**Join Group Logic**:
```dart
Future<void> joinGroup(String groupId) async {
  final group = await communityRepository.getGroup(groupId);
  
  // Check if group is full
  if (group.isFull) {
    showSnackbar('This group is full');
    return;
  }
  
  // Check if already a member
  if (group.isMember(currentUser.uid)) {
    showSnackbar('You are already a member');
    return;
  }
  
  // Add user to group
  await communityRepository.joinGroup(groupId, currentUser.uid);
  
  // Send system message
  await communityRepository.sendMessage(Message(
    id: uuid.v4(),
    conversationId: groupId,
    conversationType: ConversationType.group,
    senderId: 'system',
    senderName: 'System',
    content: '${currentUser.displayName} joined the group',
    timestamp: DateTime.now(),
  ));
  
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => GroupChatScreen(groupId: groupId),
  ));
}
```

**Group Chat Screen**:

**Screen**: `GroupChatScreen`

**Design**: Standard group chat
- Group name in app bar
- Member count "(12 members)"
- Message list (newest at bottom)
- Text input with send button
- Options menu: View members, Leave group, Report

**Message Features**:
- Show sender name + message
- Timestamp (group by date)
- Own messages right-aligned
- Others' messages left-aligned
- System messages centered (joins, leaves)

**Moderation**:
- Auto-filter profanity/explicit content
- Flag suspicious links
- "Report message" on long-press
- Moderators can delete messages

#### 5.4 Community Feed (Celebrations)

**Design**:
```
Recent Victories 🎉

┌──────────────────────────┐
│ John reached Day 30!     │
│ "Deo gratias! 🙏"        │
│                          │
│ 👏 12  💬 3              │
└──────────────────────────┘

┌──────────────────────────┐
│ Maria completed 90 days! │
│ "All glory to God!"      │
│                          │
│ 👏 24  💬 7              │
└──────────────────────────┘
```

**What Gets Posted**:
- Milestone days (7, 14, 30, 60, 90, 180, 365)
- User opts-in to share
- Can add optional message

**Posting Logic**:
```dart
// Triggered when logging a clean day that hits milestone
Future<void> checkForMilestone(int daysClean) async {
  final milestones = [7, 14, 30, 60, 90, 180, 365];
  
  if (milestones.contains(daysClean)) {
    showDialog(
      context: context,
      builder: (_) => MilestoneDialog(
        days: daysClean,
        onShare: (message) async {
          await communityRepository.postCelebration(Celebration(
            id: uuid.v4(),
            userId: currentUser.uid,
            userName: currentUser.displayName,
            dayCount: daysClean,
            message: message,
            timestamp: DateTime.now(),
          ));
        },
      ),
    );
  }
}
```

**Reactions**:
- Clap emoji (👏) only
- Comment with encouragement
- No negative reactions

---

### 6. Resources & Daily Content

#### 6.1 Resources Screen Layout
**Screen**: `ResourcesScreen`

**Design**: Library aesthetic with book spines

```
┌─────────────────────────────┐
│  📚 Spiritual Library        │
│  ═══════════════════        │
│                             │
│  [Search in books...]       │
│                             │
│  ┌──────┐ ┌──────┐ ┌──────┐│
│  │Today'││Mornin││Rosary││
│  │Reflec││Prayer││Guide ││
│  │tion  ││  s   ││      ││
│  │  📖  ││  🙏  ││  📿  ││
│  └──────┘ └──────┘ └──────┘│
│                             │
│  ┌──────┐ ┌──────┐ ┌──────┐│
│  │Psalms││Liturg││Educat││
│  │  of  ││  y   ││ ion  ││
│  │Comfor││Hours ││      ││
│  │  ✟   ││  ⛪  ││  🎓  ││
│  └──────┘ └──────┘ └──────┘│
│                             │
│  📖 Today's Reading:        │
│  ┌──────────────────────┐  │
│  │ "Blessed are the pure│  │
│  │  in heart..."        │  │
│  │  - Matthew 5:8   [🔖]│  │
│  └──────────────────────┘  │
│                             │
│  🆘 Emergency Support       │
│  ☎️  Crisis Hotline         │
│  ✟  Find a Confessor        │
│                             │
└─────────────────────────────┘
```

**Book Spine Cards** (clickable):
- Vertical text
- Icon at bottom
- Tap to open category

#### 6.2 Daily Reflections

**Reflection Structure**:
- Title (theme for the day)
- Opening quote or Bible verse
- Reflection paragraph (200-400 words)
- Closing prayer


# Freedom Path - Implementation Guide

## Phase 1: Project Setup (Week 1)

### Day 1: Flutter Project Initialization

```bash
# Create Flutter project
flutter create freedom_path
cd freedom_path

# Add to pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_messaging: ^14.7.0
  firebase_storage: ^11.5.0
  
  # UI
  google_fonts: ^6.1.0
  lucide_icons: ^0.1.0
  cached_network_image: ^3.3.0
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.2.0
  url_launcher: ^6.2.0
  
  # Local Storage
  shared_preferences: ^2.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Notifications
  flutter_local_notifications: ^16.2.0
  
  # HTTP
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  hive_generator: ^2.0.0

# Run
flutter pub get
```

### Day 2: Firebase Setup

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com
   - Create new project "Freedom Path"
   - Enable Google Analytics (optional)

2. **Add Android App**:
   - Package name: `com.freedompath.app`
   - Download `google-services.json`
   - Place in `android/app/`

3. **Add iOS App** (for future):
   - Bundle ID: `com.freedompath.app`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/`

4. **Enable Firebase Services**:
   - Authentication: Enable Email/Password + Anonymous
   - Firestore: Create database (start in test mode, change later)
   - Storage: Enable
   - Cloud Messaging: Enable

5. **Initialize FlutterFire CLI**:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### Day 3: Project Structure Setup

Create the folder structure as defined in the main specification:

```bash
# Core folders
mkdir -p lib/core/{constants,theme,utils,errors,widgets}
mkdir -p lib/data/{models,repositories,services}
mkdir -p lib/domain/{entities,usecases}
mkdir -p lib/presentation/{providers,screens}
mkdir -p lib/config

# Feature screens
mkdir -p lib/presentation/screens/{splash,auth,home,calendar,panic,community,resources,profile}
mkdir -p lib/presentation/screens/shared
```

### Day 4-5: Core Setup

#### 1. Create `lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Paper/Parchment Tones
  static const Color paperCream = Color(0xFFF4ECD8);
  static const Color paperWhite = Color(0xFFFFFEF9);
  static const Color paperEdge = Color(0xFFE8DCC4);
  static const Color paperShadow = Color(0x14000000);
  
  // Ink Colors
  static const Color inkBlack = Color(0xFF2C2416);
  static const Color inkBrown = Color(0xFF5C4A3A);
  static const Color inkFaded = Color(0xFF9B8B7E);
  static const Color inkLight = Color(0xFFBFB5AA);
  
  // Catholic/Spiritual Accents
  static const Color holyBlue = Color(0xFF7B9DB4);
  static const Color crossGold = Color(0xFFB8956A);
  static const Color prayerPurple = Color(0xFF9B87A6);
  static const Color maryBlue = Color(0xFF5B8FA3);
  
  // Functional
  static const Color graceGreen = Color(0xFF7A9E7E);
  static const Color panicRed = Color(0xFFC65D4F);
  static const Color warningAmber = Color(0xFFD4A574);
  static const Color hopeYellow = Color(0xFFE8D4A0);
  
  // Overlays
  static const Color scrimDark = Color(0x99000000);
  static const Color scrimLight = Color(0x33000000);
}
```

#### 2. Create `lib/core/constants/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display
  static TextStyle display1 = GoogleFonts.caveat(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.1,
  );
  
  static TextStyle display2 = GoogleFonts.caveat(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.2,
  );
  
  // Headings
  static TextStyle h1 = GoogleFonts.kalam(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.3,
  );
  
  static TextStyle h2 = GoogleFonts.kalam(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBrown,
    height: 1.4,
  );
  
  // Body
  static TextStyle bodyLarge = GoogleFonts.crimsonText(
    fontSize: 18,
    color: AppColors.inkBlack,
    height: 1.7,
  );
  
  static TextStyle bodyMedium = GoogleFonts.crimsonText(
    fontSize: 16,
    color: AppColors.inkBlack,
    height: 1.6,
  );
  
  static TextStyle bodySmall = GoogleFonts.crimsonText(
    fontSize: 14,
    color: AppColors.inkBrown,
    height: 1.5,
  );
  
  // Special
  static TextStyle prayer = GoogleFonts.crimsonText(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.inkBrown,
    height: 1.8,
  );
  
  static TextStyle counter = GoogleFonts.kalam(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.0,
  );
  
  static TextStyle button = GoogleFonts.kalam(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
```

#### 3. Create `lib/core/constants/app_spacing.dart`

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  static const double cardPadding = 16.0;
  static const double screenPadding = 20.0;
  static const double sectionSpacing = 24.0;
  static const double listItemSpacing = 12.0;
}

class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double round = 999.0;
}
```

#### 4. Create `lib/core/constants/app_shadows.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.paperShadow,
      blurRadius: 8,
      offset: Offset(2, 4),
    ),
  ];
  
  static List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.paperShadow,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.paperShadow.withOpacity(0.15),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
```

#### 5. Create `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  static ThemeData journalTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paperCream,
    
    colorScheme: ColorScheme.light(
      primary: AppColors.holyBlue,
      secondary: AppColors.crossGold,
      error: AppColors.panicRed,
      background: AppColors.paperCream,
      surface: AppColors.paperWhite,
    ),
    
    textTheme: TextTheme(
      displayLarge: AppTextStyles.display1,
      displayMedium: AppTextStyles.display2,
      headlineMedium: AppTextStyles.h1,
      headlineSmall: AppTextStyles.h2,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.inkBrown),
      titleTextStyle: AppTextStyles.h2,
    ),
    
    cardTheme: CardTheme(
      color: AppColors.paperWhite,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.paperEdge, width: 1),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.holyBlue,
        foregroundColor: AppColors.paperWhite,
        textStyle: AppTextStyles.button,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paperWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.paperEdge),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.paperEdge),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.holyBlue, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
```

#### 6. Create `lib/core/constants/firebase_collections.dart`

```dart
class FirebaseCollections {
  static const String users = 'users';
  static const String sobrietyLogs = 'sobriety_logs';
  static const String panicRequests = 'panic_requests';
  static const String sponsorships = 'sponsorships';
  static const String groups = 'groups';
  static const String messages = 'messages';
  static const String dailyReflections = 'daily_reflections';
  static const String prayers = 'prayers';
  static const String reports = 'reports';
  static const String celebrations = 'celebrations';
}
```

#### 7. Create `lib/core/constants/route_constants.dart`

```dart
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String panic = '/panic';
  static const String panicConnecting = '/panic/connecting';
  static const String panicChat = '/panic/chat';
  static const String community = '/community';
  static const String findSponsor = '/community/find-sponsor';
  static const String groupList = '/community/groups';
  static const String groupChat = '/community/groups/chat';
  static const String resources = '/resources';
  static const String reflectionDetail = '/resources/reflection';
  static const String prayerLibrary = '/resources/prayers';
  static const String profile = '/profile';
  static const String settings = '/profile/settings';
  static const String editProfile = '/profile/edit';
}
```

#### 8. Create `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

#### 9. Create `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freedom Path',
      theme: AppTheme.journalTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
```

---

## Phase 2: Core Widgets (Week 2)

### Custom Widgets

#### 1. `lib/core/widgets/paper_card.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';

class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool hasCornerFold;
  final VoidCallback? onTap;

  const PaperCard({
    Key? key,
    required this.child,
    this.padding,
    this.hasCornerFold = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paperWhite,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadows.card,
          border: Border.all(
            color: AppColors.paperEdge,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
            if (hasCornerFold) _buildCornerFold(),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerFold() {
    return Positioned(
      top: 0,
      right: 0,
      child: CustomPaint(
        size: Size(20, 20),
        painter: CornerFoldPainter(),
      ),
    );
  }
}

class CornerFoldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.paperEdge
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - size.width / 2, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

#### 2. `lib/core/widgets/handwritten_divider.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HandwrittenDivider extends StatelessWidget {
  final double height;
  final Color? color;

  const HandwrittenDivider({
    Key? key,
    this.height = 2,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: SketchyLinePainter(color: color ?? AppColors.inkFaded),
    );
  }
}

class SketchyLinePainter extends CustomPainter {
  final Color color;

  SketchyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i += 5) {
      final y = size.height / 2 + (i % 10 == 0 ? 0.5 : -0.5);
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

#### 3. `lib/core/widgets/custom_button.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.crossGold : AppColors.holyBlue,
        foregroundColor: AppColors.paperWhite,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.paperWhite),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  SizedBox(width: 8),
                ],
                Text(text, style: AppTextStyles.button),
              ],
            ),
    );
  }
}
```

#### 4. `lib/core/widgets/loading_indicator.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.holyBlue),
          ),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(color: AppColors.inkBrown),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## Phase 3: Data Layer (Week 3)

### Entity Classes

#### 1. `lib/domain/entities/user.dart`

```dart
class User {
  final String uid;
  final String displayName;
  final String? email;
  final bool isAnonymous;
  final DateTime? sobrietyStartDate;
  final String? sponsorId;
  final bool isVolunteer;
  final bool isAvailable;
  final DateTime? lastActive;
  final DateTime createdAt;
  final UserPreferences preferences;
  final UserStats stats;

  User({
    required this.uid,
    required this.displayName,
    this.email,
    required this.isAnonymous,
    this.sobrietyStartDate,
    this.sponsorId,
    this.isVolunteer = false,
    this.isAvailable = false,
    this.lastActive,
    required this.createdAt,
    required this.preferences,
    required this.stats,
  });

  int get daysClean {
    if (sobrietyStartDate == null) return 0;
    return DateTime.now().difference(sobrietyStartDate!).inDays;
  }

  bool get hasSponsor => sponsorId != null;
  bool get hasSetSobrietyDate => sobrietyStartDate != null;

  User copyWith({
    String? displayName,
    String? email,
    DateTime? sobrietyStartDate,
    String? sponsorId,
    bool? isVolunteer,
    bool? isAvailable,
    DateTime? lastActive,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return User(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isAnonymous: isAnonymous,
      sobrietyStartDate: sobrietyStartDate ?? this.sobrietyStartDate,
      sponsorId: sponsorId ?? this.sponsorId,
      isVolunteer: isVolunteer ?? this.isVolunteer,
      isAvailable: isAvailable ?? this.isAvailable,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

class UserPreferences {
  final bool notifications;
  final String? dailyReminderTime;

  UserPreferences({
    this.notifications = true,
    this.dailyReminderTime,
  });

  UserPreferences copyWith({
    bool? notifications,
    String? dailyReminderTime,
  }) {
    return UserPreferences(
      notifications: notifications ?? this.notifications,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}

class UserStats {
  final int longestStreak;
  final int currentStreak;
  final int totalCleanDays;

  UserStats({
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalCleanDays = 0,
  });

  UserStats copyWith({
    int? longestStreak,
    int? currentStreak,
    int? totalCleanDays,
  }) {
    return UserStats(
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
    );
  }
}


# Data Models & Repositories - Complete Implementation

## Entity Classes (Domain Layer)

### 1. User Entity - `lib/domain/entities/user.dart`

```dart
class User {
  final String uid;
  final String displayName;
  final String? email;
  final bool isAnonymous;
  final DateTime? sobrietyStartDate;
  final String? sponsorId;
  final bool isVolunteer;
  final bool isAvailable;
  final DateTime? lastActive;
  final DateTime createdAt;
  final UserPreferences preferences;
  final UserStats stats;

  User({
    required this.uid,
    required this.displayName,
    this.email,
    required this.isAnonymous,
    this.sobrietyStartDate,
    this.sponsorId,
    this.isVolunteer = false,
    this.isAvailable = false,
    this.lastActive,
    required this.createdAt,
    required this.preferences,
    required this.stats,
  });

  int get daysClean {
    if (sobrietyStartDate == null) return 0;
    return DateTime.now().difference(sobrietyStartDate!).inDays;
  }

  bool get hasSponsor => sponsorId != null;
  bool get hasSetSobrietyDate => sobrietyStartDate != null;

  User copyWith({
    String? displayName,
    String? email,
    DateTime? sobrietyStartDate,
    String? sponsorId,
    bool? isVolunteer,
    bool? isAvailable,
    DateTime? lastActive,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return User(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isAnonymous: isAnonymous,
      sobrietyStartDate: sobrietyStartDate ?? this.sobrietyStartDate,
      sponsorId: sponsorId ?? this.sponsorId,
      isVolunteer: isVolunteer ?? this.isVolunteer,
      isAvailable: isAvailable ?? this.isAvailable,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

class UserPreferences {
  final bool notifications;
  final String? dailyReminderTime;

  UserPreferences({
    this.notifications = true,
    this.dailyReminderTime,
  });

  UserPreferences copyWith({
    bool? notifications,
    String? dailyReminderTime,
  }) {
    return UserPreferences(
      notifications: notifications ?? this.notifications,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}

class UserStats {
  final int longestStreak;
  final int currentStreak;
  final int totalCleanDays;

  UserStats({
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalCleanDays = 0,
  });

  UserStats copyWith({
    int? longestStreak,
    int? currentStreak,
    int? totalCleanDays,
  }) {
    return UserStats(
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
    );
  }
}
```

### 2. SobrietyLog Entity - `lib/domain/entities/sobriety_log.dart`

```dart
enum SobrietyStatus { clean, relapse }

class SobrietyLog {
  final String id;
  final String userId;
  final DateTime date;
  final SobrietyStatus status;
  final String? mood;
  final List<String> triggers;
  final String? notes;
  final DateTime createdAt;

  SobrietyLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.status,
    this.mood,
    this.triggers = const [],
    this.notes,
    required this.createdAt,
  });

  bool get isClean => status == SobrietyStatus.clean;
  bool get isRelapse => status == SobrietyStatus.relapse;
  bool get hasTriggers => triggers.isNotEmpty;

  SobrietyLog copyWith({
    SobrietyStatus? status,
    String? mood,
    List<String>? triggers,
    String? notes,
  }) {
    return SobrietyLog(
      id: id,
      userId: userId,
      date: date,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
```

### 3. PanicRequest Entity - `lib/domain/entities/panic_request.dart`

```dart
enum PanicStatus { pending, active, resolved, cancelled }
enum ConnectionType { chat, call }

class PanicRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final int requesterDayCount;
  final DateTime timestamp;
  final PanicStatus status;
  final String? responderId;
  final String? responderName;
  final ConnectionType connectionType;
  final DateTime? resolvedAt;

  PanicRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterDayCount,
    required this.timestamp,
    required this.status,
    this.responderId,
    this.responderName,
    required this.connectionType,
    this.resolvedAt,
  });

  bool get isPending => status == PanicStatus.pending;
  bool get isActive => status == PanicStatus.active;
  bool get isResolved => status == PanicStatus.resolved;
  bool get isCancelled => status == PanicStatus.cancelled;
  
  Duration get waitTime => DateTime.now().difference(timestamp);
  
  bool get hasResponder => responderId != null;

  PanicRequest copyWith({
    PanicStatus? status,
    String? responderId,
    String? responderName,
    DateTime? resolvedAt,
  }) {
    return PanicRequest(
      id: id,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterDayCount: requesterDayCount,
      timestamp: timestamp,
      status: status ?? this.status,
      responderId: responderId ?? this.responderId,
      responderName: responderName ?? this.responderName,
      connectionType: connectionType,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
```

### 4. Other Entities

```dart
// lib/domain/entities/sponsorship.dart
enum SponsorshipStatus { pending, active, ended }

class Sponsorship {
  final String id;
  final String sponsorId;
  final String sponsoredUserId;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final SponsorshipStatus status;
  final DateTime? endedAt;
  final String? endReason;

  Sponsorship({
    required this.id,
    required this.sponsorId,
    required this.sponsoredUserId,
    required this.requestedAt,
    this.acceptedAt,
    required this.status,
    this.endedAt,
    this.endReason,
  });

  bool get isPending => status == SponsorshipStatus.pending;
  bool get isActive => status == SponsorshipStatus.active;
  bool get isEnded => status == SponsorshipStatus.ended;
}

// lib/domain/entities/group.dart
enum GroupCategory { support, prayer, discussion }

class Group {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final int memberCount;
  final bool isPrivate;
  final int maxMembers;
  final GroupCategory category;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
    required this.memberCount,
    this.isPrivate = false,
    this.maxMembers = 50,
    required this.category,
  });

  bool get isFull => memberCount >= maxMembers;
  bool isMember(String userId) => memberIds.contains(userId);
}

// lib/domain/entities/message.dart
enum ConversationType { group, direct }

class Message {
  final String id;
  final String conversationId;
  final ConversationType conversationType;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool flaggedForReview;
  final DateTime? reviewedAt;
  final DateTime? deletedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.conversationType,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.flaggedForReview = false,
    this.reviewedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  bool get needsReview => flaggedForReview && reviewedAt == null;
  bool get isGroup => conversationType == ConversationType.group;
}

// lib/domain/entities/reflection.dart
class DailyReflection {
  final String date;
  final String title;
  final String content;
  final String? bibleVerse;
  final String? verseReference;
  final String prayer;
  final String? author;
  final DateTime createdAt;

  DailyReflection({
    required this.date,
    required this.title,
    required this.content,
    this.bibleVerse,
    this.verseReference,
    required this.prayer,
    this.author,
    required this.createdAt,
  });

  bool get hasVerseReference => verseReference != null;
}

// lib/domain/entities/prayer.dart
enum PrayerCategory { morning, evening, rosary, emergency, liturgy }

class Prayer {
  final String id;
  final String title;
  final PrayerCategory category;
  final String content;
  final String? latinVersion;
  final String? notes;
  final int order;

  Prayer({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.latinVersion,
    this.notes,
    required this.order,
  });

  bool get hasLatinVersion => latinVersion != null;
}
```

---

## Model Classes (Data Layer)

### 1. UserModel - `lib/data/models/user_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String uid,
    required String displayName,
    String? email,
    required bool isAnonymous,
    DateTime? sobrietyStartDate,
    String? sponsorId,
    bool isVolunteer = false,
    bool isAvailable = false,
    DateTime? lastActive,
    required DateTime createdAt,
    required UserPreferences preferences,
    required UserStats stats,
  }) : super(
          uid: uid,
          displayName: displayName,
          email: email,
          isAnonymous: isAnonymous,
          sobrietyStartDate: sobrietyStartDate,
          sponsorId: sponsorId,
          isVolunteer: isVolunteer,
          isAvailable: isAvailable,
          lastActive: lastActive,
          createdAt: createdAt,
          preferences: preferences,
          stats: stats,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      sobrietyStartDate: json['sobrietyStartDate'] != null
          ? (json['sobrietyStartDate'] as Timestamp).toDate()
          : null,
      sponsorId: json['sponsorId'] as String?,
      isVolunteer: json['isVolunteer'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] as Timestamp).toDate()
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      preferences: UserPreferencesModel.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      stats: UserStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'isAnonymous': isAnonymous,
      'sobrietyStartDate': sobrietyStartDate != null
          ? Timestamp.fromDate(sobrietyStartDate!)
          : null,
      'sponsorId': sponsorId,
      'isVolunteer': isVolunteer,
      'isAvailable': isAvailable,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': {
        'notifications': preferences.notifications,
        'dailyReminderTime': preferences.dailyReminderTime,
      },
      'stats': {
        'longestStreak': stats.longestStreak,
        'currentStreak': stats.currentStreak,
        'totalCleanDays': stats.totalCleanDays,
      },
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      isAnonymous: user.isAnonymous,
      sobrietyStartDate: user.sobrietyStartDate,
      sponsorId: user.sponsorId,
      isVolunteer: user.isVolunteer,
      isAvailable: user.isAvailable,
      lastActive: user.lastActive,
      createdAt: user.createdAt,
      preferences: user.preferences,
      stats: user.stats,
    );
  }
}

class UserPreferencesModel extends UserPreferences {
  UserPreferencesModel({
    bool notifications = true,
    String? dailyReminderTime,
  }) : super(
          notifications: notifications,
          dailyReminderTime: dailyReminderTime,
        );

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      notifications: json['notifications'] as bool? ?? true,
      dailyReminderTime: json['dailyReminderTime'] as String?,
    );
  }
}

class UserStatsModel extends UserStats {
  UserStatsModel({
    int longestStreak = 0,
    int currentStreak = 0,
    int totalCleanDays = 0,
  }) : super(
          longestStreak: longestStreak,
          currentStreak: currentStreak,
          totalCleanDays: totalCleanDays,
        );

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      longestStreak: json['longestStreak'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalCleanDays: json['totalCleanDays'] as int? ?? 0,
    );
  }
}
```

### 2. SobrietyLogModel - `lib/data/models/sobriety_log_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sobriety_log.dart';

class SobrietyLogModel extends SobrietyLog {
  SobrietyLogModel({
    required String id,
    required String userId,
    required DateTime date,
    required SobrietyStatus status,
    String? mood,
    List<String> triggers = const [],
    String? notes,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          date: date,
          status: status,
          mood: mood,
          triggers: triggers,
          notes: notes,
          createdAt: createdAt,
        );

  factory SobrietyLogModel.fromJson(Map<String, dynamic> json, String id) {
    return SobrietyLogModel(
      id: id,
      userId: json['userId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      status: _statusFromString(json['status'] as String),
      mood: json['mood'] as String?,
      triggers: List<String>.from(json['triggers'] as List? ?? []),
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'status': _statusToString(status),
      'mood': mood,
      'triggers': triggers,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static SobrietyStatus _statusFromString(String status) {
    switch (status) {
      case 'clean':
        return SobrietyStatus.clean;
      case 'relapse':
        return SobrietyStatus.relapse;
      default:
        return SobrietyStatus.clean;
    }
  }

  static String _statusToString(SobrietyStatus status) {
    switch (status) {
      case SobrietyStatus.clean:
        return 'clean';
      case SobrietyStatus.relapse:
        return 'relapse';
    }
  }

  factory SobrietyLogModel.fromEntity(SobrietyLog log) {
    return SobrietyLogModel(
      id: log.id,
      userId: log.userId,
      date: log.date,
      status: log.status,
      mood: log.mood,
      triggers: log.triggers,
      notes: log.notes,
      createdAt: log.createdAt,
    );
  }
}
```

### 3. PanicRequestModel - `lib/data/models/panic_request_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/panic_request.dart';

class PanicRequestModel extends PanicRequest {
  PanicRequestModel({
    required String id,
    required String requesterId,
    required String requesterName,
    required int requesterDayCount,
    required DateTime timestamp,
    required PanicStatus status,
    String? responderId,
    String? responderName,
    required ConnectionType connectionType,
    DateTime? resolvedAt,
  }) : super(
          id: id,
          requesterId: requesterId,
          requesterName: requesterName,
          requesterDayCount: requesterDayCount,
          timestamp: timestamp,
          status: status,
          responderId: responderId,
          responderName: responderName,
          connectionType: connectionType,
          resolvedAt: resolvedAt,
        );

  factory PanicRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return PanicRequestModel(
      id: id,
      requesterId: json['requesterId'] as String,
      requesterName: json['requesterName'] as String,
      requesterDayCount: json['requesterDayCount'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      status: _statusFromString(json['status'] as String),
      responderId: json['responderId'] as String?,
      responderName: json['responderName'] as String?,
      connectionType: _connectionTypeFromString(
        json['connectionType'] as String? ?? 'chat',
      ),
      resolvedAt: json['resolvedAt'] != null
          ? (json['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterDayCount': requesterDayCount,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': _statusToString(status),
      'responderId': responderId,
      'responderName': responderName,
      'connectionType': _connectionTypeToString(connectionType),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  static PanicStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return PanicStatus.pending;
      case 'active':
        return PanicStatus.active;
      case 'resolved':
        return PanicStatus.resolved;
      case 'cancelled':
        return PanicStatus.cancelled;
      default:
        return PanicStatus.pending;
    }
  }

  static String _statusToString(PanicStatus status) {
    return status.toString().split('.').last;
  }

  static ConnectionType _connectionTypeFromString(String type) {
    switch (type) {
      case 'chat':
        return ConnectionType.chat;
      case 'call':
        return ConnectionType.call;
      default:
        return ConnectionType.chat;
    }
  }

  static String _connectionTypeToString(ConnectionType type) {
    return type.toString().split('.').last;
  }

  factory PanicRequestModel.fromEntity(PanicRequest request) {
    return PanicRequestModel(
      id: request.id,
      requesterId: request.requesterId,
      requesterName: request.requesterName,
      requesterDayCount: request.requesterDayCount,
      timestamp: request.timestamp,
      status: request.status,
      responderId: request.responderId,
      responderName: request.responderName,
      connectionType: request.connectionType,
      resolvedAt: request.resolvedAt,
    );
  }
}
```

---

## Repositories

### 1. AuthRepository - `lib/data/repositories/auth_repository.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../../core/constants/firebase_collections.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  // Register with email and password
  Future<User> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    DateTime? sobrietyStartDate,
  }) async {
    try {
      // Create Firebase Auth user
      final firebaseUser = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create Firestore user document
      final user = UserModel(
        uid: firebaseUser.uid,
        displayName: displayName,
        email: email,
        isAnonymous: false,
        sobrietyStartDate: sobrietyStartDate,
        createdAt: DateTime.now(),
        preferences: UserPreferences(),
        stats: UserStats(),
      );

      await _firestoreService.setDocument(
        collection: FirebaseCollections.users,
        docId: user.uid,
        data: UserModel.fromEntity(user).toJson(),
      );

      return user;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Login with email and password
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final firebaseUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userData = await _firestoreService.getDocument(
        collection: FirebaseCollections.users,
        docId: firebaseUser.uid,
      );

      if (userData == null) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Login anonymously
  Future<User> loginAnonymously() async {
    try {
      final firebaseUser = await _authService.signInAnonymously();

      // Generate random display name
      final displayName = _generateAnonymousName();

      final user = UserModel(
        uid: firebaseUser.uid,
        displayName: displayName,
        isAnonymous: true,
        createdAt: DateTime.now(),
        preferences: UserPreferences(),
        stats: UserStats(),
      );

      await _firestoreService.setDocument(
        collection: FirebaseCollections.users,
        docId: user.uid,
        data: UserModel.fromEntity(user).toJson(),
      );

      return user;
    } catch (e) {
      throw Exception('Failed to login anonymously: $e');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) return null;

      final userData = await _firestoreService.getDocument(
        collection: FirebaseCollections.users,
        docId: firebaseUser.uid,
      );

      if (userData == null) return null;

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  // Helper: Generate anonymous name
  String _generateAnonymousName() {
    final random = DateTime.now().millisecondsSinceEpoch % 9999;
    return 'Anonymous_${random.toString().padLeft(4, '0')}';
  }
}
```

### 2. UserRepository - `lib/data/repositories/user_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/firebase_collections.dart';

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final data = await _firestoreService.getDocument(
        collection: FirebaseCollections.users,
        docId: userId,
      );

      if (data == null) return null;
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: updates,
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update sobriety start date
  Future<void> updateSobrietyStartDate(
    String userId,
    DateTime startDate,
  ) async {
    await updateUser(userId, {
      'sobrietyStartDate': Timestamp.fromDate(startDate),
    });
  }

  // Update volunteer status
  Future<void> updateVolunteerStatus(String userId, bool isVolunteer) async {
    await updateUser(userId, {
      'isVolunteer': isVolunteer,
    });
  }

  // Update availability
  Future<void> updateAvailability(String userId, bool isAvailable) async {
    await updateUser(userId, {
      'isAvailable': isAvailable,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // Update stats
  Future<void> updateStats(String userId, UserStats stats) async {
    await updateUser(userId, {
      'stats': {
        'longestStreak': stats.longestStreak,
        'currentStreak': stats.currentStreak,
        'totalCleanDays': stats.totalCleanDays,
      },
    });
  }

  // Get available volunteers
  Future<List<User>> getAvailableVolunteers() async {
    try {
      final snapshot = await _firestoreService.queryDocuments(
        collection: FirebaseCollections.users,
        where: [
          {'field': 'isVolunteer', 'operator': '==', 'value': true},
          {'field': 'isAvailable', 'operator': '==', 'value': true},
        ],
        limit: 20,
      );

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get volunteers: $e');
    }
  }

  // Get potential sponsors
  Future<List<User>> getPotentialSponsors() async {
    try {
      final snapshot = await _firestoreService.queryDocuments(
        collection: FirebaseCollections.users,
        where: [
          {'field': 'isVolunteer', 'operator': '==', 'value': true},
        ],
        orderBy: {'field': 'stats.currentStreak', 'descending': true},
        limit: 20,
      );

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sponsors: $e');
    }
  }

# Data Architecture & Repository Guide

## Overview
This guide explains how to structure your data layer following Clean Architecture principles. No code - just the concepts and patterns to implement.

---

## Data Layer Structure

### Three-Layer Approach

**1. Domain Layer (Pure Business Logic)**
- Contains entity classes (pure Dart, no Flutter/Firebase dependencies)
- Defines what the app does, not how
- Example: User entity knows how to calculate days clean, but doesn't know about Firestore

**2. Data Layer (Implementation Details)**
- Contains models (entities + JSON serialization)
- Contains repositories (concrete implementations)
- Contains services (Firebase, API wrappers)
- Handles all external data sources

**3. Presentation Layer (UI + State)**
- Uses Riverpod providers to access repositories
- Never directly accesses Firebase or services
- Works with domain entities, not models

---

## Entity Design Pattern

### Purpose
Entities are pure Dart classes that represent your core business objects without any dependencies on frameworks.

### How to Create an Entity

**Step 1: Identify Core Properties**
- What data does this object absolutely need?
- What are the relationships to other objects?
- Example: User needs uid, displayName, sobrietyStartDate

**Step 2: Add Computed Properties**
- What can be calculated from existing data?
- Example: `daysClean` is computed from `sobrietyStartDate`
- These are getters that don't store data

**Step 3: Add Business Logic Methods**
- What actions/validations does this object need?
- Example: User.canBecomeSponsor() checks if days clean >= 90
- Keep logic domain-specific, not implementation-specific

**Step 4: Implement copyWith Pattern**
- Entities are immutable (all fields final)
- copyWith() creates new instances with updated fields
- This makes state management predictable

**Step 5: No Serialization Here**
- Entities don't know about JSON, Firestore, etc.
- That's the model's job

---

## Model Design Pattern

### Purpose
Models extend entities and add serialization/deserialization logic for external data sources (Firestore, APIs).

### How to Create a Model

**Step 1: Extend the Entity**
- Model class extends the corresponding entity
- Inherits all properties and methods
- Example: UserModel extends User

**Step 2: Create fromJson Factory**
- Static method that takes Map<String, dynamic>
- Converts JSON/Firestore data to model instance
- Handle null safety carefully
- Parse timestamps to DateTime objects
- Use null-aware operators for optional fields

**Step 3: Create toJson Method**
- Converts model instance to Map<String, dynamic>
- Use for writing to Firestore
- Convert DateTime to ISO strings or Timestamps
- Only include fields that should be stored

**Step 4: Handle Type Conversions**
- Enums: Convert to/from strings
- Dates: Handle both Timestamp and ISO strings
- Lists: Parse each item properly
- Nested objects: Recursively parse sub-models

**Step 5: Add fromSnapshot (Optional)**
- If using Firestore directly
- Takes DocumentSnapshot and extracts data
- Adds document ID to model

---

## Repository Pattern

### Purpose
Repositories abstract away data source details. The app doesn't care if data comes from Firestore, REST API, or local cache - it just asks the repository.

### Repository Structure

**Each Repository Should Have:**
1. A single data source it manages (e.g., AuthRepository manages authentication)
2. Clear, domain-focused method names (not "getDocumentFromFirestore", but "getCurrentUser")
3. Returns entities, not models (convert inside repository)
4. Handles all error cases and throws custom exceptions

### How to Build a Repository

**Step 1: Define the Interface (Optional but Recommended)**
- Create abstract class defining all methods
- Example: Abstract UserRepository with methods like getUser(), updateUser()
- This allows for easy testing with mock implementations

**Step 2: Implement the Concrete Repository**
- Create class that implements the interface
- Inject dependencies (Firebase services) via constructor
- Example: UserRepositoryImpl needs FirestoreService

**Step 3: Method Pattern for Reading Data**
- Accept ID or query parameters
- Call service to fetch data
- Convert model to entity before returning
- Wrap in try-catch and throw custom exceptions
- Return Stream for real-time data, Future for one-time fetches

**Step 4: Method Pattern for Writing Data**
- Accept entity as parameter
- Convert entity to model inside method
- Call service to write data
- Handle errors appropriately
- Return success/failure indicator or throw exception

**Step 5: Method Pattern for Listening (Real-time)**
- Return Stream<Entity> or Stream<List<Entity>>
- Use Firestore snapshots converted to streams
- Transform DocumentSnapshot to entity before emitting
- Handle stream errors gracefully

---

## Service Layer Pattern

### Purpose
Services are thin wrappers around external SDKs (Firebase, APIs). They handle low-level operations but don't contain business logic.

### How to Build a Service

**Step 1: FirestoreService**
- Create methods for generic Firestore operations
- Methods: getDocument, getCollection, addDocument, updateDocument, deleteDocument
- These are generic and work with any collection
- Accept collection name and document ID as parameters
- Return raw data (Map) or DocumentSnapshot

**Step 2: FirebaseAuthService**
- Wrap Firebase Auth methods
- signInWithEmail, signInAnonymously, signOut, etc.
- Return FirebaseUser or user ID
- Let repository handle user document creation

**Step 3: NotificationService**
- Handle FCM token management
- Send push notifications
- Request permissions
- Handle notification tap events

**Step 4: StorageService (If Needed)**
- Upload/download files
- Manage file URLs
- Handle compression, resizing

**Step 5: ModerationService**
- Call content moderation API
- Check for inappropriate content
- Flag messages for review
- Return moderation result (clean/flagged)

---

## Use Case Pattern

### Purpose
Use cases encapsulate a single business action. They orchestrate between repositories and contain complex business logic that doesn't belong in entities.

### When to Create a Use Case

**Create a use case when:**
- Action involves multiple repositories
- Complex validation or business rules
- Multi-step process
- Example: CreatePanicRequest needs to validate user, create request, notify volunteers

**Don't create use case when:**
- Simple CRUD operation (just use repository)
- No business logic beyond data access
- Example: GetUser can be direct repository call

### How to Build a Use Case

**Step 1: Single Responsibility**
- Each use case does ONE thing
- Name clearly: LoginUseCase, CreatePanicRequestUseCase
- Has one public method: execute() or call()

**Step 2: Inject Dependencies**
- Accept repositories in constructor
- Don't instantiate repositories inside
- Makes testing easier

**Step 3: Execute Method Pattern**
- Accept parameters needed for the action
- Perform validation first
- Call repositories in correct order
- Handle errors and edge cases
- Return result or throw exception

**Step 4: Return Meaningful Results**
- Don't just return bool
- Return entity, or custom result object
- Example: LoginResult with user + token
- Or throw specific exceptions for failures

---

## Error Handling Strategy

### Exception Hierarchy

**Step 1: Define Custom Exceptions**
- Create exception classes for different error types
- AuthException, NetworkException, ValidationException
- Each has meaningful message

**Step 2: Repository Error Handling**
- Catch Firebase/API exceptions
- Convert to custom exceptions
- Add context to error messages
- Re-throw custom exceptions

**Step 3: Use Case Error Handling**
- Catch repository exceptions
- Add business context
- Return user-friendly error messages
- Log errors for debugging

**Step 4: UI Error Handling**
- Providers catch exceptions
- Set error state
- UI displays user-friendly messages
- Offer retry options

---

## Data Flow Example: Logging a Sobriety Day

### Step-by-Step Flow

**1. User Interaction (Presentation Layer)**
- User taps "Log Day" button in CalendarScreen
- Screen calls provider method: `logSobrietyDay(date, status, mood, triggers, notes)`

**2. Provider Processing (Presentation Layer)**
- Provider has reference to LogDayUseCase
- Calls `useCase.execute(LogDayParams(...))`
- Sets loading state while waiting
- Updates UI state with result or error

**3. Use Case Execution (Domain Layer)**
- LogDayUseCase receives parameters
- Validates date (not in future)
- Creates SobrietyLog entity from parameters
- Calls repository: `sobrietyRepository.saveLog(log)`
- If needed, updates user stats: `userRepository.updateStats(...)`
- Returns success

**4. Repository Operations (Data Layer)**
- SobrietyRepository receives entity
- Converts entity to model using `SobrietyLogModel.fromEntity(log)`
- Calls service: `firestoreService.addDocument('sobriety_logs', model.toJson())`
- Returns saved log entity

**5. Service Interaction (Data Layer)**
- FirestoreService receives collection name and data map
- Calls Firebase: `FirebaseFirestore.instance.collection(...).add(...)`
- Returns document ID
- Handles any Firebase exceptions

**6. Response Flow Back**
- Service returns to repository
- Repository returns to use case
- Use case returns to provider
- Provider updates UI state
- Screen rebuilds with new data

---

## Real-time Data Pattern

### Listening to Firestore Changes

**Step 1: Create Stream in Service**
- FirestoreService method returns Stream<DocumentSnapshot> or Stream<QuerySnapshot>
- Uses Firestore .snapshots() method
- Example: `collection('panic_requests').where(...).snapshots()`

**Step 2: Transform in Repository**
- Repository receives stream from service
- Maps stream to transform DocumentSnapshot → Model → Entity
- Handles errors in stream
- Returns Stream<Entity> or Stream<List<Entity>>

**Step 3: Expose via Provider**
- Create StreamProvider in Riverpod
- Provider listens to repository stream
- Automatically rebuilds widgets when data changes
- Example: `panicRequestStreamProvider`

**Step 4: Consume in UI**
- Widget uses `ref.watch(streamProvider)`
- AsyncValue handles loading/data/error states
- Automatically updates when stream emits new data

### When to Use Streams

**Use streams for:**
- Messages (real-time chat)
- Panic requests (need instant updates)
- User availability status
- Live group member count

**Don't use streams for:**
- Static content (prayers, reflections)
- User profile (changes infrequently)
- Historical data (calendar logs)
- Use Future + manual refresh instead

---

## Caching Strategy

### Why Cache?

- Reduce Firestore reads (save costs)
- Offline functionality
- Faster app load times
- Better user experience

### What to Cache

**Cache Locally:**
- Daily reflections (after first load)
- Prayer library (static content)
- User profile (until logout)
- Recent messages (last 50)
- Calendar data (current month)

**Don't Cache:**
- Panic requests (always real-time)
- User availability status
- Sensitive data

### How to Implement Caching

**Step 1: Choose Storage**
- Use Hive for complex objects
- Use SharedPreferences for simple key-value
- Use in-memory cache for session data

**Step 2: Cache in Repository**
- Check cache first before network call
- Return cached data immediately
- Fetch fresh data in background
- Update cache with fresh data

**Step 3: Set Expiration**
- Add timestamp to cached data
- Check if data is stale (e.g., > 24 hours old)
- Fetch fresh if stale, use cache if fresh

**Step 4: Clear Cache Strategy**
- Clear on logout
- Clear specific data when updated
- Provide manual "Refresh" option

---

## Testing Strategy for Data Layer

### Unit Testing Repositories

**Step 1: Mock Dependencies**
- Create mock FirestoreService
- Define expected behavior
- Example: When getDocument called, return specific map

**Step 2: Test Happy Path**
- Call repository method
- Verify correct service method called
- Assert returned entity is correct

**Step 3: Test Error Cases**
- Mock service throwing exception
- Verify repository converts to custom exception
- Assert error message is meaningful

**Step 4: Test Data Transformation**
- Verify model correctly converts to entity
- Check all fields mapped properly
- Test null handling

### Integration Testing Services

**Step 1: Use Firebase Emulator**
- Run Firestore emulator locally
- No internet needed, no costs
- Fast, repeatable tests

**Step 2: Seed Test Data**
- Create known data in emulator
- Test service methods against real Firestore
- Verify reads/writes work correctly

**Step 3: Test Real-time Streams**
- Subscribe to stream
- Update data in emulator
- Verify stream emits new data

---

## Performance Optimization

### Firestore Query Optimization

**Step 1: Use Indexed Queries**
- Create composite indexes for complex queries
- Firestore will prompt you when needed
- Add to firestore.indexes.json

**Step 2: Limit Query Results**
- Always use .limit() on queries
- Paginate large lists
- Example: Load 20 messages at a time

**Step 3: Query Only What You Need**
- Don't fetch entire documents if you only need one field
- Use projections when possible
- Avoid unnecessary subcollection reads

### Batch Operations

**When to Batch:**
- Updating multiple documents at once
- Creating related documents together
- Deleting multiple items

**How to Batch:**
- Use WriteBatch in Firestore
- Maximum 500 operations per batch
- All succeed or all fail (atomic)
- Example: Delete user + all their logs in one batch

### Connection Management

**Step 1: Detect Connectivity**
- Listen to connectivity changes
- Show offline indicator in UI
- Queue writes when offline

**Step 2: Handle Offline State**
- Firestore has offline persistence enabled by default
- Reads come from cache when offline
- Writes queued and sync when online

**Step 3: Optimize Connection Usage**
- Close unnecessary listeners
- Pause real-time updates when app in background
- Resume when app active

---

## Security Rules Considerations

### Design Data Structure for Security

**Step 1: User Ownership**
- Every document should have an owner field (userId)
- Makes security rules simple: `request.auth.uid == resource.data.userId`

**Step 2: Privacy Flags**
- Add visibility fields (isPublic, isPrivate)
- Control who can read data
- Example: Group has memberIds array for access control

**Step 3: Role-Based Access**
- Store roles in user document (isVolunteer, isModerator)
- Security rules check role before allowing write
- Example: Only volunteers can respond to panic requests

### Repository-Side Validation

**Even with security rules, validate in app:**
- Don't rely solely on backend rules
- Check permissions before attempting write
- Provide better error messages to user
- Example: Check if user is volunteer before allowing panic response

---

## Migration Strategy

### Handling Schema Changes

**Step 1: Additive Changes**
- New fields: Add with default values
- Old clients ignore new fields
- New clients handle missing fields with defaults

**Step 2: Field Renames**
- Add new field, keep old field
- Write to both for transition period
- Read new field, fall back to old
- Remove old field after all clients updated

**Step 3: Type Changes**
- Create new field with correct type
- Migrate data via Cloud Function
- Update app to use new field
- Delete old field later

**Step 4: Data Migration**
- Write Cloud Function to update documents
- Run in batches to avoid timeouts
- Keep track of progress
- Verify before deleting old data

---

## Summary Checklist

### For Each Feature:

**Domain Layer:**
- [ ] Create entity class with business logic
- [ ] Add computed properties
- [ ] Implement copyWith for immutability
- [ ] Write unit tests for entity logic

**Data Layer:**
- [ ] Create model extending entity
- [ ] Implement fromJson factory
- [ ] Implement toJson method
- [ ] Create repository interface
- [ ] Implement repository with service calls
- [ ] Handle errors and convert to custom exceptions
- [ ] Add caching if needed
- [ ] Write repository unit tests

**Service Layer:**
- [ ] Create service for external API/Firebase
- [ ] Implement generic methods
- [ ] Handle connection errors
- [ ] Return raw data to repository
- [ ] Write integration tests with emulator

**Use Cases (if needed):**
- [ ] Identify complex business actions
- [ ] Create use case class
- [ ] Inject required repositories
- [ ] Implement execute method
- [ ] Handle validation and errors
- [ ] Write unit tests with mocked repositoriescd