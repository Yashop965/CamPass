import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const Color _primary = Color(0xFF1152D4);
const Color _backgroundLight = Color(0xFFF6F6F8);
const Color _backgroundDark = Color(0xFF101622);
const Color _success = Color(0xFF22C55E);

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late final AnimationController _pulseController;

  final LatLng _campus = LatLng(34.0522, -118.2437);
  final LatLng _student = LatLng(34.0528, -118.2428);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMapStyle();
  }

  Future<void> _applyMapStyle() async {
    if (_mapController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await _mapController!.setMapStyle(isDark ? _darkMapStyle : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.lexendTextTheme(theme.textTheme),
      ),
      child: Scaffold(
        backgroundColor: isDark ? _backgroundDark : _backgroundLight,
        body: Stack(
          children: [
            MapLayer(
              isDark: isDark,
              campus: _campus,
              student: _student,
              onMapCreated: (controller) {
                _mapController = controller;
                _applyMapStyle();
              },
            ),
            // Safe zone label overlay and path painter
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      SafeZoneOverlay(
                        constraints: constraints,
                        isDark: isDark,
                      ),
                      RoutePathPainter(
                        constraints: constraints,
                        color: _primary,
                      ),
                      CampusMarkerOverlay(
                        constraints: constraints,
                        isDark: isDark,
                      ),
                      LiveMarkerWidget(
                        constraints: constraints,
                        isDark: isDark,
                        pulse: _pulseController,
                      ),
                      MapControlButtons(isDark: isDark),
                      HeaderOverlay(isDark: isDark),
                      TrackingInfoPanel(isDark: isDark),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapLayer extends StatelessWidget {
  final bool isDark;
  final LatLng campus;
  final LatLng student;
  final void Function(GoogleMapController controller) onMapCreated;

  const MapLayer({
    super.key,
    required this.isDark,
    required this.campus,
    required this.student,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('campus'),
        position: campus,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('student'),
        position: student,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: _primary,
      width: 4,
      patterns: [
        PatternItem.dash(18),
        PatternItem.gap(10),
      ],
      points: [
        campus,
        LatLng(34.0525, -118.2432),
        LatLng(34.0527, -118.2430),
        student,
      ],
    );

    final polygon = Polygon(
      polygonId: const PolygonId('safe_zone'),
      fillColor: _primary.withOpacity(0.10),
      strokeColor: _primary.withOpacity(0.30),
      strokeWidth: 2,
      points: const [
        LatLng(34.0538, -118.2454),
        LatLng(34.0536, -118.2418),
        LatLng(34.0524, -118.2412),
        LatLng(34.0516, -118.2434),
        LatLng(34.0522, -118.2458),
      ],
    );

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(34.0524, -118.2435),
        zoom: 15.5,
      ),
      onMapCreated: onMapCreated,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: false,
      markers: markers,
      polylines: {polyline},
      polygons: {polygon},
    );
  }
}

class HeaderOverlay extends StatelessWidget {
  final bool isDark;

  const HeaderOverlay({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        (isDark ? _backgroundDark : Colors.white).withOpacity(0.90),
        (isDark ? _backgroundDark : Colors.white).withOpacity(0.0),
      ],
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(gradient: gradient),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PressableScale(
                onTap: () {},
                child: _GlassIconButton(
                  icon: Icons.arrow_back,
                  isDark: isDark,
                ),
              ),
              Text(
                'Live Tracking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              PressableScale(
                onTap: () {},
                child: _GlassIconButton(
                  icon: Icons.settings,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;

  const _GlassIconButton({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
            (isDark ? const Color(0xFF1F2937) : Colors.white).withOpacity(0.80),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isDark ? Colors.white : const Color(0xFF334155),
      ),
    );
  }
}

class MapControlButtons extends StatelessWidget {
  final bool isDark;

  const MapControlButtons({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 110,
      right: 12,
      child: Column(
        children: [
          PressableScale(
            onTap: () {},
            child: _MapControlButton(
              icon: Icons.my_location,
              isDark: isDark,
              activeColor: _primary,
            ),
          ),
          const SizedBox(height: 12),
          PressableScale(
            onTap: () {},
            child: _MapControlButton(
              icon: Icons.layers,
              isDark: isDark,
              activeColor:
                  isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color activeColor;

  const _MapControlButton({
    required this.icon,
    required this.isDark,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color:
            (isDark ? const Color(0xFF1F2937) : Colors.white).withOpacity(0.90),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: activeColor),
    );
  }
}

class SafeZoneOverlay extends StatelessWidget {
  final BoxConstraints constraints;
  final bool isDark;

  const SafeZoneOverlay({
    super.key,
    required this.constraints,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final labelBg = _primary.withOpacity(0.10);
    const labelText = _primary;

    return Positioned(
      top: constraints.maxHeight * 0.16,
      left: constraints.maxWidth * 0.18,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: labelBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _primary.withOpacity(0.2)),
        ),
        child: Text(
          'SAFE ZONE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: labelText,
          ),
        ),
      ),
    );
  }
}

class RoutePathPainter extends StatelessWidget {
  final BoxConstraints constraints;
  final Color color;

  const RoutePathPainter({
    super.key,
    required this.constraints,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _DashedRoutePainter(color: color),
      ),
    );
  }
}

class _DashedRoutePainter extends CustomPainter {
  final Color color;

  _DashedRoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(size.width * 0.48, size.height * 0.28)
      ..lineTo(size.width * 0.48, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.55);

    _drawDashedPath(canvas, path, paint, 8, 6);
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, double dash, double gap) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = min(dash, metric.length - distance);
        final segment = metric.extractPath(distance, distance + length);
        canvas.drawPath(segment, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoutePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class CampusMarkerOverlay extends StatelessWidget {
  final BoxConstraints constraints;
  final bool isDark;

  const CampusMarkerOverlay({
    super.key,
    required this.constraints,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: constraints.maxHeight * 0.28,
      left: constraints.maxWidth * 0.48 - 30,
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Campus',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveMarkerWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final bool isDark;
  final AnimationController pulse;

  const LiveMarkerWidget({
    super.key,
    required this.constraints,
    required this.isDark,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: constraints.maxHeight * 0.55 - 50,
      left: constraints.maxWidth * 0.65 - 40,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (context, _) {
                  final scale = lerpDouble(0.8, 2.5, pulse.value)!;
                  final opacity = lerpDouble(0.5, 0.0, pulse.value)!;
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                    child: Transform.scale(scale: scale),
                  );
                },
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC5Xwfq9FdYLF1uMZB8U0-cm2xgKWXL2WyQLTLQNC8L5GbQwUiVwi_4jjinrWzY7E_UVdqBAjaj-YMnEh7IPZ1CRZ1LsXgvXZeh3WFo7omIC70ngzi7q3Xsx6nUoY37udmX69HMIgz4VL8umQFLIUlQlco3FHKqvkLcHG3-TdgfdHsyuL3T4oZ36SxfU5gVnReWijmyUmz2kgA1AmgTQXCx76AW5CnsxtFFt2EJmjozJbLj5VTMkbjT85cwA_i--pJ955E0-xf-0_KM',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _primary,
                        child: const Icon(Icons.person, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: -6,
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Alex - 2 min ago',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingInfoPanel extends StatelessWidget {
  final bool isDark;

  const TrackingInfoPanel({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final panelColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Positioned.fill(
      child: DraggableScrollableSheet(
        minChildSize: 0.18,
        maxChildSize: 0.55,
        initialChildSize: 0.30,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: panelColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StudentInfoHeader(isDark: isDark),
                  const SizedBox(height: 16),
                  TripDetailsGrid(isDark: isDark),
                  const SizedBox(height: 16),
                  DriverActionSection(isDark: isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class StudentInfoHeader extends StatelessWidget {
  final bool isDark;

  const StudentInfoHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAj-88Mf3zM5eY8X9UB2wmQEzC5Iw4S6hkNMbFkAYev6FKY-vz_8HzXxIrvLbAsu7pnc2OSmYmYsoQr_-Epz9anCkx8Eob1DqAZls7TsAtjc7H9BK7f7ZMi31mdIZllfdvcJsN80Xs-yZtp9SGWUhKqdTS7uiY-NzwOUmYx6eaKVSy97DEUGlLqY9JPyEXsFhZPTKiC-nrdkj3d45K-dIFSnPWXq4Ez83hSJ0FPpTXlB4seDJoY_ssrO6akMRNr6fw11hZwpxHzZMXj',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _success,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.school, size: 16, color: _primary),
                  const SizedBox(width: 4),
                  Text(
                    'Grade 10-B',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'On Time',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Updated just now',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TripDetailsGrid extends StatelessWidget {
  final bool isDark;

  const TripDetailsGrid({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF243043) : _backgroundLight;

    return Row(
      children: [
        Expanded(
          child: _DetailCard(
            isDark: isDark,
            color: cardColor,
            label: 'Destination',
            icon: Icons.location_on,
            value: 'North Gate Drop-off',
            subValue: null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DetailCard(
            isDark: isDark,
            color: cardColor,
            label: 'Est. Arrival',
            icon: Icons.schedule,
            value: '4:15 PM',
            subValue: '(~12m)',
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final bool isDark;
  final Color color;
  final String label;
  final IconData icon;
  final String value;
  final String? subValue;

  const _DetailCard({
    required this.isDark,
    required this.color,
    required this.label,
    required this.icon,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final valueColor =
        isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DriverActionSection extends StatelessWidget {
  final bool isDark;

  const DriverActionSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final titleColor =
        isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          ClipOval(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAi-2SKr79vDG5I0mbY1W0mUqn4p3E612lW8zKVkNNOdwMpRlVkslMjLQr0TUqzVsQfJVkQCV_NRvIahn83P4crNK-dQGlIcw8WBIGx4c40QoftnQEGbP5RyGY7P_hGXdycv7hr8ON5yZAnSIb2h0uB27oGJRmCn3qKwMiD-SJvjBJJ-bknTO8wAlSyFaiJUhgrHRJdZQsDUMR0zBsh3HOo1WlhpJ5SfNh9MEOfa6kYT_WVKoapMtdudBbLXM7Oni9e-LRT7al56JOA',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus 42 - Mr. Davis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'XYZ Transport Co.',
                  style: TextStyle(
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PressableScale(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                Icons.message,
                size: 20,
                color:
                    isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PressableScale(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.call, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Call Driver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableScale({super.key, required this.child, required this.onTap});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

const String _darkMapStyle = '''
[
  { "elementType": "geometry", "stylers": [ { "color": "#1d2c4d" } ] },
  { "elementType": "labels.text.fill", "stylers": [ { "color": "#8ec3b9" } ] },
  { "elementType": "labels.text.stroke", "stylers": [ { "color": "#1a3646" } ] },
  { "featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [ { "color": "#4b6878" } ] },
  { "featureType": "administrative.land_parcel", "elementType": "labels.text.fill", "stylers": [ { "color": "#64779e" } ] },
  { "featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [ { "color": "#4b6878" } ] },
  { "featureType": "landscape.man_made", "elementType": "geometry.stroke", "stylers": [ { "color": "#334e87" } ] },
  { "featureType": "landscape.natural", "elementType": "geometry", "stylers": [ { "color": "#023e58" } ] },
  { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#283d6a" } ] },
  { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#6f9ba5" } ] },
  { "featureType": "poi", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1d2c4d" } ] },
  { "featureType": "poi.park", "elementType": "geometry.fill", "stylers": [ { "color": "#023e58" } ] },
  { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#3C7680" } ] },
  { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#304a7d" } ] },
  { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#98a5be" } ] },
  { "featureType": "road", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1d2c4d" } ] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#2c6675" } ] },
  { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#255763" } ] },
  { "featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [ { "color": "#b0d5ce" } ] },
  { "featureType": "road.highway", "elementType": "labels.text.stroke", "stylers": [ { "color": "#023e58" } ] },
  { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#98a5be" } ] },
  { "featureType": "transit", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1d2c4d" } ] },
  { "featureType": "transit.line", "elementType": "geometry.fill", "stylers": [ { "color": "#283d6a" } ] },
  { "featureType": "transit.station", "elementType": "geometry", "stylers": [ { "color": "#3a4762" } ] },
  { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#0e1626" } ] },
  { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#4e6d70" } ] }
]
''';
