# CAMPASS Project - Deployment & Integration Guide

## Project Overview

CAMPASS is a comprehensive Smart Campus Pass system with real-time location tracking, SOS emergency alerts, and role-based dashboards:

- **Backend**: Node.js + Express + PostgreSQL + Sequelize + Firebase Admin SDK
- **Frontend**: Flutter mobile app with 5 role-based modules
- **Features**:
  - Barcode/QR code pass system with approval workflow
  - Real-time student location tracking with geofence alerts
  - One-tap emergency SOS system with location capture
  - Firebase Cloud Messaging push notifications with custom sounds
  - Parent approval and tracking portal
  - Admin dashboard with analytics
  - Guard barcode scanning module
  - Role-based access control (Student, Parent, Admin, Guard, Warden)

---

## System Architecture

### Technology Stack

-

### Frontend (Flutter)

- Flutter 3.x with Dart 2.18+
- State Management: Provider pattern
- Push Notifications: Firebase Cloud Messaging (FCM)
- Local Notifications: flutter_local_notifications
- Location Services: Geolocator + Google Maps
- Barcode Scanning: mobile_scanner package
- Authentication: JWT with Flutter Secure Storage

### Backend (Node.js)

- Express.js 5.x
- PostgreSQL with Sequelize ORM
- Firebase Admin SDK for push notifications
- JWT-based authentication with bcrypt hashing
- RESTful API architecture

### Key Features Implementation

| Feature             | Frontend                 | Backend                     | Status   |
| ------------------- | ------------------------ | --------------------------- | -------- |
| User Authentication | ✅ JWT tokens            | ✅ Login/Register endpoints | Complete |
| Pass Management     | ✅ QR/Barcode generation | ✅ Pass CRUD & approval     | Complete |
| Guard Scanning      | ✅ Mobile Scanner UI     | ✅ Barcode verification     | Complete |
| Location Tracking   | ✅ Geolocator + Maps     | ✅ Location API             | Complete |
| SOS Alerts          | ✅ Shake gesture trigger | ✅ FCM notifications        | Complete |
| Push Notifications  | ✅ FCM integration       | ✅ Admin SDK setup          | Complete |
| Audio Notifications | ✅ Asset manager         | ✅ Custom sounds            | Complete |
| Parent Dashboard    | ✅ Tracking + Approvals  | ✅ Parent-specific APIs     | Complete |
| Admin Dashboard     | ✅ User & pass mgmt      | ✅ Analytics endpoints      | Complete |
| Guard Portal        | ✅ Scan history          | ✅ Scan endpoints           | Complete |

---

## Pre-Deployment Requirements

### System Requirements

- **Server**: Ubuntu 20.04+ / CentOS 8+ / Windows Server 2019+
- **RAM**: 4GB minimum (8GB recommended)
- **Storage**: 20GB minimum
- **Network**: Stable internet connection with static IP recommended

### Required Software

- **Node.js**: v16.x or higher
- **PostgreSQL**: v12 or higher
- **Flutter**: 3.x
- **Dart**: 2.18+
- **Git**: Latest version

## Backend Setup

### Installation Steps

## Backend Setup

### Installation Steps

1. **Install Dependencies**

```bash
cd backend
npm install firebase-admin
npm install
```

1. **Configure Environment Variables**

Create `.env` file:

```
PORT=5000
NODE_ENV=development
DB_HOST=127.0.0.1
DB_PORT=5432
DB_NAME=campass
DB_USER=postgres
DB_PASS=your_password
JWT_SECRET=your_secret_key
JWT_EXPIRES_IN=7d
BARCODE_OUTPUT_DIR=./docs/barcodes
FIREBASE_PROJECT_ID=your-firebase-project
```

1. **Create PostgreSQL Database**

```sql
CREATE DATABASE campass;
CREATE USER your_user WITH PASSWORD 'your_password';
ALTER ROLE your_user SET client_encoding TO 'utf8';
ALTER ROLE your_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE your_user SET default_transaction_deferrable TO on;
ALTER ROLE your_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE campass TO your_user;
```

1. **Run Migrations**

```bash
npx sequelize-cli db:migrate
```

1. **Seed Data** (optional)

```bash
npx sequelize-cli db:seed:all
```

1. **Download Firebase Service Account Key**

- Go to Firebase Console → Project Settings → Service Accounts
- Click "Generate new private key"
- Save as `serviceAccountKey.json` in backend root
- Add to `.gitignore` to prevent accidental commit

1. **Start Backend Server**

```bash
npm start
# or for development:
npm run dev
```

Server runs on: `http://localhost:5000`

---

## Frontend Setup

### Installation Steps

1. **Get Dependencies**

   ```bash
   cd frontend/campass_app
   flutter pub get
   ```

2. **Update API Base URL**

   Edit `lib/core/constants/api_endpoints.dart`:

   ```dart
   class ApiEndpoints {
     static const String baseUrl = 'http://YOUR_BACKEND_IP:5000';
     // ... other endpoints
   }
   ```

   For local testing:

   - Android Emulator: `http://10.0.2.2:5000`
   - iOS Simulator: `http://localhost:5000`
   - Physical Device: `http://YOUR_PC_IP:5000`

3. **Configure Permissions** (Android)

   Edit `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.CAMERA" />
   ```

4. **Run the App**

   ```bash
   # Get list of connected devices
   flutter devices

   # Run on emulator/device
   flutter run -d <device_id>

   # Or simply run on default device
   flutter run
   ```

---

## Feature Implementation Details

### 1. SOS Alert Feature (Shake Gesture)

**Flow:**

1. Student shakes phone 4 times within 500ms
2. App captures current location
3. Sends SOS alert to backend with coordinates
4. Backend creates SOS record and triggers notifications:
   - Push notification to parents (with beep/alarm sound)
   - Alert to warden
   - Alert to admin

**Implementation:**

- File: `lib/screens/student/sos_screen.dart`
- Provider: `lib/providers/sos_provider.dart`
- Service: `lib/services/sos_service.dart`
- Backend: `src/controllers/sos.controller.js`

**Backend Endpoints:**

- `POST /api/sos/alert` - Send SOS alert
- `GET /api/sos/active` - Get active SOS alerts
- `PATCH /api/sos/:sosId/resolve` - Resolve alert
- `GET /api/sos/history/:studentId` - Get SOS history

---

### 2. Geofence & Live Tracking

**Flow:**

1. Student enables location tracking
2. App periodically sends location to backend
3. Backend checks if location is within geofence (500m from campus center)
4. If outside geofence:
   - Automatic SOS alert is triggered
   - Parents receive notification
   - Location is marked as "geofence violation"

**Geofence Parameters:**

- Campus Center: Latitude 28.5355, Longitude 77.2707 (Delhi example)
- Radius: 500 meters

**Implementation:**

- File: `lib/screens/student/location_tracking_screen.dart`
- Provider: `lib/providers/location_provider.dart`
- Service: `lib/services/location_service.dart`
- Backend: `src/controllers/location.controller.js`

**Backend Endpoints:**

- `POST /api/location/update` - Update student location
- `GET /api/location/student/:studentId` - Get current location
- `GET /api/location/history/:studentId` - Get location history
- `GET /api/location/violations` - Get geofence violations

---

### 3. Notifications with Beep Sound (Parents Only)

**Implementation:**

- File: `lib/services/notification_service.dart`
- Uses: `flutter_local_notifications` + `firebase_messaging`

**For Parents to Receive Beep:**

1. Set up Firebase Cloud Messaging (FCM) in your app
2. When SOS alert is triggered, backend sends push notification to parent's FCM token
3. App shows notification with high-priority alert sound
4. Sound file: `android/app/src/main/res/raw/sos_alarm.mp3`

---

## API Integration

### Authentication Flow

1. **Register/Login**

   ```dart
   final authService = AuthService();
   final response = await authService.login(
     email: 'student@college.com',
     password: 'password123',
   );

   final token = response['token'];
   final user = response['user'];
   ```

2. **Token Storage**
   - Tokens are automatically saved to secure storage
   - Passed in all subsequent API requests via `Authorization: Bearer <token>` header

### Example API Usage

**Send SOS Alert:**

```dart
final sosProvider = Provider.of<SOSProvider>(context, listen: false);
await sosProvider.sendSOSAlert(
  studentId: userId,
  token: authToken,
);
```

**Update Location:**

```dart
final locationProvider = Provider.of<LocationProvider>(context, listen: false);
await locationProvider.initializeLocationTracking(
  studentId: userId,
  token: authToken,
);
```

---

## Database Schema

### Models Created

1. **User** - Student, Parent, Warden, Guard, Admin

   - id, name, email, password, role, timestamps

2. **Pass** - Barcode passes

   - id, userId, type, validFrom, validTo, barcode, barcodeImagePath, status

3. **SOS** - Emergency alerts

   - id, studentId, latitude, longitude, alertType, status, resolvedAt, resolvedBy

4. **Location** - GPS tracking
   - id, studentId, latitude, longitude, timestamp, accuracy, isGeofenceViolation

---

## Testing & Verification

### Backend Testing

```bash
# Test login endpoint
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@college.com","password":"password123"}'

# Test SOS endpoint (with token)
curl -X POST http://localhost:5000/api/sos/alert \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"studentId":"UUID","latitude":28.5355,"longitude":77.2707}'
```

### Frontend Testing

1. Run app in emulator/device
2. Navigate to Student Dashboard
3. Test SOS button (manual trigger)
4. Test Location Tracking screen
5. Verify notifications appear

---

## Common Issues & Solutions

### Issue: "Connection refused" error

**Solution:**

- Ensure backend is running on correct IP
- Update `api_endpoints.dart` with correct IP
- Check firewall settings

### Issue: Location permissions not granted

**Solution:**

- Grant location permissions through app settings
- Ensure `AndroidManifest.xml` has location permissions declared
- For iOS, update `Info.plist` with location usage description

### Issue: Notifications not showing

**Solution:**

- Ensure `flutter_local_notifications` is properly initialized
- Check notification channel configuration
- Verify app has notification permissions

### Issue: Database connection error

**Solution:**

- Verify PostgreSQL is running
- Check database credentials in `.env`
- Ensure database exists and user has permissions

---

## Project Structure Summary

```
CAMPASS/
├── backend/
│   ├── src/
│   │   ├── models/
│   │   │   ├── user.js
│   │   │   ├── pass.js
│   │   │   ├── sos.js          (NEW)
│   │   │   └── location.js      (NEW)
│   │   ├── controllers/
│   │   │   ├── auth.controller.js
│   │   │   ├── pass.controller.js
│   │   │   ├── sos.controller.js (NEW)
│   │   │   └── location.controller.js (NEW)
│   │   ├── routes/
│   │   │   ├── auth.routes.js
│   │   │   ├── pass.routes.js
│   │   │   ├── sos.routes.js    (NEW)
│   │   │   └── location.routes.js (NEW)
│   │   └── middleware/
│   │       └── auth.middleware.js
│   ├── server.js (UPDATED)
│   └── package.json
│
├── frontend/campass_app/
│   ├── lib/
│   │   ├── screens/student/
│   │   │   ├── student_dashboard.dart
│   │   │   ├── sos_screen.dart          (UPDATED)
│   │   │   ├── location_tracking_screen.dart (NEW)
│   │   │   └── ...
│   │   ├── services/
│   │   │   ├── sos_service.dart         (NEW)
│   │   │   ├── location_service.dart    (NEW)
│   │   │   ├── notification_service.dart (UPDATED)
│   │   │   └── ...
│   │   ├── providers/
│   │   │   ├── sos_provider.dart        (NEW)
│   │   │   ├── location_provider.dart   (UPDATED)
│   │   │   └── ...
│   │   ├── utils/
│   │   │   ├── shake_detector.dart      (NEW)
│   │   │   ├── api_client.dart          (UPDATED)
│   │   │   └── ...
│   │   └── core/constants/
│   │       └── api_endpoints.dart       (UPDATED)
│   ├── pubspec.yaml (UPDATED)
│   └── ...
```

---

## Firebase Cloud Messaging (FCM) Setup

### Backend Configuration

1. **Add Firebase Admin SDK to package.json** ✅ COMPLETED

Firebase Admin SDK is already installed. It enables:

- Sending push notifications to topics
- Device token management
- Multicast messaging
- SOS and geofence notifications

2. **Initialize Firebase in Backend**

File: `src/config/firebase.js`

Functions implemented:

- `initializeFirebase()` - Initialize Firebase Admin SDK
- `sendToTopic(topic, notification, data)` - Send to topic
- `sendSOSAlert(topic, studentName, studentId, latitude, longitude)` - SOS notifications
- `sendGeofenceViolation(topic, studentName, studentId, latitude, longitude)` - Geofence alerts

3. **Update User Model with FCM Token** ✅ COMPLETED

Migration: `migrations/20251208-add-fcm-token-to-users.js`
Model: `src/models/user.js` - Added `fcm_token` field

4. **FCM Token Endpoint** ✅ COMPLETED

Route: `POST /api/auth/update-fcm-token`

After user login, frontend calls:

```javascript
const response = await apiClient.post(
  "/api/auth/update-fcm-token",
  { fcmToken: token },
  { headers: { Authorization: `Bearer ${authToken}` } }
);
```

### Frontend Configuration

1. **Firebase Integration in main.dart** ✅ COMPLETED

```dart
await FirebaseService().initializeFirebase();
```

2. **Topic Subscriptions** ✅ COMPLETED

After login:

- Students: `student_{userId}_alerts`, `student_{userId}_tracking`
- Parents: `parent_{userId}_alerts`, `parent_{userId}_tracking`
- Admin/Wardens: `admin_sos_alerts`, `admin_geofence_violations`

3. **Notification Handling** ✅ COMPLETED

File: `lib/services/notification_service.dart`

Handles:

- SOS alerts with alarm sound
- Geofence violations
- Pass status updates
- General notifications

### Testing FCM

```bash
# Send test notification from Firebase Console
1. Go to Cloud Messaging in Firebase Console
2. Create new campaign
3. Select topic (e.g., admin_sos_alerts)
4. Send test message
5. Verify app receives notification
```

---

## Audio Files Configuration

### Required Audio Files Setup ✅ COMPLETED

Directory: `frontend/campass_app/assets/sounds/`

Required files:

1. **sos_alarm.mp3** - Emergency SOS sound (5-10 sec, 128-256 kbps)
2. **geofence_alert.mp3** - Geofence alert (2-3 sec, 128-256 kbps)
3. **notification.mp3** - General notification (1-2 sec, 128-256 kbps)

Optional:

- **pass_approved.mp3** - Pass approval confirmation
- **pass_rejected.mp3** - Pass rejection alert

### Audio Asset Manager ✅ COMPLETED

File: `lib/utils/audio_asset_manager.dart`

Features:

- Automatic audio file initialization on app startup
- Copy audio files to app documents directory
- Get audio paths for playback
- Error handling for missing files

### Notification Service Audio ✅ COMPLETED

File: `lib/services/notification_service.dart`

Implemented methods:

```dart
showSOSAlertNotification(studentName, message, latitude, longitude)
showGeofenceViolationNotification(studentName, message)
showNotification(title, body)
```

### Android Audio Setup

Create directory: `android/app/src/main/res/raw/`

Copy audio files there for native access.

### iOS Audio Setup

In Xcode:

1. Open `ios/Runner.xcworkspace`
2. Add audio files to Runner
3. Ensure in "Copy Bundle Resources" build phase
4. Convert MP3 to AIFF for iOS native support

### Audio Testing

```dart
// Test audio playback
final audioPath = await AudioAssetManager().getAudioPath('sos_alarm');
if (audioPath != null) {
  // Audio is available
}
```

For detailed audio setup, see: `AUDIO_CONFIGURATION.md`

---

## Updated Features Status

All major features are now complete:

| Feature                | Status      | Files                                         |
| ---------------------- | ----------- | --------------------------------------------- |
| Firebase FCM Setup     | ✅ Complete | src/config/firebase.js                        |
| Push Notifications     | ✅ Complete | lib/services/firebase_service.dart            |
| SOS Notifications      | ✅ Complete | src/controllers/sos.controller.js             |
| Geofence Notifications | ✅ Complete | src/controllers/location.controller.js        |
| Audio Files            | ✅ Complete | assets/sounds/                                |
| Audio Asset Manager    | ✅ Complete | lib/utils/audio_asset_manager.dart            |
| Barcode Scanner        | ✅ Complete | lib/screens/guard/barcode_scanner_screen.dart |
| Parent Dashboard       | ✅ Complete | lib/screens/parent/                           |
| Admin Dashboard        | ✅ Complete | lib/screens/admin/                            |
| Location Tracking      | ✅ Complete | lib/services/location_service.dart            |
| User Model FCM         | ✅ Complete | src/models/user.js                            |
| FCM Token Endpoint     | ✅ Complete | src/routes/auth.routes.js                     |

---

## Production Deployment Checklist

### Backend

- [ ] Download Firebase serviceAccountKey.json
- [ ] Create .env with all required variables
- [ ] Create PostgreSQL database
- [ ] Run all migrations
- [ ] Test Firebase initialization
- [ ] Test FCM message sending
- [ ] Configure CORS for frontend domain
- [ ] Set up HTTPS/SSL certificates
- [ ] Configure firewall rules
- [ ] Set up PM2 or equivalent process manager
- [ ] Configure error logging
- [ ] Set up database backups

### Frontend

- [ ] Obtain google-services.json from Firebase
- [ ] Place in android/app/
- [ ] Update API base URL for production
- [ ] Obtain audio files and place in assets/sounds/
- [ ] Update iOS min deployment target to 11.0+
- [ ] Add Push Notifications capability (iOS)
- [ ] Obtain APNs certificate
- [ ] Configure release signing keys (Android)
- [ ] Test on physical Android device
- [ ] Test on physical iOS device
- [ ] Build APK and AAB for Play Store
- [ ] Build IPA for App Store

### General

- [ ] Security audit completed
- [ ] Performance testing completed
- [ ] Load testing on backend
- [ ] Database optimization
- [ ] CDN setup (if needed)
- [ ] Monitoring and logging configured
- [ ] Backup and recovery tested
- [ ] User documentation completed

---

## Support & References

For detailed setup instructions:

- Firebase FCM: See `FIREBASE_FCM_SETUP.md`
- Audio Configuration: See `AUDIO_CONFIGURATION.md`
- Flutter Docs: [https://flutter.dev/docs](https://flutter.dev/docs)
- Firebase Docs: [https://firebase.google.com/docs](https://firebase.google.com/docs)
- Express Docs: [https://expressjs.com](https://expressjs.com)
- Sequelize Docs: [https://sequelize.org](https://sequelize.org)

---

**Last Updated:** December 8, 2025
**Version:** 2.0 - Complete with Firebase and Audio Integration
**Status:** Ready for Production Deployment
