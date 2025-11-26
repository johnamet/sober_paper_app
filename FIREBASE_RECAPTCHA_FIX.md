# Firebase reCAPTCHA Configuration Fix

## Problem
You're getting the error: `CONFIGURATION_NOT_FOUND` when trying to register/login.

This happens because Firebase requires your app's SHA-1 certificate fingerprint to be registered in the Firebase Console for authentication to work properly on Android.

## Your SHA-1 Fingerprint
```
28:F4:7C:8F:C4:88:A9:E0:03:6A:45:74:9A:13:8E:40:B4:C3:01:8C
```

## Solution: Add SHA-1 to Firebase Console

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project (sober_paper)

### Step 2: Open Project Settings
1. Click the **⚙️ gear icon** next to "Project Overview"
2. Select **Project Settings**

### Step 3: Find Your Android App
1. Scroll down to the **"Your apps"** section
2. Find your Android app (com.example.sober_paper)
3. If you don't see it, click **"Add app"** and select Android

### Step 4: Add SHA-1 Fingerprint
1. Under **SHA certificate fingerprints**, click **"Add fingerprint"**
2. Paste this SHA-1:
   ```
   28:F4:7C:8F:C4:88:A9:E0:03:6A:45:74:9A:13:8E:40:B4:C3:01:8C
   ```
3. Click **Save**

### Step 5: Download Updated google-services.json
1. In the same screen, click **"Download google-services.json"**
2. Replace the file in your project:
   ```bash
   # Backup old file
   mv android/app/google-services.json android/app/google-services.json.backup
   
   # Copy new file to android/app/
   cp ~/Downloads/google-services.json android/app/
   ```

### Step 6: Rebuild and Run
```bash
# Clean build
flutter clean
flutter pub get

# Run app
flutter run
```

## Alternative: Disable reCAPTCHA (Development Only)

If you want to disable reCAPTCHA for development/testing:

1. Go to Firebase Console
2. Navigate to **Authentication** → **Settings** → **Advanced**
3. Under **Manage sign-up quota**, you can adjust settings
4. Or use Firebase Auth Emulator for local testing

## Verification

After adding the SHA-1 and updating google-services.json:

1. Restart your app
2. Try registering with a new email
3. You should no longer see the CONFIGURATION_NOT_FOUND error

## Notes

- This SHA-1 is from your **debug keystore** (for development)
- When you release your app, you'll need to add the **release keystore** SHA-1 too
- If you use Google Play signing, add the **Play Console** SHA-1 as well

## Need Help?

If you still see errors after following these steps:
1. Make sure you replaced the google-services.json file
2. Run `flutter clean`
3. Rebuild the app completely
4. Check that your Firebase project has Authentication enabled
5. Verify the email/password sign-in method is enabled in Firebase Console

## Quick Test Command

To verify your SHA-1 fingerprint anytime:
```bash
cd android && ./gradlew signingReport | grep SHA1
```
