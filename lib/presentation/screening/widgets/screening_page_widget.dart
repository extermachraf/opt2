import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// Reusable template for screening pages with gradient background
class ScreeningPageWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? question;
  final String? description;
  final Widget content;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool showSkipOption;
  final bool isSkipChecked;
  final ValueChanged<bool?>? onSkipChanged;
  final bool isButtonEnabled;

  const ScreeningPageWidget({
    Key? key,
    this.title = 'Prima di iniziare',
    this.subtitle = 'Qualche informazione su di te',
    this.question,
    this.description,
    required this.content,
    this.buttonText = 'Avanti →',
    required this.onButtonPressed,
    this.showSkipOption = true,
    this.isSkipChecked = false,
    this.onSkipChanged,
    this.isButtonEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.seaMid, AppTheme.seaDeep],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Top section with logo and Salta button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 60), // Spacer for centering
                        // Logo
                        Image.asset(
                          'assets/images/NUTRI_VITA_-_REV_3-1762874673630.png',
                          height: 7.h,
                        ),
                        // Salta button
                        if (showSkipOption)
                          TextButton(
                            onPressed: () {
                              if (onSkipChanged != null) {
                                onSkipChanged!(true);
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            ),
                            child: Text(
                              'Salta',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 60), // Spacer
                      ],
                    ),
                  ),
                  
                  // Title and Subtitle
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Question
                  if (question != null) ...[
                    SizedBox(height: 5.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        question!,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Description
                  if (description != null) ...[
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        description!,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        child: content,
                      ),
                    ),
                  ),

                  // Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.seaTop, AppTheme.seaMid],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isButtonEnabled ? onButtonPressed : null,
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            child: Text(
                              buttonText,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Skip option at bottom
                  if (showSkipOption) ...[
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Nutrivita ti proporrà un supporto e tuo percorso nutrizionale, Clicca sempre il tuo percorso',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 2.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
