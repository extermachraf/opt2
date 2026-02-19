import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickEntryButtons extends StatelessWidget {
  final VoidCallback onSameAsYesterday;

  const QuickEntryButtons({
    Key? key,
    required this.onSameAsYesterday,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: const CustomIconWidget(
                  iconName: 'flash_on',
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Opzioni Inserimento Rapido',
                  style: TextStyle(
                    fontSize: 16.sp, // Increased from 14.sp for better readability
                    color: AppTheme.seaDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildQuickEntryButton(
            title: 'Come Ieri',
            subtitle: 'Usa il peso del giorno precedente',
            iconName: 'history',
            onTap: onSameAsYesterday,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEntryButton({
    required String title,
    required String subtitle,
    required String iconName,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Add haptic feedback for better user experience
          try {
            HapticFeedback.lightImpact();
          } catch (e) {
            // Ignore if haptic feedback fails
          }

          // Call the original onTap callback
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.seaMid.withValues(alpha: 0.1),
        highlightColor: AppTheme.seaMid.withValues(alpha: 0.05),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.seaMid.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.seaMid.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.seaMid.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.seaMid,
                  size: 18,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp, // Increased from 13.sp for better readability
                        color: AppTheme.seaDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp, // Increased from 11.sp for better readability
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
