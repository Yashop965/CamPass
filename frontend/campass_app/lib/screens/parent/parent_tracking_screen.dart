import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parent_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';

class ParentTrackingScreen extends StatefulWidget {
  final String parentId;
  final String childId;
  final String token;

  const ParentTrackingScreen({
    super.key,
    required this.parentId,
    required this.childId,
    required this.token,
  });

  @override
  State<ParentTrackingScreen> createState() => _ParentTrackingScreenState();
}

class _ParentTrackingScreenState extends State<ParentTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Default to a campus location
  static const CameraPosition _kCampus = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 16, 
  );

  // Dark Map Style
  static const String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#746855"}]
  },
  {
     "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#38414e"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#17263c"}]
  }
]
''';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (widget.childId.isNotEmpty) {
           Provider.of<ParentProvider>(context, listen: false).startChildTracking(widget.childId, widget.token);
       }
    });
  }

  @override
  void dispose() {
    // We should stop tracking when leaving the screen
    // Using simple provider access might fail if context is unmounted, but addPostFrameCallback is safe?
    // Actually, just calling it directly if mounted.
    if (mounted) {
       Provider.of<ParentProvider>(context, listen: false).stopChildTracking();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<ParentProvider>(
        builder: (context, provider, child) {
           LatLng? currentPos;
           Set<Marker> markers = {};
           String status = "Waiting for location...";

           if (provider.childLocation.isNotEmpty && provider.childLocation['latitude'] != null) {
              final lat = double.parse(provider.childLocation['latitude'].toString());
              final lng = double.parse(provider.childLocation['longitude'].toString());
              currentPos = LatLng(lat, lng);
              status = "Live Tracking Active";
              
              markers.add(
                 Marker(
                    markerId: const MarkerId('student'),
                    position: currentPos,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan), // Cyan for futuristic look
                    infoWindow: InfoWindow(title: provider.childLocation['studentName'] ?? 'Student'),
                 )
              );

              // Move camera if controller is ready
              _controller.future.then((controller) {
                 controller.animateCamera(CameraUpdate.newLatLng(currentPos!));
              });
           }

           return Stack(
             children: [
               GoogleMap(
                 mapType: MapType.normal, // Or MapType.hybrid
                 initialCameraPosition: currentPos != null 
                     ? CameraPosition(target: currentPos, zoom: 16) 
                     : _kCampus,
                 markers: markers,
                 onMapCreated: (GoogleMapController controller) {
                   if (!_controller.isCompleted) {
                     _controller.complete(controller);
                   }
                   // Set dark style
                   controller.setMapStyle(_mapStyle);
                 },
                 myLocationEnabled: false,
                 zoomControlsEnabled: false,
                 compassEnabled: true,
               ),
               
               // Gradient Overlay
               Positioned(
                 top: 0, left: 0, right: 0, height: 100,
                 child: Container(
                    decoration: const BoxDecoration(
                       gradient: LinearGradient(
                          colors: [AppTheme.background, Colors.transparent],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter
                       )
                    ),
                 ),
               ),

               // Info Card
               Positioned(
                 bottom: 100, 
                 left: 16, right: 16,
                 child: GlassyCard(
                    enableBlur: false,
                    child: Row(
                       children: [
                          Container(
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
                             ),
                             child: const Icon(Icons.location_searching, color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  const Text("Student Location (Live)", style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  if (currentPos != null)
                                    Text(
                                      "Lat: ${currentPos.latitude.toStringAsFixed(4)}, Lng: ${currentPos.longitude.toStringAsFixed(4)}",
                                      style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontFamily: 'monospace'),
                                    ),
                               ],
                            ),
                          )
                       ],
                    ),
                 ),
               )
             ],
           );
        },
      ),
    );
  }


}


