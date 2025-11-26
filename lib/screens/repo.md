# Repositories Implementation Guide

## Overview
Repositories are the bridge between your app and Firebase. They handle all data operations (CRUD) and provide a clean interface for your use cases to interact with data.

**Key Principles:**
- Repositories work with Models (not Entities)
- They handle Firebase-specific logic
- They convert between Models and Entities
- They handle errors and return meaningful failures
- They provide both single operations and streams for real-time data

---

## Repository Architecture

### Base Structure
Each repository should:
1. Have a constructor that takes Firebase services
2. Use try-catch for error handling
3. Return `Future<Entity>` or `Stream<Entity>` (not Models)
4. Handle null cases gracefully
5. Log errors for debugging

---

## 1. Auth Repository

### Location
`lib/data/repositories/auth_repository.dart`

### Dependencies
- `FirebaseAuth`
- `FirestoreService` (for creating user documents)
- `UserModel`

### Methods to Implement

#### `Future<User> registerWithEmail(String email, String password, String displayName)`
**What it does:**
- Creates Firebase Auth account with email/password
- Creates Firestore user document with initial data
- Returns User entity

**Steps:**
1. Call `FirebaseAuth.instance.createUserWithEmailAndPassword()`
2. Get the created user's UID
3. Create a UserModel with:
   - uid from auth
   - displayName from parameter
   - email from parameter
   - isAnonymous = false
   - createdAt = now
   - Default preferences and stats
4. Save to Firestore collection `users/{uid}`
5. Return as User entity
6. Wrap in try-catch, throw custom exceptions

#### `Future<User> loginWithEmail(String email, String password)`
**What it does:**
- Signs in with Firebase Auth
- Fetches user document from Firestore
- Returns User entity

**Steps:**
1. Call `FirebaseAuth.instance.signInWithEmailAndPassword()`
2. Get UID from result
3. Fetch user document from Firestore
4. Convert to User entity
5. Update lastActive timestamp
6. Return User entity

#### `Future<User> loginAnonymously()`
**What it does:**
- Creates anonymous Firebase Auth account
- Generates random display name
- Creates Firestore user document
- Returns User entity

**Steps:**
1. Call `FirebaseAuth.instance.signInAnonymously()`
2. Generate display name: "Anonymous_" + random 4 digits
3. Create UserModel with isAnonymous = true
4. Save to Firestore
5. Return as User entity

#### `Future<void> logout()`
**What it does:**
- Signs out from Firebase Auth
- Clears any local cache

**Steps:**
1. Call `FirebaseAuth.instance.signOut()`
2. Clear local storage if needed

#### `Future<User?> getCurrentUser()`
**What it does:**
- Gets current logged-in user
- Returns null if not logged in

**Steps:**
1. Check `FirebaseAuth.instance.currentUser`
2. If null, return null
3. If exists, fetch from Firestore using UID
4. Return as User entity

#### `Stream<User?> authStateChanges()`
**What it does:**
- Listens to auth state changes
- Returns stream of User or null

**Steps:**
1. Listen to `FirebaseAuth.instance.authStateChanges()`
2. When user changes, fetch from Firestore
3. Convert to User entity
4. Emit to stream

#### `Future<void> sendPasswordResetEmail(String email)`
**What it does:**
- Sends password reset email

**Steps:**
1. Call `FirebaseAuth.instance.sendPasswordResetEmail(email: email)`
2. Handle errors

#### `Future<User> upgradeAnonymousAccount(String email, String password, String displayName)`
**What it does:**
- Converts anonymous account to permanent
- Links email/password credential

**Steps:**
1. Get current anonymous user
2. Create EmailAuthCredential
3. Call `user.linkWithCredential(credential)`
4. Update Firestore document with email, displayName
5. Set isAnonymous = false
6. Return updated User entity

---

## 2. User Repository

### Location
`lib/data/repositories/user_repository.dart`

### Dependencies
- `FirebaseFirestore`
- `UserModel`

### Methods to Implement

#### `Future<User> getUser(String userId)`
**What it does:**
- Fetches user document by ID

**Steps:**
1. Get document from `users/{userId}`
2. Check if exists
3. Convert to UserModel using `fromJson`
4. Return as User entity

#### `Future<void> updateUser(String userId, Map<String, dynamic> updates)`
**What it does:**
- Updates specific fields in user document

**Steps:**
1. Get document reference
2. Call `update(updates)`
3. Handle errors

#### `Future<void> setSobrietyStartDate(String userId, DateTime date)`
**What it does:**
- Sets user's sobriety start date
- Resets current streak if needed

**Steps:**
1. Calculate new streak from date
2. Update document with:
   - sobrietyStartDate
   - stats.currentStreak
3. Use transaction if updating multiple fields

#### `Future<void> updateAvailability(String userId, bool isAvailable)`
**What it does:**
- Updates volunteer availability for panic responses

**Steps:**
1. Update `isAvailable` field
2. Update `lastActive` timestamp

#### `Future<void> updatePreferences(String userId, UserPreferences preferences)`
**What it does:**
- Updates user notification preferences

**Steps:**
1. Convert preferences to map
2. Update `preferences` nested object
3. Handle errors

#### `Future<void> updateStats(String userId, UserStats stats)`
**What it does:**
- Updates user sobriety statistics

**Steps:**
1. Convert stats to map
2. Update `stats` nested object
3. Use transaction if reading before writing

#### `Future<List<User>> getAvailableVolunteers()`
**What it does:**
- Gets all users who are available volunteers

**Steps:**
1. Query Firestore where `isVolunteer == true` AND `isAvailable == true`
2. Order by `lastActive` descending
3. Limit to 50 results
4. Convert each to User entity
5. Return list

#### `Stream<User> userStream(String userId)`
**What it does:**
- Real-time stream of user data

**Steps:**
1. Use `snapshots()` on document reference
2. Convert each snapshot to User entity
3. Return stream

---

## 3. Sobriety Repository

### Location
`lib/data/repositories/sobriety_repository.dart`

### Dependencies
- `FirebaseFirestore`
- `SobrietyLogModel`

### Methods to Implement

#### `Future<void> saveLog(SobrietyLog log)`
**What it does:**
- Saves or updates a sobriety log entry

**Steps:**
1. Convert SobrietyLog to SobrietyLogModel
2. Call `toJson()`
3. Use `set()` with merge to save/update
4. Handle errors

#### `Future<SobrietyLog?> getLogForDate(String userId, DateTime date)`
**What it does:**
- Gets log entry for specific date

**Steps:**
1. Query where `userId == userId` AND `date == date`
2. Normalize date (start of day) for comparison
3. If found, convert to entity
4. Return null if not found

#### `Future<List<SobrietyLog>> getLogsForMonth(String userId, int year, int month)`
**What it does:**
- Gets all logs for a month

**Steps:**
1. Calculate start of month and end of month
2. Query where `userId == userId` AND `date >= start` AND `date <= end`
3. Order by `date` descending
4. Convert each to entity
5. Return list

#### `Future<List<SobrietyLog>> getLogsForDateRange(String userId, DateTime startDate, DateTime endDate)`
**What it does:**
- Gets logs between two dates

**Steps:**
1. Query with date range
2. Order by date
3. Convert and return

#### `Future<void> deleteLog(String logId)`
**What it does:**
- Deletes a log entry

**Steps:**
1. Delete document by ID
2. Handle errors

#### `Future<int> getCurrentStreak(String userId)`
**What it does:**
- Calculates current clean streak

**Steps:**
1. Get user's sobriety start date
2. Get all logs from start date to today
3. Iterate backwards from today
4. Count consecutive clean days
5. Stop at first relapse
6. Return count

#### `Future<int> getLongestStreak(String userId)`
**What it does:**
- Calculates longest streak ever

**Steps:**
1. Get all logs ordered by date
2. Iterate through and find longest consecutive clean period
3. Return max count

#### `Future<Map<String, int>> getTriggerInsights(String userId, int days)`
**What it does:**
- Gets most common triggers in last X days

**Steps:**
1. Get logs for last X days where status == relapse
2. Count frequency of each trigger
3. Return map of trigger -> count
4. Sort by count descending

#### `Stream<List<SobrietyLog>> logsStream(String userId)`
**What it does:**
- Real-time stream of user's logs

**Steps:**
1. Query collection with snapshots()
2. Where userId matches
3. Order by date descending
4. Convert each snapshot
5. Return stream

---

## 4. Panic Repository

### Location
`lib/data/repositories/panic_repository.dart`

### Dependencies
- `FirebaseFirestore`
- `PanicRequestModel`
- `NotificationService`

### Methods to Implement

#### `Future<PanicRequest> createRequest(PanicRequest request)`
**What it does:**
- Creates new panic request
- Notifies available volunteers

**Steps:**
1. Convert to PanicRequestModel
2. Save to Firestore
3. Call NotificationService to alert volunteers
4. Return created request

#### `Future<void> respondToRequest(String requestId, String responderId, String responderName)`
**What it does:**
- Claims a panic request
- Updates status to active

**Steps:**
1. Use transaction to check status is still pending
2. Update with responderId, responderName, status = active
3. If already claimed, throw error
4. Notify requester that help is coming

#### `Future<void> cancelRequest(String requestId)`
**What it does:**
- Cancels a panic request

**Steps:**
1. Update status to cancelled
2. Add timestamp
3. Notify responder if already assigned

#### `Future<void> resolveRequest(String requestId)`
**What it does:**
- Marks panic session as complete

**Steps:**
1. Update status to resolved
2. Set resolvedAt timestamp
3. Calculate session duration for analytics

#### `Future<PanicRequest?> getPendingRequest(String requestId)`
**What it does:**
- Gets a panic request by ID

**Steps:**
1. Fetch document
2. Check if exists
3. Convert to entity
4. Return null if not found

#### `Stream<PanicRequest> requestStream(String requestId)`
**What it does:**
- Real-time updates for a panic request

**Steps:**
1. Listen to document snapshots
2. Convert each update to entity
3. Return stream

#### `Stream<List<PanicRequest>> pendingRequestsStream()`
**What it does:**
- Stream of all pending panic requests
- For volunteers to see available requests

**Steps:**
1. Query where status == pending
2. Order by timestamp descending
3. Listen with snapshots()
4. Convert to list of entities
5. Return stream

#### `Future<List<PanicRequest>> getUserRequestHistory(String userId, {int limit = 20})`
**What it does:**
- Gets user's past panic requests

**Steps:**
1. Query where requesterId == userId
2. Order by timestamp descending
3. Limit results
4. Convert to list
5. Return list

---

## 5. Community Repository

### Location
`lib/data/repositories/community_repository.dart`

### Dependencies
- `FirebaseFirestore`
- `SponsorshipModel`
- `GroupModel`
- `MessageModel`

### Methods to Implement

#### `Future<void> createSponsorship(Sponsorship sponsorship)`
**What it does:**
- Creates sponsorship request

**Steps:**
1. Convert to model and save
2. Notify sponsor
3. Handle errors

#### `Future<void> acceptSponsorship(String sponsorshipId)`
**What it does:**
- Accepts sponsorship request

**Steps:**
1. Update status to active
2. Set acceptedAt timestamp
3. Notify sponsored user

#### `Future<void> endSponsorship(String sponsorshipId, String reason)`
**What it does:**
- Ends sponsorship relationship

**Steps:**
1. Update status to ended
2. Set endedAt and endReason
3. Notify both parties

#### `Future<Sponsorship?> getUserSponsorship(String userId)`
**What it does:**
- Gets user's active or pending sponsorship

**Steps:**
1. Query where sponsoredUserId == userId
2. Where status in [pending, active]
3. Return first result or null

#### `Future<List<User>> getAvailableSponsors()`
**What it does:**
- Gets users who can be sponsors

**Steps:**
1. Query users where isVolunteer == true
2. Where daysClean >= 90
3. Count their current sponsees
4. Filter out those at max (e.g., 3 sponsees)
5. Return list

#### `Future<Group> createGroup(Group group)`
**What it does:**
- Creates new group

**Steps:**
1. Convert to model
2. Save to Firestore
3. Add creator to memberIds
4. Return created group

#### `Future<void> joinGroup(String groupId, String userId)`
**What it does:**
- Adds user to group

**Steps:**
1. Use transaction to:
   - Check group not full
   - Add userId to memberIds array
   - Increment memberCount
2. Post system message "{user} joined"
3. Handle errors

#### `Future<void> leaveGroup(String groupId, String userId)`
**What it does:**
- Removes user from group

**Steps:**
1. Use transaction to:
   - Remove userId from memberIds
   - Decrement memberCount
2. Post system message "{user} left"

#### `Future<List<Group>> getUserGroups(String userId)`
**What it does:**
- Gets groups user is member of

**Steps:**
1. Query where memberIds array-contains userId
2. Convert to list of entities
3. Return list

#### `Future<List<Group>> browseGroups(GroupCategory? category)`
**What it does:**
- Gets available groups to join

**Steps:**
1. Query all groups (or by category if provided)
2. Where isPrivate == false
3. Order by memberCount descending
4. Limit to 50
5. Return list

#### `Future<void> sendMessage(Message message)`
**What it does:**
- Sends message to group or direct chat

**Steps:**
1. Convert to model and save
2. Run content moderation check
3. If flagged, update flaggedForReview
4. Increment group/conversation message count
5. Send push notification to members

#### `Future<List<Message>> getMessages(String conversationId, {int limit = 50})`
**What it does:**
- Gets messages for conversation

**Steps:**
1. Query where conversationId matches
2. Where deletedAt == null (exclude deleted)
3. Order by timestamp descending
4. Limit results
5. Return list

#### `Stream<List<Message>> messagesStream(String conversationId)`
**What it does:**
- Real-time messages stream

**Steps:**
1. Same query as getMessages
2. Use snapshots()
3. Convert each update
4. Return stream

#### `Future<void> deleteMessage(String messageId)`
**What it does:**
- Soft deletes a message

**Steps:**
1. Update deletedAt timestamp
2. Keep message for moderation records

#### `Future<void> reportContent(Report report)`
**What it does:**
- Reports message or user

**Steps:**
1. Save report to reports collection
2. Notify moderators
3. Auto-flag if keywords detected

#### `Future<void> postCelebration(Celebration celebration)`
**What it does:**
- Posts milestone celebration

**Steps:**
1. Save to celebrations collection
2. Initialize reaction and comment counts to 0
3. Notify followers/friends (future feature)

#### `Future<List<Celebration>> getCelebrations({int limit = 20})`
**What it does:**
- Gets recent celebrations feed

**Steps:**
1. Query celebrations collection
2. Order by timestamp descending
3. Limit results
4. Return list

#### `Future<void> reactToCelebration(String celebrationId, String userId)`
**What it does:**
- Adds reaction (clap) to celebration

**Steps:**
1. Use transaction to:
   - Check user hasn't already reacted
   - Increment reactionCount
   - Save reaction in subcollection
2. Notify celebration author

---

## 6. Reflection Repository

### Location
`lib/data/repositories/reflection_repository.dart`

### Dependencies
- `FirebaseFirestore`
- `DailyReflectionModel`
- `PrayerModel`

### Methods to Implement

#### `Future<DailyReflection?> getReflectionForDate(DateTime date)`
**What it does:**
- Gets reflection for specific date

**Steps:**
1. Format date as "YYYY-MM-DD"
2. Get document with that ID from daily_reflections
3. If exists, convert to entity
4. Return null if not found

#### `Future<DailyReflection?> getTodayReflection()`
**What it does:**
- Gets today's reflection

**Steps:**
1. Get current date
2. Call getReflectionForDate with today
3. Cache result locally for offline access
4. Return reflection

#### `Future<List<Prayer>> getPrayersByCategory(PrayerCategory category)`
**What it does:**
- Gets all prayers in a category

**Steps:**
1. Query prayers where category matches
2. Order by order field ascending
3. Convert to list
4. Return list

#### `Future<Prayer?> getPrayer(String prayerId)`
**What it does:**
- Gets specific prayer by ID

**Steps:**
1. Fetch document
2. Convert to entity
3. Return null if not found

#### `Future<List<Prayer>> searchPrayers(String query)`
**What it does:**
- Searches prayers by title or content

**Steps:**
1. Query prayers
2. Filter locally by checking if title or content contains query
   (Firestore doesn't have full-text search natively)
3. Return matching prayers

---

## 7. Moderation Repository

### Location
`lib/data/repositories/moderation_repository.dart`

### Dependencies
- `FirebaseFirestore`
- `ReportModel`
- `ModerationService` (external API)

### Methods to Implement

#### `Future<bool> checkContent(String content)`
**What it does:**
- Checks if content is appropriate
- Uses external moderation API

**Steps:**
1. Call ModerationService (Perspective API or similar)
2. Get toxicity score
3. Return true if safe, false if flagged
4. Log for monitoring

#### `Future<void> flagMessage(String messageId, String reason)`
**What it does:**
- Flags message for review

**Steps:**
1. Update message flaggedForReview = true
2. Create report record
3. Notify moderators

#### `Future<List<Report>> getPendingReports({int limit = 50})`
**What it does:**
- Gets reports needing review

**Steps:**
1. Query where status == pending
2. Order by createdAt descending
3. Limit results
4. Return list

#### `Future<void> reviewReport(String reportId, String reviewerId, ReportStatus newStatus)`
**What it does:**
- Moderator reviews report

**Steps:**
1. Update report with:
   - status = newStatus
   - reviewedBy = reviewerId
   - reviewedAt = now
2. Take action if needed (delete message, ban user)

---

## Error Handling Pattern

Every repository method should handle errors:

```dart
// Wrap operations in try-catch
try {
  // Firebase operation
  final result = await firestore.collection('users').doc(id).get();
  
  // Check if exists
  if (!result.exists) {
    throw NotFoundException('User not found');
  }
  
  // Convert and return
  return UserModel.fromJson(result.data()!);
  
} on FirebaseException catch (e) {
  // Firebase-specific errors
  throw DataException('Firebase error: ${e.message}');
  
} catch (e) {
  // Generic errors
  throw DataException('Failed to get user: $e');
}
```

---

## Repository Testing Checklist

For each repository method:
- [ ] Test successful operation
- [ ] Test with null/missing data
- [ ] Test error handling
- [ ] Test with invalid IDs
- [ ] Test concurrent operations (where applicable)
- [ ] Test transactions work correctly
- [ ] Mock Firebase for unit tests

---