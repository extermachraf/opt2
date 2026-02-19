import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MetricInputCard extends StatelessWidget {
  final String title;
  final String iconName;
  final String value;
  final String unit;
  final VoidCallback onTap;
  final bool showUnitToggle;
  final String? alternateUnit;
  final VoidCallback? onUnitToggle;

  const MetricInputCard({
    Key? key,
    required this.title,
    required this.iconName,
    required this.value,
    required this.unit,
    required this.onTap,
    this.showUnitToggle = false,
    this.alternateUnit,
    this.onUnitToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF26C6DA), Color(0xFF00ACC1)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomIconWidget(
                        iconName: iconName,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp, // Increased from 14.sp for better readability
                          color: AppTheme.seaDeep,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (showUnitToggle && alternateUnit != null)
                      GestureDetector(
                        onTap: onUnitToggle,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.seaMid.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.seaMid.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                alternateUnit!,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppTheme.seaMid,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              CustomIconWidget(
                                iconName: 'swap_horiz',
                                color: AppTheme.seaMid,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.isEmpty ? '--' : value,
                          style: TextStyle(
                            fontSize: 28.sp,
                            color: AppTheme.seaMid,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 0.5.h),
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomIconWidget(
                          iconName: 'edit',
                          color: AppTheme.seaMid.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Tocca per aggiornare',
                          style: TextStyle(
                            fontSize: 12.sp, // Increased from 10.sp for better readability
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
