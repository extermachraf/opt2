import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../../services/recipe_service.dart';

class FoodSearchWidget extends StatefulWidget {
  final List<Map<String, dynamic>> selectedFoods;
  final Function(Map<String, dynamic>) onFoodAdded;
  final Function(int) onFoodRemoved;
  final Function(int, String, dynamic) onFoodUpdated;

  const FoodSearchWidget({
    Key? key,
    required this.selectedFoods,
    required this.onFoodAdded,
    required this.onFoodRemoved,
    required this.onFoodUpdated,
  }) : super(key: key);

  @override
  State<FoodSearchWidget> createState() => _FoodSearchWidgetState();
}

class _FoodSearchWidgetState extends State<FoodSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Map<int, TextEditingController> _quantityControllers = {};
  bool _showSuggestions = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _filteredFoods = [];
  List<Map<String, dynamic>> _recentFoods = [];
  String? _errorMessage;
  Set<String> _favoriteRecipeIds = {}; // FIXED: Track favorite recipe IDs

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showSuggestions = _searchFocusNode.hasFocus &&
              (_searchController.text.isNotEmpty || _recentFoods.isNotEmpty);
        });
      }
    });
    _loadRecentFoods();
    _loadFavoriteRecipes(); // FIXED: Load favorite recipes on init
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    // Dispose all quantity controllers
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    _quantityControllers.clear();
    super.dispose();
  }

  Future<void> _loadRecentFoods() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Enhanced query with comprehensive nutritional data (70+ parameters)
      final foodItemsResponse = await Supabase.instance.client
          .from('food_items')
          .select('''
            id, name, italian_name, english_name, scientific_name, brand, category,
            calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, 
            fiber_per_100g, sugar_per_100g, sodium_per_100g, 
            saturated_fat_g, monounsaturated_fat_g, polyunsaturated_fat_g,
            omega_3_g, omega_6_g, cholesterol_mg, water_g, ash_g, starch_g,
            calcium_mg, iron_mg, magnesium_mg, phosphorus_mg, potassium_mg, zinc_mg,
            copper_mg, manganese_mg, selenium_mcg, iodine_mcg,
            vitamin_a_mcg, vitamin_c_mg, vitamin_d_mcg, vitamin_e_mg, vitamin_k_mcg,
            vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg, vitamin_b6_mg, vitamin_b12_mcg,
            folate_mcg, caffeine_mg, alcohol_g,
            fructose_g, glucose_g, sucrose_g, lactose_g,
            histidine_mg, isoleucine_mg, leucine_mg, lysine_mg, methionine_mg,
            phenylalanine_mg, threonine_mg, tryptofan_mg, valine_mg,
            is_verified, edible_portion_percent, food_code, energy_kj
          ''')
          .eq('is_verified', true)
          .order('created_at', ascending: false)
          .limit(8);

      // Load recent Food Ingredients from the database as well
      final foodIngredientsResponse = await Supabase.instance.client
          .from('Food Ingredients')
          .select('''
            "Codice Alimento",
            "Nome Alimento ITA",
            "Nome Alimento ENG",
            "Nome Scientifico",
            "Simbolo",
            "Energia, Ric con fibra (kcal)",
            "Proteine totali",
            "Lipidi totali",
            "Carboidrati disponibili (MSE)",
            "Fibra alimentare totale"
          ''')
          .order('Nome Alimento ITA',
              ascending: true) // Remove quotes from column name in order
          .limit(5);

      final recipesResponse = await RecipeService.instance.getRecentRecipes(
        limit: 5,
      );

      final recentFoods = <Map<String, dynamic>>[];

      // Process food items with comprehensive nutritional data
      for (final item in foodItemsResponse) {
        if (item['id'] != null &&
            item['name'] != null &&
            item['name'].toString().trim().isNotEmpty) {
          recentFoods.add(_processFoodItemData(item));
        }
      }

      // Process Food Ingredients data
      for (final item in foodIngredientsResponse) {
        if (item['Codice Alimento'] != null &&
            item['Nome Alimento ITA'] != null &&
            item['Nome Alimento ITA'].toString().trim().isNotEmpty) {
          recentFoods.add(_processFoodIngredientData(item));
        }
      }

      // Add recipes after ingredients
      for (final recipe in recipesResponse) {
        if (recipe['id'] != null &&
            recipe['title'] != null &&
            recipe['title'].toString().trim().isNotEmpty) {
          final processedRecipe = _processRecipeData(recipe);
          // CRITICAL FIX: Skip invalid recipes (those with 0 calories)
          if (processedRecipe['type'] != 'invalid_recipe') {
            recentFoods.add(processedRecipe);
          }
        }
      }

      if (mounted) {
        setState(() {
          _recentFoods = recentFoods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _recentFoods = [];
          _errorMessage = 'Errore nel caricamento degli alimenti recenti';
        });
      }
      print('Error loading recent foods: $e');
    }
  }

  /// FIXED: Load user's favorite recipes
  Future<void> _loadFavoriteRecipes() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() {
        _favoriteRecipeIds = {};
      });
      return;
    }

    try {
      final favoriteRecipes = await RecipeService.instance.getFavoriteRecipes(user.id);
      if (mounted) {
        setState(() {
          _favoriteRecipeIds = favoriteRecipes
              .map((recipe) => recipe['id'] as String)
              .toSet();
        });
      }
    } catch (e) {
      print('Error loading favorite recipes: $e');
    }
  }

  /// FIXED: Toggle recipe favorite status
  Future<void> _toggleRecipeFavorite(Map<String, dynamic> recipe) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accedi per salvare i preferiti')),
      );
      return;
    }

    final recipeId = recipe['id'] as String;
    final isFavorite = _favoriteRecipeIds.contains(recipeId);

    try {
      if (isFavorite) {
        await RecipeService.instance.removeFromFavorites(recipeId, user.id);
        setState(() {
          _favoriteRecipeIds.remove(recipeId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rimossa dai preferiti')),
          );
        }
      } else {
        await RecipeService.instance.addToFavorites(recipeId, user.id);
        setState(() {
          _favoriteRecipeIds.add(recipeId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aggiunta ai preferiti')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }


  Map<String, dynamic> _processFoodIngredientData(Map<String, dynamic> item) {
    // Convert Food Ingredients data to standard format
    final kcal = _parseNumericValue(item['Energia, Ric con fibra (kcal)']);
    final proteins = _parseNumericValue(item['Proteine totali']);
    final fats = _parseNumericValue(item['Lipidi totali']);
    final carbs = _parseNumericValue(item['Carboidrati disponibili (MSE)']);
    final fiber = _parseNumericValue(item['Fibra alimentare totale']);

    return {
      'id': item['Codice Alimento'],
      'name': item['Nome Alimento ITA'].toString().trim(),
      'type': 'food_ingredient',
      'category': 'Database Alimenti',
      'calories_per_100g': kcal.round(),
      'protein': proteins,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': 0.0,
      'sodium': 0.0,
      // Additional comprehensive nutritional data (defaults to 0)
      'saturated_fat': 0.0,
      'monounsaturated_fat': 0.0,
      'polyunsaturated_fat': 0.0,
      'omega_3': 0.0,
      'omega_6': 0.0,
      'cholesterol': 0.0,
      'water': 0.0,
      'ash': 0.0,
      'starch': 0.0,
      // Minerals (defaults)
      'calcium': 0.0,
      'iron': 0.0,
      'magnesium': 0.0,
      'phosphorus': 0.0,
      'potassium': 0.0,
      'zinc': 0.0,
      'copper': 0.0,
      'manganese': 0.0,
      'selenium': 0.0,
      'iodine': 0.0,
      // Vitamins (defaults)
      'vitamin_a': 0.0,
      'vitamin_c': 0.0,
      'vitamin_d': 0.0,
      'vitamin_e': 0.0,
      'vitamin_k': 0.0,
      'vitamin_b1': 0.0,
      'vitamin_b2': 0.0,
      'vitamin_b3': 0.0,
      'vitamin_b6': 0.0,
      'vitamin_b12': 0.0,
      'folate': 0.0,
      // Other
      'caffeine': 0.0,
      'alcohol': 0.0,
      'energy_kj': (kcal * 4.184).round(),
      'edible_portion': 100.0,
      // Display data
      'brand': '',
      'food_code': item['Codice Alimento']?.toString() ?? '',
      'italian_name': item['Nome Alimento ITA']?.toString() ?? '',
      'english_name': item['Nome Alimento ENG']?.toString() ?? '',
      'scientific_name': item['Nome Scientifico']?.toString() ?? '',
      'symbol': item['Simbolo']?.toString() ?? '',
      'servings': ['100g'],
      'recent': true,
      'favorite': false,
    };
  }

  double _parseNumericValue(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    String stringValue = value.toString().trim();

    // Handle special cases like "-3", "tr" (traces), empty strings
    if (stringValue.isEmpty ||
        stringValue == '-3' ||
        stringValue == '-2' ||
        stringValue.toLowerCase() == 'tr' ||
        stringValue == 'n.d.' ||
        stringValue == '-') {
      return 0.0;
    }

    // Try to parse as double
    return double.tryParse(stringValue) ?? 0.0;
  }

  Map<String, dynamic> _processFoodItemData(Map<String, dynamic> item) {
    return {
      'id': item['id'],
      'name': _getDisplayName(item),
      'type': 'food_item',
      'category': _getCategoryDisplayName(item['category']),
      'calories_per_100g': (item['calories_per_100g'] as int?) ?? 0,
      'protein': ((item['protein_per_100g'] as num?) ?? 0).toDouble(),
      'carbs': ((item['carbs_per_100g'] as num?) ?? 0).toDouble(),
      'fats': ((item['fat_per_100g'] as num?) ?? 0).toDouble(),
      'fiber': ((item['fiber_per_100g'] as num?) ?? 0).toDouble(),
      'sugar': ((item['sugar_per_100g'] as num?) ?? 0).toDouble(),
      'sodium': ((item['sodium_per_100g'] as num?) ?? 0).toDouble(),
      // Comprehensive nutritional data
      'saturated_fat': ((item['saturated_fat_g'] as num?) ?? 0).toDouble(),
      'monounsaturated_fat':
          ((item['monounsaturated_fat_g'] as num?) ?? 0).toDouble(),
      'polyunsaturated_fat':
          ((item['polyunsaturated_fat_g'] as num?) ?? 0).toDouble(),
      'omega_3': ((item['omega_3_g'] as num?) ?? 0).toDouble(),
      'omega_6': ((item['omega_6_g'] as num?) ?? 0).toDouble(),
      'cholesterol': ((item['cholesterol_mg'] as num?) ?? 0).toDouble(),
      'water': ((item['water_g'] as num?) ?? 0).toDouble(),
      'ash': ((item['ash_g'] as num?) ?? 0).toDouble(),
      'starch': ((item['starch_g'] as num?) ?? 0).toDouble(),
      // Minerals
      'calcium': ((item['calcium_mg'] as num?) ?? 0).toDouble(),
      'iron': ((item['iron_mg'] as num?) ?? 0).toDouble(),
      'magnesium': ((item['magnesium_mg'] as num?) ?? 0).toDouble(),
      'phosphorus': ((item['phosphorus_mg'] as num?) ?? 0).toDouble(),
      'potassium': ((item['potassium_mg'] as num?) ?? 0).toDouble(),
      'zinc': ((item['zinc_mg'] as num?) ?? 0).toDouble(),
      'copper': ((item['copper_mg'] as num?) ?? 0).toDouble(),
      'manganese': ((item['manganese_mg'] as num?) ?? 0).toDouble(),
      'selenium': ((item['selenium_mcg'] as num?) ?? 0).toDouble(),
      'iodine': ((item['iodine_mcg'] as num?) ?? 0).toDouble(),
      // Vitamins
      'vitamin_a': ((item['vitamin_a_mcg'] as num?) ?? 0).toDouble(),
      'vitamin_c': ((item['vitamin_c_mg'] as num?) ?? 0).toDouble(),
      'vitamin_d': ((item['vitamin_d_mcg'] as num?) ?? 0).toDouble(),
      'vitamin_e': ((item['vitamin_e_mg'] as num?) ?? 0).toDouble(),
      'vitamin_k': ((item['vitamin_k_mcg'] as num?) ?? 0).toDouble(),
      'vitamin_b1': ((item['vitamin_b1_mg'] as num?) ?? 0).toDouble(),
      'vitamin_b2': ((item['vitamin_b2_mg'] as num?) ?? 0).toDouble(),
      'vitamin_b3': ((item['vitamin_b3_mg'] as num?) ?? 0).toDouble(),
      'vitamin_b6': ((item['vitamin_b6_mg'] as num?) ?? 0).toDouble(),
      'vitamin_b12': ((item['vitamin_b12_mcg'] as num?) ?? 0).toDouble(),
      'folate': ((item['folate_mcg'] as num?) ?? 0).toDouble(),
      // Amino acids - FIXED: Changed from tryptophan_mg to tryptofan_mg
      'histidine': ((item['histidine_mg'] as num?) ?? 0).toDouble(),
      'isoleucine': ((item['isoleucine_mg'] as num?) ?? 0).toDouble(),
      'leucine': ((item['leucine_mg'] as num?) ?? 0).toDouble(),
      'lysine': ((item['lysine_mg'] as num?) ?? 0).toDouble(),
      'methionine': ((item['methionine_mg'] as num?) ?? 0).toDouble(),
      'phenylalanine': ((item['phenylalanine_mg'] as num?) ?? 0).toDouble(),
      'threonine': ((item['threonine_mg'] as num?) ?? 0).toDouble(),
      'tryptophan': ((item['tryptofan_mg'] as num?) ?? 0).toDouble(),
      'valine': ((item['valine_mg'] as num?) ?? 0).toDouble(),
      // Sugars
      'fructose': ((item['fructose_g'] as num?) ?? 0).toDouble(),
      'glucose': ((item['glucose_g'] as num?) ?? 0).toDouble(),
      'sucrose': ((item['sucrose_g'] as num?) ?? 0).toDouble(),
      'lactose': ((item['lactose_g'] as num?) ?? 0).toDouble(),
      // Other
      'caffeine': ((item['caffeine_mg'] as num?) ?? 0).toDouble(),
      'alcohol': ((item['alcohol_g'] as num?) ?? 0).toDouble(),
      'energy_kj': (item['energy_kj'] as int?) ?? 0,
      'edible_portion':
          ((item['edible_portion_percent'] as num?) ?? 100).toDouble(),
      // Display data
      'brand': (item['brand'] as String?) ?? '',
      'food_code': (item['food_code'] as String?) ?? '',
      'italian_name': (item['italian_name'] as String?) ?? '',
      'english_name': (item['english_name'] as String?) ?? '',
      'scientific_name': (item['scientific_name'] as String?) ?? '',
      'servings': ['100g'],
      'recent': true,
      'favorite': false,
    };
  }

  Map<String, dynamic> _processRecipeData(Map<String, dynamic> recipe) {
    final totalCalories = (recipe['total_calories'] as int?) ?? 0;
    final totalProtein = ((recipe['total_protein_g'] as num?) ?? 0).toDouble();
    final totalCarbs = ((recipe['total_carbs_g'] as num?) ?? 0).toDouble();
    final totalFat = ((recipe['total_fat_g'] as num?) ?? 0).toDouble();
    final totalFiber = ((recipe['total_fiber_g'] as num?) ?? 0).toDouble();
    final servings = (recipe['servings'] as int?) ?? 1;

    // Calculate per 100g values
    int caloriesPer100g = _calculateRecipeCaloriesPer100g(recipe);

    // CRITICAL FIX: If recipe has 0 total calories, it's invalid - skip it
    // This prevents showing recipes that were imported incorrectly
    if (totalCalories == 0 && totalProtein == 0 && totalCarbs == 0 && totalFat == 0) {
      // Return null or throw to skip this recipe
      return {
        'id': recipe['id'],
        'name': recipe['title'].toString().trim(),
        'type': 'invalid_recipe',  // Mark as invalid so it's filtered out
        'category': 'Invalid',
        'calories_per_100g': 0,
        'protein': 0.0,
        'carbs': 0.0,
        'fats': 0.0,
        'fiber': 0.0,
        'servings': ['100g'],
        'servings_count': servings,
        'total_calories': 0,
        'recent': false,
        'favorite': false,
      };
    }

    return {
      'id': recipe['id'],
      'name': recipe['title'].toString().trim(),
      'type': 'recipe',
      'category': _translateCategory(
        (recipe['category'] as String?) ?? 'snack',
      ),
      'calories_per_100g': caloriesPer100g,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFat,
      'fiber': totalFiber,
      'servings': ['100g'],
      'servings_count': servings,
      'total_calories': totalCalories,
      'recent': true,
      'favorite': false,
    };
  }

  String _getDisplayName(Map<String, dynamic> item) {
    final name = item['name'] as String?;
    final italianName = item['italian_name'] as String?;

    // Prefer Italian name if available, otherwise use main name
    if (italianName != null && italianName.trim().isNotEmpty) {
      return italianName.trim();
    } else if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }

    return 'Alimento';
  }

  String _getCategoryDisplayName(String? category) {
    if (category == null) return 'Ingrediente';

    switch (category) {
      case '1001':
        return 'Tuberi';
      case '2001':
        return 'Verdure a foglia';
      case '2003':
        return 'Radici';
      case '2004':
        return 'Cavoli';
      case '2005':
        return 'Frutti';
      case '3000':
      case '3001':
      case '3002':
        return 'Frutta';
      case '4001':
      case '4002':
        return 'Cereali';
      default:
        return 'Ingrediente';
    }
  }

  Future<void> _searchFoods(String query) async {
    if (!mounted) return;

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _filteredFoods = [];
          _showSuggestions =
              _searchFocusNode.hasFocus && _recentFoods.isNotEmpty;
          _errorMessage = null;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
      _errorMessage = null;
    });

    try {
      final searchResults = <Map<String, dynamic>>[];
      print('🔍 Starting search for query: "$query"');

      // 1. Search Food Ingredients table with correct syntax
      try {
        print('🔍 Searching Food Ingredients table...');
        print('🔍 Query: "$query"');

        final foodIngredientsResponse = await Supabase.instance.client
            .from('Food Ingredients')
            .select()
            .ilike('Nome Alimento ITA', '%$query%')
            .limit(10);

        print(
            '✅ Food Ingredients search returned: ${foodIngredientsResponse.length} items');
        print(
            '✅ Sample data: ${foodIngredientsResponse.isNotEmpty ? foodIngredientsResponse.first : "empty"}');

        for (final item in foodIngredientsResponse) {
          if (item['Codice Alimento'] != null &&
              item['Nome Alimento ITA'] != null &&
              item['Nome Alimento ITA'].toString().trim().isNotEmpty) {
            searchResults.add(_processFoodIngredientData(item));
          }
        }
      } catch (foodIngredientsError, stackTrace) {
        print('Food Ingredients search failed: $foodIngredientsError');
        print('Stack trace: $stackTrace');
        // Don't rethrow - continue with other searches
      }

      // 2. Use the database search_foods function for comprehensive search
      try {
        final searchFunctionResponse = await Supabase.instance.client.rpc(
          'search_foods',
          params: {'query_text': query},
        );

        for (final item in searchFunctionResponse as List) {
          if (item['id'] != null &&
              item['name'] != null &&
              item['name'].toString().trim().isNotEmpty) {
            searchResults.add(_processFoodItemData(item));
          }
        }
      } catch (searchFunctionError) {
        print(
          'Search function failed, using fallback search: $searchFunctionError',
        );

        // Fallback to comprehensive direct search with multiple name fields
        final foodItemsResponse = await Supabase.instance.client
            .from('food_items')
            .select('''
              id, name, italian_name, english_name, scientific_name, brand, category,
              calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, 
              fiber_per_100g, sugar_per_100g, sodium_per_100g, 
              saturated_fat_g, monounsaturated_fat_g, polyunsaturated_fat_g,
              omega_3_g, omega_6_g, cholesterol_mg, water_g, ash_g, starch_g,
              calcium_mg, iron_mg, magnesium_mg, phosphorus_mg, potassium_mg, zinc_mg,
              copper_mg, manganese_mg, selenium_mcg, iodine_mcg,
              vitamin_a_mcg, vitamin_c_mg, vitamin_d_mcg, vitamin_e_mg, vitamin_k_mcg,
              vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg, vitamin_b6_mg, vitamin_b12_mcg,
              folate_mcg, caffeine_mg, alcohol_g,
              fructose_g, glucose_g, sucrose_g, lactose_g,
              histidine_mg, isoleucine_mg, leucine_mg, lysine_mg, methionine_mg,
              phenylalanine_mg, threonine_mg, tryptofan_mg, valine_mg,
              is_verified, edible_portion_percent, food_code, energy_kj
            ''')
            .or(
              'name.ilike.%$query%,italian_name.ilike.%$query%,english_name.ilike.%$query%,scientific_name.ilike.%$query%',
            )
            .limit(15);

        for (final item in foodItemsResponse) {
          if (item['id'] != null &&
              item['name'] != null &&
              item['name'].toString().trim().isNotEmpty) {
            searchResults.add(_processFoodItemData(item));
          }
        }
      }

      // 3. Then search recipes
      final recipesResponse =
          await RecipeService.instance.searchRecipesForMeals(query);

      for (final recipe in recipesResponse) {
        if (recipe['id'] != null &&
            recipe['title'] != null &&
            recipe['title'].toString().trim().isNotEmpty) {
          final processedRecipe = _processRecipeData(recipe);
          // CRITICAL FIX: Skip invalid recipes (those with 0 calories)
          if (processedRecipe['type'] != 'invalid_recipe') {
            searchResults.add(processedRecipe);
          }
        }
      }

      if (mounted) {
        setState(() {
          _filteredFoods = searchResults.take(20).toList();
          _showSuggestions = true;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _filteredFoods = [];
          _showSuggestions = _searchFocusNode.hasFocus;
          _errorMessage = 'Errore durante la ricerca degli alimenti';
        });
      }
      print('Error searching foods: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore durante la ricerca. Controlla la tua connessione.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(4.w),
          ),
        );
      }
    }
  }

  void _addFood(Map<String, dynamic> food) {
    if (food['id'] == null ||
        food['name'] == null ||
        food['name'].toString().trim().isEmpty) {
      _showErrorToast('Dati dell\'alimento non disponibili');
      return;
    }

    try {
      final foodWithDefaults = Map<String, dynamic>.from(food);
      foodWithDefaults["selected_serving"] = "100g";
      foodWithDefaults["servings"] = ["100g"];
      foodWithDefaults["quantity"] = 100.0;

      // Ensure type is set correctly
      if (foodWithDefaults['type'] == null) {
        foodWithDefaults['type'] = 'food_item';
      }

      print(
          'Adding food: ${foodWithDefaults['name']} (ID: ${foodWithDefaults['id']})');

      // Call the callback to add food to parent component
      widget.onFoodAdded(foodWithDefaults);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foodWithDefaults['name']} aggiunto al pasto'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error adding food: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nell\'aggiunta dell\'alimento'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _showErrorToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
        ),
      );
    }
  }

  // Ocean Blue colors
  static const Color _seaMid = Color(0xFF00ACC1);
  static const Color _seaDeep = Color(0xFF006064);
  static const Color _textMuted = Color(0xFF78909C);
  static const Color _textDark = Color(0xFF006064);
  static const Color _inputBg = Color(0xFFF0F8FF);

  @override
  Widget build(BuildContext context) {
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
          // Header row with icon and title
          Row(
            children: [
              Text('🔍', style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 2.w),
              Text(
                'Cerca cibo nel database',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Description text
          Text(
            'Trova ingredienti con valori nutrizionali completi (kcal, proteine, grassi, carboidrati, fibra)',
            style: TextStyle(
              fontSize: 14.sp, // Increased from 12.sp for better readability
              color: _textMuted,
              height: 1.4,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSearchField(),
          if (_showSuggestions && _searchFocusNode.hasFocus)
            _buildSuggestionsList(),
          if (widget.selectedFoods.isNotEmpty) ...[
            SizedBox(height: 3.h),
            _buildSelectedFoodsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _searchFoods,
        decoration: InputDecoration(
          hintText: 'Cerca cibo... (es: "carote", "pollo")',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: _textMuted,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(_seaMid),
                    ),
                  )
                : Text('🔍', style: TextStyle(fontSize: 16.sp)),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    if (mounted) {
                      setState(() {
                        _showSuggestions = _recentFoods.isNotEmpty;
                        _filteredFoods = [];
                        _errorMessage = null;
                      });
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: const CustomIconWidget(
                      iconName: 'clear',
                      color: _textMuted,
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),
        ),
        style: TextStyle(
          fontSize: 14.sp,
          color: _textDark,
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    final itemsToShow =
        _searchController.text.isNotEmpty ? _filteredFoods : _recentFoods;

    // Show loading state
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.only(top: 1.h),
        padding: EdgeInsets.all(4.w),
        constraints: BoxConstraints(maxHeight: 30.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.3,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Ricerca in corso...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error state if there's an error message
    if (_errorMessage != null) {
      return Container(
        margin: EdgeInsets.only(top: 1.h),
        padding: EdgeInsets.all(4.w),
        constraints: BoxConstraints(maxHeight: 30.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 32,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                if (_searchController.text.isNotEmpty) {
                  _searchFoods(_searchController.text);
                } else {
                  _loadRecentFoods();
                }
              },
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                'Riprova',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state when no items and user has typed something
    if (itemsToShow.isEmpty && _searchController.text.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 1.h),
        padding: EdgeInsets.all(4.w),
        constraints: BoxConstraints(maxHeight: 25.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.4,
              ),
              size: 32,
            ),
            SizedBox(height: 2.h),
            Text(
              'Nessun alimento trovato nel database.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Prova a cercare ingredienti come "carote", "pollo", "riso", "pomodoro"',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                if (mounted) {
                  setState(() {
                    _showSuggestions = _recentFoods.isNotEmpty;
                    _filteredFoods = [];
                    _errorMessage = null;
                  });
                }
              },
              icon: CustomIconWidget(
                iconName: 'clear',
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                'Cancella ricerca',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
          ],
        ),
      );
    }

    // If no items to show and no search text, don't show suggestions
    if (itemsToShow.isEmpty) {
      return SizedBox.shrink();
    }

    // Group items to show food ingredients first, then regular ingredients, then recipes
    final foodIngredients = itemsToShow
        .where((item) => (item["type"] as String?) == "food_ingredient")
        .toList();
    final ingredients = itemsToShow
        .where((item) => (item["type"] as String?) == "food_item")
        .toList();
    final recipes = itemsToShow
        .where((item) => (item["type"] as String?) == "recipe")
        .toList();
    final organizedItems = [...foodIngredients, ...ingredients, ...recipes];

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      constraints: BoxConstraints(maxHeight: 40.h, minHeight: 0),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_searchController.text.isEmpty && _recentFoods.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'history',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Ingredienti e ricette recenti',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (_searchController.text.isNotEmpty && foodIngredients.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0.5.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'database',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Database ingredienti (${foodIngredients.length})',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: organizedItems.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                  indent: 4.w,
                  endIndent: 4.w,
                );
              },
              itemBuilder: (context, index) {
                final food = organizedItems[index];

                if (food["name"] == null ||
                    food["name"].toString().trim().isEmpty) {
                  return SizedBox.shrink();
                }

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _addFood(food),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.5.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                (food["type"] as String?) ?? 'food_item',
                                (food["category"] as String?) ?? 'Ingrediente',
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: _getCategoryIcon(
                                  (food["type"] as String?) ?? 'food_item',
                                  (food["category"] as String?) ??
                                      'Ingrediente',
                                ),
                                color: _getCategoryColor(
                                  (food["type"] as String?) ?? 'food_item',
                                  (food["category"] as String?) ??
                                      'Ingrediente',
                                ),
                                size: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  food["name"].toString(),
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${(food["calories_per_100g"] as int?) ?? 0} kcal • P:${((food["protein"] as num?) ?? 0).toStringAsFixed(1)}g • C:${((food["carbs"] as num?) ?? 0).toStringAsFixed(1)}g • F:${((food["fats"] as num?) ?? 0).toStringAsFixed(1)}g • Fibra:${((food["fiber"] as num?) ?? 0).toStringAsFixed(1)}g',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                          fontSize: 11.sp,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if ((food["type"] as String?) != "recipe" &&
                                    (food["brand"] as String?)?.isNotEmpty ==
                                        true) ...[
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    'Marca: ${food["brand"]}',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if ((food["type"] as String?) == "recipe")
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.5.h,
                                      ),
                                      margin: EdgeInsets.only(right: 1.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.secondary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'RICETTA',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.secondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ),
                                  if ((food["type"] as String?) ==
                                      "food_ingredient")
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.5.h,
                                      ),
                                      margin: EdgeInsets.only(right: 1.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'DATABASE',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ),
                                  if ((food["type"] as String?) == "food_item")
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.5.h,
                                      ),
                                      margin: EdgeInsets.only(right: 1.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.secondary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'ITEMS',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.secondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ),
                                  if ((food["recent"] as bool?) == true)
                                    Padding(
                                      padding: EdgeInsets.only(right: 1.w),
                                      child: CustomIconWidget(
                                        iconName: 'history',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              // FIXED: Show both favorite and add buttons for recipes
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Favorite button (only for recipes)
                                  if ((food["type"] as String?) == "recipe") ...[
                                    GestureDetector(
                                      onTap: () => _toggleRecipeFavorite(food),
                                      child: Container(
                                        padding: EdgeInsets.all(1.5.w),
                                        decoration: BoxDecoration(
                                          color: _favoriteRecipeIds.contains(food['id'])
                                              ? AppTheme.lightTheme.colorScheme.error
                                                  .withValues(alpha: 0.1)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          _favoriteRecipeIds.contains(food['id'])
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: _favoriteRecipeIds.contains(food['id'])
                                              ? AppTheme.lightTheme.colorScheme.error
                                              : Colors.grey.shade600,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                  ],
                                  // Add button (for all items)
                                  Container(
                                    padding: EdgeInsets.all(1.5.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'add_circle_outline',
                                      color:
                                          AppTheme.lightTheme.colorScheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoodsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'restaurant',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Cibi selezionati per il pasto',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          'Modifica le quantità per calcolare automaticamente i valori nutrizionali',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.selectedFoods.length,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            final food = widget.selectedFoods[index];
            return _buildSelectedFoodItem(food, index);
          },
        ),
      ],
    );
  }

  Widget _buildSelectedFoodItem(Map<String, dynamic> food, int index) {
    final quantity = (food["quantity"] as num?)?.toDouble() ?? 100.0;
    final selectedServing = (food["selected_serving"] as String?) ?? "100g";

    final foodName = (food["name"] as String?) ?? 'Alimento senza nome';
    if (foodName.trim().isEmpty) {
      food["name"] = 'Alimento senza nome';
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((food["type"] as String?) == "recipe") ...[
                      SizedBox(height: 0.8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'RICETTA',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if ((food["type"] as String?) == "food_ingredient") ...[
                      SizedBox(height: 0.8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'DATABASE INGREDIENTI',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    // Show additional food information
                    if ((food["type"] as String?) != "recipe") ...[
                      SizedBox(height: 0.5.h),
                      if ((food["brand"] as String?)?.isNotEmpty == true)
                        Text(
                          'Marca: ${food["brand"]}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if ((food["italian_name"] as String?)?.isNotEmpty ==
                              true &&
                          food["italian_name"] != food["name"])
                        Text(
                          'Nome: ${food["italian_name"]}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if ((food["scientific_name"] as String?)?.isNotEmpty ==
                          true)
                        Text(
                          'Scientifico: ${food["scientific_name"]}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () => _handleFoodRemoval(index),
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Quantity input with enhanced validation
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
                    SizedBox(height: 0.5.h),
                    _buildQuantityInput(food, index),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Enhanced nutrition display with key nutrients
          _buildEnhancedNutritionDisplay(food, quantity),
        ],
      ),
    );
  }

  Widget _buildEnhancedNutritionDisplay(
    Map<String, dynamic> food,
    double quantity,
  ) {
    final calories = _calculateNutrientValue(
      food,
      'calories_per_100g',
      quantity,
    );
    final protein = _calculateNutrientValue(food, 'protein', quantity);
    final carbs = _calculateNutrientValue(food, 'carbs', quantity);
    final fat = _calculateNutrientValue(food, 'fats', quantity);
    final fiber = _calculateNutrientValue(food, 'fiber', quantity);
    final sugar = _calculateNutrientValue(food, 'sugar', quantity);
    final sodium = _calculateNutrientValue(food, 'sodium', quantity);

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valori nutrizionali (per ${quantity.toStringAsFixed(0)}g)',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          // Primary macronutrients
          Row(
            children: [
              Expanded(
                child: _buildNutrientChip(
                  '${calories.toStringAsFixed(0)} kcal',
                  'Energia',
                  AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildNutrientChip(
                  '${protein.toStringAsFixed(1)}g',
                  'Proteine',
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child: _buildNutrientChip(
                  '${carbs.toStringAsFixed(1)}g',
                  'Carboidrati',
                  Colors.blue,
                ),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildNutrientChip(
                  '${fat.toStringAsFixed(1)}g',
                  'Grassi',
                  Colors.red,
                ),
              ),
            ],
          ),

          // Secondary nutrients if significant
          if (fiber > 0.5 || sugar > 0.5 || sodium > 5) ...[
            SizedBox(height: 0.5.h),
            Row(
              children: [
                if (fiber > 0.5)
                  Expanded(
                    child: _buildNutrientChip(
                      '${fiber.toStringAsFixed(1)}g',
                      'Fibre',
                      Colors.green,
                    ),
                  ),
                if (fiber > 0.5 && (sugar > 0.5 || sodium > 5))
                  SizedBox(width: 1.w),
                if (sugar > 0.5)
                  Expanded(
                    child: _buildNutrientChip(
                      '${sugar.toStringAsFixed(1)}g',
                      'Zuccheri',
                      Colors.purple,
                    ),
                  ),
                if (sugar > 0.5 && sodium > 5) SizedBox(width: 1.w),
                if (sodium > 5)
                  Expanded(
                    child: _buildNutrientChip(
                      '${sodium.toStringAsFixed(0)}mg',
                      'Sodio',
                      Colors.grey,
                    ),
                  ),
              ],
            ),
          ],

          // Show vitamin and mineral highlights for food items
          if ((food['type'] as String?) != 'recipe')
            _buildMicronutrientHighlights(food, quantity),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicronutrientHighlights(
    Map<String, dynamic> food,
    double quantity,
  ) {
    final highlights = <Widget>[];

    // Check for significant vitamin and mineral content
    final vitaminC = _calculateNutrientValue(food, 'vitamin_c', quantity);
    final vitaminA = _calculateNutrientValue(food, 'vitamin_a', quantity);
    final calcium = _calculateNutrientValue(food, 'calcium', quantity);
    final iron = _calculateNutrientValue(food, 'iron', quantity);
    final potassium = _calculateNutrientValue(food, 'potassium', quantity);

    if (vitaminC > 5) {
      highlights.add(
        _buildMicronutrientChip('${vitaminC.toStringAsFixed(0)}mg', 'Vit. C'),
      );
    }
    if (vitaminA > 50) {
      highlights.add(
        _buildMicronutrientChip('${vitaminA.toStringAsFixed(0)}μg', 'Vit. A'),
      );
    }
    if (calcium > 20) {
      highlights.add(
        _buildMicronutrientChip('${calcium.toStringAsFixed(0)}mg', 'Calcio'),
      );
    }
    if (iron > 0.5) {
      highlights.add(
        _buildMicronutrientChip('${iron.toStringAsFixed(1)}mg', 'Ferro'),
      );
    }
    if (potassium > 50) {
      highlights.add(
        _buildMicronutrientChip(
          '${potassium.toStringAsFixed(0)}mg',
          'Potassio',
        ),
      );
    }

    if (highlights.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.h),
          Text(
            'Micronutrienti significativi:',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Wrap(spacing: 1.w, runSpacing: 0.5.h, children: highlights),
        ],
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildMicronutrientChip(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
            alpha: 0.8,
          ),
          fontSize: 10.sp,
        ),
      ),
    );
  }

  double _calculateNutrientValue(
    Map<String, dynamic> food,
    String nutrientKey,
    double quantity,
  ) {
    final nutrientPer100g = ((food[nutrientKey] as num?) ?? 0).toDouble();
    return (quantity / 100.0) * nutrientPer100g;
  }

  int _calculateRecipeCaloriesPer100g(Map<String, dynamic> recipe) {
    // Use calories_per_100g from DB if available (populated from CSV)
    final dbCaloriesPer100g = (recipe['calories_per_100g'] as int?) ?? 0;
    if (dbCaloriesPer100g > 0) return dbCaloriesPer100g;

    // Fallback: use total_weight_g from DB if available
    final dbTotalWeight = ((recipe['total_weight_g'] as num?) ?? 0).toDouble();
    final totalCalories = (recipe['total_calories'] as int?) ?? 0;
    if (dbTotalWeight > 0 && totalCalories > 0) {
      return ((totalCalories / dbTotalWeight) * 100).round();
    }

    // Last resort fallback: estimate with 250g per serving
    final servings = (recipe['servings'] as int?) ?? 1;
    if (servings == 0) return 0;
    final totalWeight = 250.0 * servings;
    return totalWeight > 0 ? ((totalCalories / totalWeight) * 100).round() : 0;
  }

  String _translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return 'Colazione';
      case 'lunch':
        return 'Pranzo';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Spuntino';
      case 'dessert':
        return 'Dolce';
      case 'beverage':
        return 'Bevanda';
      default:
        return 'Ricetta';
    }
  }

  Widget _buildQuantityInput(Map<String, dynamic> food, int index) {
    final quantity = (food["quantity"] as num?)?.toDouble() ?? 100.0;

    // Get or create a persistent controller for this index
    if (!_quantityControllers.containsKey(index)) {
      _quantityControllers[index] = TextEditingController(
        text: _formatQuantityDisplay(quantity),
      );
    } else {
      // Update text only if the value has changed from external source
      final currentText = _quantityControllers[index]!.text;
      final formattedQuantity = _formatQuantityDisplay(quantity);
      if (currentText != formattedQuantity && !_quantityControllers[index]!.selection.isValid) {
        _quantityControllers[index]!.text = formattedQuantity;
      }
    }

    final quantityController = _quantityControllers[index]!;

    return Column(
      children: [
        Container(
          height: 5.h,
          child: TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.error,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 1.h,
              ),
              suffixText: 'g',
              suffixStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            onChanged: (value) {
              _handleQuantityChange(value, index);
            },
            validator: (value) {
              return _validateQuantity(value);
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        if (_getQuantityValidationError(quantityController.text) != null)
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            child: Text(
              _getQuantityValidationError(quantityController.text)!,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  String _formatQuantityDisplay(double quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    } else {
      return quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    }
  }

  void _handleQuantityChange(String value, int index) {
    String cleanValue =
        value.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), '');

    double? parsedValue = double.tryParse(cleanValue);

    if (parsedValue != null && parsedValue > 0 && parsedValue <= 10000) {
      widget.onFoodUpdated(index, "quantity", parsedValue);
      widget.onFoodUpdated(index, "selected_serving", "100g");
    } else if (cleanValue.isEmpty) {
      return;
    }
  }

  void _handleFoodRemoval(int index) {
    // Dispose and remove the controller for this index
    if (_quantityControllers.containsKey(index)) {
      _quantityControllers[index]?.dispose();
      _quantityControllers.remove(index);
    }

    // Rebuild the controllers map with updated indices
    final updatedControllers = <int, TextEditingController>{};
    _quantityControllers.forEach((key, value) {
      if (key < index) {
        updatedControllers[key] = value;
      } else if (key > index) {
        updatedControllers[key - 1] = value;
      }
    });
    _quantityControllers.clear();
    _quantityControllers.addAll(updatedControllers);

    // Call the parent's onFoodRemoved
    widget.onFoodRemoved(index);
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    String cleanValue = value.replaceAll(',', '.');

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(cleanValue)) {
      return 'Solo numeri';
    }

    double? parsedValue = double.tryParse(cleanValue);

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

  String? _getQuantityValidationError(String value) {
    return _validateQuantity(value);
  }

  double _calculateCalories(Map<String, dynamic> food) {
    final quantity = (food["quantity"] as num?)?.toDouble() ?? 100.0;
    final foodType = (food["type"] as String?) ?? "food_item";

    try {
      if (foodType == "recipe") {
        final caloriesPer100g = (food["calories_per_100g"] as int?) ?? 0;
        return (quantity / 100.0) * caloriesPer100g;
      } else {
        final caloriesPer100g = (food["calories_per_100g"] as int?) ?? 0;
        return (quantity / 100.0) * caloriesPer100g;
      }
    } catch (e) {
      print('Error calculating calories: $e');
      return 0.0;
    }
  }

  Color _getCategoryColor(String type, String category) {
    if (type == "recipe") {
      return AppTheme.lightTheme.colorScheme.secondary;
    }

    if (type == "food_ingredient") {
      return AppTheme.lightTheme.colorScheme.primary;
    }

    switch (category.toLowerCase()) {
      case 'ingrediente':
      case 'alimento':
      case 'food item':
      case 'tuberi':
      case 'radici':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'verdure a foglia':
      case 'cavoli':
        return const Color(0xFF27AE60);
      case 'frutti':
      case 'frutta':
        return Colors.orange;
      case 'cereali':
        return Colors.brown;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getCategoryIcon(String type, String category) {
    if (type == "recipe") {
      return 'restaurant_menu';
    }

    if (type == "food_ingredient") {
      return 'storage';
    }

    switch (category.toLowerCase()) {
      case 'ingrediente':
      case 'alimento':
      case 'food item':
        return 'local_dining';
      case 'tuberi':
      case 'radici':
        return 'grass';
      case 'verdure a foglia':
      case 'cavoli':
        return 'eco';
      case 'frutti':
      case 'frutta':
        return 'apple';
      case 'cereali':
        return 'grain';
      default:
        return 'fastfood';
    }
  }
}
