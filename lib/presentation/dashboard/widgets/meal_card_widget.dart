import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MealCardWidget extends StatelessWidget {
  final Map<String, dynamic> mealData;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const MealCardWidget({
    Key? key,
    required this.mealData,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealName = mealData['name'] as String? ?? 'Unknown Meal';
    final mealType = mealData['type'] as String? ?? 'Meal';
    final calories = mealData['calories'] as int? ?? 0;
    final protein = mealData['protein'] as double? ?? 0.0;
    final carbs = mealData['carbs'] as double? ?? 0.0;
    final imageUrl = mealData['imageUrl'] as String? ?? '';
    final timestamp = mealData['timestamp'] as DateTime? ?? DateTime.now();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 3.w),
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
        child: Row(
          children: [
            // Image section - left side
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(20)),
              child: imageUrl.isNotEmpty
                  ? CustomImageWidget(
                      imageUrl: imageUrl,
                      width: 25.w,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 25.w,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF26C6DA), // seaTop
                            Color(0xFF00ACC1), // seaMid
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CustomIconWidget(
                          iconName: 'restaurant',
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
            ),
            // Content section - right side
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            mealName,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004D40), // textDark
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 0.2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7FA), // Light cyan
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mealType,
                            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00838F), // Teal
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatTimestamp(timestamp),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF78909C), // textMuted
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutrientInfo(
                            'Cal', '$calories', const Color(0xFFFFCC80)), // accentSand
                        _buildNutrientInfo('Pro',
                            '${protein.toStringAsFixed(0)}g', const Color(0xFF4DD0E1)), // accentWave
                        _buildNutrientInfo('Carb',
                            '${carbs.toStringAsFixed(0)}g', const Color(0xFF00ACC1)), // seaMid
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF78909C), // textMuted
          ),
        ),
      ],
    );
  }

  Color _getMealTypeColor(String mealType) {
    // Handle both Italian and English meal type labels
    switch (mealType.toLowerCase()) {
      // Italian labels (primary)
      case 'colazione':
      case 'breakfast':
        return Colors.orange;
      case 'pranzo':
      case 'lunch':
        return Colors.green;
      case 'cena':
      case 'dinner':
        return Colors.blue;
      case 'spuntino':
      case 'snack':
        return Colors.purple;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
