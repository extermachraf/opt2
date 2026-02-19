import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionSheetWidget extends StatelessWidget {
  final VoidCallback onLogMeal;
  final VoidCallback onAddRecipe;
  final VoidCallback onTakePhoto;

  const QuickActionSheetWidget({
    Key? key,
    required this.onLogMeal,
    required this.onAddRecipe,
    required this.onTakePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006064).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Azioni Rapide',
            style: TextStyle(
              fontSize: 20.sp, // Increased from 18.sp for better readability
              fontWeight: FontWeight.w600,
              color: const Color(0xFF004D40), // textDark
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                'Registra Pasto',
                const CustomIconWidget(
                  iconName: 'restaurant_menu',
                  color: Colors.white,
                  size: 24,
                ),
                const Color(0xFF009688), // Teal green
                onLogMeal,
              ),
              _buildActionButton(
                'Aggiungi Ricetta',
                const CustomIconWidget(
                  iconName: 'menu_book',
                  color: Colors.white,
                  size: 24,
                ),
                const Color(0xFF00ACC1), // seaMid
                onAddRecipe,
              ),
              _buildActionButton(
                'Scatta Foto',
                const CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Colors.white,
                  size: 24,
                ),
                const Color(0xFFFFCC80), // accentSand
                onTakePhoto,
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    CustomIconWidget icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: icon),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp, // Increased from 12.sp for better readability
            fontWeight: FontWeight.w500,
            color: const Color(0xFF004D40), // textDark
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
