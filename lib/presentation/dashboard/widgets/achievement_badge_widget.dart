import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementBadgeWidget extends StatelessWidget {
  final Map<String, dynamic> achievementData;
  final VoidCallback? onTap;

  const AchievementBadgeWidget({
    Key? key,
    required this.achievementData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = achievementData['title'] as String? ?? 'Achievement';
    final description = achievementData['description'] as String? ?? '';
    final iconName = achievementData['iconName'] as String? ?? 'emoji_events';
    final isUnlocked = achievementData['isUnlocked'] as bool? ?? false;
    final progress = achievementData['progress'] as double? ?? 0.0;
    final category = achievementData['category'] as String? ?? 'general';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        constraints: BoxConstraints(
          minHeight: 18.h, // Minimum height for consistency
          maxHeight: 18.h, // Maximum height to prevent overflow
        ),
        margin: EdgeInsets.only(right: 3.w),
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006064).withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCategoryColor(category),
                              _getCategoryColor(category).withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: isUnlocked ? null : const Color(0xFFE0F7FA), // Light cyan when locked
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: isUnlocked
                          ? Colors.white
                          : const Color(0xFF78909C), // textMuted when locked
                      size: 7.w,
                    ),
                  ),
                ),
                if (!isUnlocked && progress > 0)
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isUnlocked
                    ? _getCategoryColor(category)
                    : const Color(0xFF78909C), // textMuted
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF78909C), // textMuted
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Ocean Blue themed category colors
    switch (category.toLowerCase()) {
      case 'nutrition':
        return const Color(0xFF009688); // Teal green
      case 'consistency':
        return const Color(0xFF00ACC1); // seaMid
      case 'milestone':
        return const Color(0xFFFFCC80); // accentSand
      case 'social':
        return const Color(0xFF4DD0E1); // accentWave
      case 'health':
        return const Color(0xFF26C6DA); // seaTop
      case 'assessment':
        return const Color(0xFF006064); // seaDeep
      default:
        return const Color(0xFF00ACC1); // seaMid
    }
  }
}
