import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class IconPreviewWidget extends StatelessWidget {
  final File? selectedImageFile;
  final Uint8List? selectedImageBytes;
  final Animation<double> animation;

  const IconPreviewWidget({
    super.key,
    required this.selectedImageFile,
    required this.selectedImageBytes,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animation.value),
          child: Opacity(
            opacity: 0.5 + (0.5 * animation.value),
            child: Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Icon Preview',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.borderLight,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: _buildImage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.borderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.phone_android,
                            color: AppTheme.neutralLight,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Device Preview',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.neutralLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    if (selectedImageFile != null && !kIsWeb) {
      return Image.file(
        selectedImageFile!,
        fit: BoxFit.cover,
        width: 116,
        height: 116,
      );
    } else if (selectedImageBytes != null) {
      return Image.memory(
        selectedImageBytes!,
        fit: BoxFit.cover,
        width: 116,
        height: 116,
      );
    } else {
      return Container(
        width: 116,
        height: 116,
        color: AppTheme.surfaceLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 32,
              color: AppTheme.neutralLight,
            ),
            const SizedBox(height: 8),
            Text(
              'Default Icon',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.neutralLight,
              ),
            ),
          ],
        ),
      );
    }
  }
}
