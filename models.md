# Data Models Implementation Guide

## Overview
This document details how to implement all data models for the Freedom Path app. Each model has three components:
1. **Entity** (domain layer) - Pure Dart objects with business logic
2. **Model** (data layer) - Extends entity, handles JSON serialization
3. **Firestore Structure** - Database schema

---

## 1. User Model

### Location
- Entity: `lib/domain/entities/user.dart`
- Model: `lib/data/models/user_model.dart`

### Entity Implementation (`user.dart`)

**Fields to include:**
- `String uid` - Firebase Auth user ID
- `String displayName` - User's display name (or generated anonymous name)
- `String? email` - Email (nullable for anonymous users)
- `bool isAnonymous` - Whether user is anonymous
- `DateTime? sobrietyStartDate` - When they started sobriety (nullable if not set)
- `String? sponsorId` - Their sponsor's user ID (nullable)
- `bool isVolunteer` - Can respond to panic requests
- `bool isAvailable` - Currently available for panic responses
- `DateTime? lastActive` - Last time they were active
- `DateTime createdAt` - Account creation date
- `UserPreferences preferences` - Nested preferences object
- `UserStats stats` - Nested stats object

**Computed properties to add:**
- `int get daysClean` - Calculate days from sobrietyStartDate to now
- `bool get hasSponsor` - Check if sponsorId is not null
- `bool get hasSetSobrietyDate` - Check if sobrietyStartDate is set

**Methods to include:**
- `User copyWith({...})` - For immutability, allows creating copy with changed fields

### UserPreferences Sub-class

**Fields:**
- `bool notifications` - Default true
- `String? dailyReminderTime` - Format "HH:mm" (e.g., "08:00")

**Methods:**
- `UserPreferences copyWith({...})`

### UserStats Sub-class

**Fields:**
- `int longestStreak` - Highest consecutive clean days achieved
- `int currentStreak` - Current consecutive clean days
- `int totalCleanDays` - Total clean days across all time

**Methods:**
- `UserStats copyWith({...})`

### Model Implementation (`user_model.dart`)

**What to implement:**
1. Extend the User entity
2. Add `factory UserModel.fromJson(Map<String, dynamic> json)` constructor
   - Handle null values safely
   - Parse timestamps to DateTime
   - Parse nested objects (preferences, stats)
3. Add `Map<String, dynamic> toJson()` method
   - Convert DateTime to ISO8601 strings
   - Convert nested objects to maps
   - Handle null values

**JSON field mapping:**
- Firestore uses camelCase field names
- DateTime fields stored as Firestore Timestamps (convert to/from)
- Nested objects stored as maps

### Firestore Document Structure

**Collection:** `users/{userId}`

**Document fields:**
```
{
  uid: string,
  displayName: string,
  email: string | null,
  isAnonymous: boolean,
  sobrietyStartDate: timestamp | null,
  sponsorId: string | null,
  isVolunteer: boolean,
  isAvailable: boolean,
  lastActive: timestamp,
  createdAt: timestamp,
  preferences: {
    notifications: boolean,
    dailyReminderTime: string | null
  },
  stats: {
    longestStreak: number,
    currentStreak: number,
    totalCleanDays: number
  }
}
```

---

## 2. SobrietyLog Model

### Location
- Entity: `lib/domain/entities/sobriety_log.dart`
- Model: `lib/data/models/sobriety_log_model.dart`

### Entity Implementation

**Create enum first:**
```dart
enum SobrietyStatus { clean, relapse }
```

**Fields:**
- `String id` - Unique log ID (UUID)
- `String userId` - User who created the log
- `DateTime date` - Date of the log (day only, no time)
- `SobrietyStatus status` - clean or relapse
- `String? mood` - Optional mood (e.g., "Peaceful", "Struggling")
- `List<String> triggers` - List of trigger names (default empty list)
- `String? notes` - Optional journal entry
- `DateTime createdAt` - When log was created

**Computed properties:**
- `bool get isClean` - Returns true if status is clean
- `bool get isRelapse` - Returns true if status is relapse
- `bool get hasMood` - Check if mood is not null
- `bool get hasTriggers` - Check if triggers list is not empty
- `bool get hasNotes` - Check if notes is not null

**Methods:**
- `SobrietyLog copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend SobrietyLog entity
2. `fromJson` factory:
   - Parse status enum from string (use `SobrietyStatus.values.byName`)
   - Parse date timestamp
   - Parse triggers array
   - Handle all nullable fields
3. `toJson` method:
   - Convert status enum to string (use `.name`)
   - Convert date to timestamp
   - Convert triggers list to array
   - Handle nulls

### Firestore Document Structure

**Collection:** `sobriety_logs/{logId}`

**Document fields:**
```
{
  id: string,
  userId: string,
  date: timestamp,
  status: string ("clean" | "relapse"),
  mood: string | null,
  triggers: array<string>,
  notes: string | null,
  createdAt: timestamp
}
```

**Indexes needed:**
- Composite: `userId` + `date` (descending)

---

## 3. PanicRequest Model

### Location
- Entity: `lib/domain/entities/panic_request.dart`
- Model: `lib/data/models/panic_request_model.dart`

### Entity Implementation

**Create enums:**
```dart
enum PanicStatus { pending, active, resolved, cancelled }
enum ConnectionType { chat, call }
```

**Fields:**
- `String id` - Request ID
- `String requesterId` - User who needs help
- `String requesterName` - Display name
- `int requesterDayCount` - Days clean (for context)
- `DateTime timestamp` - When request was created
- `PanicStatus status` - Current status
- `String? responderId` - Who responded (nullable)
- `String? responderName` - Responder's name (nullable)
- `ConnectionType connectionType` - chat or call
- `DateTime? resolvedAt` - When session ended (nullable)

**Computed properties:**
- `bool get isPending` - status == pending
- `bool get isActive` - status == active
- `bool get isResolved` - status == resolved
- `bool get isCancelled` - status == cancelled
- `bool get hasResponder` - responderId is not null
- `Duration get waitTime` - Difference between now and timestamp
- `Duration? get sessionDuration` - If resolved, difference between timestamp and resolvedAt

**Methods:**
- `PanicRequest copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend PanicRequest entity
2. `fromJson`:
   - Parse both enums from strings
   - Handle nullable responder fields
   - Parse timestamps
3. `toJson`:
   - Convert enums to strings
   - Handle nulls
   - Convert timestamps

### Firestore Document Structure

**Collection:** `panic_requests/{requestId}`

**Document fields:**
```
{
  id: string,
  requesterId: string,
  requesterName: string,
  requesterDayCount: number,
  timestamp: timestamp,
  status: string ("pending" | "active" | "resolved" | "cancelled"),
  responderId: string | null,
  responderName: string | null,
  connectionType: string ("chat" | "call"),
  resolvedAt: timestamp | null
}
```

**Indexes needed:**
- Composite: `status` + `timestamp` (descending)

---

## 4. Sponsorship Model

### Location
- Entity: `lib/domain/entities/sponsorship.dart`
- Model: `lib/data/models/sponsorship_model.dart`

### Entity Implementation

**Create enum:**
```dart
enum SponsorshipStatus { pending, active, ended }
```

**Fields:**
- `String id` - Sponsorship ID
- `String sponsorId` - Sponsor's user ID
- `String sponsoredUserId` - Sponsee's user ID
- `DateTime requestedAt` - When request was sent
- `DateTime? acceptedAt` - When sponsor accepted (nullable)
- `SponsorshipStatus status` - Current status
- `DateTime? endedAt` - When relationship ended (nullable)
- `String? endReason` - Why it ended (nullable)

**Computed properties:**
- `bool get isPending` - status == pending
- `bool get isActive` - status == active
- `bool get isEnded` - status == ended
- `Duration? get activeDuration` - If active, difference between acceptedAt and now

**Methods:**
- `Sponsorship copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend Sponsorship entity
2. `fromJson`:
   - Parse status enum
   - Handle nullable datetime fields
3. `toJson`:
   - Convert enum to string
   - Handle nulls

### Firestore Document Structure

**Collection:** `sponsorships/{sponsorshipId}`

**Document fields:**
```
{
  id: string,
  sponsorId: string,
  sponsoredUserId: string,
  requestedAt: timestamp,
  acceptedAt: timestamp | null,
  status: string ("pending" | "active" | "ended"),
  endedAt: timestamp | null,
  endReason: string | null
}
```

**Indexes needed:**
- Single field: `sponsorId`
- Single field: `sponsoredUserId`
- Composite: `sponsorId` + `status`
- Composite: `sponsoredUserId` + `status`

---

## 5. Group Model

### Location
- Entity: `lib/domain/entities/group.dart`
- Model: `lib/data/models/group_model.dart`

### Entity Implementation

**Create enum:**
```dart
enum GroupCategory { support, prayer, discussion }
```

**Fields:**
- `String id` - Group ID
- `String name` - Group name
- `String description` - Group description
- `String createdBy` - Creator's user ID
- `DateTime createdAt` - When group was created
- `List<String> memberIds` - List of member user IDs
- `int memberCount` - Cached count of members
- `bool isPrivate` - Whether group is private
- `int maxMembers` - Maximum allowed members (default 50)
- `GroupCategory category` - Group type

**Computed properties:**
- `bool get isFull` - memberCount >= maxMembers
- `bool isMember(String userId)` - Check if userId is in memberIds
- `int get availableSlots` - maxMembers - memberCount

**Methods:**
- `Group copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend Group entity
2. `fromJson`:
   - Parse category enum
   - Parse memberIds array
   - Handle all fields
3. `toJson`:
   - Convert enum to string
   - Convert memberIds list to array

### Firestore Document Structure

**Collection:** `groups/{groupId}`

**Document fields:**
```
{
  id: string,
  name: string,
  description: string,
  createdBy: string,
  createdAt: timestamp,
  memberIds: array<string>,
  memberCount: number,
  isPrivate: boolean,
  maxMembers: number,
  category: string ("support" | "prayer" | "discussion")
}
```

**Indexes needed:**
- Single field: `category`
- Composite: `category` + `isPrivate`

---

## 6. Message Model

### Location
- Entity: `lib/domain/entities/message.dart`
- Model: `lib/data/models/message_model.dart`

### Entity Implementation

**Create enum:**
```dart
enum ConversationType { group, direct }
```

**Fields:**
- `String id` - Message ID
- `String conversationId` - Group ID or "userId1_userId2" for direct
- `ConversationType conversationType` - group or direct
- `String senderId` - User who sent message
- `String senderName` - Sender's display name
- `String content` - Message text
- `DateTime timestamp` - When sent
- `bool flaggedForReview` - If flagged by moderation
- `DateTime? reviewedAt` - When reviewed by moderator (nullable)
- `DateTime? deletedAt` - When deleted (nullable)

**Computed properties:**
- `bool get isDeleted` - deletedAt is not null
- `bool get needsReview` - flaggedForReview && reviewedAt == null
- `bool get isGroup` - conversationType == group
- `bool get isDirect` - conversationType == direct

**Methods:**
- `Message copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend Message entity
2. `fromJson`:
   - Parse conversationType enum
   - Handle nullable datetime fields
3. `toJson`:
   - Convert enum to string
   - Handle nulls

### Firestore Document Structure

**Collection:** `messages/{messageId}`

**Document fields:**
```
{
  id: string,
  conversationId: string,
  conversationType: string ("group" | "direct"),
  senderId: string,
  senderName: string,
  content: string,
  timestamp: timestamp,
  flaggedForReview: boolean,
  reviewedAt: timestamp | null,
  deletedAt: timestamp | null
}
```

**Indexes needed:**
- Composite: `conversationId` + `timestamp` (descending)
- Composite: `conversationId` + `deletedAt` + `timestamp`

---

## 7. DailyReflection Model

### Location
- Entity: `lib/domain/entities/daily_reflection.dart`
- Model: `lib/data/models/daily_reflection_model.dart`

### Entity Implementation

**Fields:**
- `String date` - Date string in format "YYYY-MM-DD" (used as document ID)
- `String title` - Reflection title
- `String content` - Main reflection text (200-400 words)
- `String? bibleVerse` - Optional Bible verse text
- `String? verseReference` - Optional reference (e.g., "John 3:16")
- `String prayer` - Closing prayer
- `String? author` - Optional author name
- `DateTime createdAt` - When created

**Computed properties:**
- `bool get hasVerseReference` - verseReference is not null
- `bool get hasBibleVerse` - bibleVerse is not null
- `bool get hasAuthor` - author is not null
- `DateTime get dateAsDateTime` - Parse date string to DateTime

**Methods:**
- `DailyReflection copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend DailyReflection entity
2. `fromJson`:
   - Date is already a string
   - Handle nullable fields
3. `toJson`:
   - Keep date as string
   - Handle nulls

### Firestore Document Structure

**Collection:** `daily_reflections/{YYYY-MM-DD}`

**Document fields:**
```
{
  date: string ("YYYY-MM-DD"),
  title: string,
  content: string,
  bibleVerse: string | null,
  verseReference: string | null,
  prayer: string,
  author: string | null,
  createdAt: timestamp
}
```

**Note:** Document ID is the date string itself for easy lookup

---

## 8. Prayer Model

### Location
- Entity: `lib/domain/entities/prayer.dart`
- Model: `lib/data/models/prayer_model.dart`

### Entity Implementation

**Create enum:**
```dart
enum PrayerCategory { morning, evening, rosary, emergency, liturgy }
```

**Fields:**
- `String id` - Prayer ID
- `String title` - Prayer name
- `PrayerCategory category` - Category
- `String content` - Prayer text
- `String? latinVersion` - Optional Latin version
- `String? notes` - Optional notes about prayer
- `int order` - Display order within category

**Computed properties:**
- `bool get hasLatinVersion` - latinVersion is not null
- `bool get hasNotes` - notes is not null

**Methods:**
- `Prayer copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend Prayer entity
2. `fromJson`:
   - Parse category enum
   - Handle nullable fields
3. `toJson`:
   - Convert enum to string
   - Handle nulls

### Firestore Document Structure

**Collection:** `prayers/{prayerId}`

**Document fields:**
```
{
  id: string,
  title: string,
  category: string ("morning" | "evening" | "rosary" | "emergency" | "liturgy"),
  content: string,
  latinVersion: string | null,
  notes: string | null,
  order: number
}
```

**Indexes needed:**
- Composite: `category` + `order` (ascending)

---

## 9. Report Model

### Location
- Entity: `lib/domain/entities/report.dart`
- Model: `lib/data/models/report_model.dart`

### Entity Implementation

**Create enum:**
```dart
enum ReportStatus { pending, reviewed, actionTaken, dismissed }
```

**Fields:**
- `String id` - Report ID
- `String reportedBy` - User who reported
- `String? reportedUserId` - Reported user (nullable, can report messages too)
- `String? reportedMessageId` - Reported message (nullable)
- `String? reportedGroupId` - Context: which group (nullable)
- `String reason` - Predefined reason (e.g., "Harassment", "Inappropriate Content")
- `String description` - User's explanation
- `ReportStatus status` - Current status
- `String? reviewedBy` - Moderator who reviewed (nullable)
- `DateTime? reviewedAt` - When reviewed (nullable)
- `DateTime createdAt` - When reported

**Computed properties:**
- `bool get isPending` - status == pending
- `bool get isReviewed` - reviewedAt is not null
- `bool get isUserReport` - reportedUserId is not null
- `bool get isMessageReport` - reportedMessageId is not null

**Methods:**
- `Report copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend Report entity
2. `fromJson`:
   - Parse status enum
   - Handle many nullable fields
3. `toJson`:
   - Convert enum to string
   - Handle nulls

### Firestore Document Structure

**Collection:** `reports/{reportId}`

**Document fields:**
```
{
  id: string,
  reportedBy: string,
  reportedUserId: string | null,
  reportedMessageId: string | null,
  reportedGroupId: string | null,
  reason: string,
  description: string,
  status: string ("pending" | "reviewed" | "actionTaken" | "dismissed"),
  reviewedBy: string | null,
  reviewedAt: timestamp | null,
  createdAt: timestamp
}
```

**Indexes needed:**
- Single field: `status`
- Composite: `status` + `createdAt` (descending)

---

## 10. Celebration Model

### Location
- Entity: `lib/domain/entities/celebration.dart`
- Model: `lib/data/models/celebration_model.dart`

### Entity Implementation

**Fields:**
- `String id` - Celebration ID
- `String userId` - User celebrating
- `String userName` - Display name
- `int dayCount` - Milestone day count (7, 30, 90, etc.)
- `String? message` - Optional custom message
- `DateTime timestamp` - When posted
- `int reactionCount` - Count of reactions (claps)
- `int commentCount` - Count of comments

**Computed properties:**
- `bool get hasMessage` - message is not null
- `bool get isMajorMilestone` - dayCount in [30, 90, 180, 365]

**Methods:**
- `Celebration copyWith({...})`

### Model Implementation

**What to implement:**
1. Extend Celebration entity
2. `fromJson`:
   - Handle nullable message
   - Parse counts as integers
3. `toJson`:
   - Handle nulls

### Firestore Document Structure

**Collection:** `celebrations/{celebrationId}`

**Document fields:**
```
{
  id: string,
  userId: string,
  userName: string,
  dayCount: number,
  message: string | null,
  timestamp: timestamp,
  reactionCount: number,
  commentCount: number
}
```

**Indexes needed:**
- Single field: `timestamp` (descending)

---

## Implementation Checklist

For each model, follow this process:

### 1. Create Entity Class
- [ ] Create file in `lib/domain/entities/`
- [ ] Define all fields with correct types
- [ ] Make fields `final` for immutability
- [ ] Add enums if needed
- [ ] Implement computed properties (getters)
- [ ] Implement `copyWith` method
- [ ] Add constructor with required/optional parameters
- [ ] Set default values where appropriate

### 2. Create Model Class
- [ ] Create file in `lib/data/models/`
- [ ] Extend the entity class
- [ ] Implement `fromJson` factory constructor
  - [ ] Handle null values safely with null-aware operators (`?.`, `??`)
  - [ ] Parse timestamps: `(json['date'] as Timestamp).toDate()`
  - [ ] Parse enums: `EnumName.values.byName(json['field'])`
  - [ ] Parse arrays: `List<String>.from(json['field'] ?? [])`
  - [ ] Parse nested objects if any
- [ ] Implement `toJson` method
  - [ ] Convert DateTime: `date.toIso8601String()` or use `Timestamp.fromDate()`
  - [ ] Convert enums: `status.name`
  - [ ] Handle null values: `'field': field ?? null`
- [ ] Add `fromFirestore` helper if needed (converts Firestore DocumentSnapshot)
- [ ] Add `toFirestore` helper if needed (for Firestore-specific conversions)

### 3. Test the Model
- [ ] Create test data JSON
- [ ] Test `fromJson` with valid data
- [ ] Test `fromJson` with null optional fields
- [ ] Test `toJson` produces correct structure
- [ ] Test round-trip: `fromJson(toJson(object))` equals original

### 4. Document Usage
- [ ] Add dartdoc comments to entity class
- [ ] Document each field purpose
- [ ] Document computed properties
- [ ] Add usage examples in comments

---

## Common Patterns

### Handling Timestamps
```dart
// In fromJson:
timestamp: (json['timestamp'] as Timestamp).toDate(),

// In toJson:
'timestamp': Timestamp.fromDate(timestamp),
```

### Handling Nullable Fields
```dart
// In fromJson:
email: json['email'] as String?,
triggers: json['triggers'] != null 
    ? List<String>.from(json['triggers']) 
    : [],

// In toJson:
'email': email,  // Dart handles null automatically
'triggers': triggers,
```

### Handling Enums
```dart
// In fromJson:
status: SobrietyStatus.values.byName(json['status'] as String),

// In toJson:
'status': status.name,
```

### Handling Nested Objects
```dart
// In fromJson:
preferences: UserPreferences(
  notifications: json['preferences']['notifications'] as bool,
  dailyReminderTime: json['preferences']['dailyReminderTime'] as String?,
),

// In toJson:
'preferences': {
  'notifications': preferences.notifications,
  'dailyReminderTime': preferences.dailyReminderTime,
},
``