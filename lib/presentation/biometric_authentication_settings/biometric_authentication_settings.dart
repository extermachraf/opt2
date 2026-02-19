import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_auth_service.dart';
import '../../services/user_settings_service.dart';

class BiometricAuthenticationSettings extends StatefulWidget {
  const BiometricAuthenticationSettings({Key? key}) : super(key: key);

  @override
  State<BiometricAuthenticationSettings> createState() =>
      _BiometricAuthenticationSettingsState();
}

class _BiometricAuthenticationSettingsState
    extends State<BiometricAuthenticationSettings> {
  final AuthService _authService = AuthService.instance;
  final UserSettingsService _userSettingsService = UserSettingsService.instance;
  final BiometricAuthService _biometricService = BiometricAuthService.instance;

  bool _isLoading = true;
  bool _biometricEnabled = false;
  String? _error;
  bool _isSaving = false;
  List<BiometricType> _availableBiometrics = [];
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (!_authService.isAuthenticated) {
        setState(() {
          _error = 'Utente non autenticato';
          _isLoading = false;
        });
        return;
      }

      // Check biometric availability
      _biometricAvailable = await _biometricService.isBiometricAvailable();
      if (_biometricAvailable) {
        _availableBiometrics = await _biometricService.getAvailableBiometrics();
      }

      // Get current settings
      final settings = await _userSettingsService.getUserSettings();
      final biometricEnabledLocal =
          await _biometricService.isBiometricEnabled();

      if (!mounted) return;

      setState(() {
        _biometricEnabled =
            settings?['biometric_enabled'] ?? biometricEnabledLocal;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBiometricSetting(bool enabled) async {
    if (_isSaving) return;

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });

      if (enabled && !_biometricAvailable) {
        setState(() {
          _isSaving = false;
        });

        _showMessage(
          'L\'autenticazione biometrica non è disponibile su questo dispositivo. '
          'Verifica che Face ID, Touch ID o le impronte digitali siano configurati '
          'nelle impostazioni del dispositivo.',
          isError: true,
        );
        return;
      }

      if (enabled) {
        // Test biometric authentication before enabling
        final result = await _biometricService.authenticate(
          signInTitle: 'Configura Autenticazione Biometrica',
          sensitiveTransaction: false,
        );

        if (!result.isSuccess) {
          setState(() {
            _isSaving = false;
          });

          String errorMessage = result.message;
          if (result == BiometricAuthResult.notEnrolled) {
            errorMessage = 'Configura Face ID, Touch ID o le impronte digitali '
                'nelle impostazioni del dispositivo prima di attivare l\'autenticazione biometrica.';
          } else if (result == BiometricAuthResult.passcodeNotSet) {
            errorMessage = 'Configura un codice di accesso sul dispositivo '
                'prima di usare l\'autenticazione biometrica.';
          } else if (result == BiometricAuthResult.notAvailable) {
            errorMessage = 'L\'autenticazione biometrica non è supportata '
                'su questo dispositivo o non è configurata correttamente.';
          }

          _showMessage(errorMessage, isError: true);
          return;
        }
      }

      // Update local biometric service setting
      await _biometricService.setBiometricEnabled(enabled);

      // Update user settings in database
      await _userSettingsService.updateUserSettings({
        'biometric_enabled': enabled,
      });

      if (!mounted) return;

      setState(() {
        _biometricEnabled = enabled;
        _isSaving = false;
        _error = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Autenticazione biometrica attivata con successo! '
                    'Ora puoi usare Face ID, Touch ID o le impronte digitali per accedere.'
                : 'Autenticazione biometrica disattivata',
          ),
          backgroundColor: AppTheme.lightTheme.primaryColor,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _error = null;
      });

      String errorMessage = 'Errore sconosciuto durante la configurazione';

      if (error.toString().contains('not available')) {
        errorMessage = 'L\'autenticazione biometrica non è disponibile. '
            'Verifica le impostazioni del dispositivo.';
      } else if (error.toString().contains('not enrolled')) {
        errorMessage = 'Configura Face ID, Touch ID o le impronte digitali '
            'nelle impostazioni del dispositivo.';
      } else if (error.toString().contains('passcode')) {
        errorMessage = 'Configura un codice di accesso sul dispositivo.';
      }

      _showMessage(errorMessage, isError: true);
    }
  }

  Future<void> _testBiometricAuthentication() async {
    try {
      if (!_biometricAvailable) {
        _showMessage('Autenticazione biometrica non disponibile',
            isError: true);
        return;
      }

      final result = await _biometricService.authenticate(
        signInTitle: 'Test Autenticazione Biometrica',
        sensitiveTransaction: false,
      );

      _showMessage(result.message, isError: !result.isSuccess);
    } catch (error) {
      _showMessage('Errore nel test: ${error.toString()}', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppTheme.lightTheme.colorScheme.error
            : AppTheme.lightTheme.primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Autenticazione Biometrica'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.primaryColor,
            size: 6.w,
          ),
        ),
        actions: [
          if (_biometricEnabled && _biometricAvailable)
            IconButton(
              onPressed: _testBiometricAuthentication,
              icon: CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              tooltip: 'Test autenticazione',
            ),
          IconButton(
            onPressed: _showHelpDialog,
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.lightTheme.primaryColor,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.error,
          ),
          SizedBox(height: 2.h),
          Text(
            'Errore nel caricamento delle impostazioni',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              _error ?? 'Errore sconosciuto',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _loadBiometricSettings,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainToggle(),
          SizedBox(height: 3.h),
          if (_biometricAvailable) ...[
            _buildSupportedMethodsSection(),
            SizedBox(height: 3.h),
          ],
          _buildSecurityInfoCard(),
          if (!_biometricAvailable) ...[
            SizedBox(height: 3.h),
            _buildUnavailableCard(),
          ],
          SizedBox(height: 3.h),
          _buildFallbackOptionsSection(),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'fingerprint',
              color: AppTheme.lightTheme.primaryColor,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autenticazione Biometrica',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _biometricEnabled
                      ? 'Attiva - Proteggi i tuoi dati medici'
                      : 'Non attiva - Attiva per maggiore sicurezza',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _biometricEnabled
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: _biometricEnabled && _biometricAvailable,
                  onChanged:
                      _biometricAvailable ? _updateBiometricSetting : null,
                  activeColor: AppTheme.lightTheme.primaryColor,
                ),
        ],
      ),
    );
  }

  Widget _buildSupportedMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metodi Supportati',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ..._availableBiometrics.map((type) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: _buildMethodCard(
                type.displayName,
                _getDescriptionForBiometricType(type),
                type.iconName,
                true,
              ),
            )),
      ],
    );
  }

  String _getDescriptionForBiometricType(BiometricType type) {
    switch (type) {
      case BiometricType.faceId:
        return 'Disponibile su dispositivi iOS supportati';
      case BiometricType.touchId:
        return 'Touch ID disponibile su dispositivi Apple';
      case BiometricType.fingerprint:
        return 'Scanner di impronte digitali Android';
      case BiometricType.iris:
        return 'Riconoscimento dell\'iride';
      case BiometricType.webAuthn:
        return 'Autenticazione web sicura';
      default:
        return 'Metodo biometrico disponibile';
    }
  }

  Widget _buildMethodCard(
      String title, String subtitle, String iconName, bool available) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: available
              ? AppTheme.lightTheme.primaryColor.withAlpha(51)
              : AppTheme.lightTheme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: available
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: available
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (available)
            Icon(
              Icons.check_circle,
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w,
            )
          else
            Icon(
              Icons.info_outline,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
        ],
      ),
    );
  }

  Widget _buildUnavailableCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Biometria Non Disponibile',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'L\'autenticazione biometrica non è disponibile su questo dispositivo.\n\n'
            'Per utilizzare questa funzione:\n'
            '• Verifica che il tuo dispositivo supporti Face ID, Touch ID o le impronte digitali\n'
            '• Configura la biometria nelle impostazioni del dispositivo\n'
            '• Assicurati di aver impostato un codice di accesso\n\n'
            'Se il problema persiste, contatta il supporto.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onErrorContainer,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfoCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Informazioni sulla Sicurezza',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '• I dati biometrici rimangono sul tuo dispositivo\n'
            '• Conforme alle normative sulla privacy medica\n'
            '• Crittografia avanzata per i dati sanitari\n'
            '• Accesso rapido e sicuro alle informazioni di trattamento\n'
            '• Timeout di sicurezza per operazioni sensibili',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opzioni di Riserva',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildFallbackOption(
                'Password principale',
                'Usa la tua password se la biometria non funziona',
                'lock',
              ),
              Divider(height: 2.h),
              _buildFallbackOption(
                'Domande di sicurezza',
                'Rispondi alle domande di sicurezza configurate',
                'quiz',
              ),
              Divider(height: 2.h),
              _buildFallbackOption(
                'Accesso di emergenza',
                'Contatta il supporto per l\'accesso urgente',
                'emergency',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackOption(String title, String subtitle, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aiuto - Autenticazione Biometrica'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'L\'autenticazione biometrica protegge i tuoi dati medici sensibili usando Face ID, Touch ID, o impronte digitali.'),
              SizedBox(height: 2.h),
              Text(
                'Requisiti:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text('• Dispositivo con sensori biometrici supportati'),
              const Text('• Sistema operativo aggiornato'),
              const Text(
                  '• Biometria configurata nelle impostazioni del dispositivo'),
              const Text('• Codice di accesso del dispositivo impostato'),
              SizedBox(height: 2.h),
              Text(
                'Risoluzione problemi:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                  '• Su iOS: Impostazioni > Face ID e codice / Touch ID e codice'),
              const Text(
                  '• Su Android: Impostazioni > Sicurezza > Impronta digitale'),
              const Text('• Riavvia l\'app dopo aver configurato la biometria'),
              SizedBox(height: 2.h),
              const Text(
                  'La biometria funziona come livello di sicurezza aggiuntivo e non sostituisce completamente la password.'),
              SizedBox(height: 1.h),
              const Text(
                  'Per problemi tecnici, contatta il supporto a support@nutrivita.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadBiometricSettings(); // Retry loading settings
            },
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }
}
