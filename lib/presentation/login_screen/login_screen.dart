import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/error_message_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isNavigating = false;
  bool _showBiometricPrompt = false;
  String? _errorMessage;
  String? _prefilledEmail;
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ensureDemoUserExists();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['email'] != null) {
        _prefilledEmail = args['email'];
        _emailController.text = _prefilledEmail!;
      }
    });
  }

  // Ensure demo user exists for testing
  void _ensureDemoUserExists() async {
    try {
      await AuthService.instance.ensureDemoUserExists();
    } catch (error) {
      print('Demo user setup error: $error');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Prevent multiple simultaneous login attempts
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Inserisci email e password per continuare.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        HapticFeedback.lightImpact();

        String successMessage =
            'Benvenuto, ${result['user_name'] ?? 'Utente'}!';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                successMessage,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to dashboard - use WidgetsBinding to ensure navigation happens after frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _navigateToDashboard();
            }
          });
        }
        return; // Exit early to prevent finally block from running setState after navigation
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      String errorMessage = error.toString().replaceAll('Exception: ', '');

      // Enhanced error handling for specific cases
      if (errorMessage.contains('Account non trovato')) {
        errorMessage = 'Account non trovato. Verifica l\'email o registrati.';
      } else if (errorMessage.contains('Email o password non corretti') ||
          errorMessage.contains('Invalid login credentials')) {
        errorMessage = 'Email o password non corretti. Riprova.';
      } else if (errorMessage.contains('Account disattivato')) {
        errorMessage = 'Account disattivato. Contatta il supporto tecnico.';
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
      return; // Exit early after handling error
    }

    // Only reset loading if we didn't navigate or handle error
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Inserisci la tua email per recuperare la password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.instance.forgotPassword(email);

      if (result['success'] == true) {
        HapticFeedback.lightImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Email di reset password inviata!',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBiometricSetup() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate biometric setup
    await Future.delayed(Duration(milliseconds: 1000));

    HapticFeedback.lightImpact();
    if (mounted) {
      _navigateToDashboard();
    }
  }

  void _skipBiometric() {
    HapticFeedback.selectionClick();
    if (mounted) {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    // Prevent multiple navigation attempts
    if (_isNavigating) return;
    _isNavigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.loginBgDark,
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Container(
          decoration: AppTheme.loginDarkBackground,
          child: SafeArea(
            child: Stack(
              children: [
                // Main Content
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 2.h),

                          // Back Button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/splash-screen',
                                  (route) => false,
                                );
                              },
                              icon: CustomIconWidget(
                                iconName: 'arrow_back',
                                color: Colors.white,
                                size: 7.w,
                              ),
                              padding: EdgeInsets.all(2.w),
                              constraints: BoxConstraints(
                                minWidth: 12.w,
                                minHeight: 6.h,
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Logo Section
                          _buildLogoSection(),

                          SizedBox(height: 4.h),

                          // Welcome Text
                          Text(
                            'Ciao',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 1.h),

                          Text(
                            'Accedi al tuo percorso nutrizionale',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.loginTextSubtle,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 4.h),

                          // Error Message
                          if (_errorMessage != null) ...[
                            _buildErrorMessageStyled(),
                            SizedBox(height: 3.h),
                          ],

                          // Login Form
                          _buildLoginFormStyled(),

                          SizedBox(height: 4.h),

                          // Demo Credentials Section
                          _buildDemoCredentialsStyled(),

                          SizedBox(height: 4.h),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Text(
                                  'oppure',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppTheme.loginTextMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4.h),

                          // Register Link
                          Center(
                            child: TextButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.pushNamed(
                                          context,
                                          '/registration_screen',
                                        );
                                      },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.5.h,
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Nuovo paziente? ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.loginTextMuted,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Registrati',
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

                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // Biometric Prompt Overlay
                if (_showBiometricPrompt)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: BiometricPromptWidget(
                        onSuccess: _handleBiometricSetup,
                        onCancel: _skipBiometric,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // STYLED WIDGETS FOR DARK OCEAN THEME
  // ============================================

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          // NutriVita Logo
          Image.asset(
            'assets/images/dashboard.png', // <-- REPLACE with your actual path and file name
            height: 50, // Adjust the height (or width) as needed for the right size
          ),

          SizedBox(height: 2.h),

          // Developed by text
          Text(
            'È un\'applicazione sviluppata da:',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.loginTextMuted,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // AIOM Logo
          Image.asset(
            'assets/images/landing.png', // <-- REPLACE with your actual path and file name
            height: 100, // Adjust the height (or width) as needed for the right size
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessageStyled() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearError,
            icon: Icon(
              Icons.close,
              color: Colors.white.withValues(alpha: 0.7),
              size: 5.w,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Email',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.loginTextMuted,
                size: 20,
              ),
            ),
          ),
          onChanged: (value) => _clearError(),
        ),

        SizedBox(height: 2.h),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: AppTheme.loginInputDecoration(
            hintText: 'Password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.loginTextMuted,
                size: 20,
              ),
            ),
          ),
          onChanged: (value) => _clearError(),
          onFieldSubmitted: (value) => _handleLogin(),
        ),

        SizedBox(height: 1.5.h),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : _handleForgotPassword,
            child: Text(
              'Password dimenticata?',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.loginAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Login Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: AppTheme.loginButtonStyle,
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
                      'Accedi',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoCredentialsStyled() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: AppTheme.loginCredsDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.loginCredsAccent,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Credenziali Test Verificate',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.loginCredsAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: AppTheme.loginCredsInnerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Utente Demo:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.loginCredsText,
                  ),
                ),
                SizedBox(height: 0.5.h),
                GestureDetector(
                  onTap: () {
                    _emailController.text = 'yassine00kriouet@gmail.com';
                    HapticFeedback.lightImpact();
                  },
                  child: Text(
                    '📧 yassine00kriouet@gmail.com',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.loginCredsText,
                      fontFamily: 'monospace',
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.loginCredsText,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                GestureDetector(
                  onTap: () {
                    _passwordController.text = 'Test123456!';
                    HapticFeedback.lightImpact();
                  },
                  child: Text(
                    '🔐 Test123456!',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.loginCredsText,
                      fontFamily: 'monospace',
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.loginCredsText,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '💡 Tocca per compilare automaticamente',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.loginCredsAccent,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
