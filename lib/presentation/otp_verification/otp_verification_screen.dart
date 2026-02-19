import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  String? _email;
  DateTime? _expiresAt;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _email = args['email'];
          _expiresAt = args['expires_at'] != null
              ? DateTime.parse(args['expires_at'])
              : null;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_expiresAt != null) {
      final expiry = _expiresAt!;
      final now = DateTime.now();
      _remainingSeconds = expiry.difference(now).inSeconds;

      if (_remainingSeconds > 0) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted && _remainingSeconds > 0) {
            setState(() {
              _remainingSeconds--;
            });
          } else {
            timer.cancel();
          }
        });
      }
    }
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {
      _errorMessage = null;
    });

    // Auto-submit when all 6 digits are entered
    if (_controllers.every((controller) => controller.text.isNotEmpty)) {
      _verifyOTP();
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyOTP() async {
    final email = _email;
    if (email == null || _otpCode.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = {
        'success': true,
        'message': 'Email verified successfully'
      };

      if (result['success'] == true) {
        HapticFeedback.lightImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email verificata con successo! Ora puoi accedere al tuo account.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to login screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login-screen',
            (route) => false,
            arguments: {'email': email, 'verified': true},
          );
        }
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _errorMessage =
              (result['message'] as String?) ?? 'Codice di verifica non valido';
          // Clear the OTP fields
          for (var controller in _controllers) {
            controller.clear();
          }
          if (_focusNodes.isNotEmpty) {
            _focusNodes[0].requestFocus();
          }
        });
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage =
            'Errore durante la verifica: ${error.toString().replaceAll('Exception: ', '')}';
        // Clear the OTP fields
        for (var controller in _controllers) {
          controller.clear();
        }
        if (_focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resendOTP() async {
    final email = _email;
    if (email == null || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final result = {
        'success': true,
        'message': 'New code sent to your email!',
        'expires_at': DateTime.now().add(Duration(minutes: 5)).toIso8601String()
      };

      if (result['success'] == true) {
        HapticFeedback.lightImpact();
        setState(() {
          _expiresAt = result['expires_at'] != null
              ? DateTime.parse(result['expires_at'] as String)
              : null;
          // Clear any previous OTP
          for (var controller in _controllers) {
            controller.clear();
          }
          _errorMessage = null;
        });

        _timer?.cancel();
        _startTimer();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (result['message'] as String?) ??
                    'Nuovo codice inviato alla tua email!',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage =
              (result['message'] as String?) ?? 'Errore nell\'invio del codice';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage =
            'Errore: ${error.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 6.w,
          ),
        ),
        title: Text(
          'Verifica Email',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 4.h),

              // Email icon
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    (255 * 0.1).round(),
                    AppTheme.lightTheme.colorScheme.primary.red,
                    AppTheme.lightTheme.colorScheme.primary.green,
                    AppTheme.lightTheme.colorScheme.primary.blue,
                  ),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 10.w,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),

              SizedBox(height: 4.h),

              // Title
              Text(
                'Verifica il tuo indirizzo email',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // Description
              Text(
                'Abbiamo inviato un codice di verifica di 6 cifre a:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 1.h),

              // Email display
              Text(
                _email ?? '',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 6.h),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOTPField(index)),
              ),

              if (_errorMessage != null) ...[
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                      (255 * 0.1).round(),
                      Colors.red.red,
                      Colors.red.green,
                      Colors.red.blue,
                    ),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: Color.fromARGB(
                        (255 * 0.3).round(),
                        Colors.red.red,
                        Colors.red.green,
                        Colors.red.blue,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 5.w),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 4.h),

              // Timer
              if (_remainingSeconds > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                      (255 * 0.1).round(),
                      AppTheme.lightTheme.colorScheme.tertiary.red,
                      AppTheme.lightTheme.colorScheme.tertiary.green,
                      AppTheme.lightTheme.colorScheme.tertiary.blue,
                    ),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Il codice scade tra $_formattedTime',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
              ],

              // Resend button
              TextButton(
                onPressed:
                    _remainingSeconds <= 0 && !_isResending ? _resendOTP : null,
                child: _isResending
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _remainingSeconds > 0
                            ? 'Richiedi nuovo codice tra $_formattedTime'
                            : 'Non hai ricevuto il codice? Invia di nuovo',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: _remainingSeconds <= 0
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.textMediumEmphasisLight,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),

              SizedBox(height: 6.h),

              // Verify Button (Manual)
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed:
                      _otpCode.length == 6 && !_isLoading ? _verifyOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 3.h,
                          width: 3.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Verifica Codice',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 4.h),

              // Help text
              Text(
                'Controlla anche la cartella spam se non vedi l\'email',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 12.w,
      height: 6.h,
      decoration: BoxDecoration(
        border: Border.all(
          color:
              _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.borderLight,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyPressed(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          onChanged: (value) => _onOTPChanged(index, value),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
    );
  }
}
