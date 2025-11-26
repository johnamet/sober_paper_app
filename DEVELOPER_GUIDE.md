# Freedom Path - Developer Quick Start Guide

## 🚀 Getting Started

### 1. Import Providers
```dart
import 'package:sober_paper/providers/providers.dart';
```
This single import gives you access to all providers in the app.

### 2. Make Widget a Consumer
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access providers here
  }
}
```

---

## 📱 Common Use Cases

### Authentication

#### Login with Email
```dart
final loginUseCase = ref.read(loginWithEmailProvider);

try {
  final user = await loginUseCase.call('user@example.com', 'password');
  // Success - navigate to home
} on ArgumentError catch (e) {
  // Validation error (invalid email, empty fields, etc.)
  showError(e.message);
} catch (e) {
  // Authentication failed
  showError('Login failed: $e');
}
```

#### Register New User
```dart
final registerUseCase = ref.read(registerWithEmailProvider);

try {
  final user = await registerUseCase.call(
    email: 'user@example.com',
    password: 'password123',
    displayName: 'John Doe',
  );
  // Success - user created
} catch (e) {
  showError('Registration failed: $e');
}
```

#### Check Auth Status
```dart
// In build method
final isAuthenticated = ref.watch(isAuthenticatedProvider);

if (!isAuthenticated) {
  return LoginScreen();
}

// Or listen for changes
ref.listen(isAuthenticatedProvider, (previous, next) {
  if (!next) {
    Navigator.pushReplacementNamed(context, '/login');
  }
});
```

#### Get Current User
```dart
final userId = ref.watch(currentUserIdProvider);
final userProfile = ref.watch(currentUserProfileProvider);

userProfile.when(
  data: (user) => Text(user?.displayName ?? 'Loading...'),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

#### Logout
```dart
final logoutUseCase = ref.read(logoutProvider);
await logoutUseCase.call();
```

---

### User Profile Management

#### Get User Profile
```dart
final getUserProfile = ref.read(getUserProfileProvider);

try {
  final user = await getUserProfile.call('userId123');
  // Use user data
} catch (e) {
  showError('User not found');
}
```

#### Update Profile
```dart
final updateProfile = ref.read(updateUserProfileProvider);

await updateProfile.call(
  uid: currentUserId,
  displayName: 'New Name',
  isVolunteer: true,
  preferences: UserPreferences(
    enablePanicAlerts: true,
    enableDailyReminders: true,
  ),
);
```

#### Watch Profile Changes (Real-time)
```dart
final profile = ref.watch(currentUserProfileProvider);

profile.when(
  data: (user) {
    if (user == null) return Text('No profile');
    return Text('Welcome ${user.displayName}');
  },
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

---

### Sobriety Tracking

#### Log a Clean Day
```dart
final logDay = ref.read(logSobrietyDayProvider);

await logDay.call(
  userId: currentUserId,
  date: DateTime.now(),
  status: SobrietyStatus.clean,
  moodRating: 8, // 1-10
  notes: 'Felt strong today',
  triggers: ['stress', 'boredom'],
);
```

#### Display Current Streak
```dart
// Automatically updates when logs change
final streak = ref.watch(currentStreakProvider);

Text(
  '🔥 $streak days clean',
  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
);
```

#### Display Total Clean Days
```dart
final totalDays = ref.watch(totalCleanDaysProvider);
Text('Total: $totalDays days');
```

#### Watch Sobriety Logs
```dart
final logs = ref.watch(currentUserSobrietyLogsProvider);

logs.when(
  data: (logMap) {
    if (logMap.isEmpty) return Text('No logs yet');
    
    return ListView(
      children: logMap.entries.map((entry) {
        final date = entry.key;
        final log = entry.value;
        return ListTile(
          title: Text(DateFormat.yMMMd().format(date)),
          subtitle: Text('Status: ${log.status.name}'),
          trailing: log.isClean 
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.cancel, color: Colors.red),
        );
      }).toList(),
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

---

### Panic Button Support

#### Create Panic Request
```dart
final createRequest = ref.read(createPanicRequestProvider);

try {
  final request = await createRequest.call(
    requesterId: currentUserId,
    requesterName: userName,
    requesterDayCount: currentStreak,
    connectionType: ConnectionType.chat, // or ConnectionType.call
  );
  
  showSuccess('Help is on the way!');
} catch (e) {
  showError('Failed to send alert: $e');
}
```

#### Watch Pending Requests (Volunteer View)
```dart
final requests = ref.watch(pendingPanicRequestsProvider);

requests.when(
  data: (requestList) {
    if (requestList.isEmpty) {
      return Text('No pending requests');
    }
    
    return ListView.builder(
      itemCount: requestList.length,
      itemBuilder: (context, index) {
        final request = requestList[index];
        return Card(
          child: ListTile(
            title: Text('${request.requesterName} needs support'),
            subtitle: Text('${request.requesterDayCount} days clean'),
            trailing: ElevatedButton(
              onPressed: () => _respondToRequest(request.id),
              child: Text('Respond'),
            ),
          ),
        );
      },
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

#### Respond to Panic Request
```dart
final respondToRequest = ref.read(respondToPanicRequestProvider);

await respondToRequest.call(
  requestId: request.id,
  responderId: currentUserId,
  responderName: userName,
);
```

---

### Daily Reflections & Prayers

#### Get Today's Reflection
```dart
final reflection = ref.watch(todayReflectionProvider);

reflection.when(
  data: (refl) {
    if (refl == null) return Text('No reflection available');
    
    return Column(
      children: [
        Text(refl.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text(refl.content),
        SizedBox(height: 16),
        Text('- ${refl.author}', style: TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

#### Search Prayers
```dart
final searchPrayers = ref.read(searchPrayersProvider);

try {
  final prayers = await searchPrayers.call(
    'serenity',
    category: PrayerCategory.recovery, // optional
  );
  
  // Display prayer list
} catch (e) {
  showError('Search failed: $e');
}
```

---

### Community Features

#### Create a Support Group
```dart
final createGroup = ref.read(createGroupProvider);

try {
  final group = await createGroup.call(
    name: 'Daily Accountability Group',
    description: 'Morning check-ins and support',
    createdBy: currentUserId,
    category: GroupCategory.accountability,
    isPrivate: false,
    maxMembers: 20,
  );
  
  // Navigate to group
} catch (e) {
  showError('Failed to create group: $e');
}
```

#### Send Direct Message
```dart
final sendMessage = ref.read(sendDirectMessageProvider);

await sendMessage.call(
  senderId: currentUserId,
  senderName: userName,
  recipientId: recipientUserId,
  content: messageText,
);
```

---

### Content Moderation

#### Validate Message Before Sending
```dart
final moderationService = ref.read(moderationServiceProvider);

// Validate
final error = moderationService.validateMessage(messageText);
if (error != null) {
  showError(error);
  return;
}

// Check if needs review
if (moderationService.shouldFlagForReview(messageText)) {
  showWarning('Your message will be reviewed by moderators');
}

// Send message
await sendMessage(messageText);
```

#### Report Content
```dart
final reportContent = ref.read(reportContentProvider);

await reportContent.call(
  reportedBy: currentUserId,
  reason: 'Inappropriate content',
  description: 'Contains offensive language',
  reportedMessageId: messageId,
);
```

---

## 🎯 Best Practices

### 1. Use `ref.watch()` for UI Updates
```dart
// ✅ Good - UI updates automatically
final streak = ref.watch(currentStreakProvider);

// ❌ Bad - Won't update UI
final streak = ref.read(currentStreakProvider);
```

### 2. Use `ref.read()` for Actions
```dart
// ✅ Good - One-time action
onPressed: () {
  final useCase = ref.read(logSobrietyDayProvider);
  await useCase.call(...);
}

// ❌ Bad - Rebuilds on every change
onPressed: () {
  final useCase = ref.watch(logSobrietyDayProvider);
  await useCase.call(...);
}
```

### 3. Listen for State Changes
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Listen for authentication changes
  ref.listen(isAuthenticatedProvider, (previous, next) {
    if (!next) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  });
  
  return YourWidget();
}
```

### 4. Handle Async States
```dart
final data = ref.watch(someStreamProvider);

return data.when(
  data: (value) => Text('Data: $value'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### 5. Error Handling in Use Cases
```dart
try {
  await useCase.call(...);
  showSuccess('Operation successful');
} on ArgumentError catch (e) {
  // Validation errors
  showError(e.message);
} on Exception catch (e) {
  // Other errors
  showError('Operation failed: $e');
}
```

---

## 🔍 Debugging Tips

### Check Current User
```dart
final userId = ref.read(currentUserIdProvider);
print('Current user ID: $userId');

final isAuth = ref.read(isAuthenticatedProvider);
print('Is authenticated: $isAuth');
```

### Monitor Stream Updates
```dart
ref.listen(currentUserSobrietyLogsProvider, (previous, next) {
  print('Logs updated: ${next.value?.length} entries');
});
```

### Check Firebase Connection
```dart
final firebaseService = ref.read(firebaseServiceProvider);
print('Firebase initialized: ${firebaseService.isInitialized}');
print('User authenticated: ${firebaseService.isUserAuthenticated()}');
```

---

## 📦 Required Packages

Add to `pubspec.yaml` for full functionality:
```yaml
dependencies:
  flutter_riverpod: ^3.0.3  # ✅ Already added
  firebase_core: ^3.8.1      # ✅ Already added
  firebase_auth: ^6.1.2      # ✅ Already added
  cloud_firestore: ^6.1.0    # ✅ Already added
  firebase_messaging: ^15.1.5 # For push notifications
  flutter_local_notifications: ^17.0.0 # For local notifications
```

---

## 🆘 Common Issues

### Issue: "Provider not found"
**Solution**: Make sure your app is wrapped with `ProviderScope`:
```dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Issue: "Cannot use ref outside ConsumerWidget"
**Solution**: Use `ConsumerWidget` or `Consumer`:
```dart
// Option 1: ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}

// Option 2: Consumer wrapper
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) { ... }
    );
  }
}
```

### Issue: "Use case validation fails"
**Solution**: Check use case source code for validation rules:
- Email must be valid format
- Password must be 6+ characters
- User ID cannot be empty
- Mood rating must be 1-10

---

## 📚 Additional Resources

- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Flutter Setup](https://firebase.flutter.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Last Updated**: Implementation Complete
**Version**: 1.0
