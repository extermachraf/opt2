import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/meal_diary_service.dart';

class MealTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> meals;
  final Function(Map<String, dynamic>) onMealTap;
  final Function(Map<String, dynamic>) onDuplicateMeal;
  final Function(Map<String, dynamic>) onShareMeal;
  final Function(Map<String, dynamic>) onAddToFavorites;
  final Function(Map<String, dynamic>) onDeleteMeal;
  final VoidCallback onAddMeal;

  const MealTimelineWidget({
    Key? key,
    required this.meals,
    required this.onMealTap,
    required this.onDuplicateMeal,
    required this.onShareMeal,
    required this.onAddToFavorites,
    required this.onDeleteMeal,
    required this.onAddMeal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealSections = _groupMealsByType();

    return Column(
      children: mealSections.map((section) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: _buildMealSection(context, section),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _groupMealsByType() {
    final sections = [
      {'type': 'Colazione', 'icon': 'wb_sunny', 'time': '7:00'},
      {'type': 'Pranzo', 'icon': 'wb_sunny_outlined', 'time': '12:00'},
      {'type': 'Cena', 'icon': 'nights_stay', 'time': '19:00'},
      {
        'type': 'Spuntino',
        'icon': 'local_cafe',
        'time': 'In qualsiasi momento',
      },
    ];

    return sections.map((section) {
      final sectionMeals = meals
          .where(
            (meal) =>
                (meal['type'] as String? ?? '').toLowerCase() ==
                (section['type'] ?? '').toLowerCase(),
          )
          .toList();

      return {...section, 'meals': sectionMeals};
    }).toList();
  }

  Widget _buildMealSection(BuildContext context, Map<String, dynamic> section) {
    final sectionMeals = section['meals'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(section),
        SizedBox(height: 1.h),
        sectionMeals.isEmpty
            ? _buildEmptyMealCard(section['type'] as String)
            : Column(
                children: sectionMeals
                    .map(
                      (meal) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: _buildMealCard(context, meal),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildSectionHeader(Map<String, dynamic> section) {
    return Text(
      '${section['type']}',
      style: TextStyle(
        fontSize: 16.sp, // Increased from 14.sp for better readability
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmptyMealCard(String mealType) {
    return GestureDetector(
      onTap: onAddMeal,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: AppTheme.menuCardDecoration,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.seaTop.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CustomIconWidget(
                iconName: 'add',
                color: AppTheme.seaMid,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Aggiungi $mealType',
              style: TextStyle(
                fontSize: 15.sp, // Increased from 13.sp for better readability
                fontWeight: FontWeight.w500,
                color: AppTheme.seaMid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final mealName = (meal['name'] as String?)?.trim();
    final mealTime = (meal['time'] as String?) ?? '00:00';
    final notes = (meal['notes'] as String?)?.trim();
    final calories = (meal['calories'] as num?)?.toInt() ?? 0;
    final protein = (meal['protein'] as num?)?.toDouble() ?? 0;
    final carbs = (meal['carbs'] as num?)?.toDouble() ?? 0;
    final fat = (meal['fat'] as num?)?.toDouble() ?? 0;
    final imageUrl = (meal['imageUrl'] as String?)?.trim();

    final displayName = (mealName == null || mealName.isEmpty)
        ? 'Pasto del ${_formatTime(mealTime)}'
        : mealName;

    return GestureDetector(
      onTap: () => _showMealEditDialog(context, meal),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: AppTheme.menuCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and delete icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.seaDeep,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Delete icon button
                IconButton(
                  onPressed: () => onDeleteMeal(meal),
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  tooltip: 'Cancella pasto',
                ),
              ],
            ),
            // Meal image (if available)
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () => _showImageDialog(
                  context,
                  imageUrl,
                  displayName,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.w),
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            // Notes/description if available
            if (notes != null && notes.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                notes,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 1.5.h),
            // Nutrition row
            Row(
              children: [
                _buildMealNutritionItem('$calories', 'kcal'),
                SizedBox(width: 4.w),
                _buildMealNutritionItem('${protein.toStringAsFixed(0)}g', 'Prot'),
                SizedBox(width: 4.w),
                _buildMealNutritionItem('${carbs.toStringAsFixed(0)}g', 'Carb'),
                SizedBox(width: 4.w),
                _buildMealNutritionItem('${fat.toStringAsFixed(0)}g', 'Gras'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealNutritionItem(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.seaDeep,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  /// Show full-screen image dialog
  void _showImageDialog(
      BuildContext context, String imageUrl, String mealName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(2.w),
        child: Stack(
          children: [
            // Full screen image
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 90.w,
                  maxHeight: 80.h,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.w),
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'broken_image',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 12.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Immagine non disponibile',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),
            ),
            // Meal name overlay
            Positioned(
              bottom: 4.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  mealName,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show meal edit dialog for quantity adjustments
  void _showMealEditDialog(BuildContext context, Map<String, dynamic> meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MealEditBottomSheet(
        meal: meal,
        onMealUpdated: () {
          // Trigger meal diary refresh by calling the onMealTap callback
          onMealTap(meal);
        },
      ),
    );
  }

  String _formatTime(String time) {
    try {
      // If time is in HH:mm format, return it as is
      if (time.contains(':') && time.length >= 4) {
        return time;
      }
      // Otherwise provide a default time format
      return '${time.padLeft(2, '0')}:00';
    } catch (e) {
      return '00:00';
    }
  }

  Widget _buildNutritionInfo(Map<String, dynamic> meal) {
    // Enhanced null safety for nutritional values with better defaults including fiber
    final calories = _safeFormatNumber(meal['calories'], 0);
    final protein = _safeFormatNumber(meal['protein'], 1);
    final carbs = _safeFormatNumber(meal['carbs'], 1);
    final fat = _safeFormatNumber(meal['fat'], 1);
    final fiber = _safeFormatNumber(meal['fiber'], 1); // Add fiber formatting

    return Column(
      children: [
        // First row: Calories and Fiber
        Row(
          children: [
            _buildNutritionItem('Calorie', calories, 'kcal'),
            SizedBox(width: 4.w),
            _buildNutritionItem('Fibre', fiber, 'g'), // Display fiber data
          ],
        ),
        SizedBox(height: 2.h),
        // Second row: Protein, Carbs, Fat
        Row(
          children: [
            _buildNutritionItem('Proteine', protein, 'g'),
            SizedBox(width: 4.w),
            _buildNutritionItem('Carboidrati', carbs, 'g'),
            SizedBox(width: 4.w),
            _buildNutritionItem('Grassi', fat, 'g'),
          ],
        ),
      ],
    );
  }

  String _safeFormatNumber(dynamic value, int decimals) {
    try {
      if (value == null) return '0';

      final numValue =
          (value is num) ? value : double.tryParse(value.toString());
      if (numValue == null) return '0';

      return decimals == 0
          ? numValue.round().toString()
          : numValue.toStringAsFixed(decimals);
    } catch (e) {
      return '0';
    }
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            '$label ($unit)',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBreakdown(Map<String, dynamic> meal) {
    // Enhanced null safety for macro calculation with fallbacks including fiber
    final proteinValue = _safeGetDouble(meal['protein']);
    final carbsValue = _safeGetDouble(meal['carbs']);
    final fatValue = _safeGetDouble(meal['fat']);
    final fiberValue = _safeGetDouble(meal['fiber']); // Add fiber value

    final totalMacros = proteinValue + carbsValue + fatValue;

    // Only show breakdown if there are actual macros
    if (totalMacros <= 0) {
      return Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
              .withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(1.w),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'info_outline',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Dati nutrizionali non disponibili',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    final proteinPercent = proteinValue / totalMacros;
    final carbsPercent = carbsValue / totalMacros;
    final fatPercent = fatValue / totalMacros;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show fiber information separately since it's not included in macro percentages
        if (fiberValue > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fibre',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  '${fiberValue.toStringAsFixed(1)}g',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
        ],
        Text(
          'Ripartizione Macronutrienti',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.5.h),
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0.5.h),
            child: Row(
              children: [
                if (proteinPercent > 0.01) // Only show if at least 1%
                  Expanded(
                    flex: (proteinPercent * 100).round(),
                    child: Container(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      height: double.infinity,
                    ),
                  ),
                if (carbsPercent > 0.01) // Only show if at least 1%
                  Expanded(
                    flex: (carbsPercent * 100).round(),
                    child: Container(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      height: double.infinity,
                    ),
                  ),
                if (fatPercent > 0.01) // Only show if at least 1%
                  Expanded(
                    flex: (fatPercent * 100).round(),
                    child: Container(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      height: double.infinity,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _safeGetDouble(dynamic value) {
    try {
      if (value == null) return 0.0;

      if (value is double) return value;
      if (value is int) return value.toDouble();

      final parsed = double.tryParse(value.toString());
      return parsed ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

/// Bottom sheet widget for editing meal quantities
class _MealEditBottomSheet extends StatefulWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onMealUpdated;

  const _MealEditBottomSheet({
    Key? key,
    required this.meal,
    required this.onMealUpdated,
  }) : super(key: key);

  @override
  State<_MealEditBottomSheet> createState() => _MealEditBottomSheetState();
}

class _MealEditBottomSheetState extends State<_MealEditBottomSheet> {
  bool _isLoading = false;
  late List<Map<String, dynamic>> _mealFoods;
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    _loadMealFoods();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMealFoods() async {
    try {
      final mealId = widget.meal['id'] as String;
      final mealData =
          await MealDiaryService.instance.getMealForEditing(mealId);

      final mealFoods = mealData['meal_foods'] as List<dynamic>;

      setState(() {
        _mealFoods =
            mealFoods.map((mf) => Map<String, dynamic>.from(mf)).toList();

        // Initialize controllers for each food
        for (int i = 0; i < _mealFoods.length; i++) {
          final mealFood = _mealFoods[i];
          final quantity =
              (mealFood['quantity_grams'] as num?)?.toDouble() ?? 100.0;
          _quantityControllers[mealFood['id']] = TextEditingController(
            text: _formatQuantity(quantity),
          );
        }
      });
    } catch (error) {
      print('Error loading meal foods: $error');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento del pasto')),
      );
    }
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(1).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Modifica quantità',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Meal image (if available)
          if (widget.meal['imageUrl'] != null &&
              (widget.meal['imageUrl'] as String).isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onTap: () => _showMealImageDialog(context),
                  child: Stack(
                    children: [
                      CustomImageWidget(
                        imageUrl: widget.meal['imageUrl'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      // Overlay to indicate it's tappable
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Meal foods list
          Flexible(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _mealFoods.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Nessun cibo trovato in questo pasto'),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(20),
                        itemCount: _mealFoods.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final mealFood = _mealFoods[index];
                          return _buildMealFoodEditor(mealFood);
                        },
                      ),
          ),

          // Action buttons
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Aggiornamento...'),
                          ],
                        )
                      : Text(
                          'Aggiorna pasto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                SizedBox(height: 12),
                // Delete button
                OutlinedButton(
                  onPressed: _isLoading ? null : _deleteMeal,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.error,
                      width: 2,
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Cancella pasto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealFoodEditor(Map<String, dynamic> mealFood) {
    final mealFoodId = mealFood['id'] as String;
    final controller = _quantityControllers[mealFoodId]!;

    // CRITICAL FIX: Get food name from food_items, recipes, OR Food Ingredients
    String foodName = 'Alimento sconosciuto';

    // Check for food items
    if (mealFood['food_items'] != null) {
      foodName = mealFood['food_items']['name'] ?? 'Alimento sconosciuto';
    }
    // Check for recipes
    else if (mealFood['recipes'] != null) {
      foodName = mealFood['recipes']['title'] ?? 'Ricetta sconosciuta';
    }
    // CRITICAL FIX: Check for Food Ingredients
    else if (mealFood['food_ingredient_code'] != null) {
      // Try to get the name from Food Ingredients table data if available
      if (mealFood['Food Ingredients'] != null) {
        foodName = mealFood['Food Ingredients']['Nome Alimento ITA'] ?? 'Ingrediente';
      } else {
        // Fallback: try to extract from any cached data
        foodName = 'Ingrediente (${mealFood['food_ingredient_code']})';
      }
    }

    final currentQuantity =
        (mealFood['quantity_grams'] as num?)?.toDouble() ?? 100.0;
    final currentCalories = (mealFood['calories'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food name and current calories
          Row(
            children: [
              Expanded(
                child: Text(
                  foodName,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${currentCalories.toStringAsFixed(0)} cal',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Quantity input
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantità (grammi)',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 4),
                    TextFormField(
                      controller: controller,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: 'g',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) => _validateQuantity(value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {
                        // Update the meal food quantity in the local state
                        final newQuantity =
                            double.tryParse(value.replaceAll(',', '.'));
                        if (newQuantity != null && newQuantity > 0) {
                          setState(() {
                            mealFood['quantity_grams'] = newQuantity;
                            // Recalculate calories for display
                            _recalculateNutritionForFood(mealFood);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show current nutrition breakdown including fiber
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionChip(
                  'P',
                  '${(mealFood['protein_g'] as num? ?? 0).toStringAsFixed(1)}g',
                  Colors.blue),
              _buildNutritionChip(
                  'C',
                  '${(mealFood['carbs_g'] as num? ?? 0).toStringAsFixed(1)}g',
                  Colors.orange),
              _buildNutritionChip(
                  'G',
                  '${(mealFood['fat_g'] as num? ?? 0).toStringAsFixed(1)}g',
                  Colors.red),
              _buildNutritionChip(
                  'F',
                  '${(mealFood['fiber_g'] as num? ?? 0).toStringAsFixed(1)}g',
                  Colors.green), // Add fiber chip
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _recalculateNutritionForFood(Map<String, dynamic> mealFood) {
    final quantity = (mealFood['quantity_grams'] as num?)?.toDouble() ?? 100.0;
    final multiplier = quantity / 100.0;

    if (mealFood['food_items'] != null) {
      final foodItem = mealFood['food_items'];
      mealFood['calories'] =
          ((foodItem['calories_per_100g'] as int? ?? 0) * multiplier);
      mealFood['protein_g'] =
          ((foodItem['protein_per_100g'] as num? ?? 0).toDouble() * multiplier);
      mealFood['carbs_g'] =
          ((foodItem['carbs_per_100g'] as num? ?? 0).toDouble() * multiplier);
      mealFood['fat_g'] =
          ((foodItem['fat_per_100g'] as num? ?? 0).toDouble() * multiplier);
      mealFood['fiber_g'] =
          ((foodItem['fiber_per_100g'] as num? ?? 0).toDouble() *
              multiplier); // Add fiber recalculation
    } else if (mealFood['recipes'] != null) {
      final recipe = mealFood['recipes'];
      final servings = (recipe['servings'] as int? ?? 1);
      final avgWeight = 250.0;
      final totalWeight = avgWeight * servings;

      final caloriesPer100g =
          ((recipe['total_calories'] as int? ?? 0) / totalWeight) * 100;
      final proteinPer100g =
          ((recipe['total_protein_g'] as num? ?? 0) / totalWeight) * 100;
      final carbsPer100g =
          ((recipe['total_carbs_g'] as num? ?? 0) / totalWeight) * 100;
      final fatPer100g =
          ((recipe['total_fat_g'] as num? ?? 0) / totalWeight) * 100;
      final fiberPer100g =
          ((recipe['total_fiber_g'] as num? ?? 0) / totalWeight) *
              100; // Add fiber calculation for recipes

      mealFood['calories'] = caloriesPer100g * multiplier;
      mealFood['protein_g'] = proteinPer100g * multiplier;
      mealFood['carbs_g'] = carbsPer100g * multiplier;
      mealFood['fat_g'] = fatPer100g * multiplier;
      mealFood['fiber_g'] =
          fiberPer100g * multiplier; // Apply fiber recalculation for recipes
    }
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Inserisci quantità';
    }

    final cleanValue = value.replaceAll(',', '.');
    final parsedValue = double.tryParse(cleanValue);

    if (parsedValue == null) {
      return 'Numero non valido';
    }

    if (parsedValue <= 0) {
      return 'Deve essere > 0';
    }

    if (parsedValue > 10000) {
      return 'Massimo 10000g';
    }

    return null;
  }

  void _showMealImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(2.w),
        child: Stack(
          children: [
            // Full screen image
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 90.w,
                  maxHeight: 80.h,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.w),
                  child: CustomImageWidget(
                    imageUrl: widget.meal['imageUrl'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMeal() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare questo pasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await MealDiaryService.instance.deleteMealEntry(widget.meal['id']);

      Navigator.of(context).pop();
      widget.onMealUpdated(); // This will refresh the meal diary

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Pasto eliminato con successo!'),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nell\'eliminazione: $error'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare updates for each meal food
      final updates = <Map<String, dynamic>>[];

      for (final mealFood in _mealFoods) {
        final controller = _quantityControllers[mealFood['id']];
        if (controller != null) {
          final newQuantity =
              double.tryParse(controller.text.replaceAll(',', '.'));
          if (newQuantity != null && newQuantity > 0) {
            updates.add({
              'id': mealFood['id'],
              'quantity_grams': newQuantity,
            });
          }
        }
      }

      if (updates.isNotEmpty) {
        // Update meal foods through service
        await MealDiaryService.instance.updateMealFoods(
          mealEntryId: widget.meal['id'],
          updatedFoods: updates,
        );

        Navigator.of(context).pop();
        widget.onMealUpdated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Quantità aggiornate con successo!'),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nell\'aggiornamento: $error'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
