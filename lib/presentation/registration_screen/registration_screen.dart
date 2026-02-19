import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/medical_fields_section.dart';
import './widgets/password_strength_indicator.dart';
import './widgets/pdf_viewer_modal.dart';
import './widgets/terms_conditions_modal.dart';
import './widgets/terms_privacy_section.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _showDateValidationError = false;

  // Form Controllers - All fields accessible for both required and optional
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _codiceFiscaleController = TextEditingController();
  final _comuneResidenzaController = TextEditingController();
  final _regionTreatmentController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Form State
  DateTime? _selectedBirthDate;
  String? _selectedGender;

  // Updated consent state - two separate checkboxes
  bool _acceptTerms = false;
  bool _acceptDataProcessing = false;

  // Password visibility
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _telephoneController.dispose();
    _birthplaceController.dispose();
    _codiceFiscaleController.dispose();
    _comuneResidenzaController.dispose();
    _regionTreatmentController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String _getPasswordStrength(String password) {
    if (password.length < 6) return 'Debole';
    if (password.length < 8) return 'Medio';
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Forte';
    }
    return 'Medio';
  }

  void _clearMessages() {
    if (_errorMessage != null || _successMessage != null) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
        _showDateValidationError = false; // Clear date validation error
      });
    }
  }

  void _handleRegistration() async {
    // Clear any existing messages
    _clearMessages();

    // Validate birth date first
    if (_selectedBirthDate == null) {
      setState(() {
        _showDateValidationError = true;
        _errorMessage = 'Seleziona la tua data di nascita per continuare.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Updated validation - both consents required
    if (!_acceptTerms || !_acceptDataProcessing) {
      setState(() {
        _errorMessage = 'È necessario accettare tutti i termini per procedere';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService.instance.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        birthDate: _selectedBirthDate!,
        genderAtBirth: _selectedGender,
        name:
            _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
        surname:
            _surnameController.text.trim().isEmpty
                ? null
                : _surnameController.text.trim(),
        telephone:
            _telephoneController.text.trim().isEmpty
                ? null
                : _telephoneController.text.trim(),
        birthplace:
            _birthplaceController.text.trim().isEmpty
                ? null
                : _birthplaceController.text.trim(),
        codiceFiscale:
            _codiceFiscaleController.text.trim().isEmpty
                ? null
                : _codiceFiscaleController.text.trim(),
        comuneResidenza:
            _comuneResidenzaController.text.trim().isEmpty
                ? null
                : _comuneResidenzaController.text.trim(),
        // Add consent flags
        acceptedTermsOfService: _acceptTerms,
        acceptedPrivacyPolicy: _acceptDataProcessing,
        acceptedDataProcessing: _acceptDataProcessing,
      );

      if (result['success'] == true && result['immediate_login'] == true) {
        HapticFeedback.lightImpact();

        setState(() {
          _successMessage =
              result['message'] ??
              'Registrazione completata! Credenziali salvate e accessibili.';
        });

        // Show success message briefly
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registrazione completata con successo! Iniziamo con il tutorial per scoprire NutriVita.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );

          // Navigate to tutorial instead of dashboard for new users
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/tutorial-system',
            (route) => false,
          );
        }
      } else {
        // Fallback for unexpected response structure
        setState(() {
          _errorMessage = 'Risposta del server non valida. Riprova.';
        });
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      String errorMessage = error.toString().replaceAll('Exception: ', '');

      // Enhanced error handling
      if (errorMessage.contains('Utente con questa email esiste già')) {
        errorMessage =
            'Esiste già un account con questa email. Le credenziali sono già salvate - prova ad accedere.';
      } else if (errorMessage.contains('Formato email non valido')) {
        errorMessage = 'Inserisci un indirizzo email valido.';
      } else if (errorMessage.contains('Password deve essere di almeno')) {
        errorMessage = 'La password deve essere di almeno 8 caratteri.';
      } else if (errorMessage.contains(
        'È necessario accettare tutti i termini',
      )) {
        errorMessage = 'È necessario accettare tutti i termini per procedere';
      }

      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.loginBgDark,
      body: Container(
        decoration: AppTheme.loginDarkBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 2.h),

                  // Header with Back Button
                  _buildHeaderStyled(),

                  SizedBox(height: 3.h),

                  // Success Message
                  if (_successMessage != null) ...[
                    _buildSuccessMessageStyled(),
                    SizedBox(height: 3.h),
                  ],

                  // Error Message
                  if (_errorMessage != null) ...[
                    _buildErrorMessageStyled(),
                    SizedBox(height: 3.h),
                  ],

                  // Info Card
                  _buildInfoCardStyled(),

                  SizedBox(height: 4.h),

                  // Required Fields Section
                  _buildRequiredFieldsStyled(),

                  SizedBox(height: 4.h),

                  // Optional Fields Section
                  _buildMedicalFieldsSectionStyled(),

                  SizedBox(height: 4.h),

                  // Terms and Privacy Section - Updated with three checkboxes
                  _buildTermsPrivacySectionStyled(),

                  SizedBox(height: 4.h),

                  // Register Button - Updated to check both consents
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (!_acceptTerms ||
                                  !_acceptDataProcessing ||
                                  _isLoading)
                              ? null
                              : _handleRegistration,
                      style: AppTheme.loginButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.grey.shade600;
                          }
                          return AppTheme.loginButtonBg;
                        }),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 3.h,
                                width: 3.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Registrati',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Login Link
                  Center(
                    child: TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Navigator.pop(context);
                              },
                      child: RichText(
                        text: TextSpan(
                          text: 'Hai già un account? ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.loginTextMuted,
                          ),
                          children: [
                            TextSpan(
                              text: 'Accedi',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.loginAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // STYLED WIDGETS FOR DARK OCEAN THEME
  // ============================================

  Widget _buildHeaderStyled() {
    return Row(
      children: [
        // Back Button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 7.w,
          ),
          padding: EdgeInsets.all(2.w),
          constraints: BoxConstraints(minWidth: 12.w, minHeight: 6.h),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Crea Account',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'I tuoi dati vengono salvati permanentemente',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.loginTextSubtle,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 12.w),
      ],
    );
  }

  Widget _buildSuccessMessageStyled() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.loginCredsAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.loginCredsAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: AppTheme.loginCredsAccent,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _successMessage!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Le tue credenziali saranno disponibili anche dopo il logout.',
                  style: TextStyle(
                    color: AppTheme.loginCredsText,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessageStyled() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.errorLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorLight,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearMessages,
            icon: Icon(
              Icons.close,
              color: Colors.white.withValues(alpha: 0.7),
              size: 5.w,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardStyled() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.loginAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.loginAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.loginAccent,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'I tuoi dati verranno salvati permanentemente nel database e saranno accessibili anche dopo il logout.',
              style: TextStyle(
                color: AppTheme.loginTextSubtle,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredFieldsStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informazioni Obbligatorie *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 3.h),

        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Email *',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.loginTextMuted,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email è obbligatoria';
            }
            if (!RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(value.trim())) {
              return 'Inserisci un indirizzo email valido';
            }
            return null;
          },
          onChanged: (value) => _clearMessages(),
        ),

        SizedBox(height: 2.h),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Password * (min 8 caratteri)',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.loginTextMuted,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.loginTextMuted,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password è obbligatoria';
            }
            if (value.length < 8) {
              return 'Password deve essere di almeno 8 caratteri';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
            _clearMessages();
          },
        ),

        // Password Strength Indicator
        if (_passwordController.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          PasswordStrengthIndicator(password: _passwordController.text),
        ],

        SizedBox(height: 2.h),

        // Confirm Password Field
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_showConfirmPassword,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Conferma Password *',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.loginTextMuted,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.loginTextMuted,
              ),
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Conferma password è obbligatoria';
            }
            if (value != _passwordController.text) {
              return 'Le password non coincidono';
            }
            return null;
          },
          onChanged: (value) => _clearMessages(),
        ),

        SizedBox(height: 2.h),

        // Birth Date Field - CUSTOM DATE PICKER IMPLEMENTATION
        InkWell(
          onTap: () => _showCustomDatePicker(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.loginInputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.loginInputBorder),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar',
                  color: AppTheme.loginTextMuted,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data di Nascita *',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.loginTextHint,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        _selectedBirthDate != null
                            ? _formatDate(_selectedBirthDate)
                            : 'Seleziona data',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color:
                              _selectedBirthDate != null
                                  ? Colors.white
                                  : AppTheme.loginTextHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.loginTextMuted,
                ),
              ],
            ),
          ),
        ),
        // Date validation message
        if (_selectedBirthDate == null && _showDateValidationError) ...[
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.only(left: 3.w),
            child: Text(
              'Data di nascita è obbligatoria',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.errorLight,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMedicalFieldsSectionStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informazioni Aggiuntive',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Questi campi sono facoltativi ma aiutano a personalizzare la tua esperienza',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppTheme.loginTextMuted,
          ),
        ),
        SizedBox(height: 3.h),

        // Genere alla nascita Field
        DropdownButtonFormField<String>(
          value: _selectedGender,
          dropdownColor: AppTheme.loginBgDeep,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.loginTextMuted),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Genere alla nascita',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.loginTextMuted,
                size: 20,
              ),
            ),
          ),
          items: [
            DropdownMenuItem(value: 'male', child: Text('Maschio', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'female', child: Text('Femmina', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'other', child: Text('Altro', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(
              value: 'prefer_not_to_say',
              child: Text('Preferisco non specificare', style: TextStyle(color: Colors.white)),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
            _clearMessages();
          },
        ),

        SizedBox(height: 2.h),

        // Nome Field
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Nome',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.person_outline, color: AppTheme.loginTextMuted, size: 20),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Cognome Field
        TextFormField(
          controller: _surnameController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Cognome',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.person_outline, color: AppTheme.loginTextMuted, size: 20),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Telefono Field
        TextFormField(
          controller: _telephoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Numero di telefono',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.phone_outlined, color: AppTheme.loginTextMuted, size: 20),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Luogo di nascita Field
        TextFormField(
          controller: _birthplaceController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Luogo di nascita',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.location_city_outlined, color: AppTheme.loginTextMuted, size: 20),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Codice Fiscale Field
        TextFormField(
          controller: _codiceFiscaleController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 16,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Codice Fiscale',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.credit_card_outlined, color: AppTheme.loginTextMuted, size: 20),
            ),
          ).copyWith(counterText: ''),
          onChanged: (value) {
            // Auto-uppercase as user types
            if (value != value.toUpperCase()) {
              _codiceFiscaleController.value = _codiceFiscaleController.value.copyWith(
                text: value.toUpperCase(),
                selection: TextSelection.collapsed(offset: value.length),
              );
            }
          },
        ),

        SizedBox(height: 2.h),

        // Comune di residenza Field
        TextFormField(
          controller: _comuneResidenzaController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Comune di residenza',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.home_outlined, color: AppTheme.loginTextMuted, size: 20),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Info Card
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.loginAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.loginAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.loginAccent,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Tutti questi campi sono facoltativi. Puoi compilarli ora o aggiungerli successivamente nel tuo profilo.',
                  style: TextStyle(
                    color: AppTheme.loginTextSubtle,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsPrivacySectionStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Updated detailed consent information text
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            'I dati gestiti attraverso Nutrivita possono rivelare le tue condizioni di salute. Per poter accedere ai servizi di Nutrivita è necessario esprimere il tuo consenso al trattamento. Leggi con attenzione la Privacy Policy e ricorda che il tuo consenso potrà essere sempre revocato; in caso di revoca del consenso, il tuo profilo sarà rimosso e i tuoi dati cancellati. Ti chiediamo inoltre di rispettare i Termini e le condizioni di utilizzo.',
            style: TextStyle(
              color: AppTheme.loginTextSubtle,
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // "Con la presente:" text
        Text(
          'Con la presente:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 3.h),

        // Data Processing Consent Checkbox
        _buildConsentCheckbox(
          value: _acceptDataProcessing,
          onChanged: (value) {
            setState(() {
              _acceptDataProcessing = value ?? false;
            });
            _clearMessages();
          },
          text: 'acconsento al trattamento di dati personali',
          isLink: true,
          onLinkTap: () async {
            // Show PDF privacy policy modal
            await showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return const PdfViewerModal();
              },
            );
          },
        ),

        SizedBox(height: 2.h),

        // Terms of Service Checkbox
        _buildConsentCheckbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
            _clearMessages();
          },
          text: 'dichiaro di conoscere e accettare i termini e le condizioni di utilizzo',
          isLink: true,
          onLinkTap: () async {
            await showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return const TermsConditionsModal();
              },
            );
          },
        ),

        SizedBox(height: 3.h),

        // Warning Info text
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Tutti i consensi sopra elencati devono essere selezionati per poter procedere con la registrazione.',
                  style: TextStyle(
                    color: Colors.orange.shade200,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
    bool isLink = false,
    VoidCallback? onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.loginButtonBg;
                }
                return Colors.transparent;
              }),
              checkColor: WidgetStateProperty.all(Colors.white),
              side: BorderSide(color: AppTheme.loginTextMuted, width: 2),
            ),
          ),
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2.w),
            child: GestureDetector(
              onTap: isLink ? onLinkTap : null,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isLink ? AppTheme.loginAccent : AppTheme.loginTextSubtle,
                  fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
                  decoration: isLink ? TextDecoration.underline : null,
                  decorationColor: AppTheme.loginAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Back Button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 7.w,
          ),
          padding: EdgeInsets.all(2.w),
          constraints: BoxConstraints(minWidth: 12.w, minHeight: 6.h),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Crea Account',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'I tuoi dati vengono salvati permanentemente',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 12.w),
      ],
    );
  }

  Widget _buildRequiredFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informazioni Obbligatorie *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 3.h),

        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email *',
            hintText: 'esempio@email.com',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email è obbligatoria';
            }
            if (!RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(value.trim())) {
              return 'Inserisci un indirizzo email valido';
            }
            return null;
          },
          onChanged: (value) => _clearMessages(),
        ),

        SizedBox(height: 3.h),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Minimo 8 caratteri',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password è obbligatoria';
            }
            if (value.length < 8) {
              return 'Password deve essere di almeno 8 caratteri';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
            _clearMessages();
          },
        ),

        // Password Strength Indicator
        if (_passwordController.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          PasswordStrengthIndicator(password: _passwordController.text),
        ],

        SizedBox(height: 3.h),

        // Confirm Password Field
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_showConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Conferma Password *',
            hintText: 'Ripeti la password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Conferma password è obbligatoria';
            }
            if (value != _passwordController.text) {
              return 'Le password non coincidono';
            }
            return null;
          },
          onChanged: (value) => _clearMessages(),
        ),

        SizedBox(height: 3.h),

        // Birth Date Field - CUSTOM DATE PICKER IMPLEMENTATION
        InkWell(
          onTap: () => _showCustomDatePicker(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 4.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data di Nascita *',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _selectedBirthDate != null
                            ? _formatDate(_selectedBirthDate)
                            : 'Seleziona data',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color:
                              _selectedBirthDate != null
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        // Date validation message
        if (_selectedBirthDate == null && _showDateValidationError) ...[
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.only(left: 3.w),
            child: Text(
              'Data di nascita è obbligatoria',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],

        SizedBox(height: 3.h),

        // Gender Field - MADE OPTIONAL (no validator) - REMOVED FROM REQUIRED SECTION
        // DropdownButtonFormField<String>(
        //   value: _selectedGender,
        //   decoration: InputDecoration(
        //     labelText: 'Sesso alla Nascita (Opzionale)',
        //     prefixIcon: Padding(
        //       padding: EdgeInsets.all(3.w),
        //       child: CustomIconWidget(
        //         iconName: 'person',
        //         color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        //         size: 20,
        //       ),
        //     ),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(3.w),
        //     ),
        //   ),
        //   items: const [
        //     DropdownMenuItem(value: 'male', child: Text('Maschio')),
        //     DropdownMenuItem(value: 'female', child: Text('Femmina')),
        //     DropdownMenuItem(value: 'other', child: Text('Altro')),
        //     DropdownMenuItem(
        //       value: 'prefer_not_to_say',
        //       child: Text('Preferisco non specificare'),
        //     ),
        //   ],
        //   onChanged: (value) {
        //     setState(() {
        //       _selectedGender = value;
        //     });
        //     _clearMessages();
        //   },
        // ),
      ],
    );
  }

  void _showCustomDatePicker() {
    setState(() {
      _showDateValidationError = false;
    });

    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedBirthDate ?? DateTime(now.year - 25);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedYear = DateTime(initialDate.year);
        DateTime selectedMonth = DateTime(initialDate.year, initialDate.month);
        DateTime selectedDay = initialDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Container(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Text(
                      'Seleziona Data di Nascita',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Year Selection
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 3.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anno',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          SizedBox(
                            height: 20.h,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 50,
                              controller: FixedExtentScrollController(
                                initialItem: now.year - selectedYear.year,
                              ),
                              onSelectedItemChanged: (index) {
                                setDialogState(() {
                                  selectedYear = DateTime(now.year - index);
                                  selectedMonth = DateTime(
                                    selectedYear.year,
                                    selectedMonth.month,
                                  );
                                  selectedDay = DateTime(
                                    selectedYear.year,
                                    selectedMonth.month,
                                    selectedDay.day >
                                            DateTime(
                                              selectedYear.year,
                                              selectedMonth.month + 1,
                                              0,
                                            ).day
                                        ? DateTime(
                                          selectedYear.year,
                                          selectedMonth.month + 1,
                                          0,
                                        ).day
                                        : selectedDay.day,
                                  );
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 100,
                                builder: (context, index) {
                                  final year = now.year - index;
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$year',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color:
                                            year == selectedYear.year
                                                ? AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .primary
                                                : AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurface,
                                        fontWeight:
                                            year == selectedYear.year
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Month and Day Selection Row
                    Row(
                      children: [
                        // Month Selection
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 2.w,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mese',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                SizedBox(
                                  height: 15.h,
                                  child: ListWheelScrollView.useDelegate(
                                    itemExtent: 40,
                                    controller: FixedExtentScrollController(
                                      initialItem: selectedMonth.month - 1,
                                    ),
                                    onSelectedItemChanged: (index) {
                                      setDialogState(() {
                                        selectedMonth = DateTime(
                                          selectedYear.year,
                                          index + 1,
                                        );
                                        final maxDay =
                                            DateTime(
                                              selectedYear.year,
                                              index + 2,
                                              0,
                                            ).day;
                                        if (selectedDay.day > maxDay) {
                                          selectedDay = DateTime(
                                            selectedYear.year,
                                            index + 1,
                                            maxDay,
                                          );
                                        } else {
                                          selectedDay = DateTime(
                                            selectedYear.year,
                                            index + 1,
                                            selectedDay.day,
                                          );
                                        }
                                      });
                                    },
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                          childCount: 12,
                                          builder: (context, index) {
                                            final months = [
                                              'Gen',
                                              'Feb',
                                              'Mar',
                                              'Apr',
                                              'Mag',
                                              'Giu',
                                              'Lug',
                                              'Ago',
                                              'Set',
                                              'Ott',
                                              'Nov',
                                              'Dic',
                                            ];
                                            return Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                months[index],
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color:
                                                      (index + 1) ==
                                                              selectedMonth
                                                                  .month
                                                          ? AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .primary
                                                          : AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .onSurface,
                                                  fontWeight:
                                                      (index + 1) ==
                                                              selectedMonth
                                                                  .month
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 3.w),

                        // Day Selection
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 2.w,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giorno',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                SizedBox(
                                  height: 15.h,
                                  child: ListWheelScrollView.useDelegate(
                                    itemExtent: 40,
                                    controller: FixedExtentScrollController(
                                      initialItem: selectedDay.day - 1,
                                    ),
                                    onSelectedItemChanged: (index) {
                                      setDialogState(() {
                                        selectedDay = DateTime(
                                          selectedYear.year,
                                          selectedMonth.month,
                                          index + 1,
                                        );
                                      });
                                    },
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                          childCount:
                                              DateTime(
                                                selectedYear.year,
                                                selectedMonth.month + 1,
                                                0,
                                              ).day,
                                          builder: (context, index) {
                                            final day = index + 1;
                                            return Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$day',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color:
                                                      day == selectedDay.day
                                                          ? AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .primary
                                                          : AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .onSurface,
                                                  fontWeight:
                                                      day == selectedDay.day
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Selected Date Display
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Data selezionata: ${_formatDate(selectedDay)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 3.w),
                            ),
                            child: Text(
                              'Annulla',
                              style: TextStyle(
                                color:
                                    AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate age (must be at least 13 and not more than 120 years old)
                              final age = now.year - selectedDay.year;
                              if (age < 13) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Devi avere almeno 13 anni per registrarti.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (age > 120) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Inserisci una data di nascita valida.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _selectedBirthDate = selectedDay;
                                _birthDateController.text = _formatDate(
                                  selectedDay,
                                );
                                _showDateValidationError = false;
                              });
                              _clearMessages();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 3.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                            ),
                            child: Text(
                              'Conferma',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
