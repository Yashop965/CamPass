class AppConfig {
  static const String appName = 'CAMPASS';
  static const String version = '1.0.0';

  // Environment configuration
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://your-production-api.com'; // Replace with your production URL
      case 'staging':
        return 'https://your-staging-api.com'; // Replace with your staging URL
      case 'development':
      default:
        // For development, use 10.0.2.2 for Android Emulator, or localhost for iOS/Web
        // If testing on a physical device, change this to your computer's IP
        return 'http://192.168.1.197:5000';
    }
  }

  // Firebase Configuration
  static const String firebaseProjectId = 'campass-app-12345'; // Replace with your Firebase project ID

  // Timeout configurations
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Feature flags
  static const bool enableLogging = !isProduction;
  static const bool enableCrashReporting = isProduction;
}