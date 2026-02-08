import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController cameraController;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
      formats: [BarcodeFormat.code128, BarcodeFormat.qrCode], // Critical speed fix
      detectionTimeoutMs: 500, // Debounce slightly
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student Pass'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              if (_scanned) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final barcode = barcodes.first;
              final rawValue = barcode.rawValue;
              if (rawValue == null || rawValue.isEmpty) return;

              setState(() => _scanned = true);

              // Return the barcode to the previous screen
              Navigator.of(context).pop<String>(rawValue);
            },
          ),
          // Scanner overlay
          _buildScannerOverlay(),

          // Instructions
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Point camera at QR code to scan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Darkened corners
          Container(
            decoration: const ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 3,
                cutOutSize: 250,
              ),
            ),
          ),
          // Top instruction
          Positioned(
            top: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Align QR code within the box',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom shape for QR code scanner overlay
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  const QrScannerOverlayShape({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..fillType = PathFillType.evenOdd;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path();
    path.addRect(rect);

    double x = rect.center.dx;
    double y = rect.center.dy;

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y),
          width: cutOutSize,
          height: cutOutSize,
        ),
        Radius.circular(borderRadius),
      ),
    );

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    double x = rect.center.dx;
    double y = rect.center.dy;

    Rect cutOutRect = Rect.fromCenter(
      center: Offset(x, y),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw border corners
    Offset topLeft = Offset(cutOutRect.left, cutOutRect.top);
    Offset topRight = Offset(cutOutRect.right, cutOutRect.top);
    Offset bottomLeft = Offset(cutOutRect.left, cutOutRect.bottom);
    Offset bottomRight = Offset(cutOutRect.right, cutOutRect.bottom);

    Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawLine(
      Offset(topLeft.dx, topLeft.dy + borderLength),
      topLeft,
      borderPaint,
    );
    canvas.drawLine(
      Offset(topLeft.dx + borderLength, topLeft.dy),
      topLeft,
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(topRight.dx, topRight.dy + borderLength),
      topRight,
      borderPaint,
    );
    canvas.drawLine(
      Offset(topRight.dx - borderLength, topRight.dy),
      topRight,
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(bottomLeft.dx, bottomLeft.dy - borderLength),
      bottomLeft,
      borderPaint,
    );
    canvas.drawLine(
      Offset(bottomLeft.dx + borderLength, bottomLeft.dy),
      bottomLeft,
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(bottomRight.dx, bottomRight.dy - borderLength),
      bottomRight,
      borderPaint,
    );
    canvas.drawLine(
      Offset(bottomRight.dx - borderLength, bottomRight.dy),
      bottomRight,
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      borderWidth: borderWidth * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
