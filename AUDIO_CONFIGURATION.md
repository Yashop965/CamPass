# Audio Files Configuration Guide

## Overview

This guide explains how to set up audio files for SOS alerts, geofence violations, and other notifications.

## Required Audio Files

### 1. SOS Alarm Sound

- **File name**: `sos_alarm.mp3`
- **Duration**: 5-10 seconds
- **Type**: High-priority emergency alert
- **Volume**: 100% with vibration
- **Purpose**: Beep sound played on parent/warden device when SOS received
- **Characteristics**:
  - Loud, attention-grabbing alarm
  - Repeating beeps or continuous sound
  - Professional emergency sound

### 2. Geofence Alert Sound

- **File name**: `geofence_alert.mp3`
- **Duration**: 2-3 seconds
- **Type**: Warning alert
- **Volume**: 80-90%
- **Purpose**: Notification sound for geofence violations
- **Characteristics**:
  - Distinct from SOS (lower priority)
  - Bell or warning tone
  - Clear and recognizable

### 3. General Notification Sound

- **File name**: `notification.mp3`
- **Duration**: 1-2 seconds
- **Type**: Standard notification
- **Volume**: 70-80%
- **Purpose**: General pass approvals, updates, messages
- **Characteristics**:
  - Subtle notification tone
  - Non-intrusive
  - Professional sound

### 4. Optional Sounds

- `pass_approved.mp3` - Confirmation sound for pass approval
- `pass_rejected.mp3` - Alert for pass rejection

## File Setup Instructions

### Step 1: Create Audio Directory

```bash
mkdir -p frontend/campass_app/assets/sounds
```

### Step 2: Add Audio Files

Place the following MP3 files in `assets/sounds/`:

```
frontend/campass_app/assets/sounds/
├── sos_alarm.mp3
├── geofence_alert.mp3
├── notification.mp3
├── pass_approved.mp3 (optional)
└── pass_rejected.mp3 (optional)
```

### Step 3: Update pubspec.yaml

Ensure audio files are included in assets:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/fonts/
    - assets/lottie/
    - assets/sounds/ # Add this line
```

### Step 4: Update pubspec.yaml Dependencies

Add audio playback package:

```yaml
dependencies:
  audioplayers: ^5.0.0
  path_provider: ^2.0.0
```

Then run:

```bash
flutter pub get
```

### Step 5: Initialize Audio Assets in main.dart

```dart
import 'utils/audio_asset_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio assets
  await AudioAssetManager().initializeAudioAssets();

  // Initialize Firebase
  await FirebaseService().initializeFirebase();

  runApp(const CampassApp());
}
```

## Recommended Audio Sources

### Free Audio Resources

1. **Freesound.org** - https://freesound.org/

   - Search: "emergency alarm", "geofence alert", "notification"
   - Filter: MP3 format, CC0 or CC-BY license

2. **Zapsplat** - https://www.zapsplat.com/

   - Search: "alarm sound", "beep notification"
   - Free download with attribution

3. **Notificationsounds.com** - https://notificationsounds.com/

   - Notification and alert sounds
   - Free for personal use

4. **Incompetech** - https://incompetech.com/
   - Royalty-free music and sound effects
   - CC0 license

### Professional Audio Options

1. **Epidemic Sound** - Commercial license
2. **Artlist** - Professional sound effects library
3. **Audio Jungle** - Wide variety of premium sounds

## Audio File Specifications

### Format Requirements

- **Format**: MP3
- **Bit Rate**: 128 kbps - 256 kbps
- **Sample Rate**: 44100 Hz or 48000 Hz
- **Channels**: Mono or Stereo
- **File Size**: < 500 KB per file (for quick download)

### Compression

Use FFmpeg to optimize:

```bash
# Convert to MP3 with optimal settings
ffmpeg -i input_audio.wav -b:a 128k -ar 44100 output.mp3

# For SOS alarm (keep quality)
ffmpeg -i input_audio.wav -b:a 192k -ar 48000 sos_alarm.mp3
```

## Audio Implementation in Code

### In notification_service.dart

Already includes SOS alert and geofence notification methods:

```dart
Future<void> showSOSAlertNotification(
  String studentName,
  String message,
  double latitude,
  double longitude,
) async {
  // Uses sos_alarm.mp3 via Android notification channel
}

Future<void> showGeofenceViolationNotification(
  String studentName,
  String message,
) async {
  // Uses geofence_alert.mp3 via Android notification channel
}
```

### Android Native Implementation

For custom audio in Android, edit `android/app/src/main/res/raw/`:

Create directory if not exists:

```bash
mkdir -p android/app/src/main/res/raw
```

Copy MP3 files:

```bash
cp frontend/campass_app/assets/sounds/sos_alarm.mp3 android/app/src/main/res/raw/
cp frontend/campass_app/assets/sounds/geofence_alert.mp3 android/app/src/main/res/raw/
```

Update notification channel in notification_service.dart:

```dart
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'sos_alert_channel',
  'SOS Alerts',
  importance: Importance.max,
  priority: Priority.high,
  sound: RawResourceAndroidNotificationSound('sos_alarm'),
  enableVibration: true,
  vibrationPattern: [0, 250, 250, 250],
  ledColor: const Color.fromARGB(255, 255, 0, 0),
  ledOnMs: 1000,
  ledOffMs: 500,
  fullScreenIntent: true,
);
```

### iOS Native Implementation

For iOS, add audio files to Xcode:

1. Open `ios/Runner.xcworkspace`
2. Drag audio files to Runner folder
3. Ensure "Copy items if needed" is checked
4. Build phase shows files in "Copy Bundle Resources"

In notification_service.dart:

```dart
const IOSNotificationDetails iosNotificationDetails =
    IOSNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
  sound: 'sos_alarm.aiff', // Convert to AIFF for iOS
);
```

## Testing Audio Playback

### Test 1: Foreground Notification

1. Keep app open
2. Send test SOS alert
3. Verify audio plays immediately

### Test 2: Background Notification

1. Put app in background
2. Send test geofence violation
3. Verify system notification appears with sound

### Test 3: Device Silent Mode

1. Put device in silent/vibrate mode
2. Send SOS alert (should still vibrate)
3. Disable vibration in settings
4. Send alert (verify silent)

### Test 4: Volume Control

1. Adjust device volume
2. Send notifications at different volumes
3. Verify volume levels respected

## Troubleshooting

### Issue: Audio Not Playing

**Solutions:**

- Check audio files exist in `assets/sounds/`
- Verify pubspec.yaml includes `assets/sounds/` path
- Ensure audioplayers package installed
- Check device volume is not muted
- Test with different audio file

### Issue: Sound Stuttering or Crackling

**Solutions:**

- Reduce audio file bitrate to 128kbps
- Re-encode audio with different encoder
- Try different audio format (AAC, OGG)
- Check device storage space

### Issue: Audio Not Playing on Android

**Solutions:**

- Verify `android/app/src/main/res/raw/` exists
- Copy audio files to raw directory
- Check file names don't contain uppercase letters
- Ensure notification channel created properly

### Issue: Audio Not Playing on iOS

**Solutions:**

- Convert MP3 to AIFF format
- Add to Xcode project properly
- Check Info.plist has audio permissions
- Verify entitlements configured

## Performance Optimization

### 1. Lazy Load Audio Files

Only load audio when needed:

```dart
final audioPath = await AudioAssetManager().getAudioPath('sos_alarm');
if (audioPath != null) {
  // Play audio
}
```

### 2. Cache Audio Paths

Store paths in provider to avoid repeated lookups:

```dart
class AudioProvider extends ChangeNotifier {
  final Map<String, String> _audioCache = {};

  Future<String?> getAudioPath(String name) async {
    if (_audioCache.containsKey(name)) {
      return _audioCache[name];
    }
    // Load and cache
  }
}
```

### 3. Preload Critical Sounds

Preload SOS alarm on app start:

```dart
void main() async {
  // Preload SOS alarm
  await AudioAssetManager().initializeAudioAssets();
}
```

## Production Checklist

- [ ] All required audio files present in `assets/sounds/`
- [ ] Audio files compressed to < 500 KB each
- [ ] pubspec.yaml includes `assets/sounds/` in flutter section
- [ ] pubspec.yaml includes `audioplayers` and `path_provider`
- [ ] main.dart initializes AudioAssetManager
- [ ] Android raw directory contains audio files
- [ ] iOS audio files added to Xcode project
- [ ] Notification channels configured with correct sounds
- [ ] Tested on physical Android device
- [ ] Tested on physical iOS device
- [ ] Tested with device in silent mode
- [ ] Tested volume control

## References

- [Audioplayers Package](https://pub.dev/packages/audioplayers)
- [Flutter Assets & Images](https://flutter.dev/docs/development/ui/assets-and-images)
- [Android Notification Sounds](https://developer.android.com/guide/topics/media-apps/audio-focus)
- [iOS Audio](https://developer.apple.com/documentation/avfoundation)
