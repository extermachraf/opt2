import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String semanticLabel;
  final bool isLogoScreen;
  final bool isTextOnlyScreen;
  final bool showLogo;
  final String? logoAsset;

  const OnboardingPageWidget({
    Key? key,
    required this.title,
    this.subtitle = "",
    required this.description,
    required this.imageUrl,
    required this.semanticLabel,
    this.isLogoScreen = false,
    this.isTextOnlyScreen = false,
    this.showLogo = false,
    this.logoAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTextOnlyScreen) {
      // Text-only layout with optional logo at top - Ocean Blue Dark Theme
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // NutriVita logo at top
            Container(
              height: 90,
              width: 180,
              margin: EdgeInsets.only(bottom: 2.h, top: 1.h),
              child: Image.asset(
                'assets/images/NUTRI_VITA_-_REV_3-1762874531000.png',
                height: 90,
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.high,
                semanticLabel: 'NutriVita application logo',
              ),
            ),

            SizedBox(height: 1.5.h),

            // Main title - TEAL COLOR on dark background (matching HTML #80cbc4)
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF80CBC4), // Teal color for dark theme
                height: 1.4,
                letterSpacing: -0.2,
              ),
            ),

            SizedBox(height: 2.h),

            // Description text - Light color for dark background
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFECEFF1), // Light text for dark bg
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Top section with image - adjusted proportions for better image sizing
          Expanded(
            flex:
                isLogoScreen
                    ? 5
                    : 4, // Reduce flex for non-logo screens to prevent image taking too much space
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                top:
                    isLogoScreen ? 1.h : 2.h, // More space for non-logo screens
                bottom: 1.h,
              ),
              child: _buildImageSection(),
            ),
          ),

          // Content section - increased for non-logo screens to accommodate text
          Expanded(
            flex:
                isLogoScreen
                    ? 2
                    : 3, // More space for content on non-logo screens
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isLogoScreen)
                    _buildLogoScreenContent()
                  else
                    _buildContentScreenContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (isLogoScreen) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // NutriVita Logo at the top
              Container(
                height: 80,
                width: 160,
                margin: EdgeInsets.only(bottom: 2.h),
                child: Image.asset(
                  'assets/images/NUTRI_VITA_-_REV_3-1762874531000.png',
                  height: 80,
                  fit: BoxFit.fitHeight,
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'NutriVita application logo',
                ),
              ),

              // Text: "È un'applicazione di" - Light text for dark background
              Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  "È un'applicazione di",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE0E0E0), // Light grey for dark bg
                    height: 1.4,
                    letterSpacing: 0.3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // The green sponsor logo (AIOM) - directly below
              Container(
                height: 80,
                width: 160,
                margin: EdgeInsets.only(bottom: 2.h),
                child: Image.asset(
                  'assets/images/landing.png',
                  height: 80,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'AIOM organization logo with green O element',
                ),
              ),

              // Text: "sviluppata dal Gruppo di Lavoro intersocietario Nutrizione in Oncologia"
              Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Text(
                  "sviluppata dal Gruppo di Lavoro \nintersocietario Nutrizione in \nOncologia",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE0E0E0), // Light grey for dark bg
                    height: 1.5,
                    letterSpacing: 0.2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // Text: "con il supporto non condizionato di"
              Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  "con il supporto non condizionato di",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE0E0E0), // Light grey for dark bg
                    height: 1.5,
                    letterSpacing: 0.2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // The blue sponsor logo - final thing at the bottom
              Container(
                height: 80,
                width: 160,
                child: Image.asset(
                  'assets/images/foundation.png',
                  height: 80,
                  fit: BoxFit.fitHeight,
                  filterQuality: FilterQuality.high,
                  semanticLabel:
                      'Fondazione Guido Berlucchi logo providing unconditional support',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Image section with curved bottom corners (matching HTML design)
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: 35.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: CustomImageWidget(
            imageUrl: imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  Widget _buildLogoScreenContent() {
    // Remove all text content for logo screen - only showing organizational structure
    return const SizedBox.shrink();
  }

  Widget _buildContentScreenContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main title - White for dark background
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white, // White text for dark bg
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),

        SizedBox(height: 1.5.h),

        // Description text - Light grey for dark background
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFE0E0E0), // Light grey for dark bg
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ),

        SizedBox(height: 1.5.h),

        // Feature indicator tag - styled for dark theme (matching HTML)
        if (title.contains("Traccia") ||
            title.contains("Valuta") ||
            title.contains("Accedi"))
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withAlpha(77), // 30% white border
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFeatureIcon(),
                  size: 14,
                  color: const Color(0xFFCFD8DC), // Light grey icon
                ),
                SizedBox(width: 1.5.w),
                Text(
                  _getFeatureText(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFCFD8DC), // Light grey text
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getFeatureIcon() {
    if (title.contains("Traccia")) return Icons.restaurant;
    if (title.contains("Valuta")) return Icons.analytics;
    if (title.contains("Accedi")) return Icons.library_books;
    return Icons.star;
  }

  String _getFeatureText() {
    if (title.contains("Traccia")) return "Diario Alimentare";
    if (title.contains("Valuta")) return "Monitoraggio";
    if (title.contains("Accedi")) return "Educazione";
    return "Funzione";
  }
}
