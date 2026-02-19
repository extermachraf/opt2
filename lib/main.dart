import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';

import './core/app_export.dart';
import './core/theme_provider.dart';
import './core/accessibility_provider.dart';
import './routes/app_routes.dart';
import './services/supabase_service.dart';
import './services/notification_service.dart';
import './services/user_settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase first - CRITICAL for all providers
    await SupabaseService.instance.initialize();
    print('✅ Supabase initialized successfully in main');

    // Initialize notification service with cross-platform support
    await NotificationService.instance.initialize();
    print('✅ NotificationService initialized successfully in main');

    // Initialize user settings service
    await UserSettingsService.instance.initialize();
    print('✅ UserSettingsService initialized successfully in main');

    // Initialize providers after Supabase is ready
    final themeProvider = ThemeProvider.instance;
    final accessibilityProvider = AccessibilityProvider.instance;

    // Initialize theme and accessibility providers
    await themeProvider.initialize();
    await accessibilityProvider.initialize();

    // Start accessibility listener for theme updates
    themeProvider.startAccessibilityListener();

    // Schedule meal reminders if enabled (cross-platform)
    await NotificationService.instance.scheduleDailyMealReminder();

    // Remove auto-start test notifications for production
    // await NotificationService.instance.startTestNotifications();
    // print('🧪 Test notifications auto-started for testing');

    print('✅ All providers and services initialized successfully');
  } catch (e) {
    // If initialization fails, continue with defaults but log the error
    print('❌ Initialization error: $e');
    print('⚠️ Continuing with default settings...');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            ThemeProvider.instance,
            AccessibilityProvider.instance,
          ]),
          builder: (context, child) {
            final themeProvider = ThemeProvider.instance;
            final accessibilityProvider = AccessibilityProvider.instance;

            return MaterialApp(
              title: 'NutriVita',
              debugShowCheckedModeBanner: false,
              // Register route observer for navigation tracking
              navigatorObservers: [AppRoutes.routeObserver],
              // Italian localization for date pickers and other widgets
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('it', 'IT'), // Italian
              ],
              locale: const Locale('it', 'IT'),
              theme: themeProvider.getCurrentThemeData(context),
              themeMode: themeProvider.themeMode,
              initialRoute: AppRoutes.splashScreen,
              routes: AppRoutes.routes,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    // Apply accessibility text scaling while preserving system scaling
                    textScaler: TextScaler.linear(
                      accessibilityProvider.isInitialized
                          ? accessibilityProvider.textScaleFactor
                          : 1.0,
                    ),
                  ),
                  child: Container(
                    decoration: AppTheme.oceanGradientBackground, // GLOBAL GRADIENT
                    child: child,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
