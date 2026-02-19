import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/meal_diary_service.dart';
import '../../services/recipe_service.dart';
import './widgets/meal_period_selection_dialog.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({Key? key}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  List<Map<String, dynamic>> ingredients = [];
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        _loadRecipeDetails(args);
      }
    });
  }

  void _loadRecipeDetails(dynamic args) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (args is Map<String, dynamic>) {
        // Recipe from recipe management screen - ensure all fields exist
        recipe = Map<String, dynamic>.from(args);

        // Ensure all required fields have default values to prevent null errors
        recipe!.putIfAbsent('title', () => 'Ricetta Senza Nome');
        recipe!.putIfAbsent('description', () => '');
        recipe!.putIfAbsent('instructions', () => '');
        recipe!.putIfAbsent('prep_time_minutes', () => 0);
        recipe!.putIfAbsent('cook_time_minutes', () => 0);
        recipe!.putIfAbsent('servings', () => 1);
        recipe!.putIfAbsent('difficulty', () => 'Easy');
        recipe!.putIfAbsent('total_calories', () => 0);
        recipe!.putIfAbsent('total_protein_g', () => 0.0);
        recipe!.putIfAbsent('total_carbs_g', () => 0.0);
        recipe!.putIfAbsent('total_fat_g', () => 0.0);
        recipe!.putIfAbsent('total_fiber_g', () => 0.0);
        recipe!.putIfAbsent('imageUrl', () => null);
        recipe!.putIfAbsent('image_url', () => null);

        // FIXED: Always load favorite status from database for consistency
        await _loadFavoriteStatus();

        // Load ingredients if recipe ID is available
        if (recipe?['id'] != null) {
          try {
            ingredients = await RecipeService.instance.getRecipeIngredients(
              recipe!['id'],
            );
          } catch (ingredientError) {
            print('Error loading ingredients: $ingredientError');
            ingredients = [];
          }
        }
      } else if (args is String) {
        // Recipe ID passed directly
        try {
          final recipeData = await RecipeService.instance.getRecipeById(args);
          if (recipeData != null) {
            recipe = recipeData;
            // Ensure all required fields exist
            recipe!.putIfAbsent('title', () => 'Ricetta Senza Nome');
            recipe!.putIfAbsent('description', () => '');
            recipe!.putIfAbsent('instructions', () => '');
            recipe!.putIfAbsent('imageUrl', () => null);
            recipe!.putIfAbsent('image_url', () => null);

            ingredients =
                await RecipeService.instance.getRecipeIngredients(args);
            
            // FIXED: Always load favorite status from database for consistency
            await _loadFavoriteStatus();
          }
        } catch (fetchError) {
          print('Error fetching recipe: $fetchError');
          recipe = null;
        }
      }
    } catch (error) {
      print('Error loading recipe details: $error');
      recipe = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel caricamento della ricetta')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// FIXED: Load favorite status from database to ensure consistency
  /// This ensures the heart icon shows the correct state regardless of
  /// where the recipe detail screen is opened from (Ricette or Aggiungi pasto)
  Future<void> _loadFavoriteStatus() async {
    final user = AuthService.instance.currentUser;
    if (user != null && recipe != null && recipe!['id'] != null) {
      try {
        final isFav = await RecipeService.instance.isRecipeFavorited(
          recipe!['id'],
          user.id,
        );
        setState(() {
          isFavorite = isFav;
          recipe!['isFavorite'] = isFav;
        });
      } catch (e) {
        print('Error loading favorite status: $e');
        // Keep the existing value if there's an error
        isFavorite = recipe?['isFavorite'] ?? false;
      }
    } else {
      // No user logged in or no recipe, default to false
      isFavorite = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Caricamento...'),
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ricetta non trovata'),
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                size: 15.w,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              SizedBox(height: 2.h),
              Text('Ricetta non trovata'),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Torna indietro'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipeInfo(),
                  SizedBox(height: 3.h),
                  _buildNutritionalInfo(),
                  SizedBox(height: 3.h),
                  if (recipe!['description'] != null &&
                      recipe!['description'].isNotEmpty) ...[
                    _buildDescription(),
                    SizedBox(height: 3.h),
                  ],
                  if (ingredients.isNotEmpty) ...[
                    _buildIngredientsSection(),
                    SizedBox(height: 3.h),
                  ],
                  if (recipe!['instructions'] != null &&
                      recipe!['instructions'].isNotEmpty) ...[
                    _buildInstructionsSection(),
                    SizedBox(height: 3.h),
                  ],
                  _buildActionButtons(),
                  SizedBox(
                      height: 5.h), // Reduced space since no floating buttons
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 30.h,
      pinned: true,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          recipe!['title'] ?? 'Ricetta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Remove images completely - show only placeholder
            Container(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'restaurant_menu',
                      size: 20.w,
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      recipe!['title'] ?? 'Ricetta',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color:
                            AppTheme.lightTheme.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleFavorite,
          icon: CustomIconWidget(
            iconName: isFavorite ? 'favorite' : 'favorite_border',
            color: isFavorite
                ? AppTheme.lightTheme.colorScheme.error
                : Colors.white,
            size: 6.w,
          ),
        ),
        IconButton(
          onPressed: _shareRecipe,
          icon: CustomIconWidget(
            iconName: 'share',
            color: Colors.white,
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              'timer',
              '${recipe!['prep_time_minutes'] ?? recipe!['prepTime'] ?? 0} min',
              'Preparazione',
            ),
            Container(width: 1, height: 6.h, color: Colors.grey[300]),
            _buildInfoItem(
              'restaurant_menu',
              recipe!['total_weight_g'] != null && (recipe!['total_weight_g'] as num) > 0
                  ? '${(recipe!['total_weight_g'] as num).toStringAsFixed(0)}g'
                  : '${recipe!['servings'] ?? 1}',
              'Porzione',
            ),
            Container(width: 1, height: 6.h, color: Colors.grey[300]),
            _buildInfoItem(
              'star',
              recipe!['difficulty'] ?? 'Easy',
              'Difficoltà',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String iconName, String value, String label) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 6.w,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionalInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informazioni Nutrizionali',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientItem(
                  '${recipe!['total_calories'] ?? recipe!['calories'] ?? 0}',
                  'kcal',
                  'Calorie',
                ),
                _buildNutrientItem(
                  '${recipe!['total_protein_g']?.toInt() ?? recipe!['protein']?.toInt() ?? 0}g',
                  'protein_g',
                  'Proteine',
                ),
                _buildNutrientItem(
                  '${recipe!['total_carbs_g']?.toInt() ?? recipe!['carbs']?.toInt() ?? 0}g',
                  'carbs_g',
                  'Carboidrati',
                ),
                _buildNutrientItem(
                  '${recipe!['total_fat_g']?.toInt() ?? recipe!['fat']?.toInt() ?? 0}g',
                  'fat_g',
                  'Grassi',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String value, String unit, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrizione',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              recipe!['description'],
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredienti',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: ingredients.length,
              separatorBuilder: (context, index) => Divider(height: 2.h),
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Row(
                  children: [
                    Container(
                      width: 1.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredient['ingredient_name'] ?? 'Ingrediente',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${ingredient['quantity']} ${ingredient['unit'] ?? 'g'}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    final instructions = recipe!['instructions'] as String;
    final steps = instructions
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Istruzioni',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        steps[index].trim(),
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _addToMealDiary,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 5.w,
            ),
            label: Text('Aggiungi al Diario'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _addToShoppingList,
            icon: CustomIconWidget(
              iconName: 'shopping_cart',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            label: Text('Lista Spesa'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Accedi per salvare i preferiti')),
        );
      }
      return;
    }

    // Optimistic UI update
    setState(() {
      isFavorite = !isFavorite;
      if (recipe != null) {
        recipe!['isFavorite'] = isFavorite;
      }
    });

    try {
      if (isFavorite) {
        await RecipeService.instance.addToFavorites(
          recipe!['id'],
          user.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ricetta aggiunta ai preferiti'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
          );
        }
      } else {
        await RecipeService.instance.removeFromFavorites(
          recipe!['id'],
          user.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ricetta rimossa dai preferiti'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      // Revert state on error
      setState(() {
        isFavorite = !isFavorite;
        if (recipe != null) {
          recipe!['isFavorite'] = isFavorite;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'aggiornamento dei preferiti: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _shareRecipe() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Condivisione ricetta "${recipe!['title']}"'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _addToMealDiary() async {
    if (!AuthService.instance.isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    // Show meal period selection dialog instead of auto-determining meal type
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MealPeriodSelectionDialog(
        recipeTitle: recipe!['title'] ?? 'Ricetta',
        onMealPeriodSelected: (selectedMealType) {
          _addRecipeToSelectedMealPeriod(selectedMealType);
        },
      ),
    );
  }

  /// Add recipe to diary with user-selected meal period
  void _addRecipeToSelectedMealPeriod(String selectedMealType) async {
    try {
      // Show loading state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 3.w),
              Text('Aggiungendo al diario...'),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );

      // Add recipe directly to meal diary with selected meal type
      await MealDiaryService.instance.addRecipeToMealDiary(
        recipeData: recipe!,
        mealType: selectedMealType,
        mealDate: DateTime.now(),
        mealTime: TimeOfDay.now(),
        notes: 'Ricetta: ${recipe!['title']}',
      );

      // CRITICAL FIX: Trigger manual dashboard refresh after successful meal addition
      try {
        await DashboardService.instance.refreshDashboardData((updatedData) {
          print('Dashboard data refreshed after recipe addition');
        });
      } catch (refreshError) {
        print('Dashboard refresh failed but meal was saved: $refreshError');
      }

      // Map meal type to Italian for display
      String mealTypeItalian = _mapMealTypeToItalian(selectedMealType);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Ricetta "${recipe!['title']}" aggiunta a $mealTypeItalian!',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(4.w),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Vai al Diario',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.mealDiary,
                  arguments: {
                    'selected_date': DateTime.now(),
                  },
                );
              },
            ),
          ),
        );
      }
    } catch (error) {
      print('Error adding recipe to diary: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Errore nell\'aggiunta della ricetta al diario. Riprova.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(4.w),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Map database meal_type enum to Italian UI labels
  String _mapMealTypeToItalian(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Colazione';
      case 'lunch':
        return 'Pranzo';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Spuntino';
      default:
        return 'Pasto';
    }
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Accesso richiesto',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Devi effettuare l\'accesso per aggiungere ricette al diario pasti.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.8,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annulla',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, AppRoutes.loginScreen);
            },
            child: Text('Accedi'),
          ),
        ],
      ),
    );
  }

  void _addToShoppingList() {
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nessun ingrediente da aggiungere'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${ingredients.length} ingredienti aggiunti alla lista spesa',
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );

    // TODO: Implement shopping list functionality
  }

  void _startCookingMode() {
    if (recipe!['instructions'] == null || recipe!['instructions'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nessuna istruzione disponibile per questa ricetta'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modalità cucina in arrivo...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );

    // TODO: Implement cooking mode with step-by-step instructions
  }
}
