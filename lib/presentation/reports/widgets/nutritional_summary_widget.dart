import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NutritionalSummaryWidget extends StatelessWidget {
  final String dateRange;
  final Map<String, dynamic>? summaryData;

  const NutritionalSummaryWidget({
    Key? key,
    required this.dateRange,
    this.summaryData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = summaryData ?? {};

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
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
      child: Row(
        children: [
          // Left side - kcal/giorno
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(data['avg_calories_per_day'] ?? 0.0).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.seaDeep,
                    fontSize: 22.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'kcal/giorno',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 6.h,
            color: AppTheme.seaMid.withValues(alpha: 0.2),
          ),
          // Right side - pasti totali
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${data['meal_count'] ?? 0}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.seaDeep,
                    fontSize: 22.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'pasti totali',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
