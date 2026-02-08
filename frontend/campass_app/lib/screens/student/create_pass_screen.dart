import 'package:flutter/material.dart';
import '../../services/pass_service.dart';
import '../../services/session_manager.dart';
import '../../models/pass_model.dart';
import 'barcode_display_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_error_dialog.dart';
import 'package:intl/intl.dart';

class CreatePassScreen extends StatefulWidget {
  final String userId;
  const CreatePassScreen({super.key, required this.userId});

  @override
  State<CreatePassScreen> createState() => _CreatePassScreenState();
}

class _CreatePassScreenState extends State<CreatePassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purpose = TextEditingController();
  DateTime? _validTo;
  final PassService _passService = PassService();
  bool loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _validTo == null) {
       if(_validTo == null) {
          CustomErrorDialog.show(context, title: 'Missing Information', message: 'Please select a return time for your outing.');
       }
       return;
    }
    setState(() => loading = true);
    try {
      final token = await SessionManager.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final payload = {
        'userId': widget.userId,
        'type': 'outing',
        'validFrom': DateTime.now().toIso8601String(),
        'validTo': _validTo!.toIso8601String(),
        'purpose': _purpose.text,
      };
      
      final response = await _passService.createPass(payload, token, DateTime.now(), _validTo!);
      final passData = response['pass'] as Map<String, dynamic>;
      
      setState(() => loading = false);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BarcodeDisplayScreen(pass: PassModel.fromJson(passData)),
        ),
      );
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      CustomErrorDialog.show(context, message: 'Failed to generate pass: $e');
    }
  }

  Future<void> _pickDateTime() async {
    final dt = await showDatePicker(
       context: context, 
       initialDate: DateTime.now(), 
       firstDate: DateTime.now(), 
       lastDate: DateTime.now().add(const Duration(days: 30)),
       builder: (context, child) {
          return Theme(
             data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                   primary: AppTheme.primary,
                   onPrimary: Colors.black,
                   surface: AppTheme.surface,
                   onSurface: Colors.white,
                ),
                dialogBackgroundColor: AppTheme.surface,
             ),
             child: child!,
          );
       }
    );
    if (dt != null) {
      if (!mounted) return;
      final t = await showTimePicker(
         context: context, 
         initialTime: TimeOfDay.now(),
         builder: (context, child) {
            return Theme(
               data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                     primary: AppTheme.primary,
                     onPrimary: Colors.black,
                     surface: AppTheme.surface,
                     onSurface: Colors.white,
                  ),
                  timePickerTheme: const TimePickerThemeData(
                     backgroundColor: AppTheme.surface,
                     dialHandColor: AppTheme.primary,
                     hourMinuteColor: AppTheme.surface,
                     hourMinuteTextColor: AppTheme.primary,
                  )
               ),
               child: child!,
            );
         }
      );
      if (t != null) setState(() => _validTo = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
         title: const Text("Request Outing", style: TextStyle(color: Colors.white)),
         backgroundColor: Colors.transparent,
         elevation: 0,
         centerTitle: true,
         iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
        child: Column(
          children: [
            const Hero(
              tag: 'menu_icon_New Pass',
              child: Icon(Icons.add_circle_outline, size: 60, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            GlassyCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PASS DETAILS", style: TextStyle(color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    TextFormField(
                      controller: _purpose,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Purpose of Outing',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Enter purpose' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    const Text("Return Time", style: TextStyle(color: AppTheme.textGrey)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDateTime,
                      child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                         decoration: BoxDecoration(
                            color: AppTheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                         ),
                         child: Row(
                            children: [
                               const Icon(Icons.calendar_today, color: AppTheme.primary),
                               const SizedBox(width: 16),
                               Text(
                                  _validTo == null ? 'Select Date & Time' : DateFormat('MMM dd, yyyy - hh:mm a').format(_validTo!),
                                  style: TextStyle(color: _validTo == null ? AppTheme.textGrey : Colors.white, fontSize: 16),
                               ),
                            ],
                         ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    GradientButton(
                      text: "GENERATE PASS",
                      icon: Icons.qr_code,
                      isLoading: loading,
                      onPressed: _submit,
                    )
                  ]
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
