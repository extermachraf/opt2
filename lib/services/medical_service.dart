import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class MedicalService {
  static MedicalService? _instance;
  static MedicalService get instance => _instance ??= MedicalService._();
  MedicalService._();

  final _client = SupabaseService.instance.client;
  final _auth = AuthService.instance;

  // Get user's medical profile
  Future<Map<String, dynamic>?> getMedicalProfile() async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('medical_profiles')
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .maybeSingle();
      return response;
    } catch (error) {
      throw Exception('Failed to get medical profile: $error');
    }
  }

  // Create or update medical profile
  Future<Map<String, dynamic>> upsertMedicalProfile(
      Map<String, dynamic> profileData) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      profileData['user_id'] = _auth.currentUser!.id;

      final response = await _client
          .from('medical_profiles')
          .upsert(profileData, onConflict: 'user_id')
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to save medical profile: $error');
    }
  }

  // Get weight entries
  Future<List<dynamic>> getWeightEntries({int limit = 30}) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('weight_entries')
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .order('recorded_at', ascending: false)
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to get weight entries: $error');
    }
  }

  // Add weight entry
  Future<Map<String, dynamic>> addWeightEntry({
    required double weightKg,
    double? bodyFatPercentage,
    double? muscleMassKg,
    String? notes,
    DateTime? recordedAt,
  }) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      final data = {
        'user_id': _auth.currentUser!.id,
        'weight_kg': weightKg,
        'body_fat_percentage': bodyFatPercentage,
        'muscle_mass_kg': muscleMassKg,
        'notes': notes,
        'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
      };

      final response =
          await _client.from('weight_entries').insert(data).select().single();
      return response;
    } catch (error) {
      throw Exception('Failed to add weight entry: $error');
    }
  }

  // Get food items
  Future<List<dynamic>> searchFoodItems(String query, {int limit = 20}) async {
    try {
      final response = await _client
          .from('food_items')
          .select()
          .ilike('name', '%$query%')
          .eq('is_verified', true)
          .order('name')
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to search food items: $error');
    }
  }

  // Get all verified food items
  Future<List<dynamic>> getFoodItems({int limit = 100}) async {
    try {
      final response = await _client
          .from('food_items')
          .select()
          .eq('is_verified', true)
          .order('name')
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to get food items: $error');
    }
  }

  // Add custom food item
  Future<Map<String, dynamic>> addFoodItem(
      Map<String, dynamic> foodData) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      foodData['created_by'] = _auth.currentUser!.id;
      foodData['is_verified'] = false; // Custom foods need verification

      final response =
          await _client.from('food_items').insert(foodData).select().single();
      return response;
    } catch (error) {
      throw Exception('Failed to add food item: $error');
    }
  }

  // Get meal entries for a date range
  Future<List<dynamic>> getMealEntries({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('meal_entries')
          .select('''
            *,
            meal_foods (
              *,
              food_items (name, brand, calories_per_100g)
            )
          ''')
          .eq('user_id', _auth.currentUser!.id)
          .gte('meal_date', startDate.toIso8601String().split('T')[0])
          .lte('meal_date', endDate.toIso8601String().split('T')[0])
          .order('meal_date', ascending: false)
          .order('meal_time', ascending: true);
      return response;
    } catch (error) {
      throw Exception('Failed to get meal entries: $error');
    }
  }

  // Add meal entry with foods
  Future<Map<String, dynamic>> addMealEntry({
    required String mealType,
    required DateTime mealDate,
    required List<Map<String, dynamic>> foods,
    String? notes,
    String? mealTime,
  }) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      // Insert meal entry
      final mealData = {
        'user_id': _auth.currentUser!.id,
        'meal_type': mealType,
        'meal_date': mealDate.toIso8601String().split('T')[0],
        'meal_time': mealTime,
        'notes': notes,
      };

      final mealResponse =
          await _client.from('meal_entries').insert(mealData).select().single();

      // Insert meal foods
      final mealFoods = foods
          .map((food) => {
                'meal_entry_id': mealResponse['id'],
                'food_item_id': food['food_item_id'],
                'quantity_grams': food['quantity_grams'],
                'calories': food['calories'],
                'protein_g': food['protein_g'] ?? 0,
                'carbs_g': food['carbs_g'] ?? 0,
                'fat_g': food['fat_g'] ?? 0,
              })
          .toList();

      await _client.from('meal_foods').insert(mealFoods);

      return mealResponse;
    } catch (error) {
      throw Exception('Failed to add meal entry: $error');
    }
  }

  // Get nutrition summary for a date
  Future<Map<String, dynamic>> getNutritionSummary(DateTime date) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('meal_entries')
          .select('''
            meal_foods (calories, protein_g, carbs_g, fat_g)
          ''')
          .eq('user_id', _auth.currentUser!.id)
          .eq('meal_date', date.toIso8601String().split('T')[0]);

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final entry in response) {
        if (entry['meal_foods'] != null) {
          for (final food in entry['meal_foods']) {
            totalCalories += (food['calories'] ?? 0).toDouble();
            totalProtein += (food['protein_g'] ?? 0).toDouble();
            totalCarbs += (food['carbs_g'] ?? 0).toDouble();
            totalFat += (food['fat_g'] ?? 0).toDouble();
          }
        }
      }

      return {
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'date': date.toIso8601String().split('T')[0],
      };
    } catch (error) {
      throw Exception('Failed to get nutrition summary: $error');
    }
  }

  // Calculate BMI
  double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Get BMI category
  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate daily calorie needs (Harris-Benedict equation)
  int calculateDailyCalories({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    double bmr;

    // Calculate BMR
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }

    // Apply activity multiplier
    double multiplier;
    switch (activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'lightly_active':
        multiplier = 1.375;
        break;
      case 'moderately_active':
        multiplier = 1.55;
        break;
      case 'very_active':
        multiplier = 1.725;
        break;
      case 'extremely_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.55;
    }

    return (bmr * multiplier).round();
  }
}
