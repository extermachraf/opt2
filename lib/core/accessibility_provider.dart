import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_settings_service.dart';
import '../services/auth_service.dart';

class AccessibilityProvider extends ChangeNotifier {
  static final AccessibilityProvider _instance =
      AccessibilityProvider._internal();
  factory AccessibilityProvider() => _instance;
  AccessibilityProvider._internal();

  static AccessibilityProvider get instance => _instance;

  final UserSettingsService _userSettingsService = UserSettingsService.instance;
  final AuthService _authService = AuthService.instance;

  // Accessibility settings state
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reducedAnimationEnabled = false;
  double _textScaleFactor = 1.0;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  bool get highContrastEnabled => _highContrastEnabled;
  bool get largeTextEnabled => _largeTextEnabled;
  bool get reducedAnimationEnabled => _reducedAnimationEnabled;
  double get textScaleFactor => _textScaleFactor;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  // Animation duration based on accessibility settings
  Duration get animationDuration => _reducedAnimationEnabled
      ? const Duration(milliseconds: 100)
      : const Duration(milliseconds: 300);

  // Curve based on accessibility settings
  Curve get animationCurve =>
      _reducedAnimationEnabled ? Curves.linear : Curves.easeInOut;

  /// Initialize accessibility provider and load user preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _loadAccessibilityFromStorage();
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // If loading fails, use default settings
      _highContrastEnabled = false;
      _largeTextEnabled = false;
      _reducedAnimationEnabled = false;
      _textScaleFactor = 1.0;
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      debugPrint('Failed to initialize accessibility settings: $e');
    }
  }

  /// Load accessibility preferences from storage
  Future<void> _loadAccessibilityFromStorage() async {
    try {
      // First try to load from local storage
      final prefs = await SharedPreferences.getInstance();
      bool? localHighContrast = prefs.getBool('accessibility_high_contrast');
      bool? localLargeText = prefs.getBool('accessibility_large_text');
      bool? localReducedAnimation =
          prefs.getBool('accessibility_reduced_animation');
      double? localTextScale = prefs.getDouble('accessibility_text_scale');

      // If user is authenticated, try to load from Supabase
      if (_authService.isAuthenticated) {
        try {
          final settings = await _userSettingsService.getUserSettings();
          if (settings != null) {
            if (settings['high_contrast_enabled'] != null) {
              localHighContrast = settings['high_contrast_enabled'] as bool;
              await prefs.setBool(
                  'accessibility_high_contrast', localHighContrast);
            }
            if (settings['large_text_enabled'] != null) {
              localLargeText = settings['large_text_enabled'] as bool;
              await prefs.setBool('accessibility_large_text', localLargeText);
            }
            if (settings['reduced_animation_enabled'] != null) {
              localReducedAnimation =
                  settings['reduced_animation_enabled'] as bool;
              await prefs.setBool(
                  'accessibility_reduced_animation', localReducedAnimation);
            }
            if (settings['text_scale_factor'] != null) {
              localTextScale =
                  (settings['text_scale_factor'] as num).toDouble();
              await prefs.setDouble('accessibility_text_scale', localTextScale);
            }
          }
        } catch (e) {
          // If Supabase fails, use local storage
          debugPrint('Failed to load accessibility from Supabase: $e');
        }
      }

      // Apply the settings
      _highContrastEnabled = localHighContrast ?? false;
      _largeTextEnabled = localLargeText ?? false;
      _reducedAnimationEnabled = localReducedAnimation ?? false;
      _textScaleFactor = localTextScale ?? 1.0;
    } catch (e) {
      debugPrint('Failed to load accessibility from storage: $e');
      // Use defaults
      _highContrastEnabled = false;
      _largeTextEnabled = false;
      _reducedAnimationEnabled = false;
      _textScaleFactor = 1.0;
    }
  }

  /// Update high contrast setting
  Future<void> updateHighContrast(bool enabled) async {
    if (_highContrastEnabled == enabled) return;

    try {
      _highContrastEnabled = enabled;
      await _saveAccessibilityToStorage();
      notifyListeners();

      // Provide haptic feedback
      if (enabled) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Revert on error
      _highContrastEnabled = !enabled;
      notifyListeners();
      throw Exception('Errore nel salvataggio impostazioni alto contrasto: $e');
    }
  }

  /// Update large text setting
  Future<void> updateLargeText(bool enabled) async {
    if (_largeTextEnabled == enabled) return;

    try {
      _largeTextEnabled = enabled;
      // Auto-adjust text scale factor when large text is enabled/disabled
      _textScaleFactor = enabled ? 1.3 : 1.0;
      await _saveAccessibilityToStorage();
      notifyListeners();

      // Provide haptic feedback
      if (enabled) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Revert on error
      _largeTextEnabled = !enabled;
      _textScaleFactor = enabled ? 1.0 : 1.3;
      notifyListeners();
      throw Exception(
          'Errore nel salvataggio impostazioni testo ingrandito: $e');
    }
  }

  /// Update reduced animation setting
  Future<void> updateReducedAnimation(bool enabled) async {
    if (_reducedAnimationEnabled == enabled) return;

    try {
      _reducedAnimationEnabled = enabled;
      await _saveAccessibilityToStorage();
      notifyListeners();

      // Provide haptic feedback (only if animations aren't reduced)
      if (!enabled) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Revert on error
      _reducedAnimationEnabled = !enabled;
      notifyListeners();
      throw Exception(
          'Errore nel salvataggio impostazioni animazioni ridotte: $e');
    }
  }

  /// Update text scale factor
  Future<void> updateTextScaleFactor(double scaleFactor) async {
    // Clamp value between 0.5 and 2.0
    final clampedFactor = scaleFactor.clamp(0.5, 2.0);

    if ((_textScaleFactor - clampedFactor).abs() < 0.01) return;

    try {
      _textScaleFactor = clampedFactor;
      // Auto-enable large text if scale factor is above 1.2
      _largeTextEnabled = clampedFactor > 1.2;
      await _saveAccessibilityToStorage();
      notifyListeners();

      // Provide haptic feedback for significant changes
      if ((clampedFactor - 1.0).abs() > 0.2) {
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Revert on error - restore previous values
      notifyListeners();
      throw Exception('Errore nel salvataggio fattore di scala testo: $e');
    }
  }

  /// Save accessibility preferences to storage
  Future<void> _saveAccessibilityToStorage() async {
    try {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('accessibility_high_contrast', _highContrastEnabled);
      await prefs.setBool('accessibility_large_text', _largeTextEnabled);
      await prefs.setBool(
          'accessibility_reduced_animation', _reducedAnimationEnabled);
      await prefs.setDouble('accessibility_text_scale', _textScaleFactor);

      // If user is authenticated, save to Supabase
      if (_authService.isAuthenticated) {
        try {
          await _userSettingsService.updateUserSettings({
            'high_contrast_enabled': _highContrastEnabled,
            'large_text_enabled': _largeTextEnabled,
            'reduced_animation_enabled': _reducedAnimationEnabled,
            'text_scale_factor': _textScaleFactor,
          });
        } catch (e) {
          debugPrint('Failed to save accessibility to Supabase: $e');
          // Local storage is still saved, so continue
        }
      }
    } catch (e) {
      debugPrint('Failed to save accessibility to storage: $e');
      throw Exception('Errore nel salvataggio preferenze accessibilità: $e');
    }
  }

  /// Get theme data adjusted for accessibility
  ThemeData getAccessibleThemeData(ThemeData baseTheme) {
    if (!_highContrastEnabled) return baseTheme;

    // High contrast color scheme
    final ColorScheme highContrastColorScheme = ColorScheme.fromSeed(
      seedColor: baseTheme.primaryColor,
      brightness: baseTheme.brightness,
      // Enhanced contrast colors
      primary: baseTheme.brightness == Brightness.light
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF),
      onPrimary: baseTheme.brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000),
      surface: baseTheme.brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000),
      onSurface: baseTheme.brightness == Brightness.light
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF),
    );

    return baseTheme.copyWith(
      colorScheme: highContrastColorScheme,
      // Enhanced focus indicators for high contrast
      focusColor: highContrastColorScheme.primary.withAlpha(77),
      // Thicker borders for better visibility
      dividerTheme: baseTheme.dividerTheme.copyWith(
        thickness: 2.0,
        color: highContrastColorScheme.onSurface,
      ),
      // More prominent outline buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: highContrastColorScheme.primary,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  /// Get text theme adjusted for accessibility
  TextTheme getAccessibleTextTheme(TextTheme baseTextTheme) {
    if (!_largeTextEnabled && _textScaleFactor == 1.0) return baseTextTheme;

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize:
            (baseTextTheme.displayLarge?.fontSize ?? 57) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.displayLarge?.fontWeight,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize:
            (baseTextTheme.displayMedium?.fontSize ?? 45) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.displayMedium?.fontWeight,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize:
            (baseTextTheme.displaySmall?.fontSize ?? 36) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.displaySmall?.fontWeight,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize:
            (baseTextTheme.headlineLarge?.fontSize ?? 32) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.headlineLarge?.fontWeight,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize:
            (baseTextTheme.headlineMedium?.fontSize ?? 28) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.headlineMedium?.fontWeight,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize:
            (baseTextTheme.headlineSmall?.fontSize ?? 24) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.headlineSmall?.fontWeight,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.titleLarge?.fontWeight,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize:
            (baseTextTheme.titleMedium?.fontSize ?? 16) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.titleMedium?.fontWeight,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.titleSmall?.fontWeight,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w500
            : baseTextTheme.bodyLarge?.fontWeight,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w500
            : baseTextTheme.bodyMedium?.fontWeight,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w500
            : baseTextTheme.bodySmall?.fontWeight,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.labelLarge?.fontWeight,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize:
            (baseTextTheme.labelMedium?.fontSize ?? 12) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.labelMedium?.fontWeight,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : baseTextTheme.labelSmall?.fontWeight,
      ),
    );
  }

  /// Reset all accessibility settings to defaults
  Future<void> resetAccessibilitySettings() async {
    try {
      _highContrastEnabled = false;
      _largeTextEnabled = false;
      _reducedAnimationEnabled = false;
      _textScaleFactor = 1.0;

      await _saveAccessibilityToStorage();
      notifyListeners();

      HapticFeedback.mediumImpact();
    } catch (e) {
      throw Exception('Errore nel ripristino impostazioni accessibilità: $e');
    }
  }

  /// Force refresh accessibility settings from storage (useful after login/logout)
  Future<void> refreshAccessibilitySettings() async {
    _isInitialized = false;
    await initialize();
  }

  /// Check if any accessibility feature is enabled
  bool get hasAccessibilityEnabled =>
      _highContrastEnabled ||
      _largeTextEnabled ||
      _reducedAnimationEnabled ||
      _textScaleFactor != 1.0;
}
