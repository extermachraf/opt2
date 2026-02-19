import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart' as platform_interface;

/// Comprehensive biometric authentication service for Face ID, Touch ID, and Fingerprint
class BiometricAuthService {
  static BiometricAuthService? _instance;
  static BiometricAuthService get instance =>
      _instance ??= BiometricAuthService._();
  BiometricAuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastBiometricAuthKey = 'last_biometric_auth';

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      if (kIsWeb) {
        // Web: Check for WebAuthn support
        return await _checkWebAuthnSupport();
      }

      // Check if device supports biometrics
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      if (kIsWeb) {
        final isAvailable = await _checkWebAuthnSupport();
        return isAvailable ? [BiometricType.webAuthn] : [];
      }

      // Fix type mismatch by using platform interface type
      final List<platform_interface.BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics
          .map((type) => BiometricType.fromLocalAuthType(type))
          .toList();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometric methods
  Future<BiometricAuthResult> authenticate({
    String localizedFallbackTitle = 'Usa password',
    String signInTitle = 'Accesso Sicuro NutriVita',
    String cancelButton = 'Annulla',
    String goToSettingsButton = 'Impostazioni',
    String goToSettingsDescription = 'Configura l\'autenticazione biometrica',
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
  }) async {
    try {
      // Check if biometric is enabled in settings
      final isEnabled = await _getBiometricEnabledFromStorage();
      if (!isEnabled) {
        return BiometricAuthResult.disabled;
      }

      // Check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult.notAvailable;
      }

      // Platform-specific authentication
      if (kIsWeb) {
        return await _authenticateWeb();
      }

      return await _authenticateMobile(
        localizedFallbackTitle: localizedFallbackTitle,
        signInTitle: signInTitle,
        stickyAuth: stickyAuth,
        sensitiveTransaction: sensitiveTransaction,
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return BiometricAuthResult.error;
    }
  }

  /// Mobile biometric authentication using local_auth
  Future<BiometricAuthResult> _authenticateMobile({
    required String localizedFallbackTitle,
    required String signInTitle,
    required bool stickyAuth,
    required bool sensitiveTransaction,
  }) async {
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: signInTitle,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: 'Autenticazione Biometrica',
            cancelButton: 'Annulla',
            deviceCredentialsRequiredTitle: 'Credenziali Richieste',
            deviceCredentialsSetupDescription:
                'Configura le credenziali del dispositivo',
            goToSettingsButton: 'Impostazioni',
            goToSettingsDescription:
                'Configura l\'autenticazione biometrica nelle impostazioni',
          ),
          IOSAuthMessages(
            cancelButton: 'Annulla',
            goToSettingsButton: 'Impostazioni',
            goToSettingsDescription:
                'Configura l\'autenticazione biometrica nelle impostazioni del dispositivo',
            lockOut: 'Autenticazione bloccata. Riprova più tardi.',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
        ),
      );

      if (authenticated) {
        await _saveBiometricAuthTimestamp();
        return BiometricAuthResult.success;
      }

      return BiometricAuthResult.failed;
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notEnrolled:
          return BiometricAuthResult.notEnrolled;
        case auth_error.notAvailable:
          return BiometricAuthResult.notAvailable;
        case auth_error.passcodeNotSet:
          return BiometricAuthResult.passcodeNotSet;
        case auth_error.permanentlyLockedOut:
          return BiometricAuthResult.lockedOut;
        case auth_error.lockedOut:
          return BiometricAuthResult.lockedOut;
        case 'UserCancel':
        case 'UserFallback':
        case 'SystemCancel':
          return BiometricAuthResult.cancelled;
        default:
          print(
              'PlatformException during authentication: ${e.code} - ${e.message}');
          return BiometricAuthResult.error;
      }
    } catch (e) {
      print('Unexpected error during authentication: $e');
      return BiometricAuthResult.error;
    }
  }

  /// Web biometric authentication using WebAuthn
  Future<BiometricAuthResult> _authenticateWeb() async {
    try {
      // Simulate WebAuthn authentication
      // In a real implementation, this would use the WebAuthn API
      final hasWebAuthn = await _checkWebAuthnSupport();
      if (hasWebAuthn) {
        await _saveBiometricAuthTimestamp();
        return BiometricAuthResult.success;
      }
      return BiometricAuthResult.notAvailable;
    } catch (e) {
      print('Web biometric authentication error: $e');
      return BiometricAuthResult.error;
    }
  }

  /// Check WebAuthn support in browser
  Future<bool> _checkWebAuthnSupport() async {
    try {
      if (kIsWeb) {
        // Check if browser supports WebAuthn
        return true; // Most modern browsers support WebAuthn
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Enable or disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      return true;
    } catch (e) {
      print('Error setting biometric enabled: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    return await _getBiometricEnabledFromStorage();
  }

  /// Get biometric enabled status from storage
  Future<bool> _getBiometricEnabledFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      print('Error getting biometric enabled status: $e');
      return false;
    }
  }

  /// Save timestamp of last successful biometric authentication
  Future<void> _saveBiometricAuthTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _lastBiometricAuthKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving biometric auth timestamp: $e');
    }
  }

  /// Get timestamp of last successful biometric authentication
  Future<DateTime?> getLastBiometricAuthTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastBiometricAuthKey);
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      print('Error getting last biometric auth time: $e');
      return null;
    }
  }

  /// Check if biometric authentication is required (based on time since last auth)
  Future<bool> isBiometricAuthRequired(
      {Duration timeout = const Duration(minutes: 15)}) async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;

      final lastAuth = await getLastBiometricAuthTime();
      if (lastAuth == null) return true;

      final now = DateTime.now();
      return now.difference(lastAuth) > timeout;
    } catch (e) {
      print('Error checking if biometric auth required: $e');
      return false;
    }
  }

  /// Quick biometric check for sensitive operations
  Future<bool> quickBiometricCheck(
      {String reason = 'Conferma la tua identità'}) async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return true; // Allow if biometric is not enabled

      final result = await authenticate(
        signInTitle: reason,
        sensitiveTransaction: true,
      );

      return result == BiometricAuthResult.success;
    } catch (e) {
      print('Error in quick biometric check: $e');
      return false;
    }
  }
}

/// Available biometric types
enum BiometricType {
  faceId,
  touchId,
  fingerprint,
  iris,
  weak,
  strong,
  webAuthn;

  static BiometricType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'face':
      case 'faceid':
        return BiometricType.faceId;
      case 'touch':
      case 'touchid':
        return BiometricType.touchId;
      case 'fingerprint':
        return BiometricType.fingerprint;
      case 'iris':
        return BiometricType.iris;
      case 'weak':
        return BiometricType.weak;
      case 'strong':
        return BiometricType.strong;
      case 'webauthn':
        return BiometricType.webAuthn;
      default:
        return BiometricType.fingerprint;
    }
  }

  static BiometricType fromLocalAuthType(platform_interface.BiometricType localAuthType) {
    // Convert from local_auth BiometricType to our enum
    switch (localAuthType) {
      case platform_interface.BiometricType.face:
        return BiometricType.faceId;
      case platform_interface.BiometricType.fingerprint:
        return BiometricType.fingerprint;
      case platform_interface.BiometricType.iris:
        return BiometricType.iris;
      case platform_interface.BiometricType.weak:
        return BiometricType.weak;
      case platform_interface.BiometricType.strong:
        return BiometricType.strong;
      default:
        return BiometricType.fingerprint;
    }
  }

  String get displayName {
    switch (this) {
      case BiometricType.faceId:
        return 'Face ID';
      case BiometricType.touchId:
        return 'Touch ID';
      case BiometricType.fingerprint:
        return 'Impronta digitale';
      case BiometricType.iris:
        return 'Riconoscimento iris';
      case BiometricType.weak:
        return 'Biometria debole';
      case BiometricType.strong:
        return 'Biometria forte';
      case BiometricType.webAuthn:
        return 'Autenticazione web';
    }
  }

  String get iconName {
    switch (this) {
      case BiometricType.faceId:
      case BiometricType.iris:
        return 'face';
      case BiometricType.touchId:
      case BiometricType.fingerprint:
        return 'fingerprint';
      case BiometricType.weak:
      case BiometricType.strong:
        return 'security';
      case BiometricType.webAuthn:
        return 'web';
    }
  }
}

/// Result of biometric authentication
enum BiometricAuthResult {
  success,
  failed,
  cancelled,
  notAvailable,
  notEnrolled,
  disabled,
  lockedOut,
  passcodeNotSet,
  error;

  String get message {
    switch (this) {
      case BiometricAuthResult.success:
        return 'Autenticazione riuscita';
      case BiometricAuthResult.failed:
        return 'Autenticazione fallita';
      case BiometricAuthResult.cancelled:
        return 'Autenticazione annullata dall\'utente';
      case BiometricAuthResult.notAvailable:
        return 'Autenticazione biometrica non disponibile su questo dispositivo';
      case BiometricAuthResult.notEnrolled:
        return 'Configura Face ID, Touch ID o impronte digitali nelle impostazioni del dispositivo';
      case BiometricAuthResult.disabled:
        return 'Autenticazione biometrica disabilitata';
      case BiometricAuthResult.lockedOut:
        return 'Autenticazione biometrica bloccata. Riprova più tardi';
      case BiometricAuthResult.passcodeNotSet:
        return 'Configura un codice di accesso sul dispositivo prima di usare la biometria';
      case BiometricAuthResult.error:
        return 'Errore durante l\'autenticazione biometrica';
    }
  }

  bool get isSuccess => this == BiometricAuthResult.success;
  bool get requiresUserAction =>
      this == BiometricAuthResult.notEnrolled ||
      this == BiometricAuthResult.passcodeNotSet;
}