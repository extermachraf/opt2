import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ThemePreviewWidget extends StatelessWidget {
  final String themeMode;

  const ThemePreviewWidget({
    Key? key,
    required this.themeMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildPreviewContent(),
      ),
    );
  }

  Widget _buildPreviewContent() {
    final isDark = themeMode == 'dark';
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final surfaceColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final primaryColor =
        isDark ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50);

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          // Mock app bar
          Container(
            height: 6.h,
            color: primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Mock content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mock card
                  Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            color: primaryColor,
                            size: 4.w,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dati Medici',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Informazioni trattamento',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 9.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Mock text content
                  Text(
                    'Tema ${_getThemeName()}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'I dati medici rimangono chiaramente leggibili',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName() {
    switch (themeMode) {
      case 'light':
        return 'Chiaro';
      case 'dark':
        return 'Scuro';
      case 'system':
        return 'Sistema';
      default:
        return 'Sconosciuto';
    }
  }
}
