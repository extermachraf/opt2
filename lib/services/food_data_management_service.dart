import 'package:supabase_flutter/supabase_flutter.dart';

class FoodDataManagementService {
  static final FoodDataManagementService _instance =
      FoodDataManagementService._internal();
  factory FoodDataManagementService() => _instance;
  FoodDataManagementService._internal();

  static FoodDataManagementService get instance => _instance;

  // Cross-check foods against existing database
  Future<Map<String, dynamic>> crossCheckFoods(
    List<Map<String, dynamic>> foodList,
  ) async {
    try {
      final existingFoods = <String>[];
      final missingFoods = <Map<String, dynamic>>[];
      final errors = <String>[];

      // Get all existing food names from database with proper column name quoting
      final existingFoodNamesResponse = await Supabase.instance.client
          .from('Food Ingredients')
          .select('"Nome Alimento ITA", "Codice Alimento"');

      final existingFoodNamesSet = <String>{};
      for (final item in existingFoodNamesResponse) {
        final foodName =
            item['Nome Alimento ITA']?.toString().trim().toLowerCase();
        if (foodName != null && foodName.isNotEmpty) {
          existingFoodNamesSet.add(foodName);
        }
      }

      // Process each food in the user's list
      for (int index = 0; index < foodList.length; index++) {
        try {
          final food = foodList[index];

          final foodName = food['food_name']?.toString().trim();
          final nameIta = food['name_it']?.toString().trim();

          // Skip if this is just a header row with null values
          if (foodName == null ||
              foodName.isEmpty ||
              foodName == 'Food Name ITA') {
            continue;
          }

          // Use Italian name if available, otherwise use food_name
          final searchName =
              (nameIta != null && nameIta.isNotEmpty) ? nameIta : foodName;

          if (existingFoodNamesSet.contains(searchName.toLowerCase())) {
            existingFoods.add(searchName);
          } else {
            // Clean and validate the food data
            final cleanedFood = _cleanFoodData(food, index);
            if (cleanedFood != null) {
              missingFoods.add(cleanedFood);
            }
          }
        } catch (e) {
          final errorMsg =
              'Error processing food at index $index: ${e.toString()}';
          errors.add(errorMsg);
          print(errorMsg); // Also log for debugging
        }
      }

      return {
        'existing_count': existingFoods.length,
        'missing_count': missingFoods.length,
        'existing_foods': existingFoods,
        'missing_foods': missingFoods,
        'errors': errors,
        'total_processed': existingFoods.length + missingFoods.length,
      };
    } catch (e) {
      final errorMsg = 'Failed to cross-check foods: ${e.toString()}';
      print(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // Add missing foods to database in batches
  Future<Map<String, dynamic>> addMissingFoodsToDatabase(
    List<Map<String, dynamic>> missingFoods,
  ) async {
    try {
      if (missingFoods.isEmpty) {
        return {
          'success_count': 0,
          'error_count': 0,
          'total_batches': 0,
          'errors': <String>[],
        };
      }

      final batchSize = 50; // Process in batches of 50
      final totalBatches = (missingFoods.length / batchSize).ceil();
      var successCount = 0;
      var errorCount = 0;
      final errors = <String>[];

      for (int batchIndex = 0; batchIndex < totalBatches; batchIndex++) {
        final start = batchIndex * batchSize;
        final end = (start + batchSize < missingFoods.length)
            ? start + batchSize
            : missingFoods.length;

        final batch = missingFoods.sublist(start, end);

        try {
          // Insert batch to database - FIXED: Remove quotes from table name
          final response = await Supabase.instance.client
              .from('Food Ingredients')
              .insert(batch);

          // Check if response is null or has error
          if (response != null && response.hasError) {
            throw Exception(
                'Database insert error: ${response.error?.message}');
          }

          successCount += batch.length;
          print(
            'Successfully inserted batch ${batchIndex + 1}/$totalBatches (${batch.length} items)',
          );
        } catch (e) {
          errorCount += batch.length;
          final errorMsg = 'Batch ${batchIndex + 1} failed: ${e.toString()}';
          errors.add(errorMsg);
          print('Failed to insert batch ${batchIndex + 1}: ${e.toString()}');
        }
      }

      return {
        'success_count': successCount,
        'error_count': errorCount,
        'total_batches': totalBatches,
        'errors': errors,
      };
    } catch (e) {
      final errorMsg = 'Failed to add foods to database: ${e.toString()}';
      print(errorMsg);
      throw Exception(errorMsg);
    }
  }

  // Clean and validate food data for database insertion
  Map<String, dynamic>? _cleanFoodData(
    Map<String, dynamic> rawFood,
    int index,
  ) {
    try {
      final foodName = rawFood['food_name']?.toString().trim();
      final nameIta = rawFood['name_it']?.toString().trim();
      final foodCode = rawFood['food_code']?.toString().trim();

      // Skip if essential fields are missing
      if ((foodName == null || foodName.isEmpty) &&
          (nameIta == null || nameIta.isEmpty)) {
        return null;
      }

      // Use Italian name as primary, fall back to food_name
      final primaryName =
          (nameIta != null && nameIta.isNotEmpty) ? nameIta : foodName;

      if (primaryName == null || primaryName.isEmpty) {
        return null;
      }

      // Generate food code if missing
      final generatedCode = foodCode?.isNotEmpty == true
          ? foodCode
          : 'USER_${DateTime.now().millisecondsSinceEpoch}_$index';

      return {
        // Primary keys
        'Codice Alimento': generatedCode,
        'Nome Alimento ITA': primaryName,
        'Nome Alimento ENG': rawFood['name_en']?.toString().trim() ?? '',
        'Nome Scientifico': rawFood['scientific_name']?.toString() ?? '',
        'Simbolo': generatedCode,

        // Basic nutritional data
        'Energia, Ric con fibra (kcal)': _parseNutrientValue(
          rawFood['Energia_Ric_con_fibra_(kcal)'],
        ),
        'Energia_1, Ric con fibra (kJ)': _parseNutrientValue(
          rawFood['Energia_Ric_con_fibra_(kJ)'],
        ),
        'Proteine totali': _parseNutrientValue(rawFood['Proteine_totali']),
        'Proteine animali': _parseNutrientValue(rawFood['Proteine_animali']),
        'Proteine vegetali': _parseNutrientValue(rawFood['Proteine_vegetali']),
        'Lipidi totali': _parseNutrientValue(rawFood['Lipidi_totali']),
        'Carboidrati disponibili (MSE)': _parseNutrientValue(
          rawFood['Carboidrati_disponibili_(MSE)'],
        ),
        'Carboidrati solubili (MSE)': _parseNutrientValue(
          rawFood['Carboidrati_solubili_(MSE)'],
        ),
        'Fibra alimentare totale': _parseNutrientValue(
          rawFood['Fibra_alimentare_totale'],
        ),
        'Colesterolo': _parseNutrientValue(rawFood['Colesterolo']),
        'Alcol': _parseNutrientValue(rawFood['Alcol']),
        'Acqua': _parseNutrientValue(rawFood['Acqua']),

        // Minerals
        'Ferro': _parseNutrientValue(rawFood['Ferro']),
        'Calcio': _parseNutrientValue(rawFood['Calcio']),
        'Potassio': _parseNutrientValue(rawFood['Potassio']),
        'Zinco': _parseNutrientValue(rawFood['Zinco']),
        'Magnesio': _parseNutrientValue(rawFood['Magnesio']),
        'Fosforo': _parseNutrientValue(rawFood['Fosforo']),
        'Sodio': _parseNutrientValue(rawFood['Sodio']),

        // Vitamins
        'Vitamina B1, Tiamina': _parseNutrientValue(
          rawFood['Vitamina_B1_Tiamina'],
        ),
        'Vitamina B2, Riboflavina': _parseNutrientValue(
          rawFood['Vitamina_B2_Riboflavina'],
        ),
        'Vitamina C': _parseNutrientValue(rawFood['Vitamina_C']),
        'Vitamina B6': _parseNutrientValue(rawFood['Vitamina_B6']),
        'Vitamina B12': _parseNutrientValue(rawFood['Vitamina_B12']),
        'Vitamina E (ATE)': _parseNutrientValue(rawFood['Vitamina_E_(ATE)']),
        'Vitamina D': _parseNutrientValue(rawFood['Vitamina_D']),
        'Vitamina K': _parseNutrientValue(rawFood['Vitamina_K']),

        // Fatty acids
        'Acidi grassi saturi totali': _parseNutrientValue(
          rawFood['Acidi_grassi_saturi_totali'],
        ),
        'Acidi grassi monoinsaturi totali': _parseNutrientValue(
          rawFood['Acidi_grassi_monoinsaturi_totali'],
        ),
        'Acidi grassi polinsaturi totali': _parseNutrientValue(
          rawFood['Acidi_grassi_polinsaturi_totali'],
        ),
        'Altri acidi grassi polinsaturi': _parseNutrientValue(
          rawFood['Altri_acidi_grassi_polinsaturi'],
        ),

        // Category
        'Categoria Merceologica': _parseNutrientValue(rawFood['category']),

        // Edible portion
        'parte edibile': rawFood['edible_portion']?.toString() ?? '100',
      };
    } catch (e) {
      print('Error cleaning food data at index $index: ${e.toString()}');
      return null;
    }
  }

  // Parse nutrient values, handling special cases like NaN, -3, -2, etc.
  dynamic _parseNutrientValue(dynamic value) {
    try {
      if (value == null) return null;

      final stringValue = value.toString().trim();

      if (stringValue.toLowerCase() == 'nan' || stringValue.isEmpty)
        return null;

      // Handle special database codes
      if (stringValue == '-3' ||
          stringValue == '-2' ||
          stringValue.toLowerCase() == 'tr' ||
          stringValue == 'n.d.' ||
          stringValue == '-') {
        return null;
      }

      // Try to parse as number
      final numValue = double.tryParse(stringValue);
      if (numValue != null) {
        // Return as integer if it's a whole number, otherwise double
        return numValue == numValue.toInt() ? numValue.toInt() : numValue;
      }

      // Return as string for text values
      return stringValue;
    } catch (e) {
      print('Error parsing nutrient value: $value - ${e.toString()}');
      return null;
    }
  }

  // Validate that foods were added successfully
  Future<bool> validateFoodsInDatabase(List<String> foodNames) async {
    try {
      if (foodNames.isEmpty) return true;

      // Use proper column name quoting for spaces
      final response = await Supabase.instance.client
          .from('Food Ingredients')
          .select('"Nome Alimento ITA"')
          .inFilter('Nome Alimento ITA', foodNames);

      return response.length == foodNames.length;
    } catch (e) {
      print('Error validating foods in database: ${e.toString()}');
      return false;
    }
  }

  // Get statistics about the Food Ingredients database
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      // Count total foods in database
      final totalCountResponse =
          await Supabase.instance.client.from('Food Ingredients').select('*');

      // Get sample foods with proper column name handling
      final sampleFoodsResponse = await Supabase.instance.client
          .from('Food Ingredients')
          .select('"Nome Alimento ITA", "Categoria Merceologica"')
          .limit(10);

      final sampleFoods = sampleFoodsResponse != null
          ? sampleFoodsResponse
              .where((item) => item['Nome Alimento ITA'] != null)
              .map((item) => item['Nome Alimento ITA'].toString())
              .toList()
          : <String>[];

      return {
        'total_foods': totalCountResponse.length,
        'sample_foods': sampleFoods,
        'database_status': 'connected',
      };
    } catch (e) {
      print('Error getting database stats: ${e.toString()}');
      return {
        'total_foods': 0,
        'sample_foods': <String>[],
        'database_status': 'error',
        'error': e.toString(),
      };
    }
  }
}
