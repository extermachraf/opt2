import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class UploadSectionWidget extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final bool isProcessing;

  const UploadSectionWidget({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.isProcessing,
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
              'Upload New Icon',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an image that will be converted to app icons for all Android densities.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : onCameraPressed,
                    icon: Icon(Icons.camera_alt_outlined),
                    label: Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : onGalleryPressed,
                    icon: Icon(Icons.photo_library_outlined),
                    label: Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tips for best results:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Use high-resolution images (min 512x512)\n'
                    '• Simple designs work better for small icons\n'
                    '• Avoid text that may become illegible',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondaryLight,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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
