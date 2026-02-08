import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/session_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glassy_card.dart';
import '../../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _selectedRole;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _selectedRole = args?['role'] as String?;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // ... Validation methods remain the same ...
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        await SessionManager.saveSession(
          token: await _authService.api.getToken() ?? '',
          role: user.role,
          user: user,
        );
        if(!mounted) return;
        Navigator.pushReplacementNamed(context, '/${user.role}');
      } else {
        _showErrorDialog('Invalid email or password');
      }
    } catch (e) {
      _showErrorDialog('Login failed. Please try again.');
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Login Failed', style: TextStyle(color: AppTheme.textWhite)),
        content: Text(message, style: const TextStyle(color: AppTheme.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. Ambient Background Orb
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.3),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.primary,
                    blurRadius: 150,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),
          
          Positioned(
             bottom: -50,
             left: -50,
             child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: AppTheme.primary.withOpacity(0.2),
                   boxShadow: const [
                      BoxShadow(
                         color: AppTheme.secondary,
                         blurRadius: 120,
                         spreadRadius: 40,
                      )
                   ],
                ),
             ),
          ),

          // 2. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Icon(
                      Icons.shield_outlined, 
                      size: 64, 
                      color: AppTheme.primary
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CAMPASS', 
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        letterSpacing: 2,
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: AppTheme.primary, blurRadius: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secure Campus Access',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppTheme.primary.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Glass Form Card
                    GlassyCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login as ${_selectedRole?.toUpperCase() ?? 'Admin'}',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 24),
                            
                            // Email
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            
                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppTheme.textGrey,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Login Button
                            GradientButton(
                              text: 'AUTHENTICATE',
                              icon: Icons.login_rounded,
                              isLoading: _isLoading,
                              onPressed: _login,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                         onPressed: () {
                            // Register Navigation
                         },
                         child: RichText(
                            text: TextSpan(
                               text: "Don't have an account? ",
                               style: Theme.of(context).textTheme.bodyMedium,
                               children: const [
                                  TextSpan(
                                     text: "Register",
                                     style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                     ),
                                  ),
                               ]
                            ),
                         ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          
          // Back Button
          Positioned(
             top: 40,
             left: 16,
             child:  IconButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
             ),
          ),
        ],
      ),
    );
  }
}
