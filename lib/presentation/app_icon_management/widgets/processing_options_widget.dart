import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ProcessingOptionsWidget extends StatelessWidget {
  final bool removeBackground;
  final bool applyRoundedCorners;
  final bool enhanceContrast;
  final double cornerRadius;
  final ValueChanged<bool> onRemoveBackgroundChanged;
  final ValueChanged<bool> onRoundedCornersChanged;
  final ValueChanged<bool> onEnhanceContrastChanged;
  final ValueChanged<double> onCornerRadiusChanged;

  const ProcessingOptionsWidget({
    super.key,
    required this.removeBackground,
    required this.applyRoundedCorners,
    required this.enhanceContrast,
    required this.cornerRadius,
    required this.onRemoveBackgroundChanged,
    required this.onRoundedCornersChanged,
    required this.onEnhanceContrastChanged,
    required this.onCornerRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Processing Options',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize how your image is processed for optimal icon appearance.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Remove Background Option
            SwitchListTile(
              title: Text(
                'Remove Background',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Automatically removes white/transparent backgrounds',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.neutralLight,
                ),
              ),
              value: removeBackground,
              onChanged: onRemoveBackgroundChanged,
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(height: 32),

            // Rounded Corners Option
            SwitchListTile(
              title: Text(
                'Apply Rounded Corners',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Adds rounded corners for modern app icon appearance',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.neutralLight,
                ),
              ),
              value: applyRoundedCorners,
              onChanged: onRoundedCornersChanged,
              contentPadding: EdgeInsets.zero,
            ),

            // Corner Radius Slider
            if (applyRoundedCorners) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corner Radius',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.neutralLight,
                      ),
                    ),
                    Slider(
                      value: cornerRadius,
                      min: 0.0,
                      max: 0.5,
                      divisions: 10,
                      label: '${(cornerRadius * 100).round()}%',
                      onChanged: onCornerRadiusChanged,
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 32),

            // Enhance Contrast Option
            SwitchListTile(
              title: Text(
                'Enhance Contrast',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Improves visibility and accessibility of the icon',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.neutralLight,
                ),
              ),
              value: enhanceContrast,
              onChanged: onEnhanceContrastChanged,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.accessibility_new,
                    color: AppTheme.warningLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Processing options optimize icons for medical app accessibility standards.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.warningLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
