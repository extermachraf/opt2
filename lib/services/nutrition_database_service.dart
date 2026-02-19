import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionDatabaseService {
  static final NutritionDatabaseService _instance =
      NutritionDatabaseService._internal();
  factory NutritionDatabaseService() => _instance;
  NutritionDatabaseService._internal();

  static NutritionDatabaseService get instance => _instance;
  SupabaseClient get _client => Supabase.instance.client;

  /// Search foods with comprehensive filtering options
  Future<List<Map<String, dynamic>>> searchFoods({
    String searchQuery = '',
    String? categoryFilter,
    double? minProtein,
    int? maxCalories,
    int limit = 50,
  }) async {
    try {
      final response = await _client.rpc(
        'search_foods',
        params: {
          'search_query': searchQuery,
          'category_filter': categoryFilter,
          'min_protein': minProtein,
          'max_calories': maxCalories,
          'limit_count': limit,
        },
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Food search failed: $error');
    }
  }

  /// Get comprehensive nutritional breakdown for a food item
  Future<Map<String, dynamic>> getNutritionalBreakdown(
    String foodItemId, {
    double portionGrams = 100,
  }) async {
    try {
      final response = await _client.rpc(
        'get_nutritional_breakdown',
        params: {'food_item_id': foodItemId, 'portion_grams': portionGrams},
      );

      // Organize the response into a structured format
      Map<String, dynamic> breakdown = {};
      for (var item in response) {
        breakdown[item['nutrient_category']] = item['nutrients'];
      }

      return breakdown;
    } catch (error) {
      throw Exception('Nutritional breakdown failed: $error');
    }
  }

  /// Get all food categories
  Future<List<Map<String, dynamic>>> getFoodCategories() async {
    try {
      final response = await _client
          .from('food_categories_view')
          .select()
          .order('code');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch food categories: $error');
    }
  }

  /// Get foods by category
  Future<List<Map<String, dynamic>>> getFoodsByCategory(
    String categoryCode,
  ) async {
    try {
      final response = await _client
          .from('food_items')
          .select('''
            id, food_code, italian_name, english_name, scientific_name,
            category, edible_portion_percent, calories_per_100g,
            protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g
          ''')
          .eq('category', categoryCode)
          .order('english_name');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch foods by category: $error');
    }
  }

  /// Get detailed food information
  Future<Map<String, dynamic>?> getFoodDetails(String foodId) async {
    try {
      final response =
          await _client
              .from('food_items')
              .select('''
            *, 
            vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
            vitamin_b6_mg, vitamin_b12_mcg, folate_mcg, vitamin_c_mg,
            vitamin_d_mcg, vitamin_e_mg, vitamin_k_mcg,
            potassium_mg, calcium_mg, phosphorus_mg, magnesium_mg,
            iron_mg, zinc_mg, copper_mg, manganese_mg, selenium_mcg,
            saturated_fat_g, monounsaturated_fat_g, polyunsaturated_fat_g,
            omega_3_g, omega_6_g, glucose_g, fructose_g, sucrose_g,
            water_g, starch_g, cholesterol_mg
          ''')
              .eq('id', foodId)
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch food details: $error');
    }
  }

  /// Add custom food item
  Future<Map<String, dynamic>> addCustomFoodItem(
    Map<String, dynamic> foodData,
  ) async {
    try {
      final response =
          await _client.from('food_items').insert(foodData).select().single();

      return response;
    } catch (error) {
      throw Exception('Failed to add custom food item: $error');
    }
  }

  /// Update food item (only for custom items created by user)
  Future<Map<String, dynamic>> updateFoodItem(
    String foodId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response =
          await _client
              .from('food_items')
              .update(updates)
              .eq('id', foodId)
              .select()
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update food item: $error');
    }
  }

  /// Get recently used foods for quick access
  Future<List<Map<String, dynamic>>> getRecentlyUsedFoods({
    int limit = 10,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('meal_foods')
          .select('''
            food_item_id,
            food_items!inner(
              id, food_code, italian_name, english_name,
              category, calories_per_100g, protein_per_100g
            )
          ''')
          .eq('meal_entries.user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      // Extract unique food items
      final seenIds = <String>{};
      final uniqueFoods = <Map<String, dynamic>>[];

      for (final item in response) {
        final foodItem = item['food_items'];
        if (foodItem != null && !seenIds.contains(foodItem['id'])) {
          seenIds.add(foodItem['id']);
          uniqueFoods.add(foodItem);
        }
      }

      return uniqueFoods;
    } catch (error) {
      throw Exception('Failed to fetch recently used foods: $error');
    }
  }

  /// Get foods with high protein content
  Future<List<Map<String, dynamic>>> getHighProteinFoods({
    double minProtein = 15.0,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('food_items')
          .select('''
            id, food_code, italian_name, english_name,
            category, calories_per_100g, protein_per_100g,
            carbs_per_100g, fat_per_100g
          ''')
          .gte('protein_per_100g', minProtein)
          .order('protein_per_100g', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch high protein foods: $error');
    }
  }

  /// Get nutrient-rich foods (high in vitamins/minerals)
  Future<List<Map<String, dynamic>>> getNutrientRichFoods({
    String nutrientType = 'vitamin_c_mg',
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('food_items')
          .select('''
            id, food_code, italian_name, english_name,
            category, calories_per_100g, $nutrientType
          ''')
          .gt(nutrientType, 0)
          .order(nutrientType, ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch nutrient-rich foods: $error');
    }
  }

  /// Compare nutritional values between foods
  Future<Map<String, dynamic>> compareFoods(List<String> foodIds) async {
    try {
      final response = await _client
          .from('food_items')
          .select('''
            id, english_name, italian_name, calories_per_100g,
            protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g,
            vitamin_c_mg, calcium_mg, iron_mg, potassium_mg
          ''')
          .inFilter('id', foodIds);

      return {
        'foods': response,
        'comparison_date': DateTime.now().toIso8601String(),
        'total_foods': response.length,
      };
    } catch (error) {
      throw Exception('Failed to compare foods: $error');
    }
  }

  /// Get food suggestions based on nutritional needs
  Future<List<Map<String, dynamic>>> getFoodSuggestions({
    required String nutritionalGoal,
    String? excludeCategory,
    int limit = 15,
  }) async {
    try {
      var query = _client.from('food_items').select('''
            id, food_code, italian_name, english_name,
            category, calories_per_100g, protein_per_100g,
            carbs_per_100g, fat_per_100g, fiber_per_100g
          ''');

      // Apply filters based on nutritional goals
      switch (nutritionalGoal.toLowerCase()) {
        case 'high_protein':
          query = query.gte('protein_per_100g', 15);
          break;
        case 'low_calorie':
          query = query.lte('calories_per_100g', 100);
          break;
        case 'high_fiber':
          query = query.gte('fiber_per_100g', 5);
          break;
        case 'low_carb':
          query = query.lte('carbs_per_100g', 10);
          break;
      }

      if (excludeCategory != null) {
        query = query.neq('category', excludeCategory);
      }

      final response = await query.order('calories_per_100g').limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get food suggestions: $error');
    }
  }
}
