import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MealTypeSelectorWidget extends StatelessWidget {
  final String selectedMealType;
  final Function(String) onMealTypeChanged;
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeChanged;

  const MealTypeSelectorWidget({
    Key? key,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    required this.selectedTime,
    required this.onTimeChanged,
  }) : super(key: key);

  // Ocean Blue colors
  static const Color _seaMid = Color(0xFF00ACC1);
  static const Color _seaDeep = Color(0xFF006064);
  static const Color _textMuted = Color(0xFF78909C);
  static const Color _textDark = Color(0xFF006064);
  static const Color _accentLight = Color(0xFFE0F7FA);
  static const Color _inputBg = Color(0xFFF0F8FF);
  static const Color _borderLight = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final mealTypes = [
      {'value': 'breakfast', 'label': 'Colazione', 'emoji': '☕', 'useIcon': false},
      {'value': 'lunch', 'label': 'Pranzo', 'emoji': '☀️', 'useIcon': true, 'iconData': Icons.wb_sunny, 'iconColor': const Color(0xFFFFA726)},
      {'value': 'dinner', 'label': 'Cena', 'emoji': '🌙', 'useIcon': false},
      {'value': 'snack', 'label': 'Spuntino', 'emoji': '🍎', 'useIcon': false},
    ];

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _seaDeep.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            'Tipo di pasto',
            style: TextStyle(
              fontSize: 14.sp, // Increased from 12.sp for better readability
              fontWeight: FontWeight.w500,
              color: _textMuted,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2.h),
          // 2x2 Grid of meal types
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
            ),
            itemCount: mealTypes.length,
            itemBuilder: (context, index) {
              final mealType = mealTypes[index];
              final isSelected = selectedMealType == mealType['value'];

              return GestureDetector(
                onTap: () => onMealTypeChanged(mealType['value'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? _accentLight : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _seaMid : _borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // FIXED: Use colored icon for Pranzo, emoji for others
                      (mealType['useIcon'] as bool? ?? false)
                          ? Icon(
                              mealType['iconData'] as IconData,
                              size: 20.sp,
                              color: mealType['iconColor'] as Color,
                            )
                          : Text(
                              mealType['emoji'] as String,
                              style: TextStyle(fontSize: 18.sp),
                            ),
                      SizedBox(width: 2.w),
                      Text(
                        mealType['label'] as String,
                        style: TextStyle(
                          fontSize: 15.sp, // Increased from 13.sp for better readability
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? _textDark : _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 3.h),
          // Time selector
          Text(
            'Orario',
            style: TextStyle(
              fontSize: 14.sp, // Increased from 12.sp for better readability
              fontWeight: FontWeight.w500,
              color: _textMuted,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('🕐', style: TextStyle(fontSize: 16.sp)),
                  SizedBox(width: 3.w),
                  Text(
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 17.sp, // Increased from 15.sp for better readability
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: _textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      helpText: 'Seleziona ora',
      cancelText: 'Annulla',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _seaMid,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }
}
