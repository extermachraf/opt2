import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecipeCardWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onLongPress;

  const RecipeCardWidget({
    Key? key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.onShare,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = recipe['title'] ?? 'Ricetta Senza Nome';
    final int prepTime = recipe['prep_time_minutes'] ?? recipe['prepTime'] ?? 0;
    final int servings = recipe['servings'] ?? 1;
    final bool isFavorite = recipe['isFavorite'] ?? false;
    final int calories = recipe['calories'] ?? recipe['total_calories'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title - takes most of the space
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.seaDeep,
                  fontSize: 15.sp,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 3.w),

            // Stats row - compact on the right
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Time
                Icon(
                  Icons.access_time,
                  size: 4.5.w,
                  color: AppTheme.seaMid,
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '${prepTime}m',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2.w),

                // Servings
                Icon(
                  Icons.person_outline,
                  size: 4.5.w,
                  color: AppTheme.seaMid,
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '$servings',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2.w),

                // Calories
                Icon(
                  Icons.local_fire_department,
                  size: 4.5.w,
                  color: AppTheme.seaTop,
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '$calories',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2.w),

                // Favorite heart
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 5.w,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
