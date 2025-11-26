/// App-wide string constants
class AppStrings {
  // App Name
  static const String appName = 'Freedom Path';
  static const String appSubtitle = 'Your Journey to Recovery';
  
  // Encouraging Quotes (rotate daily)
  static const List<String> encouragingQuotes = [
    "Stay strong in faith",
    "God is with you",
    "One day at a time",
    "You are not alone",
    "Progress, not perfection",
    "Christ strengthens me",
    "Grace upon grace",
    "Victory through prayer",
    "Trust in the Lord",
    "He makes all things new",
  ];
  
  // Error Messages
  static const String errorEmailInvalid = 'Please enter a valid email address';
  static const String errorPasswordWeak = 'Password must be at least 8 characters with 1 uppercase letter and 1 number';
  static const String errorDisplayNameInvalid = 'Display name must be between 3-30 characters';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  
  // Auth Messages
  static const String authInvalidCredentials = 'Invalid email or password';
  static const String authAccountNotFound = 'Account not found';
  static const String authTooManyAttempts = 'Too many attempts. Please try again later';
  
  // Crisis Hotline
  static const String crisisHotlineNumber = '1-800-273-8255';
  static const String crisisTextLine = 'Text HOME to 741741';
  
  // Prayers
  static const String jesusPrayerShort = 'Lord Jesus Christ, have mercy on me, a sinner.';
}
