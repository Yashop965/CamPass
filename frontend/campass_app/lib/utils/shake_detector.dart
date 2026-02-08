// lib/utils/shake_detector.dart
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
class ShakeDetector {
  /// Start listening to accelerometer and detect shakes
  /// Note: This requires sensors_plus plugin to be properly configured in the app
  Stream<bool> detectShake() async* {
    // Gravity is ~9.8 m/s^2.
    // 2.3g (approx 22) is a good threshold for a forceful shake.
    const double shakeThreshold = 22.0; 
    const int requiredShakeCount = 4;
    
    // Min time to wait before counting the NEXT shake (debounce)
    // This prevents one long arm swing from registering as 10 shakes.
    const int minTimeBetweenShakesMs = 250; 
    
    // Max time allowed between shakes to keep the combo alive.
    // If you wait longer than this, the counter resets.
    const int maxTimeBetweenShakesMs = 1500;

    int shakeCount = 0;
    int lastShakeTimestamp = 0;

    await for (final event in accelerometerEvents) {
      final acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      if (acceleration > shakeThreshold) {
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if we are inside the debounce window (ignore this event if so)
        if (lastShakeTimestamp == 0 || (now - lastShakeTimestamp > minTimeBetweenShakesMs)) {
          
          // Check if the previous shake was too long ago (reset counter)
          if (lastShakeTimestamp > 0 && (now - lastShakeTimestamp > maxTimeBetweenShakesMs)) {
            shakeCount = 0;
          }

          shakeCount++;
          lastShakeTimestamp = now;

          if (shakeCount >= requiredShakeCount) {
            yield true;
            shakeCount = 0; // Reset
            lastShakeTimestamp = 0; 
          }
        }
      }
    }
  }
}
