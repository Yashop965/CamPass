import 'package:latlong2/latlong.dart';

class MapConstants {
  // IILM University, Gurugram
  static const double campusLatitude = 28.4334316;
  static const double campusLongitude = 77.1034226;
  
  static const double geofenceRadiusMeters = 500.0;

  static LatLng get campusLocation => LatLng(campusLatitude, campusLongitude);
}
