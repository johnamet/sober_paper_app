# Use Cases, Providers, and Services - Implementation Summary

## 📋 Overview
This document summarizes the business logic layer, state management, and services implemented for the Freedom Path Catholic recovery app.

## 🎯 Use Cases (Business Logic Layer)

### Authentication Use Cases (`domain/use_cases/auth/`)
- ✅ `LoginWithEmail` - Email/password authentication with validation
- ✅ `RegisterWithEmail` - User registration with email validation
- ✅ `LoginAnonymously` - Anonymous user creation
- ✅ `Logout` - Sign out functionality
- ✅ `GetCurrentUser` - Retrieve authenticated user
- ✅ `SendPasswordReset` - Password recovery
- ✅ `UpgradeAnonymousAccount` - Convert anonymous to full account

### User Management Use Cases (`domain/use_cases/user/`)
- ✅ `GetUserProfile` - Fetch user profile by ID
- ✅ `UpdateUserProfile` - Update profile (name, sobriety date, preferences)
- ✅ `WatchUserProfile` - Real-time profile stream
- ✅ `UpdateUserStats` - Update user statistics (streaks, clean days)

### Sobriety Tracking Use Cases (`domain/use_cases/sobriety/`)
- ✅ `LogSobrietyDay` - Log daily sobriety status with mood and triggers
- ✅ `GetSobrietyLogs` - Retrieve logs for date range
- ✅ `CalculateCurrentStreak` - Calculate active streak
- ✅ `GetTotalCleanDays` - Count total clean days
- ✅ `WatchSobrietyLogs` - Real-time sobriety log stream

### Panic Support Use Cases (`domain/use_cases/panic/`)
- ✅ `CreatePanicRequest` - Create emergency support request
- ✅ `RespondToPanicRequest` - Volunteer response to request
- ✅ `WatchPendingPanicRequests` - Stream of active requests

### Community Use Cases (`domain/use_cases/community/`)
- ✅ `CreateGroup` - Create support group with category
- ✅ `SendDirectMessage` - Send private message between users

### Reflection Use Cases (`domain/use_cases/reflection/`)
- ✅ `GetTodayReflection` - Fetch daily Catholic reflection
- ✅ `SearchPrayers` - Search prayer library with optional category filter

### Moderation Use Cases (`domain/use_cases/moderation/`)
- ✅ `ReportContent` - Report inappropriate content (user, message, group)

---

## 🔌 Riverpod Providers (State Management)

### Repository Providers (`providers/repository_providers.dart`)
All 7 repositories exposed as Riverpod providers:
- `authRepositoryProvider`
- `userRepositoryProvider`
- `sobrietyRepositoryProvider`
- `panicRepositoryProvider`
- `communityRepositoryProvider`
- `reflectionRepositoryProvider`
- `moderationRepositoryProvider`

### Use Case Providers
Each use case is provided with automatic dependency injection:

**Auth**: `providers/auth_use_case_providers.dart`
- `loginWithEmailProvider`
- `registerWithEmailProvider`
- `loginAnonymouslyProvider`
- `logoutProvider`
- `getCurrentUserProvider`
- `sendPasswordResetProvider`
- `upgradeAnonymousAccountProvider`

**User**: `providers/user_use_case_providers.dart`
- `getUserProfileProvider`
- `updateUserProfileProvider`
- `watchUserProfileProvider`
- `updateUserStatsProvider`

**Sobriety**: `providers/sobriety_use_case_providers.dart`
- `logSobrietyDayProvider`
- `getSobrietyLogsProvider`
- `calculateCurrentStreakProvider`
- `getTotalCleanDaysProvider`
- `watchSobrietyLogsProvider`

**Panic**: `providers/panic_use_case_providers.dart`
- `createPanicRequestProvider`
- `respondToPanicRequestProvider`
- `watchPendingPanicRequestsProvider`

**Community**: `providers/community_use_case_providers.dart`
- `createGroupProvider`
- `sendDirectMessageProvider`

**Reflection**: `providers/reflection_use_case_providers.dart`
- `getTodayReflectionProvider`
- `searchPrayersProvider`

**Moderation**: `providers/moderation_use_case_providers.dart`
- `reportContentProvider`

### State Providers (`providers/state_providers.dart`)

**Authentication State**:
- `firebaseAuthUserProvider` - Stream of Firebase auth user
- `currentUserIdProvider` - Current user ID
- `isAuthenticatedProvider` - Authentication status
- `isAnonymousProvider` - Anonymous user check

**User Profile State**:
- `currentUserProfileProvider` - Stream of current user profile
- `userProfileProvider` - Family provider for any user profile

**Sobriety State**:
- `currentUserSobrietyLogsProvider` - Stream of user's sobriety logs
- `currentStreakProvider` - Computed current streak
- `totalCleanDaysProvider` - Computed total clean days

**Panic Request State**:
- `pendingPanicRequestsProvider` - Stream of pending requests
- `userPanicRequestsProvider` - Stream of user's panic requests
- `activePanicRequestCountProvider` - Count of active requests

**Reflection State**:
- `todayReflectionProvider` - Future of today's reflection

**UI State**:
- `isLoadingProvider` - Loading state
- `errorMessageProvider` - Error messages
- `successMessageProvider` - Success messages
- `selectedTabIndexProvider` - Bottom navigation state
- `themeModeProvider` - Light/dark theme

### Service Providers (`providers/service_providers.dart`)
- `firebaseServiceProvider` - Firebase initialization service
- `moderationServiceProvider` - Content moderation service
- `notificationServiceProvider` - Notification service (commented - needs package)

---

## ⚙️ Services Layer

### Firebase Service (`services/firebase_service.dart`)
**Purpose**: Initialize and configure Firebase
**Features**:
- Firebase initialization with options
- Firestore offline persistence
- Auth persistence configuration
- Auth state monitoring
- User authentication checks

**Usage**:
```dart
final firebaseService = ref.read(firebaseServiceProvider);
await firebaseService.initialize();
final isAuth = firebaseService.isUserAuthenticated();
```

### Notification Service (`services/notification_service.dart`)
**Purpose**: Handle local and push notifications
**Features**:
- Local notifications (flutter_local_notifications)
- Firebase Cloud Messaging (FCM)
- Permission handling
- Foreground/background message handling
- Custom notification types:
  - Panic alerts
  - Daily reminders
  - Celebration milestones
- Topic subscriptions
- Scheduled notifications

**Note**: Requires `flutter_local_notifications` package in pubspec.yaml

**Usage**:
```dart
final notificationService = NotificationService.instance;
await notificationService.initialize();
await notificationService.showPanicAlertNotification(
  requesterName: 'John',
  dayCount: 30,
);
```

### Moderation Service (`services/moderation_service.dart`)
**Purpose**: Content filtering and validation
**Features**:
- Profanity detection
- Sensitive content detection
- Content filtering (asterisk replacement)
- Message validation
- Automatic flagging for review
- Moderation scoring (0-100)
- Customizable word lists

**Usage**:
```dart
final moderationService = ref.read(moderationServiceProvider);
final error = moderationService.validateMessage(content);
if (error != null) {
  // Show error to user
}
```

---

## 🏗️ Architecture Benefits

### Clean Architecture
- **Separation of Concerns**: Use cases contain business logic, repositories handle data
- **Testability**: Each layer can be tested independently
- **Flexibility**: Easy to swap implementations (e.g., different data sources)

### Dependency Injection
- **Automatic**: Riverpod handles dependency graph
- **Type-Safe**: Compile-time checking of dependencies
- **Scoped**: Can override providers for testing

### Reactive Programming
- **Real-Time**: Stream providers update UI automatically
- **Computed State**: Derived providers (streaks, counts) recalculate automatically
- **Memory Efficient**: Providers dispose when not watched

---

## 📦 Usage Examples

### Authentication Flow
```dart
// Login
final loginUseCase = ref.read(loginWithEmailProvider);
try {
  final user = await loginUseCase.call('email@example.com', 'password');
  // Navigate to home
} catch (e) {
  // Show error
}

// Watch auth state
ref.listen(isAuthenticatedProvider, (_, isAuth) {
  if (isAuth) {
    // Navigate to home
  } else {
    // Navigate to login
  }
});
```

### Sobriety Tracking
```dart
// Log a clean day
final logUseCase = ref.read(logSobrietyDayProvider);
await logUseCase.call(
  userId: currentUserId,
  date: DateTime.now(),
  status: SobrietyStatus.clean,
  moodRating: 8,
);

// Watch streak in UI
final streak = ref.watch(currentStreakProvider);
Text('🔥 $streak days');
```

### Panic Button
```dart
// Create panic request
final createRequest = ref.read(createPanicRequestProvider);
await createRequest.call(
  requesterId: currentUserId,
  requesterName: userName,
  requesterDayCount: streak,
  connectionType: ConnectionType.chat,
);

// Watch pending requests (for volunteers)
final requests = ref.watch(pendingPanicRequestsProvider);
```

---

## 🔄 State Flow Diagram

```
User Action
    ↓
Widget (ConsumerWidget)
    ↓
Use Case Provider (business logic + validation)
    ↓
Repository Provider (data operations)
    ↓
Firebase/Cloud Firestore
    ↓
Stream Provider (real-time updates)
    ↓
UI Updates Automatically
```

---

## ✅ Implementation Checklist

- ✅ 7 Auth use cases with validation
- ✅ 4 User management use cases
- ✅ 5 Sobriety tracking use cases
- ✅ 3 Panic support use cases
- ✅ 2 Community use cases (more can be added)
- ✅ 2 Reflection use cases
- ✅ 1 Moderation use case
- ✅ Repository providers for all 7 repositories
- ✅ Use case providers with dependency injection
- ✅ State providers for auth, user, sobriety, panic, reflection
- ✅ Service providers for Firebase, moderation, notifications
- ✅ Firebase initialization service
- ✅ Notification service (needs package)
- ✅ Content moderation service
- ✅ Central providers export file

---

## 🚀 Next Steps

1. **Add Package**: Add `flutter_local_notifications: ^17.0.0` to pubspec.yaml
2. **Test Use Cases**: Write unit tests for business logic
3. **Integrate UI**: Update existing screens to use new providers
4. **Add More Use Cases**: Expand community, sponsorship, group features
5. **Error Handling**: Add consistent error handling across use cases
6. **Logging**: Add logging service for debugging
7. **Analytics**: Add Firebase Analytics integration
8. **Performance**: Add caching strategies for frequently accessed data

---

## 📚 File Structure

```
lib/
├── domain/
│   └── use_cases/
│       ├── auth/ (7 files)
│       ├── user/ (4 files)
│       ├── sobriety/ (5 files)
│       ├── panic/ (3 files)
│       ├── community/ (2 files)
│       ├── reflection/ (2 files)
│       └── moderation/ (1 file)
├── providers/
│   ├── providers.dart (central export)
│   ├── repository_providers.dart
│   ├── auth_use_case_providers.dart
│   ├── user_use_case_providers.dart
│   ├── sobriety_use_case_providers.dart
│   ├── panic_use_case_providers.dart
│   ├── community_use_case_providers.dart
│   ├── reflection_use_case_providers.dart
│   ├── moderation_use_case_providers.dart
│   ├── service_providers.dart
│   └── state_providers.dart
└── services/
    ├── firebase_service.dart
    ├── notification_service.dart
    └── moderation_service.dart
```

Total Files Created: **37 files**
- 24 use case files
- 10 provider files
- 3 service files

---

**Status**: ✅ Complete and ready for integration
