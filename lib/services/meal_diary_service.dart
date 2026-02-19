import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import './supabase_service.dart';

class MealDiaryService {
  static MealDiaryService? _instance;
  static MealDiaryService get instance => _instance ??= MealDiaryService._();
  MealDiaryService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Get current user ID
  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Upload meal image to Supabase storage
  Future<String?> uploadMealImage(XFile imageFile) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$_currentUserId/meals/$fileName';

      Uint8List bytes;
      if (kIsWeb) {
        bytes = await imageFile.readAsBytes();
      } else {
        final file = File(imageFile.path);
        bytes = await file.readAsBytes();
      }

      final response = await _client.storage
          .from('meal-images')
          .uploadBinary(filePath, bytes);

      return filePath; // Return the file path for database storage
    } catch (error) {
      print('Failed to upload meal image: $error');
      throw Exception('Failed to upload image: $error');
    }
  }

  /// Get signed URL for meal image with error handling and caching
  Future<String?> getMealImageUrl(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    try {
      final response = await _client.storage
          .from('meal-images')
          .createSignedUrl(imagePath, 7200); // 2 hours expiry for better UX

      return response;
    } catch (error) {
      print('Failed to get meal image URL for path: $imagePath, error: $error');
      return null;
    }
  }

  /// Delete meal image from storage
  Future<void> deleteMealImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    try {
      await _client.storage.from('meal-images').remove([imagePath]);
    } catch (error) {
      print('Failed to delete meal image: $error');
      // Don't throw error - image deletion failure shouldn't prevent meal deletion
    }
  }

  /// Enhanced getUserMeals with recipe support, fiber data, and Food Ingredients support
  Future<List<Map<String, dynamic>>> getUserMeals({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? specificDate,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      var query = _client
          .from('meal_entries')
          .select('''
            *,
            meal_foods (
              *,
              food_items (
                name,
                brand,
                calories_per_100g,
                protein_per_100g,
                carbs_per_100g,
                fat_per_100g,
                fiber_per_100g
              ),
              recipes (
                title,
                total_calories,
                total_protein_g,
                total_carbs_g,
                total_fat_g,
                total_fiber_g,
                servings
              ),
              "Food Ingredients" (
                "Nome Alimento ITA"
              )
            )
          ''')
          .eq('user_id', _currentUserId!)
          .order('meal_date', ascending: false)
          .order('meal_time', ascending: true);

      // Apply date filters
      if (specificDate != null) {
        final dateString = specificDate.toIso8601String().split('T')[0];
        query = _client
            .from('meal_entries')
            .select('''
              *,
              meal_foods (
                *,
                food_items (
                  name,
                  brand,
                  calories_per_100g,
                  protein_per_100g,
                  carbs_per_100g,
                  fat_per_100g,
                  fiber_per_100g
                ),
                recipes (
                  title,
                  total_calories,
                  total_protein_g,
                  total_carbs_g,
                  total_fat_g,
                  total_fiber_g,
                  servings
                ),
                "Food Ingredients" (
                  "Nome Alimento ITA"
                )
              )
            ''')
            .eq('user_id', _currentUserId!)
            .eq('meal_date', dateString)
            .order('meal_date', ascending: false)
            .order('meal_time', ascending: true);
      } else if (startDate != null && endDate != null) {
        final startString = startDate.toIso8601String().split('T')[0];
        final endString = endDate.toIso8601String().split('T')[0];
        query = _client
            .from('meal_entries')
            .select('''
              *,
              meal_foods (
                *,
                food_items (
                  name,
                  brand,
                  calories_per_100g,
                  protein_per_100g,
                  carbs_per_100g,
                  fat_per_100g,
                  fiber_per_100g
                ),
                recipes (
                  title,
                  total_calories,
                  total_protein_g,
                  total_carbs_g,
                  total_fat_g,
                  total_fiber_g,
                  servings
                ),
                "Food Ingredients" (
                  "Nome Alimento ITA"
                )
              )
            ''')
            .eq('user_id', _currentUserId!)
            .gte('meal_date', startString)
            .lte('meal_date', endString)
            .order('meal_date', ascending: false)
            .order('meal_time', ascending: true);
      }

      final response = await query;

      // Transform database meal data to UI-compatible format with all sources support
      final transformedMeals = <Map<String, dynamic>>[];

      for (var entry in response) {
        final mealFoods = entry['meal_foods'] as List<dynamic>? ?? [];
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        double totalFiber = 0;

        List<String> foodNames = [];

        for (var mealFood in mealFoods) {
          String foodName = 'Unknown food';

          // Handle food items
          final foodItem = mealFood['food_items'] as Map<String, dynamic>?;
          if (foodItem != null) {
            foodName = foodItem['name'] as String? ?? 'Unknown food';
          }

          // Handle recipes
          final recipe = mealFood['recipes'] as Map<String, dynamic>?;
          if (recipe != null) {
            foodName = recipe['title'] as String? ?? 'Unknown recipe';
          }

          // Handle Food Ingredients - now loaded via relation
          if (mealFood['food_ingredient_code'] != null) {
            final foodIngredient = mealFood['Food Ingredients'] as Map<String, dynamic>?;
            if (foodIngredient != null) {
              foodName = foodIngredient['Nome Alimento ITA'] as String? ?? 'Ingrediente';
            } else {
              foodName = 'Ingrediente';
            }
          }

          foodNames.add(foodName);

          totalCalories += (mealFood['calories'] as num? ?? 0).toDouble();
          totalProtein += (mealFood['protein_g'] as num? ?? 0).toDouble();
          totalCarbs += (mealFood['carbs_g'] as num? ?? 0).toDouble();
          totalFat += (mealFood['fat_g'] as num? ?? 0).toDouble();
          totalFiber += (mealFood['fiber_g'] as num? ?? 0).toDouble();
        }

        // Map database meal_type to Italian UI labels
        String mealTypeItalian = _mapMealTypeToItalian(
          entry['meal_type'] ?? 'snack',
        );

        // Format meal time
        String formattedTime = '00:00';
        if (entry['meal_time'] != null) {
          final timeString = entry['meal_time'] as String;
          final timeParts = timeString.split(':');
          if (timeParts.length >= 2) {
            formattedTime = '${timeParts[0]}:${timeParts[1]}';
          }
        }

        // Get image URL if available
        String? imageUrl;
        final imagePath = entry['image_path'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          imageUrl = await getMealImageUrl(imagePath);
        }

        // Create UI-compatible meal object with fiber data
        transformedMeals.add({
          'id': entry['id'],
          'type': mealTypeItalian,
          'time': formattedTime,
          'name':
              foodNames.isNotEmpty ? foodNames.join(', ') : 'Pasto senza cibi',
          'calories': totalCalories.round(),
          'protein': totalProtein.round(),
          'carbs': totalCarbs.round(),
          'fat': totalFat.round(),
          'fiber': totalFiber, // Add fiber data to meal object
          'hasPhoto': imagePath != null && imagePath.isNotEmpty,
          'imageUrl': imageUrl, // Add image URL for display
          'isFavorite': false, // TODO: Implement favorites
          'notes': entry['notes'] ?? '',
          'date': entry['meal_date'],
          // Keep original data for editing
          'original_data': entry,
        });
      }

      return transformedMeals;
    } catch (error) {
      print('Failed to fetch meals: $error');
      return [];
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

  /// Get meals for today
  Future<List<Map<String, dynamic>>> getTodayMeals() async {
    return getUserMeals(specificDate: DateTime.now());
  }

  /// Add a new meal entry with enhanced recipe support and validation
  Future<Map<String, dynamic>> addMealEntry({
    required DateTime mealDate,
    required String mealType, // breakfast, lunch, dinner, snack
    TimeOfDay? mealTime,
    String? notes,
    List<Map<String, dynamic>>? foods,
    XFile? imageFile,
    Map<String, dynamic>? recipeData, // Add recipe data parameter
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print(
        '🔍 Starting meal entry creation with ${foods?.length ?? 0} foods and ${recipeData != null ? '1 recipe' : 'no recipe'}',
      );

      // Critical validation: ensure we have foods to save
      if ((foods == null || foods.isEmpty) && recipeData == null) {
        throw Exception(
          'Cannot create meal entry without foods or recipe data',
        );
      }

      String? imagePath;

      // Upload image if provided
      if (imageFile != null) {
        try {
          imagePath = await uploadMealImage(imageFile);
          print('✅ Image uploaded successfully: $imagePath');
        } catch (imageError) {
          print('⚠️ Warning: Failed to upload image: $imageError');
          // Continue without image rather than failing the entire meal save
          imagePath = null;
        }
      }

      // Format time
      String? timeString;
      if (mealTime != null) {
        timeString = '${mealTime.hour.toString().padLeft(2, '0')}:'
            '${mealTime.minute.toString().padLeft(2, '0')}:00';
      }

      // Create meal entry
      print('🔍 Creating meal entry in database...');
      final mealEntry = await _client
          .from('meal_entries')
          .insert({
            'user_id': _currentUserId,
            'meal_date': mealDate.toIso8601String().split('T')[0],
            'meal_time': timeString,
            'meal_type': mealType,
            'notes': notes,
            'image_path': imagePath,
          })
          .select()
          .single();

      final mealEntryId = mealEntry['id'] as String;
      print('✅ Meal entry created successfully with ID: $mealEntryId');

      int savedFoodsCount = 0;

      // Add foods if provided
      if (foods != null && foods.isNotEmpty) {
        print('🔍 Processing ${foods.length} food items...');
        final validMealFoods = <Map<String, dynamic>>[];

        for (int i = 0; i < foods.length; i++) {
          final food = foods[i];
          print('🔍 Validating food ${i + 1}: ${food['name'] ?? 'Unknown'}');

          // Add meal_entry_id to the food data before validation
          final foodWithMealEntry = Map<String, dynamic>.from(food);
          foodWithMealEntry['meal_entry_id'] = mealEntryId;

          // Validate each food item before adding to database
          if (_validateFoodData(foodWithMealEntry)) {
            final mealFood = {
              'meal_entry_id': mealEntryId,
              'food_item_id': foodWithMealEntry['food_item_id'],
              'food_ingredient_code': foodWithMealEntry['food_ingredient_code'],
              'recipe_id': foodWithMealEntry['recipe_id'],
              'quantity_grams':
                  (foodWithMealEntry['quantity_grams'] as num).toDouble(),
              'calories': (foodWithMealEntry['calories'] as num).toDouble(),
              'protein_g':
                  (foodWithMealEntry['protein_g'] as num?)?.toDouble() ?? 0.0,
              'carbs_g':
                  (foodWithMealEntry['carbs_g'] as num?)?.toDouble() ?? 0.0,
              'fat_g': (foodWithMealEntry['fat_g'] as num?)?.toDouble() ?? 0.0,
              'fiber_g': (foodWithMealEntry['fiber_g'] as num?)?.toDouble() ??
                  0.0, // Add fiber data
            };
            validMealFoods.add(mealFood);
            print('✅ Food ${i + 1} validated and prepared for database');
          } else {
            print(
              '⚠️ Warning: Skipping invalid food data: ${food['name'] ?? 'Unknown'}',
            );
          }
        }

        if (validMealFoods.isNotEmpty) {
          try {
            print(
              '🔍 Inserting ${validMealFoods.length} validated foods into database...',
            );
            await _client.from('meal_foods').insert(validMealFoods);
            savedFoodsCount = validMealFoods.length;
            print(
              '✅ Successfully inserted ${validMealFoods.length} meal foods into database',
            );
          } catch (insertError) {
            print('❌ Error inserting meal foods: $insertError');
            // If there's an error inserting foods, delete the meal entry
            await _client.from('meal_entries').delete().eq('id', mealEntryId);
            throw Exception('Failed to save meal foods: $insertError');
          }
        }
      }

      // Handle direct recipe addition
      if (recipeData != null) {
        print('🔍 Adding recipe to meal entry...');
        await _addRecipeToMealEntry(mealEntryId, recipeData);
        savedFoodsCount += 1;
        print('✅ Recipe added successfully to meal entry');
      }

      // Final validation: ensure we actually saved some foods
      if (savedFoodsCount == 0) {
        // Delete the meal entry since it has no foods
        await _client.from('meal_entries').delete().eq('id', mealEntryId);
        print('❌ No valid foods saved - deleting meal entry');
        throw Exception('No valid foods were saved for this meal entry');
      }

      // Verify the meal entry was created successfully and has foods
      print('🔍 Verifying meal entry and foods were saved...');
      final verificationQuery = await _client.from('meal_entries').select('''
            *,
            meal_foods (count)
          ''').eq('id', mealEntryId).single();

      final mealFoodsCount = verificationQuery['meal_foods'];
      if (mealFoodsCount == null ||
          (mealFoodsCount is List && mealFoodsCount.isEmpty)) {
        print(
          '⚠️ Warning: Meal entry created but no foods found in verification',
        );
      } else {
        print('✅ Verification successful: Meal entry has associated foods');
      }

      print(
        '🎉 MEAL SUCCESSFULLY SAVED TO DATABASE with $savedFoodsCount food items',
      );
      return mealEntry;
    } catch (error) {
      print('❌ Failed to add meal entry: $error');
      throw Exception('Failed to add meal: $error');
    }
  }

  /// Validate food data before database insertion - now includes fiber validation
  bool _validateFoodData(Map<String, dynamic> food) {
    try {
      // Check required fields - Remove meal_entry_id check as it's added later
      if (food['quantity_grams'] == null ||
          (food['quantity_grams'] as num) <= 0) return false;
      if (food['calories'] == null || (food['calories'] as num) < 0)
        return false;

      // Ensure we have exactly one food source: food_item_id, food_ingredient_code, or recipe_id
      final hasFoodItemId = food['food_item_id'] != null;
      final hasFoodIngredientCode = food['food_ingredient_code'] != null;
      final hasRecipeId = food['recipe_id'] != null;

      final sourceCount = [hasFoodItemId, hasFoodIngredientCode, hasRecipeId]
          .where((hasSource) => hasSource)
          .length;

      if (sourceCount == 0) {
        print('Food data missing food source (food_item_id, food_ingredient_code, or recipe_id)');
        return false;
      }

      if (sourceCount > 1) {
        print(
          'Food data has multiple food sources - should only have one',
        );
        return false;
      }

      // Validate numeric ranges including fiber
      final calories = (food['calories'] as num).toDouble();
      final quantity = (food['quantity_grams'] as num).toDouble();
      final protein = (food['protein_g'] as num?)?.toDouble() ?? 0.0;
      final carbs = (food['carbs_g'] as num?)?.toDouble() ?? 0.0;
      final fat = (food['fat_g'] as num?)?.toDouble() ?? 0.0;
      final fiber = (food['fiber_g'] as num?)?.toDouble() ?? 0.0;

      if (calories > 50000 ||
          quantity > 10000 ||
          protein > 1000 ||
          carbs > 1000 ||
          fat > 1000 ||
          fiber > 1000) {
        print('Food data has values outside acceptable ranges');
        return false;
      }

      if (calories < 0 ||
          quantity < 0.1 ||
          protein < 0 ||
          carbs < 0 ||
          fat < 0 ||
          fiber < 0) {
        print('Food data has negative values');
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating food data: $e');
      return false;
    }
  }

  /// Add a recipe directly to an existing meal entry - now includes fiber calculation
  Future<void> _addRecipeToMealEntry(
    String mealEntryId,
    Map<String, dynamic> recipeData,
  ) async {
    try {
      // Calculate nutritional values per serving including fiber
      final servings = (recipeData['servings'] as num?)?.toInt() ?? 1;
      final totalCalories =
          (recipeData['total_calories'] as num?)?.toDouble() ?? 0.0;
      final totalProtein =
          (recipeData['total_protein_g'] as num?)?.toDouble() ?? 0.0;
      final totalCarbs =
          (recipeData['total_carbs_g'] as num?)?.toDouble() ?? 0.0;
      final totalFat = (recipeData['total_fat_g'] as num?)?.toDouble() ?? 0.0;
      final totalFiber =
          (recipeData['total_fiber_g'] as num?)?.toDouble() ?? 0.0; // Add fiber

      // Calculate per serving values
      final caloriesPerServing =
          servings > 0 ? totalCalories / servings : totalCalories;
      final proteinPerServing =
          servings > 0 ? totalProtein / servings : totalProtein;
      final carbsPerServing = servings > 0 ? totalCarbs / servings : totalCarbs;
      final fatPerServing = servings > 0 ? totalFat / servings : totalFat;
      final fiberPerServing = servings > 0
          ? totalFiber / servings
          : totalFiber; // Calculate fiber per serving

      // Estimate weight per serving (250g is a reasonable average serving size)
      final weightPerServing = 250.0;

      // Create meal_food entry for the recipe including fiber
      await _client.from('meal_foods').insert({
        'meal_entry_id': mealEntryId,
        'recipe_id': recipeData['id'],
        'food_item_id': null, // Recipe entries don't have food_item_id
        'quantity_grams': weightPerServing,
        'calories': caloriesPerServing,
        'protein_g': proteinPerServing,
        'carbs_g': carbsPerServing,
        'fat_g': fatPerServing,
        'fiber_g': fiberPerServing, // Add fiber to database insert
      });
    } catch (error) {
      throw Exception('Failed to add recipe to meal entry: $error');
    }
  }

  /// Add a recipe directly to the meal diary
  Future<Map<String, dynamic>> addRecipeToMealDiary({
    required Map<String, dynamic> recipeData,
    required String mealType,
    DateTime? mealDate,
    TimeOfDay? mealTime,
    String? notes,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Use current date/time if not provided
      final date = mealDate ?? DateTime.now();
      final time = mealTime ?? TimeOfDay.now();

      // Create meal entry directly
      return await addMealEntry(
        mealDate: date,
        mealType: mealType,
        mealTime: time,
        notes: notes,
        recipeData: recipeData,
      );
    } catch (error) {
      throw Exception('Failed to add recipe to diary: $error');
    }
  }

  /// Update an existing meal entry
  Future<Map<String, dynamic>> updateMealEntry({
    required String mealEntryId,
    DateTime? mealDate,
    String? mealType,
    TimeOfDay? mealTime,
    String? notes,
    XFile? imageFile,
    bool? removeImage,
  }) async {
    try {
      // Get existing meal entry to check for current image
      final existingMeal = await _client
          .from('meal_entries')
          .select('image_path')
          .eq('id', mealEntryId)
          .eq('user_id', _currentUserId!)
          .single();

      final currentImagePath = existingMeal['image_path'] as String?;

      final updates = <String, dynamic>{};

      if (mealDate != null) {
        updates['meal_date'] = mealDate.toIso8601String().split('T')[0];
      }

      if (mealType != null) {
        updates['meal_type'] = mealType;
      }

      if (mealTime != null) {
        updates['meal_time'] = '${mealTime.hour.toString().padLeft(2, '0')}:'
            '${mealTime.minute.toString().padLeft(2, '0')}:00';
      }

      if (notes != null) {
        updates['notes'] = notes;
      }

      // Handle image updates
      if (removeImage == true) {
        // Remove existing image
        if (currentImagePath != null) {
          await deleteMealImage(currentImagePath);
        }
        updates['image_path'] = null;
      } else if (imageFile != null) {
        // Delete old image if exists
        if (currentImagePath != null) {
          await deleteMealImage(currentImagePath);
        }
        // Upload new image
        final newImagePath = await uploadMealImage(imageFile);
        updates['image_path'] = newImagePath;
      }

      final response = await _client
          .from('meal_entries')
          .update(updates)
          .eq('id', mealEntryId)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update meal: $error');
    }
  }

  /// Delete a meal entry
  Future<void> deleteMealEntry(String mealEntryId) async {
    try {
      // Get meal entry to check for image
      final mealEntry = await _client
          .from('meal_entries')
          .select('image_path')
          .eq('id', mealEntryId)
          .eq('user_id', _currentUserId!)
          .single();

      final imagePath = mealEntry['image_path'] as String?;

      // Delete meal foods first (due to foreign key constraint)
      await _client
          .from('meal_foods')
          .delete()
          .eq('meal_entry_id', mealEntryId);

      // Then delete the meal entry
      await _client
          .from('meal_entries')
          .delete()
          .eq('id', mealEntryId)
          .eq('user_id', _currentUserId!);

      // Delete associated image if exists
      if (imagePath != null) {
        await deleteMealImage(imagePath);
      }
    } catch (error) {
      throw Exception('Failed to delete meal: $error');
    }
  }

  /// Get nutritional summary for date range with enhanced custom range support including fiber
  Future<Map<String, dynamic>> getNutritionalSummary({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? specificDate,
  }) async {
    if (_currentUserId == null) {
      return {
        'total_calories': 0.0,
        'total_protein': 0.0,
        'total_carbs': 0.0,
        'total_fat': 0.0,
        'total_fiber': 0.0, // Add fiber to return
        'meal_count': 0,
        'avg_calories_per_day': 0.0,
        'date_range_days': 0,
      };
    }

    try {
      // Build date filter with enhanced validation
      var query = _client.from('meal_entries').select('''
            meal_date,
            meal_foods (
              calories,
              protein_g,
              carbs_g,
              fat_g,
              fiber_g
            )
          ''').eq('user_id', _currentUserId!);

      DateTime? actualStartDate;
      DateTime? actualEndDate;

      if (specificDate != null) {
        final dateString = specificDate.toIso8601String().split('T')[0];
        query = query.eq('meal_date', dateString);
        actualStartDate = specificDate;
        actualEndDate = specificDate;
      } else if (startDate != null && endDate != null) {
        // Ensure dates are in correct format and order
        actualStartDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        actualEndDate = DateTime(endDate.year, endDate.month, endDate.day);

        // Swap dates if they're in wrong order
        if (actualEndDate.isBefore(actualStartDate)) {
          final temp = actualStartDate;
          actualStartDate = actualEndDate;
          actualEndDate = temp;
        }

        final startString = actualStartDate.toIso8601String().split('T')[0];
        final endString = actualEndDate.toIso8601String().split('T')[0];
        query = query.gte('meal_date', startString).lte('meal_date', endString);
      }

      final response = await query;

      // Calculate totals with enhanced metrics including fiber
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0; // Add fiber tracking
      int mealCount = 0;
      int totalDays = 0;

      final uniqueDates = <String>{};

      for (var entry in response) {
        final mealFoods = entry['meal_foods'] as List;
        final mealDate = entry['meal_date'] as String;
        uniqueDates.add(mealDate);

        for (var food in mealFoods) {
          totalCalories += (food['calories'] ?? 0).toDouble();
          totalProtein += (food['protein_g'] ?? 0).toDouble();
          totalCarbs += (food['carbs_g'] ?? 0).toDouble();
          totalFat += (food['fat_g'] ?? 0).toDouble();
          totalFiber +=
              (food['fiber_g'] ?? 0).toDouble(); // Add fiber calculation
          mealCount++;
        }
      }

      totalDays = uniqueDates.length;

      // Calculate date range length for custom ranges
      int dateRangeDays = 0;
      if (actualStartDate != null && actualEndDate != null) {
        dateRangeDays = actualEndDate.difference(actualStartDate).inDays + 1;
      }

      return {
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'total_fiber': totalFiber, // Include fiber in return values
        'meal_count': mealCount,
        'avg_calories_per_day': totalDays > 0 ? totalCalories / totalDays : 0.0,
        'date_range_days': dateRangeDays,
        'unique_days_with_data': totalDays,
      };
    } catch (error) {
      print('Failed to get nutritional summary: $error');
      return {
        'total_calories': 0.0,
        'total_protein': 0.0,
        'total_carbs': 0.0,
        'total_fat': 0.0,
        'total_fiber': 0.0, // Include fiber in error return
        'meal_count': 0,
        'avg_calories_per_day': 0.0,
        'date_range_days': 0,
        'unique_days_with_data': 0,
      };
    }
  }

  /// Get meal statistics for reports with enhanced custom range support
  Future<Map<String, dynamic>> getMealStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_currentUserId == null) {
      return {
        'meal_type_distribution': <String, int>{},
        'daily_meal_counts': <String, int>{},
        'total_meals': 0,
        'average_meals_per_day': 0.0,
        'most_active_day': null,
        'least_active_day': null,
      };
    }

    try {
      var query = _client
          .from('meal_entries')
          .select('meal_type, meal_date')
          .eq('user_id', _currentUserId!);

      if (startDate != null && endDate != null) {
        // Ensure proper date formatting and ordering
        final actualStartDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final actualEndDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
        );

        final startString = actualStartDate.toIso8601String().split('T')[0];
        final endString = actualEndDate.toIso8601String().split('T')[0];
        query = query.gte('meal_date', startString).lte('meal_date', endString);
      }

      final response = await query;

      // Count meal types and daily meals with enhanced analytics
      final mealTypeCount = <String, int>{};
      final dailyMealCount = <String, int>{};

      for (var entry in response) {
        final mealType = entry['meal_type'] as String;
        final mealDate = entry['meal_date'] as String;

        mealTypeCount[mealType] = (mealTypeCount[mealType] ?? 0) + 1;
        dailyMealCount[mealDate] = (dailyMealCount[mealDate] ?? 0) + 1;
      }

      // Find most and least active days
      String? mostActiveDay;
      String? leastActiveDay;
      int maxMeals = 0;
      int minMeals = 999999;

      for (var entry in dailyMealCount.entries) {
        if (entry.value > maxMeals) {
          maxMeals = entry.value;
          mostActiveDay = entry.key;
        }
        if (entry.value < minMeals) {
          minMeals = entry.value;
          leastActiveDay = entry.key;
        }
      }

      return {
        'meal_type_distribution': mealTypeCount,
        'daily_meal_counts': dailyMealCount,
        'total_meals': response.length,
        'average_meals_per_day': dailyMealCount.isEmpty
            ? 0.0
            : dailyMealCount.values.reduce((a, b) => a + b) /
                dailyMealCount.length,
        'most_active_day': mostActiveDay,
        'least_active_day': leastActiveDay,
        'max_meals_per_day': maxMeals,
        'min_meals_per_day': dailyMealCount.isNotEmpty ? minMeals : 0,
      };
    } catch (error) {
      print('Failed to get meal statistics: $error');
      return {
        'meal_type_distribution': <String, int>{},
        'daily_meal_counts': <String, int>{},
        'total_meals': 0,
        'average_meals_per_day': 0.0,
        'most_active_day': null,
        'least_active_day': null,
        'max_meals_per_day': 0,
        'min_meals_per_day': 0,
      };
    }
  }

  /// Get available food items for meal planning
  Future<List<Map<String, dynamic>>> getAvailableFoodItems({
    String? searchQuery,
    int? limit = 50,
  }) async {
    try {
      var query = _client
          .from('food_items')
          .select('*')
          .eq('is_verified', true)
          .order('name', ascending: true);

      if (limit != null) {
        query = query.limit(limit * 2); // Fetch more for client-side filtering
      }

      final response = await query;
      List<Map<String, dynamic>> foodItems = List<Map<String, dynamic>>.from(
        response,
      );

      // Implement client-side search filtering
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final searchTerm = searchQuery.trim().toLowerCase();
        foodItems = foodItems.where((item) {
          final name = (item['name'] as String?)?.toLowerCase() ?? '';
          final brand = (item['brand'] as String?)?.toLowerCase() ?? '';
          return name.contains(searchTerm) || brand.contains(searchTerm);
        }).toList();
      }

      // Apply final limit after filtering
      if (limit != null && foodItems.length > limit) {
        foodItems = foodItems.take(limit).toList();
      }

      return foodItems;
    } catch (error) {
      print('Failed to get food items: $error');
      return [];
    }
  }

  /// Check if user has any meals (for empty state)
  Future<bool> hasUserMeals() async {
    if (_currentUserId == null) return false;

    try {
      final response = await _client
          .from('meal_entries')
          .select('id')
          .eq('user_id', _currentUserId!)
          .limit(1);

      return response.isNotEmpty;
    } catch (error) {
      print('Failed to check user meals: $error');
      return false;
    }
  }

  /// Update meal food quantity and recalculate nutrition
  Future<void> updateMealFoodQuantity({
    required String mealFoodId,
    required double newQuantityGrams,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // First get the meal food with its food item or recipe data
      final mealFoodResponse = await _client.from('meal_foods').select('''
            *,
            food_items (
              calories_per_100g,
              protein_per_100g,
              carbs_per_100g,
              fat_per_100g,
              fiber_per_100g
            ),
            recipes (
              total_calories,
              total_protein_g,
              total_carbs_g,
              total_fat_g,
              total_fiber_g,
              total_weight_g,
              calories_per_100g,
              servings
            ),
            meal_entries!inner (user_id)
          ''').eq('id', mealFoodId).single();

      // Verify user owns this meal food
      final mealEntry = mealFoodResponse['meal_entries'];
      if (mealEntry['user_id'] != _currentUserId) {
        throw Exception('Unauthorized access to meal food');
      }

      // Calculate new nutritional values including fiber
      double newCalories = 0.0;
      double newProtein = 0.0;
      double newCarbs = 0.0;
      double newFat = 0.0;
      double newFiber = 0.0; // Add fiber calculation

      final multiplier = newQuantityGrams / 100.0;

      if (mealFoodResponse['food_items'] != null) {
        // Handle food item
        final foodItem = mealFoodResponse['food_items'];
        newCalories = (foodItem['calories_per_100g'] as int) * multiplier;
        newProtein = ((foodItem['protein_per_100g'] as num) ?? 0).toDouble() *
            multiplier;
        newCarbs =
            ((foodItem['carbs_per_100g'] as num) ?? 0).toDouble() * multiplier;
        newFat =
            ((foodItem['fat_per_100g'] as num) ?? 0).toDouble() * multiplier;
        newFiber = ((foodItem['fiber_per_100g'] as num) ?? 0).toDouble() *
            multiplier; // Calculate new fiber
      } else if (mealFoodResponse['recipes'] != null) {
        // Handle recipe
        final recipe = mealFoodResponse['recipes'];
        final servings =
            (recipe['servings'] as int) > 0 ? (recipe['servings'] as int) : 1;

        // Use total_weight_g from DB if available, otherwise fallback to estimate
        final dbTotalWeight = ((recipe['total_weight_g'] as num?) ?? 0).toDouble();
        final totalWeight = dbTotalWeight > 0
            ? dbTotalWeight
            : (250.0 * servings); // Fallback for recipes without weight data

        final dbCaloriesPer100g = (recipe['calories_per_100g'] as int?) ?? 0;
        final caloriesPer100g = dbCaloriesPer100g > 0
            ? dbCaloriesPer100g.toDouble()
            : ((recipe['total_calories'] as int) / totalWeight) * 100;
        final proteinPer100g =
            ((recipe['total_protein_g'] as num) / totalWeight) * 100;
        final carbsPer100g =
            ((recipe['total_carbs_g'] as num) / totalWeight) * 100;
        final fatPer100g = ((recipe['total_fat_g'] as num) / totalWeight) * 100;
        final fiberPer100g = ((recipe['total_fiber_g'] as num) / totalWeight) *
            100; // Calculate fiber per 100g

        newCalories = caloriesPer100g * multiplier;
        newProtein = proteinPer100g * multiplier;
        newCarbs = carbsPer100g * multiplier;
        newFat = fatPer100g * multiplier;
        newFiber = fiberPer100g * multiplier; // Calculate new fiber for recipe
      }

      // Update meal food with new values including fiber
      await _client.from('meal_foods').update({
        'quantity_grams': newQuantityGrams,
        'calories': newCalories,
        'protein_g': newProtein,
        'carbs_g': newCarbs,
        'fat_g': newFat,
        'fiber_g': newFiber, // Update fiber in database
      }).eq('id', mealFoodId);

      print('✅ Successfully updated meal food quantity and nutrition');
    } catch (error) {
      print('❌ Failed to update meal food: $error');
      throw Exception('Failed to update meal food: $error');
    }
  }

  /// Update multiple meal foods for a meal entry
  Future<void> updateMealFoods({
    required String mealEntryId,
    required List<Map<String, dynamic>> updatedFoods,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Verify user owns this meal entry
      final mealEntry = await _client
          .from('meal_entries')
          .select('user_id')
          .eq('id', mealEntryId)
          .eq('user_id', _currentUserId!)
          .single();

      // Update each meal food
      for (final foodUpdate in updatedFoods) {
        final mealFoodId = foodUpdate['id'] as String;
        final newQuantity = (foodUpdate['quantity_grams'] as num).toDouble();

        await updateMealFoodQuantity(
          mealFoodId: mealFoodId,
          newQuantityGrams: newQuantity,
        );
      }

      print('✅ Successfully updated all meal foods for entry: $mealEntryId');
    } catch (error) {
      print('❌ Failed to update meal foods: $error');
      throw Exception('Failed to update meal foods: $error');
    }
  }

  /// Get detailed meal data for editing
  Future<Map<String, dynamic>> getMealForEditing(String mealEntryId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _client.from('meal_entries').select('''
            *,
            meal_foods (
              *,
              food_items (
                name,
                brand,
                calories_per_100g,
                protein_per_100g,
                carbs_per_100g,
                fat_per_100g,
                fiber_per_100g
              ),
              recipes (
                title,
                total_calories,
                total_protein_g,
                total_carbs_g,
                total_fat_g,
                total_fiber_g,
                servings
              ),
              "Food Ingredients" (
                "Nome Alimento ITA",
                "Energia, Ric con fibra (kcal)",
                "Proteine totali",
                "Carboidrati disponibili (MSE)",
                "Lipidi totali",
                "Fibra alimentare totale"
              )
            )
          ''').eq('id', mealEntryId).eq('user_id', _currentUserId!).single();

      return response;
    } catch (error) {
      print('Failed to fetch meal for editing: $error');
      throw Exception('Failed to fetch meal for editing: $error');
    }
  }

  /// Add food to a meal (supports food_items, Food Ingredients, and recipes)
  Future<void> addFoodToMeal({
    required String mealEntryId,
    String? foodItemId,
    String? foodIngredientCode,
    String? recipeId,
    required double quantityGrams,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    double? fiberG,
  }) async {
    try {
      // Ensure at least one food source is provided
      if (foodItemId == null &&
          foodIngredientCode == null &&
          recipeId == null) {
        throw Exception(
          'Must provide either foodItemId, foodIngredientCode, or recipeId',
        );
      }

      // Ensure only one food source is provided
      final sourceCount = [
        foodItemId,
        foodIngredientCode,
        recipeId,
      ].where((id) => id != null).length;
      if (sourceCount != 1) {
        throw Exception(
          'Must provide exactly one food source (foodItemId, foodIngredientCode, or recipeId)',
        );
      }

      final mealFoodData = {
        'meal_entry_id': mealEntryId,
        'food_item_id': foodItemId,
        'food_ingredient_code': foodIngredientCode,
        'recipe_id': recipeId,
        'quantity_grams': quantityGrams,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG ?? 0.0,
      };

      await _client.from('meal_foods').insert(mealFoodData);
    } catch (e) {
      print('Error adding food to meal: $e');
      rethrow;
    }
  }

  /// Get meal foods with details from all sources
  Future<List<Map<String, dynamic>>> getMealFoodsWithDetails(
    String mealEntryId,
  ) async {
    try {
      final response = await _client
          .from('meal_foods')
          .select('''
            id,
            meal_entry_id,
            food_item_id,
            food_ingredient_code,
            recipe_id,
            quantity_grams,
            calories,
            protein_g,
            carbs_g,
            fat_g,
            fiber_g,
            created_at,
            food_items!inner(
              id,
              name,
              italian_name,
              calories_per_100g,
              protein_per_100g,
              carbs_per_100g,
              fat_per_100g,
              fiber_per_100g
            ),
            recipes(
              id,
              title,
              total_calories,
              total_protein_g,
              total_carbs_g,
              total_fat_g,
              total_fiber_g,
              servings
            )
          ''')
          .eq('meal_entry_id', mealEntryId)
          .order('created_at', ascending: true);

      final mealFoods = response as List<dynamic>;
      final enrichedFoods = <Map<String, dynamic>>[];

      for (final mealFood in mealFoods) {
        final foodData = Map<String, dynamic>.from(mealFood);

        // Handle Food Ingredients separately if food_ingredient_code exists
        if (foodData['food_ingredient_code'] != null) {
          final ingredientCode = foodData['food_ingredient_code'] as String;

          // Fetch from Food Ingredients table
          final ingredientResponse =
              await _client.from('Food Ingredients').select('''
                "Codice Alimento",
                "Nome Alimento ITA",
                "Energia, Ric con fibra (kcal)",
                "Proteine totali",
                "Lipidi totali",
                "Carboidrati disponibili (MSE)",
                "Fibra alimentare totale"
              ''').eq('Codice Alimento', ingredientCode).single();

          foodData['food_ingredient'] = ingredientResponse;
          foodData['source_type'] = 'food_ingredient';
          foodData['display_name'] =
              ingredientResponse['Nome Alimento ITA'] ?? 'Ingredient';
        } else if (foodData['food_items'] != null) {
          foodData['source_type'] = 'food_item';
          final foodItem = foodData['food_items'] as Map<String, dynamic>;
          foodData['display_name'] =
              foodItem['italian_name'] ?? foodItem['name'] ?? 'Food Item';
        } else if (foodData['recipes'] != null) {
          foodData['source_type'] = 'recipe';
          final recipe = foodData['recipes'] as Map<String, dynamic>;
          foodData['display_name'] = recipe['title'] ?? 'Recipe';
        }

        enrichedFoods.add(foodData);
      }

      return enrichedFoods;
    } catch (e) {
      print('Error getting meal foods with details: $e');
      return [];
    }
  }
}
