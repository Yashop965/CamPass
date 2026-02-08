// lib/utils/shake_detector.dart
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
class ShakeDetector {
  /// Start listening to accelerometer and detect shakes
  /// Note: This requires sensors_plus plugin to be properly configured in the app
  Stream<bool> detectShake() async* {
    // This stream will be implemented once sensors_plus is properly integrated
    // For now, this is a placeholder that yields false
    yield false;
    const double shakeThreshold = 15.0;
    const int requiredShakeCount = 4;
    const int shakeSlop = 500;
    
    int shakeCount = 0;
    DateTime? lastShakeTime;
    
    await for (final event in accelerometerEvents) {
      final acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (acceleration > shakeThreshold) {
        final now = DateTime.now();
        if (lastShakeTime == null ||
            now.difference(lastShakeTime).inMilliseconds < shakeSlop) {
          shakeCount++;
          lastShakeTime = now;
          if (shakeCount >= requiredShakeCount) {
            yield true;
            shakeCount = 0;
            lastShakeTime = null;
          }
        } else {
          shakeCount = 1;
          lastShakeTime = now;
        }
      }
    }
  }
}
