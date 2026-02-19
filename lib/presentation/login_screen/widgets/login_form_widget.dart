import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import './error_message_widget.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final _authService = AuthService.instance;
  final _profileService = ProfileService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response['user'] != null && mounted) {
        try {
          // Check if screening is completed
          print('🔍 Checking screening status...');
          final screeningCompleted = await _profileService.isScreeningCompleted();
          print('🔍 Screening completed: $screeningCompleted');
          
          if (!mounted) return; // Double-check before navigation
          
          if (screeningCompleted) {
            // Go to dashboard
            print('✅ Navigating to dashboard');
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          } else {
            // Go to screening flow
            print('📋 Navigating to screening flow');
            Navigator.pushReplacementNamed(context, AppRoutes.screening);
          }
        } catch (navError) {
          print('❌ Navigation error: $navError');
          // Fallback to dashboard if there's an error
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _useTestCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const CustomIconWidget(
                iconName: 'email',
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Inserire la propria email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Inserire un\'email valida';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const CustomIconWidget(
                iconName: 'lock_outline',
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  iconName: _obscurePassword ? 'visibility' : 'visibility_off',
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Inserire la password';
              }
              if (value.length < 6) {
                return 'La password deve contenere almeno 6 caratteri';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Error Message
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: ErrorMessageWidget(message: _errorMessage!),
            ),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Accedi',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 3.h),

          // Demo Credentials Section - REMOVED to hide demo accounts

          SizedBox(height: 2.h),

          // Forgot Password
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.registrationScreen);
            },
            child: Text(
              'Non hai un account? Registrati',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$role: $email',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _useTestCredentials(email, password),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade100,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              minimumSize: Size(0, 0),
            ),
            child: Text(
              'Use',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
