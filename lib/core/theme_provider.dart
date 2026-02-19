import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/user_settings_service.dart';
import '../services/auth_service.dart';
import './accessibility_provider.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  static ThemeProvider get instance => _instance;

  final UserSettingsService _userSettingsService = UserSettingsService.instance;
  final AuthService _authService = AuthService.instance;
  final AccessibilityProvider _accessibilityProvider =
      AccessibilityProvider.instance;

  // Force only light theme for now - dark mode is coming soon
  ThemeMode _themeMode = ThemeMode.light;
  String _themeModeString = 'light';
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  String get themeModeString => _themeModeString;
  bool get isInitialized => _isInitialized;

  /// Initialize theme provider and load user preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadThemeFromStorage();
      // Also initialize accessibility provider
      await _accessibilityProvider.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If loading fails, use light theme default
      _themeMode = ThemeMode.light;
      _themeModeString = 'light';
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Load theme preference from storage
  Future<void> _loadThemeFromStorage() async {
    try {
      // First try to load from local storage
      final prefs = await SharedPreferences.getInstance();
      String? localTheme = prefs.getString('theme_mode');

      // If user is authenticated, try to load from Supabase
      if (_authService.isAuthenticated) {
        try {
          final settings = await _userSettingsService.getUserSettings();
          if (settings != null && settings['theme_mode'] != null) {
            localTheme = settings['theme_mode'];
            // Save to local storage as backup
            await prefs.setString('theme_mode', localTheme!);
          }
        } catch (e) {
          // If Supabase fails, use local storage
          debugPrint('Failed to load theme from Supabase: $e');
        }
      }

      // Apply the theme - but force light mode for now
      if (localTheme != null) {
        await _updateThemeMode(localTheme, saveToStorage: false);
      }
    } catch (e) {
      debugPrint('Failed to load theme from storage: $e');
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(String themeModeString) async {
    // Show "coming soon" message for dark mode attempts
    if (themeModeString.toLowerCase() == 'dark') {
      throw Exception(
          'La modalità scura sarà disponibile presto! Stiamo lavorando per offrirti la migliore esperienza possibile.');
    }

    await _updateThemeMode(themeModeString, saveToStorage: true);
  }

  /// Internal method to update theme mode
  Future<void> _updateThemeMode(String themeModeString,
      {bool saveToStorage = true}) async {
    ThemeMode newThemeMode;

    // For now, force everything to light mode except system (which we'll handle)
    switch (themeModeString.toLowerCase()) {
      case 'light':
        newThemeMode = ThemeMode.light;
        break;
      case 'dark':
        // Redirect dark mode to light mode silently during loading
        if (saveToStorage) {
          throw Exception('La modalità scura sarà disponibile presto!');
        }
        newThemeMode = ThemeMode.light;
        themeModeString = 'light';
        break;
      case 'system':
        // For system mode, we'll force light until dark mode is ready
        newThemeMode = ThemeMode.light;
        themeModeString = 'light';
        break;
      default:
        newThemeMode = ThemeMode.light;
        themeModeString = 'light';
        break;
    }

    if (_themeMode != newThemeMode || _themeModeString != themeModeString) {
      _themeMode = newThemeMode;
      _themeModeString = themeModeString;

      if (saveToStorage) {
        await _saveThemeToStorage(themeModeString);
      }

      notifyListeners();
    }
  }

  /// Save theme preference to storage
  Future<void> _saveThemeToStorage(String themeModeString) async {
    try {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', themeModeString);

      // If user is authenticated, save to Supabase
      if (_authService.isAuthenticated) {
        try {
          await _userSettingsService.updateUserSettings({
            'theme_mode': themeModeString,
          });
        } catch (e) {
          debugPrint('Failed to save theme to Supabase: $e');
          // Local storage is still saved, so continue
        }
      }
    } catch (e) {
      debugPrint('Failed to save theme to storage: $e');
    }
  }

  /// Get current theme data based on brightness - returns accessibility-adjusted theme
  ThemeData getCurrentThemeData(BuildContext context) {
    // Start with base light theme
    ThemeData baseTheme = AppTheme.lightTheme;

    // Apply accessibility adjustments
    if (_accessibilityProvider.isInitialized) {
      // Apply high contrast adjustments
      baseTheme = _accessibilityProvider.getAccessibleThemeData(baseTheme);

      // Apply text scaling adjustments
      baseTheme = baseTheme.copyWith(
        textTheme:
            _accessibilityProvider.getAccessibleTextTheme(baseTheme.textTheme),
      );
    }

    return baseTheme;
  }

  /// Check if current theme is dark - always returns false for now
  bool isDarkMode(BuildContext context) {
    // Always return false until dark mode is ready
    return false;
  }

  /// Get current effective brightness - always returns light for now
  Brightness getCurrentBrightness(BuildContext context) {
    return Brightness.light;
  }

  /// Get animation duration based on accessibility settings
  Duration getAnimationDuration() {
    if (!_accessibilityProvider.isInitialized) {
      return const Duration(milliseconds: 300);
    }
    return _accessibilityProvider.animationDuration;
  }

  /// Get animation curve based on accessibility settings
  Curve getAnimationCurve() {
    if (!_accessibilityProvider.isInitialized) {
      return Curves.easeInOut;
    }
    return _accessibilityProvider.animationCurve;
  }

  /// Listen to system theme changes - disabled for now
  void listenToSystemThemeChanges() {
    // Disabled until dark mode is ready
    // We don't want to respond to system changes yet
  }

  /// Reset theme to light default
  Future<void> resetToSystem() async {
    await updateThemeMode('light');
  }

  /// Force refresh theme from storage (useful after login/logout)
  Future<void> refreshTheme() async {
    await _loadThemeFromStorage();
    // Also refresh accessibility settings
    await _accessibilityProvider.refreshAccessibilitySettings();
  }

  /// Listen to accessibility changes and update theme accordingly
  void _listenToAccessibilityChanges() {
    _accessibilityProvider.addListener(() {
      // Notify theme changes when accessibility settings change
      notifyListeners();
    });
  }

  /// Start listening to accessibility changes
  void startAccessibilityListener() {
    _listenToAccessibilityChanges();
  }
}
