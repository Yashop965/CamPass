import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/parent_provider.dart';
import '../../core/constants/map_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import 'dart:math' as math;

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

class _ParentTrackingScreenState extends State<ParentTrackingScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late ParentProvider _parentProvider; // visual fix: capture provider to use in dispose
  
  // Default to a campus location (IILM Gurugram)
  static final LatLng _kCampus = MapConstants.campusLocation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (widget.childId.isNotEmpty) {
           Provider.of<ParentProvider>(context, listen: false).startChildTracking(widget.childId, widget.token);
       }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parentProvider = Provider.of<ParentProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _parentProvider.stopChildTracking(); // Use captured reference
    super.dispose();
  }

  void _onRequestLocation() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Requesting current location..."),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primary,
      ),
    );
    try {
      await Provider.of<ParentProvider>(context, listen: false).requestInstantUpdate(widget.childId, widget.token);
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update: $e"), backgroundColor: AppTheme.error),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. Static Map Layer (Optimized: Rebuilt only once)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _kCampus,
              initialZoom: 16,
              // Keep rotation enabled for compass feature
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.campass.app',
                // Optimizations
                keepBuffer: 5, // Keep more tiles in memory
                panBuffer: 2,  // Preload tiles around view
                tileProvider: NetworkTileProvider(), // Standard efficient provider
              ),

              // Geofence Layer
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: MapConstants.campusLocation,
                    radius: MapConstants.geofenceRadiusMeters,
                    useRadiusInMeter: true,
                    color: Colors.green.withOpacity(0.1),
                    borderColor: Colors.green,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              
              // 2. Dynamic Marker Layer (Rebuilt on location updates)
              Consumer<ParentProvider>(
                builder: (context, provider, _) {
                   LatLng? currentPos;
                   if (provider.childLocation.isNotEmpty && provider.childLocation['latitude'] != null) {
                      final lat = double.parse(provider.childLocation['latitude'].toString());
                      final lng = double.parse(provider.childLocation['longitude'].toString());
                      currentPos = LatLng(lat, lng);
                   }

                   return MarkerLayer(
                     markers: [
                       if (currentPos != null)
                         Marker(
                           point: currentPos,
                           width: 100, // Increased size for pulse
                           height: 100,
                           child: _buildPulsingMarker(provider.childLocation['studentName'] ?? 'Student'),
                         ),
                     ],
                   );
                },
              ),
            ],
          ),

          // 3. Dark Overlay (Design)
          Positioned.fill(
             child: IgnorePointer(
               child: Container(color: Colors.black.withOpacity(0.3)),
             ),
          ),
          
          // 4. Compass (Rotates with map)
          Positioned(
             top: 100, // Below potential app bar area
             right: 16,
             child: StreamBuilder<MapEvent>(
               stream: _mapController.mapEventStream,
               builder: (context, snapshot) {
                 double rotation = 0;
                 if (snapshot.hasData) {
                    rotation = snapshot.data!.camera.rotation;
                 }
                 return GestureDetector(
                   onTap: () {
                     _mapController.rotate(0); // Reset to North
                   },
                   child: Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: AppTheme.surface.withOpacity(0.8),
                       shape: BoxShape.circle,
                       border: Border.all(color: Colors.white24),
                       boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]
                     ),
                     child: Transform.rotate(
                       angle: (rotation * (math.pi / 180)) * -1,
                       child: const Icon(Icons.navigation, color: AppTheme.primary, size: 28),
                     ),
                   ),
                 );
               },
             ),
          ),

          // 5. Info Card & Request Button
          Positioned(
            bottom: 110, // Moved up slightly to avoid bottom nav intersection
            left: 16, right: 16,
            child: Consumer<ParentProvider>(
               builder: (context, provider, _) { 
                  LatLng? currentPos;
                  String status = "Waiting for location...";
                  
                  if (provider.childLocation.isNotEmpty && provider.childLocation['latitude'] != null) {
                      final lat = double.parse(provider.childLocation['latitude'].toString());
                      final lng = double.parse(provider.childLocation['longitude'].toString());
                      currentPos = LatLng(lat, lng);
                      status = "Live Tracking Active";
                  }

                  return Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                        // Request Location Button
                        FloatingActionButton.extended(
                           onPressed: _onRequestLocation,
                           label: const Text("REQUEST LOCATION"),
                           icon: const Icon(Icons.refresh),
                           backgroundColor: AppTheme.primary,
                           foregroundColor: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        
                        // Info Card
                        GlassyCard(
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
                                         const Text("Student Location", style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                         const SizedBox(height: 4),
                                         Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                         if (currentPos != null)
                                           Text(
                                             "Lat: ${currentPos.latitude.toStringAsFixed(4)}, Lng: ${currentPos.longitude.toStringAsFixed(4)}",
                                             style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontFamily: 'monospace'),
                                           ),
                                      ],
                                   ),
                                 ),
                                 IconButton(
                                   icon: const Icon(Icons.my_location, color: Colors.white),
                                   onPressed: currentPos != null 
                                     ? () => _mapController.move(currentPos!, 16) 
                                     : null,
                                 )
                              ],
                           ),
                        ),
                     ],
                  );
               }
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPulsingMarker(String name) {
     return AnimatedBuilder(
       animation: _pulseController,
       builder: (context, child) {
         // Ring 1 (expands and fades)
         double value1 = _pulseController.value;
         double opacity1 = (1.0 - value1).clamp(0.0, 1.0);
         double size1 = 40 + (value1 * 60); // 40 -> 100

         // Ring 2 (follows with delay)
         double value2 = (_pulseController.value + 0.5) % 1.0;
         double opacity2 = (1.0 - value2).clamp(0.0, 1.0);
         double size2 = 40 + (value2 * 60);

         return Stack(
            alignment: Alignment.center,
            children: [
               // Outer Rings
               Container(
                  width: size1, height: size1,
                  decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: AppTheme.primary.withOpacity(opacity1 * 0.4),
                  ),
               ),
               Container(
                  width: size2, height: size2,
                  decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: AppTheme.primary.withOpacity(opacity2 * 0.4),
                  ),
               ),
               
               // Core Marker
               Container(
                  width: 44, height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                     color: Colors.white,
                     shape: BoxShape.circle,
                     boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                  ),
                  child: const CircleAvatar(
                     backgroundColor: AppTheme.primary,
                     child: Icon(Icons.person, color: Colors.black, size: 24),
                  ),
               ),

               // Name Tag
               Positioned(
                  bottom: 0,
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24)
                     ),
                     child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
               )
            ],
         );
       },
     );
  }
}
