import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MealPeriodSelectionDialog extends StatefulWidget {
  final String recipeTitle;
  final Function(String mealType) onMealPeriodSelected;

  const MealPeriodSelectionDialog({
    Key? key,
    required this.recipeTitle,
    required this.onMealPeriodSelected,
  }) : super(key: key);

  @override
  State<MealPeriodSelectionDialog> createState() =>
      _MealPeriodSelectionDialogState();
}

class _MealPeriodSelectionDialogState extends State<MealPeriodSelectionDialog>
    with SingleTickerProviderStateMixin {
  String? selectedMealType;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> mealPeriods = [
    {
      'type': 'breakfast',
      'label': 'Colazione',
      'icon': 'wb_sunny',
      'description': 'Inizia la giornata',
      'color': Color(0xFFFF9800),
      'time': '6:00 - 11:00',
    },
    {
      'type': 'lunch',
      'label': 'Pranzo',
      'icon': 'restaurant',
      'description': 'Pasto principale',
      'color': Color(0xFF4CAF50),
      'time': '11:00 - 16:00',
    },
    {
      'type': 'dinner',
      'label': 'Cena',
      'icon': 'dinner_dining',
      'description': 'Fine giornata',
      'color': Color(0xFF2196F3),
      'time': '18:00 - 23:00',
    },
    {
      'type': 'snack',
      'label': 'Spuntino',
      'icon': 'local_cafe',
      'description': 'Pausa gustosa',
      'color': Color(0xFF9C27B0),
      'time': 'Quando vuoi',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();

    // Auto-select based on current time
    _suggestMealPeriod();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _suggestMealPeriod() {
    final now = DateTime.now();
    final hour = now.hour;

    String suggestedType = 'snack';
    if (hour >= 6 && hour < 11) {
      suggestedType = 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      suggestedType = 'lunch';
    } else if (hour >= 18 && hour < 23) {
      suggestedType = 'dinner';
    }

    setState(() {
      selectedMealType = suggestedType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(4.w),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 90.w,
                  maxHeight: 85.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(),
                    Flexible(
                      child: _buildMealPeriodOptions(),
                    ),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'restaurant_menu',
            size: 12.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Aggiungi al Diario',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.recipeTitle,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Per quale pasto vuoi aggiungere questa ricetta?',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealPeriodOptions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children:
            mealPeriods.map((meal) => _buildMealPeriodTile(meal)).toList(),
      ),
    );
  }

  Widget _buildMealPeriodTile(Map<String, dynamic> meal) {
    final isSelected = selectedMealType == meal['type'];
    final color = meal['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMealType = meal['type'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 3.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(26)
              : AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? color
                : AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(77),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: meal['icon'],
                  color: isSelected ? Colors.white : color,
                  size: 6.w,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['label'],
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? color
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    meal['description'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meal['time'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 2.w),
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                .withAlpha(77) ??
            Colors.grey.shade100.withAlpha(77),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Annulla',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: selectedMealType != null
                  ? () {
                      widget.onMealPeriodSelected(selectedMealType!);
                      Navigator.of(context).pop();
                    }
                  : null,
              icon: CustomIconWidget(
                iconName: 'add_circle',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text(
                'Aggiungi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: selectedMealType != null ? 2 : 0,
                disabledBackgroundColor:
                    AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
                disabledForegroundColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
