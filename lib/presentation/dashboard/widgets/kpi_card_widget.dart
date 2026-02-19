import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KpiCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String target;
  final double progress;
  final Color progressColor;
  final String unit;
  final CustomIconWidget icon;

  const KpiCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.target,
    required this.progress,
    required this.progressColor,
    required this.unit,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconWidget(
                  iconName: icon.iconName, color: icon.color, size: 28),
              if (title != 'Peso')
                CircularPercentIndicator(
                  radius: 6.w,
                  lineWidth: 3.0,
                  percent: progress,
                  center: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: progressColor,
                    ),
                  ),
                  progressColor: progressColor,
                  backgroundColor: progressColor.withValues(alpha: 0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
            ],
          ),
          SizedBox(height: 2.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Text(
            '$value $unit',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 0.5.h),
          if (title != 'Peso')
            Text(
              'of $target $unit',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
