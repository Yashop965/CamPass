// lib/services/mock_location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class MockLocationService {
  // Configurable mock path or static location
  // Simulating a student walking around a campus
  static const double _baseLat = 28.6139; // New Delhi (Example)
  static const double _baseLng = 77.2090;
  
  Timer? _timer;
  final _controller = StreamController<Position>.broadcast();

  Stream<Position> get locationStream => _controller.stream;

  // Start emitting mock locations
  void startSimulation() {
    int tick = 0;
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      tick++;
      // Simulate walking in a circle
      // 0.0001 degrees is roughly 11 meters
      final lat = _baseLat + (0.0001 * tick % 10); 
      final lng = _baseLng + (0.0001 * (tick + 2) % 10);
      
      final mockPosition = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 1.5, // 1.5 m/s walking speed
        speedAccuracy: 0.5, 
        altitudeAccuracy: 1, 
        headingAccuracy: 1
      );
      
      _controller.add(mockPosition);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  Future<Position> getCurrentLocation() async {
    // Return a fixed mock location immediately
    return Position(
      latitude: _baseLat,
      longitude: _baseLng,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0, 
      altitudeAccuracy: 1, 
      headingAccuracy: 1
    );
  }
}
