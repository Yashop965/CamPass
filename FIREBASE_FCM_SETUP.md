# Firebase Cloud Messaging (FCM) Setup Guide

## Overview

Firebase Cloud Messaging (FCM) enables push notifications from the backend to student and parent devices.

## Prerequisites

- Firebase project created at [https://firebase.google.com/](https://firebase.google.com/)
- Google Cloud project with billing enabled
- Android and iOS configurations completed

## Step 1: Android Configuration

### 1.1 Add Google Services Plugin

In `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

In `android/app/build.gradle`:

```gradle
plugins {
  id 'com.google.gms.google-services'
}
```

### 1.2 Download google-services.json

1. Go to Firebase Console → Project Settings
2. Click "google-services.json" download button
3. Copy file to `android/app/` directory

### 1.3 Set Minimum SDK Version

In `android/app/build.gradle`:

```gradle
android {
  minSdkVersion 21  // FCM requires API 21+
}
```

## Step 2: iOS Configuration

### 2.1 Add Apple Push Notification Capability

1. Open Xcode project: `ios/Runner.xcworkspace`
2. Select Runner target
3. Go to Signing & Capabilities
4. Click "Capability" → Add "Push Notifications"

### 2.2 Download APNs Certificate

1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Click "Apple Configuration"
3. Follow instructions to upload APNs key

### 2.3 Minimum iOS Version

In `ios/Podfile`:

```ruby
platform :ios, '11.0'  # FCM requires iOS 11+
```

## Step 3: Dart Code Integration

### 3.1 Initialization in main.dart

```dart
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService().initializeFirebase();

  runApp(const CampassApp());
}
```

### 3.2 Get FCM Token After Login

In `lib/providers/auth_provider.dart`:

```dart
// After successful login
final firebaseService = FirebaseService();
String? fcmToken = await firebaseService.getFCMToken();

// Send to backend to store with user
await updateUserFCMToken(fcmToken);
```

### 3.3 Subscribe to Topics on Login

In `lib/providers/auth_provider.dart`:

```dart
final firebaseService = FirebaseService();

if (userRole == 'student') {
  firebaseService.subscribeToStudentAlerts(userId);
} else if (userRole == 'parent') {
  firebaseService.subscribeToParentAlerts(userId);
} else if (userRole == 'admin' || userRole == 'warden') {
  firebaseService.subscribeToAdminAlerts();
}
```

### 3.4 Unsubscribe on Logout

In `lib/providers/auth_provider.dart`:

```dart
final firebaseService = FirebaseService();

if (userRole == 'student') {
  firebaseService.unsubscribeFromStudentAlerts(userId);
} else if (userRole == 'parent') {
  firebaseService.unsubscribeFromParentAlerts(userId);
} else if (userRole == 'admin' || userRole == 'warden') {
  firebaseService.unsubscribeFromAdminAlerts();
}
```

## Step 4: Backend Integration

### 4.1 Install Firebase Admin SDK (Node.js)

```bash
npm install firebase-admin
```

### 4.2 Initialize Firebase Admin

Create `src/config/firebase.js`:

```javascript
const admin = require("firebase-admin");

// Download service account key from Firebase Console
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
```

### 4.3 Send SOS Alert Notification

In `src/controllers/sos.controller.js`:

```javascript
const admin = require("../config/firebase");

// Send SOS alert to parents via FCM
const message = {
  notification: {
    title: "SOS Alert!",
    body: `${studentName} has triggered an emergency alert`,
  },
  data: {
    type: "sos_alert",
    studentId: sos.studentId,
    latitude: sos.latitude.toString(),
    longitude: sos.longitude.toString(),
  },
  topic: `parent_${studentId}_alerts`,
};

try {
  await admin.messaging().send(message);
  console.log("SOS notification sent to parents");
} catch (error) {
  console.error("Error sending SOS notification:", error);
}
```

### 4.4 Send Geofence Violation Notification

In `src/controllers/location.controller.js`:

```javascript
const admin = require("../config/firebase");

// Send geofence violation alert
const message = {
  notification: {
    title: "Geofence Violation",
    body: `${studentName} is outside campus geofence`,
  },
  data: {
    type: "geofence_violation",
    studentId: studentId,
    latitude: latitude.toString(),
    longitude: longitude.toString(),
  },
  topic: `parent_${studentId}_tracking`,
};

try {
  await admin.messaging().send(message);
} catch (error) {
  console.error("Error sending geofence notification:", error);
}
```

### 4.5 Store FCM Token

Create migration: `migrations/20251208-add-fcm-token-to-users.js`:

```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn("users", "fcm_token", {
      type: Sequelize.STRING,
      allowNull: true,
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn("users", "fcm_token");
  },
};
```

Update User model:

```javascript
fcm_token: {
  type: DataTypes.STRING,
  allowNull: true,
}
```

Create endpoint to update FCM token:

```javascript
// In src/routes/auth.routes.js
router.post("/update-fcm-token", authenticateToken, async (req, res) => {
  try {
    const { fcmToken } = req.body;

    const user = await User.findByPk(req.user.id);
    user.fcm_token = fcmToken;
    await user.save();

    res.json({ message: "FCM token updated" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

## Step 5: Testing

### Test FCM Token Generation

1. Run app: `flutter run`
2. Check console logs for "FCM Token: xxx"
3. Verify token is valid string

### Test Foreground Notifications

1. Send test notification from Firebase Console
2. Verify notification appears while app is open

### Test Background Notifications

1. Send test notification
2. Put app in background
3. Verify notification appears in system tray

### Test Notification Click Handling

1. Send notification
2. Click notification
3. Verify app opens and routes to correct screen

## Step 6: Notification Message Format

### SOS Alert Structure

```json
{
  "notification": {
    "title": "SOS Alert!",
    "body": "Student Name has triggered an emergency alert"
  },
  "data": {
    "type": "sos_alert",
    "studentId": "uuid",
    "latitude": "28.5355",
    "longitude": "77.2707"
  },
  "topic": "parent_PARENT_ID_alerts"
}
```

### Geofence Violation Structure

```json
{
  "notification": {
    "title": "Geofence Violation",
    "body": "Student Name is outside campus geofence"
  },
  "data": {
    "type": "geofence_violation",
    "studentId": "uuid",
    "latitude": "28.5355",
    "longitude": "77.2707"
  },
  "topic": "parent_PARENT_ID_tracking"
}
```

## Troubleshooting

### Issue: FCM Token is null

**Solution**:

- Ensure Push Notifications capability added (iOS)
- Check google-services.json is in correct location (Android)
- Verify Play Services installed on device

### Issue: Notifications not received

**Solution**:

- Check user subscribed to correct topic
- Verify backend Firebase Admin initialized correctly
- Check service account key has correct permissions
- Enable Cloud Messaging API in Google Cloud

### Issue: Notifications received but not displayed

**Solution**:

- Verify notification service initialized properly
- Check Android notification channels created
- Ensure app has notification permission granted

### Issue: Token refreshes frequently

**Solution**:

- This is normal behavior
- Always update backend when token refreshes
- Don't cache token locally for extended periods

## Production Considerations

### 1. Secure Service Account Key

- Never commit serviceAccountKey.json to version control
- Store as environment variable in production
- Rotate keys regularly

### 2. Rate Limiting

- Implement rate limiting for notifications
- Prevent notification spam to users
- Track notification history

### 3. User Preferences

- Allow users to disable certain notification types
- Store notification preferences in database
- Respect user privacy settings

### 4. Performance

- Use topic-based messaging for efficiency
- Group notifications for same student
- Clean up old notification tokens

## References

- [Firebase Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [FCM Concepts](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
