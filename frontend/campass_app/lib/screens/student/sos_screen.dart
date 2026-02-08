import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sos_provider.dart';
import '../../services/session_manager.dart';
import '../../widgets/custom_error_dialog.dart';
import '../../utils/shake_detector.dart';

class SOSScreen extends StatefulWidget {
  final String? userId;
  final String? token;

  const SOSScreen({
    super.key,
    this.userId,
    this.token,
  });

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  final ShakeDetector _shakeDetector = ShakeDetector();
  late Stream<bool> _shakeStream;
  bool _isSOSActive = false;
  String? _userId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _token = widget.token;
    _loadSessionData();
    _initializeShakeDetection();
  }

  Future<void> _loadSessionData() async {
    if (_userId == null || _token == null) {
      final user = await SessionManager.getUser();
      final token = await SessionManager.getToken();
      if (mounted && user != null && token != null) {
        setState(() {
          _userId ??= user.id;
          _token ??= token;
        });
      }
    }
  }

  void _initializeShakeDetection() {
    _shakeStream = _shakeDetector.detectShake();
    _shakeStream.listen((shakeDetected) {
      if (shakeDetected && !_isSOSActive) {
        _triggerSOS();
      }
    });
  }

  Future<void> _triggerSOS() async {
    if (_userId == null || _token == null) {
      CustomErrorDialog.show(context, title: 'SOS Failed', message: 'User ID or Token not available');
      return;
    }

    try {
      setState(() => _isSOSActive = true);

      final sosProvider = Provider.of<SOSProvider>(context, listen: false);
      await sosProvider.sendSOSAlert(
        studentId: _userId!,
        token: _token!,
      );

      // Show success dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("SOS Alert Sent"),
          content: const Text(
            "Emergency alert has been sent to your parents and campus authorities.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      // Reset after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _isSOSActive = false);
        }
      });
    } catch (e) {
      if (!mounted) return;
      CustomErrorDialog.show(context, title: 'SOS Failed', message: 'Could not send alert: $e');
    } finally {
      setState(() => _isSOSActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency SOS"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instructions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _isSOSActive
                    ? "SOS Alert Sent! Stay calm."
                    : "Shake your phone 4 times to trigger SOS\nor press the button below",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 32),

            // SOS Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSOSActive ? Colors.green : Colors.red,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(80),
              ),
              onPressed: _isSOSActive ? null : _triggerSOS,
              child: Text(
                _isSOSActive ? "Sent ✓" : "SOS",
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            // Status
            if (_isSOSActive)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Alert has been sent to:\n"
                  "• Your parents\n"
                  "• Campus authorities\n"
                  "• Warden",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
