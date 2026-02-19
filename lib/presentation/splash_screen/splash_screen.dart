import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for animations and minimum splash duration
    await Future.wait([
      _animationController.forward(),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);

    if (!mounted) return;

    try {
      // Check if user is already logged in
      final isLoggedIn = await AuthService.instance.isAuthenticated;

      if (isLoggedIn) {
        // User is logged in, check if tutorial was completed
        final prefs = await SharedPreferences.getInstance();
        final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;
        
        if (tutorialCompleted) {
          // Check if screening is completed
          final screeningCompleted = await ProfileService.instance.isScreeningCompleted();
          
          if (screeningCompleted) {
            // Navigate to dashboard
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          } else {
            // Navigate to screening flow
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/screening',
              (route) => false,
            );
          }
        } else {
          // User is logged in but hasn't completed tutorial
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/tutorial-system',
            (route) => false,
          );
        }
      } else {
        // User not logged in, check if they've seen onboarding
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

        if (hasSeenOnboarding) {
          // Go directly to login
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login_screen',
            (route) => false,
          );
        } else {
          // Show onboarding first
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/onboarding_flow',
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Error checking auth status, go to onboarding
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/onboarding_flow',
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.loginBgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.loginDarkBackground,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Logo with Ocean Blue shadow
                              Container(
                                width: 35.w,
                                height: 35.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(51),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.w),
                                  child: Image.asset(
                                    "assets/images/NUTRI_VITA_-_REV_3-1762874673630.png",
                                    fit: BoxFit.contain,
                                    width: 35.w,
                                    height: 35.w,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 35.w,
                                        height: 35.w,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: 4.h),

                              // App Name - White on dark background
                              Text(
                                'NutriVita',
                                style: AppTheme
                                    .lightTheme.textTheme.displayMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),

                              SizedBox(height: 1.h),

                              // Tagline
                              Text(
                                'Il tuo compagno nutrizionale',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.loginTextSubtle,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Loading Indicator - Teal accent color
                    SizedBox(
                      width: 8.w,
                      height: 8.w,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.loginAccent,
                        ),
                        strokeWidth: 3,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Version Info
                    Text(
                      'Versione 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.loginTextMuted,
                      ),
                    ),

                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
