import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TutorialProgressIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double animationValue;

  const TutorialProgressIndicatorWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.animationValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress Bar
        Container(
          width: double.infinity,
          height: 1.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(0.5.h),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (currentPage + 1) / totalPages * animationValue,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary,
                    AppTheme.lightTheme.colorScheme.primary.withAlpha(204),
                  ],
                ),
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalPages, (index) {
            final isActive = index == currentPage;
            final isPassed = index < currentPage;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              child: GestureDetector(
                onTap: () => _onDotTapped(context, index),
                child: Container(
                  width: isActive ? 4.w : 2.5.w,
                  height: isActive ? 4.w : 2.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getDotColor(isActive, isPassed),
                    border:
                        isActive
                            ? Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              width: 2,
                            )
                            : null,
                    boxShadow:
                        isActive
                            ? [
                              BoxShadow(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withAlpha(77),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child:
                      isActive
                          ? Icon(
                            Icons.circle,
                            size: 1.5.w,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          )
                          : isPassed
                          ? Icon(Icons.check, size: 1.5.w, color: Colors.white)
                          : null,
                ),
              ),
            );
          }),
        ),

        SizedBox(height: 2.h),

        // Progress Text
        Text(
          '${currentPage + 1} di $totalPages completato',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumEmphasisLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getDotColor(bool isActive, bool isPassed) {
    if (isActive) {
      return Colors.white;
    } else if (isPassed) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else {
      return Colors.grey.shade300;
    }
  }

  void _onDotTapped(BuildContext context, int index) {
    // Allow jumping to previous slides only
    if (index <= currentPage) {
      // You could implement navigation to specific slide here
      // For now, we'll just provide haptic feedback
      // HapticFeedback.selectionClick();
    }
  }
}
