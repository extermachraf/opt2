import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../../services/biometric_auth_service.dart';

class BiometricPromptWidget extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final String? email;

  const BiometricPromptWidget({
    Key? key,
    this.onSuccess,
    this.onCancel,
    this.email,
  }) : super(key: key);

  @override
  State<BiometricPromptWidget> createState() => _BiometricPromptWidgetState();
}

class _BiometricPromptWidgetState extends State<BiometricPromptWidget> {
  final BiometricAuthService _biometricService = BiometricAuthService.instance;
  final AuthService _authService = AuthService.instance;

  bool _isAuthenticating = false;
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      _biometricAvailable = await _biometricService.isBiometricAvailable();
      if (_biometricAvailable) {
        _availableBiometrics = await _biometricService.getAvailableBiometrics();
        final isEnabled = await _biometricService.isBiometricEnabled();

        // Auto-trigger biometric if enabled and authenticated
        if (isEnabled && _authService.isAuthenticated) {
          await Future.delayed(const Duration(milliseconds: 500));
          _performBiometricAuth();
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error checking biometric availability: $e');
    }
  }

  Future<void> _performBiometricAuth() async {
    if (_isAuthenticating || !_biometricAvailable) return;

    try {
      setState(() {
        _isAuthenticating = true;
      });

      final result = await _biometricService.authenticate(
        signInTitle: 'Accedi a NutriVita',
        sensitiveTransaction: false,
      );

      if (result.isSuccess) {
        widget.onSuccess?.call();
      } else {
        _showErrorMessage(result.message);
      }
    } catch (e) {
      _showErrorMessage('Errore durante l\'autenticazione biometrica');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getPrimaryBiometricIcon() {
    if (_availableBiometrics.isEmpty) return 'fingerprint';

    return _availableBiometrics.first.iconName;
  }

  String _getBiometricTitle() {
    if (_availableBiometrics.isEmpty) return 'Autenticazione Biometrica';

    switch (_availableBiometrics.first) {
      case BiometricType.faceId:
        return 'Face ID';
      case BiometricType.touchId:
        return 'Touch ID';
      case BiometricType.fingerprint:
        return 'Impronta Digitale';
      default:
        return 'Autenticazione Biometrica';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_biometricAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Biometric icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: _isAuthenticating
                ? const CircularProgressIndicator()
                : CustomIconWidget(
                    iconName: _getPrimaryBiometricIcon(),
                    color: AppTheme.lightTheme.primaryColor,
                    size: 10.w,
                  ),
          ),
          SizedBox(height: 3.h),

          // Title
          Text(
            _getBiometricTitle(),
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 1.h),

          // Description
          Text(
            _isAuthenticating
                ? 'Autenticazione in corso...'
                : 'Tocca per autenticarti rapidamente',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                  child: const Text('Usa Password'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isAuthenticating ? null : _performBiometricAuth,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                  ),
                  child: _isAuthenticating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Autentica',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),

          // Available biometrics info
          if (_availableBiometrics.length > 1) ...[
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              children: _availableBiometrics
                  .map((type) => Chip(
                        label: Text(
                          type.displayName,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        backgroundColor:
                            AppTheme.lightTheme.primaryColor.withAlpha(13),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
