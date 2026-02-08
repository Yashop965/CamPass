// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'services/session_manager.dart';
import 'providers/pass_provider.dart';
import 'providers/location_provider.dart';
import 'providers/sos_provider.dart';
import 'providers/warden_provider.dart';
import 'providers/guard_provider.dart';
import 'providers/parent_provider.dart';

class CampassApp extends StatefulWidget {
  final String? initialRoute;

  const CampassApp({super.key, this.initialRoute});

  @override
  State<CampassApp> createState() => _CampassAppState();
}

class _CampassAppState extends State<CampassApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeFromSettings();
  }

  Future<void> _loadThemeFromSettings() async {
    final user = await SessionManager.getUser();
    if (user?.settings != null) {
      final theme = user!.settings!['theme'] as String?;
      if (theme == 'dark') {
        setState(() => _themeMode = ThemeMode.dark);
      } else if (theme == 'light') {
        setState(() => _themeMode = ThemeMode.light);
      }
    }
  }

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PassProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SOSProvider()),
        ChangeNotifierProvider(create: (_) => WardenProvider()),
        ChangeNotifierProvider(create: (_) => GuardProvider()),
        ChangeNotifierProvider(create: (_) => ParentProvider()),
      ],
      child: MaterialApp(
        title: 'CAMPASS',
        theme: AppTheme.darkTheme, // Force dark/cyber theme for now
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        initialRoute: widget.initialRoute ?? '/',
        routes: AppRoutes.routes,
        onGenerateRoute: (settings) {
        // Handle dynamic routes with theme callback
        if (settings.name?.startsWith('/student') == true ||
            settings.name?.startsWith('/parent') == true ||
            settings.name?.startsWith('/warden') == true ||
            settings.name?.startsWith('/guard') == true) {
          final routeName = settings.name!;
          final routeBuilder = AppRoutes.routes[routeName.split('/')[1]];

          if (routeBuilder != null) {
            return MaterialPageRoute(
              builder: (context) => ThemeProvider(
                themeMode: _themeMode,
                onThemeChanged: _setThemeMode,
                child: routeBuilder(context),
              ),
            );
          }
        }
        return null;
      },
    ));
  }
}

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}
