import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeService {
  static RecipeService? _instance;
  static RecipeService get instance => _instance ??= RecipeService._();

  RecipeService._();

  SupabaseClient get _client => Supabase.instance.client;

  // Get all public recipes with optional filters
  Future<List<Map<String, dynamic>>> getRecipes({
    String? searchQuery,
    List<String>? categories,
    List<String>? difficulties,
    List<String>? tags,
    int? maxPrepTime,
    bool? includeUserRecipes,
    int limit = 500, // CRITICAL FIX: Increased from 50 to 500 (DB has 175 recipes)
    int offset = 0,
  }) async {
    try {
      // Start with base query and apply filters BEFORE modifiers
      var query = _client.from('recipes').select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            total_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            is_public,
            is_verified,
            created_by,
            created_at,
            total_calories,
            total_protein_g,
            total_carbs_g,
            total_fat_g,
            total_fiber_g,
            total_weight_g,
            calories_per_100g,
            recipe_tags (
              tag_name
            )
          ''')
          .eq('is_public', true)
          .gt('total_calories', 0); // CRITICAL FIX: Exclude invalid recipes with 0 calories

      // Add search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      // Add category filter
      if (categories != null && categories.isNotEmpty) {
        query = query.inFilter('category', categories);
      }

      // Add difficulty filter
      if (difficulties != null && difficulties.isNotEmpty) {
        query = query.inFilter('difficulty', difficulties);
      }

      // Add prep time filter
      if (maxPrepTime != null) {
        query = query.lte('prep_time_minutes', maxPrepTime);
      }

      // Apply modifiers AFTER all filters
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Filter by tags if provided (client-side filtering for now)
      var filteredRecipes = response;

      if (tags != null && tags.isNotEmpty) {
        filteredRecipes = filteredRecipes.where((recipe) {
          final recipeTags = (recipe['recipe_tags'] as List?)
                  ?.map((tag) => tag['tag_name'] as String)
                  .toList() ??
              [];

          return tags.any((tag) => recipeTags.contains(tag));
        }).toList();
      }

      return filteredRecipes;
    } catch (e) {
      throw Exception('Failed to fetch recipes: $e');
    }
  }

  /// Get recipe by ID with full details
  Future<Map<String, dynamic>?> getRecipeById(String recipeId) async {
    try {
      final response = await _client.from('recipes').select('''
            *,
            recipe_ingredients (
              *,
              food_items (
                name,
                brand,
                calories_per_100g,
                protein_per_100g,
                carbs_per_100g,
                fat_per_100g
              )
            ),
            recipe_tags (
              tag_name
            )
          ''').eq('id', recipeId).eq('is_public', true).single();

      return response;
    } catch (error) {
      print('Failed to get recipe by ID: $error');
      return null;
    }
  }

  /// Get recipe ingredients
  Future<List<Map<String, dynamic>>> getRecipeIngredients(
    String recipeId,
  ) async {
    try {
      final response = await _client
          .from('recipe_ingredients')
          .select('''
            *,
            food_items (
              name,
              brand,
              calories_per_100g,
              protein_per_100g,
              carbs_per_100g,
              fat_per_100g
            )
          ''')
          .eq('recipe_id', recipeId)
          .order('ingredient_name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Failed to get recipe ingredients: $error');
      return [];
    }
  }

  // Get user's favorite recipes
  Future<List<Map<String, dynamic>>> getFavoriteRecipes(String userId) async {
    try {
      final response = await _client.from('recipe_favorites').select('''
            recipe_id,
            recipes (
              id,
              title,
              description,
              prep_time_minutes,
              cook_time_minutes,
              total_time_minutes,
              servings,
              difficulty,
              category,
              image_url,
              total_calories,
              total_protein_g,
              recipe_tags (
                tag_name
              )
            )
          ''').eq('user_id', userId).order('created_at', ascending: false);

      return response
          .map((item) => item['recipes'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite recipes: $e');
    }
  }

  // Add recipe to favorites
  Future<void> addToFavorites(String recipeId, String userId) async {
    try {
      await _client.from('recipe_favorites').insert({
        'recipe_id': recipeId,
        'user_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to add recipe to favorites: $e');
    }
  }

  // Remove recipe from favorites
  Future<void> removeFromFavorites(String recipeId, String userId) async {
    try {
      await _client
          .from('recipe_favorites')
          .delete()
          .eq('recipe_id', recipeId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to remove recipe from favorites: $e');
    }
  }

  // Check if recipe is favorited by user
  Future<bool> isRecipeFavorited(String recipeId, String userId) async {
    try {
      final response = await _client
          .from('recipe_favorites')
          .select('id')
          .eq('recipe_id', recipeId)
          .eq('user_id', userId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get recipes by category
  Future<List<Map<String, dynamic>>> getRecipesByCategory(
    String category,
  ) async {
    try {
      final response = await _client
          .from('recipes')
          .select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            total_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            total_calories,
            total_protein_g,
            recipe_tags (
              tag_name
            )
          ''')
          .eq('is_public', true)
          .eq('category', category)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Failed to fetch recipes by category: $e');
    }
  }

  // Get recipes by tags
  Future<List<Map<String, dynamic>>> getRecipesByTags(List<String> tags) async {
    try {
      final response = await _client
          .from('recipes')
          .select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            total_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            total_calories,
            total_protein_g,
            recipe_tags!inner (
              tag_name
            )
          ''')
          .eq('is_public', true)
          .inFilter('recipe_tags.tag_name', tags)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Failed to fetch recipes by tags: $e');
    }
  }

  // Get all available tags
  Future<List<String>> getAllTags() async {
    try {
      final response = await _client
          .from('recipe_tags')
          .select('tag_name')
          .order('tag_name');

      final tags =
          response.map((item) => item['tag_name'] as String).toSet().toList();

      return tags;
    } catch (e) {
      throw Exception('Failed to fetch tags: $e');
    }
  }

  // Create a new recipe
  Future<Map<String, dynamic>> createRecipe({
    required String title,
    String? description,
    String? instructions,
    required int prepTimeMinutes,
    int cookTimeMinutes = 0,
    required int servings,
    required String difficulty,
    required String category,
    String? imageUrl,
    required List<Map<String, dynamic>> ingredients,
    List<String>? tags,
    required String userId,
  }) async {
    try {
      // Insert recipe
      final recipeResponse = await _client
          .from('recipes')
          .insert({
            'title': title,
            'description': description,
            'instructions': instructions,
            'prep_time_minutes': prepTimeMinutes,
            'cook_time_minutes': cookTimeMinutes,
            'servings': servings,
            'difficulty': difficulty,
            'category': category,
            'image_url': imageUrl,
            'is_public': false, // User recipes are private by default
            'created_by': userId,
          })
          .select()
          .single();

      final recipeId = recipeResponse['id'];

      // Insert ingredients
      for (final ingredient in ingredients) {
        await _client.from('recipe_ingredients').insert({
          'recipe_id': recipeId,
          'ingredient_name': ingredient['name'],
          'quantity': ingredient['quantity'],
          'unit': ingredient['unit'] ?? 'g',
          'weight_grams': ingredient['weight_grams'] ?? ingredient['quantity'],
          'calories': ingredient['calories'] ?? 0,
          'protein_g': ingredient['protein_g'] ?? 0,
          'carbs_g': ingredient['carbs_g'] ?? 0,
          'fat_g': ingredient['fat_g'] ?? 0,
          'fiber_g': ingredient['fiber_g'] ?? 0,
        });
      }

      // Insert tags
      if (tags != null) {
        for (final tag in tags) {
          await _client.from('recipe_tags').insert({
            'recipe_id': recipeId,
            'tag_name': tag,
          });
        }
      }

      return recipeResponse;
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  // Update recipe
  Future<Map<String, dynamic>> updateRecipe(
    String recipeId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('recipes')
          .update(updates)
          .eq('id', recipeId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _client.from('recipes').delete().eq('id', recipeId);
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  // Search recipes by ingredients
  Future<List<Map<String, dynamic>>> searchRecipesByIngredients(
    List<String> ingredientNames,
  ) async {
    try {
      final response = await _client.from('recipes').select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            total_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            total_calories,
            total_protein_g,
            recipe_ingredients!inner (
              ingredient_name
            ),
            recipe_tags (
              tag_name
            )
          ''')
          .eq('is_public', true)
          .gt('total_calories', 0) // CRITICAL FIX: Exclude invalid recipes with 0 calories
          .order('created_at', ascending: false);

      // Filter recipes that contain any of the specified ingredients
      final filteredRecipes = response.where((recipe) {
        final recipeIngredients = (recipe['recipe_ingredients'] as List)
            .map(
              (ing) => (ing['ingredient_name'] as String).toLowerCase(),
            )
            .toList();

        return ingredientNames.any(
          (ingredientName) => recipeIngredients.any(
            (recipeIng) => recipeIng.contains(ingredientName.toLowerCase()),
          ),
        );
      }).toList();

      return filteredRecipes;
    } catch (e) {
      throw Exception('Failed to search recipes by ingredients: $e');
    }
  }

  // Get recent recipes
  Future<List<Map<String, dynamic>>> getRecentRecipes({int limit = 10}) async {
    try {
      // Use a subquery approach to avoid duplicates from recipe_tags join
      final response = await _client
          .from('recipes')
          .select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            total_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            total_calories,
            total_protein_g
          ''')
          .eq('is_public', true)
          .gt('total_calories', 0) // CRITICAL FIX: Exclude invalid recipes with 0 calories
          .order('created_at', ascending: false)
          .limit(limit);

      // Get unique recipes and then add tags separately to avoid duplicates
      final uniqueRecipes = <String, Map<String, dynamic>>{};

      for (final recipe in response) {
        final recipeId = recipe['id'] as String;
        if (!uniqueRecipes.containsKey(recipeId)) {
          uniqueRecipes[recipeId] = Map<String, dynamic>.from(recipe);
          uniqueRecipes[recipeId]!['recipe_tags'] = <Map<String, dynamic>>[];
        }
      }

      // Fetch tags separately for all unique recipes to avoid duplicates
      if (uniqueRecipes.isNotEmpty) {
        final recipeIds = uniqueRecipes.keys.toList();
        final tagsResponse = await _client
            .from('recipe_tags')
            .select('recipe_id, tag_name')
            .inFilter('recipe_id', recipeIds);

        // Group tags by recipe_id
        for (final tag in tagsResponse) {
          final recipeId = tag['recipe_id'] as String;
          if (uniqueRecipes.containsKey(recipeId)) {
            (uniqueRecipes[recipeId]!['recipe_tags'] as List)
                .add({'tag_name': tag['tag_name']});
          }
        }
      }

      return uniqueRecipes.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch recent recipes: $e');
    }
  }

  // New method: Get Italian recipes specifically
  Future<List<Map<String, dynamic>>> getItalianRecipes({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('recipes')
          .select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            total_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            is_public,
            is_verified,
            created_by,
            created_at,
            total_calories,
            total_protein_g,
            total_carbs_g,
            total_fat_g,
            total_fiber_g,
            total_weight_g,
            calories_per_100g,
            recipe_tags (
              tag_name
            ),
            recipe_ingredients (
              id,
              ingredient_name,
              quantity,
              unit,
              weight_grams,
              calories,
              protein_g,
              carbs_g,
              fat_g,
              fiber_g
            )
          ''')
          .eq('is_public', true)
          .eq('is_verified', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Filter for Italian recipes based on tags
      final italianRecipes = response.where((recipe) {
        final recipeTags = (recipe['recipe_tags'] as List?)
                ?.map((tag) => tag['tag_name'] as String)
                .toList() ??
            [];
        return recipeTags.contains('Italian');
      }).toList();

      return italianRecipes;
    } catch (e) {
      throw Exception('Failed to fetch Italian recipes: $e');
    }
  }

  // New method: Get recipes for meal planning (with full ingredient details)
  Future<List<Map<String, dynamic>>> getRecipesForMeals({
    String? category,
    List<String>? tags,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('recipes').select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            total_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            total_calories,
            total_protein_g,
            total_carbs_g,
            total_fat_g,
            total_fiber_g,
            total_weight_g,
            calories_per_100g,
            recipe_tags (
              tag_name
            ),
            recipe_ingredients (
              ingredient_name,
              quantity,
              unit,
              calories,
              protein_g,
              carbs_g,
              fat_g,
              fiber_g
            )
          ''')
          .eq('is_public', true)
          .eq('is_verified', true)
          .gt('total_calories', 0); // CRITICAL FIX: Exclude invalid recipes with 0 calories

      if (category != null) {
        query = query.eq('category', category);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      // Filter by tags if provided
      var filteredRecipes = response;
      if (tags != null && tags.isNotEmpty) {
        filteredRecipes = filteredRecipes.where((recipe) {
          final recipeTags = (recipe['recipe_tags'] as List?)
                  ?.map((tag) => tag['tag_name'] as String)
                  .toList() ??
              [];
          return tags.any((tag) => recipeTags.contains(tag));
        }).toList();
      }

      return filteredRecipes;
    } catch (e) {
      throw Exception('Failed to fetch recipes for meals: $e');
    }
  }

  // New method: Search recipes by title for meal adding
  Future<List<Map<String, dynamic>>> searchRecipesForMeals(String query) async {
    try {
      // Use a subquery approach to avoid duplicates from recipe_tags join
      final response = await _client
          .from('recipes')
          .select('''
            id,
            title,
            description,
            prep_time_minutes,
            cook_time_minutes,
            servings,
            difficulty,
            category,
            image_url,
            total_calories,
            total_protein_g,
            total_carbs_g,
            total_fat_g,
            total_fiber_g,
            total_weight_g,
            calories_per_100g,
            recipe_ingredients (
              ingredient_name,
              quantity,
              unit,
              calories,
              protein_g,
              carbs_g,
              fat_g,
              fiber_g
            )
          ''')
          .eq('is_public', true)
          .eq('is_verified', true)
          .gt('total_calories', 0) // CRITICAL FIX: Exclude invalid recipes with 0 calories
          .ilike('title', '%$query%')
          .order('title')
          .limit(20);

      // Get unique recipes and then add tags separately to avoid duplicates
      final uniqueRecipes = <String, Map<String, dynamic>>{};

      for (final recipe in response) {
        final recipeId = recipe['id'] as String;
        if (!uniqueRecipes.containsKey(recipeId)) {
          uniqueRecipes[recipeId] = Map<String, dynamic>.from(recipe);
          uniqueRecipes[recipeId]!['recipe_tags'] = <Map<String, dynamic>>[];
        }
      }

      // Fetch tags separately for all unique recipes to avoid duplicates
      if (uniqueRecipes.isNotEmpty) {
        final recipeIds = uniqueRecipes.keys.toList();
        final tagsResponse = await _client
            .from('recipe_tags')
            .select('recipe_id, tag_name')
            .inFilter('recipe_id', recipeIds);

        // Group tags by recipe_id
        for (final tag in tagsResponse) {
          final recipeId = tag['recipe_id'] as String;
          if (uniqueRecipes.containsKey(recipeId)) {
            (uniqueRecipes[recipeId]!['recipe_tags'] as List)
                .add({'tag_name': tag['tag_name']});
          }
        }
      }

      return uniqueRecipes.values.toList();
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }
}