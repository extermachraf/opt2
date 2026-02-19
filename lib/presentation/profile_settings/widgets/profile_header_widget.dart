import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String patientName;
  final String profileImageUrl;
  final String accountStatus;
  final VoidCallback onEditProfile;

  const ProfileHeaderWidget({
    Key? key,
    required this.patientName,
    required this.profileImageUrl,
    required this.accountStatus,
    required this.onEditProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.seaMid.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowSea.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile image centered
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.seaTop, AppTheme.seaMid],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.seaMid.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: profileImageUrl,
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditProfile,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accentSand, AppTheme.accentWave],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentWave.withAlpha(40),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'edit',
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Name
          Text(
            patientName,
            style: GoogleFonts.inter(
              fontSize: 20.sp, // Increased from 18.sp for better readability
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 0.8.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.seaMid.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.seaMid,
                  size: 16,
                ),
                SizedBox(width: 1.5.w),
                Text(
                  accountStatus,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp, // Increased from 12.sp for better readability
                    color: AppTheme.seaMid,
                    fontWeight: FontWeight.w500,
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
