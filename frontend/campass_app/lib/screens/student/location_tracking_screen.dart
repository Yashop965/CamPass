// lib/screens/student/location_tracking_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../widgets/custom_error_dialog.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/error_handler.dart';
import '../../core/constants/map_constants.dart';

class LocationTrackingScreen extends StatefulWidget {
  final String? userId;
  final String? token;

  const LocationTrackingScreen({
    super.key,
    this.userId,
    this.token,
  });

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    if (widget.userId == null || widget.token == null) {
      ErrorHandler.showErrorSnackBar(context, "User ID or Token not available");
      return;
    }

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.initializeLocationTracking(
        studentId: widget.userId!,
        token: widget.token!,
      );
      ErrorHandler.showSuccessSnackBar(context, "Location tracking started");
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Tracking"),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final position = locationProvider.currentPosition;
          final isTracking = locationProvider.isTracking;
          final isOutside = locationProvider.isOutsideGeofence;

          if (position == null) {
            return const Center(
              child: Text("No location data available"),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    color: isOutside ? Colors.red[100] : Colors.green[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOutside ? "Outside Geofence!" : "Inside Geofence",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isOutside ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tracking Status: ${isTracking ? 'Active' : 'Inactive'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location Details
                  Text(
                    "Location Details",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text("Latitude"),
                    subtitle: Text(position.latitude.toStringAsFixed(6)),
                    leading: const Icon(Icons.location_on),
                  ),
                  ListTile(
                    title: const Text("Longitude"),
                    subtitle: Text(position.longitude.toStringAsFixed(6)),
                    leading: const Icon(Icons.location_on),
                  ),
                  ListTile(
                    title: const Text("Accuracy"),
                    subtitle: Text("${position.accuracy.toStringAsFixed(2)} meters"),
                    leading: const Icon(Icons.straighten),
                  ),
                  const SizedBox(height: 24),

                  // Geofence Info
                  Text(
                    "Geofence Information",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    title: Text("Campus Center"),
                    subtitle: Text("Latitude: ${MapConstants.campusLatitude}\nLongitude: ${MapConstants.campusLongitude}"),
                    leading: Icon(Icons.location_city),
                  ),
                  const ListTile(
                    title: Text("Geofence Radius"),
                    subtitle: Text("${MapConstants.geofenceRadiusMeters} meters"),
                    leading: Icon(Icons.rounded_corner),
                  ),
                  const SizedBox(height: 24),

                  // Info Section
                  if (isOutside)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "⚠️ You are outside the campus geofence",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Your location is being tracked and parents are notified.",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Could trigger SOS from here too
                              CustomErrorDialog.show(context, message: "Alerting parents...");
                            },
                            icon: const Icon(Icons.warning),
                            label: const Text("Alert Parents"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (locationProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        "Error: ${locationProvider.errorMessage}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
