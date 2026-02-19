import 'package:supabase_flutter/supabase_flutter.dart';

class BodyMetricsService {
  static BodyMetricsService? _instance;
  late final SupabaseClient _client;

  BodyMetricsService._internal() {
    _client = Supabase.instance.client;
  }

  static BodyMetricsService get instance {
    _instance ??= BodyMetricsService._internal();
    return _instance!;
  }

  /// Normalize date to midnight (start of day) for consistent date comparison
  DateTime _normalizeToDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// NEW: Get previous day's weight entry specifically for "Come Ieri" functionality
  Future<Map<String, dynamic>?> getPreviousDayWeightEntry({
    required DateTime currentDate,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Calculate previous day from the given current date
      final previousDay = currentDate.subtract(const Duration(days: 1));
      final normalizedPreviousDay = _normalizeToDate(previousDay);

      print(
        'Looking for previous day entry: ${normalizedPreviousDay.toIso8601String()}',
      );

      // Look specifically for the previous day's entry
      final previousDayEntry = await _client
          .from('weight_entries')
          .select('*')
          .eq('user_id', userId)
          .gte('recorded_at', normalizedPreviousDay.toIso8601String())
          .lt(
            'recorded_at',
            normalizedPreviousDay
                .add(const Duration(days: 1))
                .toIso8601String(),
          )
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (previousDayEntry != null) {
        print('Found previous day entry: ${previousDayEntry['weight_kg']} kg');
        return previousDayEntry;
      }

      // If no entry for yesterday, look for the most recent entry before the current date
      final mostRecentBeforeCurrent = await _client
          .from('weight_entries')
          .select('*')
          .eq('user_id', userId)
          .lt(
            'recorded_at',
            _normalizeToDate(currentDate).toIso8601String(),
          )
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (mostRecentBeforeCurrent != null) {
        print(
          'Found most recent entry before current date: ${mostRecentBeforeCurrent['weight_kg']} kg',
        );
      }

      return mostRecentBeforeCurrent;
    } catch (error) {
      print('Error getting previous day weight entry: $error');
      return null;
    }
  }

  /// Get comprehensive body metrics summary for current user
  /// FIXED: Now distinguishes between today's weight and latest weight entry
  Future<Map<String, dynamic>> getBodyMetricsSummary() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final today = _normalizeToDate(DateTime.now());

      // FIXED: Get TODAY's weight entry specifically
      final todayWeightResponse = await _client
          .from('weight_entries')
          .select('*')
          .eq('user_id', userId)
          .gte('recorded_at', today.toIso8601String())
          .lt(
            'recorded_at',
            today.add(const Duration(days: 1)).toIso8601String(),
          )
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // Also get the latest weight entry (for reference, but not as "current")
      final latestWeightResponse = await _client
          .from('weight_entries')
          .select('*')
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // Get medical profile - USING PROPER SUPABASE METHODS
      final profileResponse = await _client
          .from('medical_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      // FIXED: Use TODAY's weight for current metrics, not just the latest entry
      final currentWeight = todayWeightResponse?['weight_kg']?.toDouble();
      final height = profileResponse?['height_cm']?.toDouble();

      // Calculate BMI if we have both TODAY's weight and height
      double? bmi;
      if (currentWeight != null && height != null && height > 0) {
        bmi = calculateBMI(weightKg: currentWeight, heightCm: height);
      }

      print('📊 Body Metrics Summary:');
      print('   Today\'s weight: ${currentWeight ?? "none"} kg');
      print('   Latest weight entry date: ${latestWeightResponse?['recorded_at']}');
      print('   Is today\'s entry: ${todayWeightResponse != null}');

      return {
        'today_weight': todayWeightResponse, // TODAY's weight entry
        'latest_weight': latestWeightResponse, // Most recent weight entry (may be past)
        'medical_profile': profileResponse,
        'weight': currentWeight ?? 0.0, // Only TODAY's weight, or 0 if none
        'height': height ?? 0.0,
        'bmi': bmi,
        'body_fat_percentage':
            todayWeightResponse?['body_fat_percentage']?.toDouble(),
        'muscle_mass_kg': todayWeightResponse?['muscle_mass_kg']?.toDouble(),
        'waist_circumference_cm':
            todayWeightResponse?['waist_circumference_cm']?.toDouble(),
        'hip_circumference_cm':
            todayWeightResponse?['hip_circumference_cm']?.toDouble(),
        'lean_mass_kg': todayWeightResponse?['lean_mass_kg']?.toDouble(),
        'fat_mass_kg': todayWeightResponse?['fat_mass_kg']?.toDouble(),
        'cellular_mass_kg': todayWeightResponse?['cellular_mass_kg']?.toDouble(),
        'phase_angle_degrees':
            todayWeightResponse?['phase_angle_degrees']?.toDouble(),
        'hand_grip_strength_kg':
            todayWeightResponse?['hand_grip_strength_kg']?.toDouble(),
        'last_updated':
            todayWeightResponse?['recorded_at'] ?? todayWeightResponse?['created_at'],
      };
    } catch (error) {
      throw Exception('Failed to load body metrics summary: $error');
    }
  }

  /// NEW: Get weight entry for a specific date
  Future<Map<String, dynamic>?> getWeightEntryForDate(DateTime date) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final normalizedDate = _normalizeToDate(date);

      print('🔍 Getting weight entry for date: ${normalizedDate.toIso8601String()}');

      final weightEntry = await _client
          .from('weight_entries')
          .select('*')
          .eq('user_id', userId)
          .gte('recorded_at', normalizedDate.toIso8601String())
          .lt(
            'recorded_at',
            normalizedDate.add(const Duration(days: 1)).toIso8601String(),
          )
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (weightEntry != null) {
        print('✅ Found weight entry: ${weightEntry['weight_kg']} kg');
      } else {
        print('❌ No weight entry found for this date');
      }

      return weightEntry;
    } catch (error) {
      print('Error getting weight entry for date: $error');
      return null;
    }
  }


  /// Get weight progress data for charts - USING PROPER SUPABASE METHODS
  Future<List<Map<String, dynamic>>> getWeightProgressData({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 30,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // BUILD QUERY USING PROPER SUPABASE METHODS (.eq, .gte, .lt, .order, .limit)
      var queryBuilder = _client
          .from('weight_entries')
          .select(
            'id, weight_kg, recorded_at, body_fat_percentage, muscle_mass_kg, '
            'waist_circumference_cm, hip_circumference_cm, lean_mass_kg, '
            'fat_mass_kg, cellular_mass_kg, phase_angle_degrees, hand_grip_strength_kg, notes',
          )
          .eq('user_id', userId);

      // Apply date filters with normalization - USING .gte() and .lt() methods
      if (startDate != null) {
        final normalizedStart = _normalizeToDate(startDate);
        queryBuilder = queryBuilder.gte(
          'recorded_at',
          normalizedStart.toIso8601String(),
        );
      }
      if (endDate != null) {
        final normalizedEnd = _normalizeToDate(
          endDate,
        ).add(const Duration(days: 1));
        queryBuilder = queryBuilder.lt(
          'recorded_at',
          normalizedEnd.toIso8601String(),
        );
      }

      // FIXED: Order by recorded_at ascending for charts (oldest to newest)
      // This ensures chart displays with oldest dates on left, newest on right
      final response =
          await queryBuilder.order('recorded_at', ascending: true).limit(limit);

      final weightData = (response as List<dynamic>)
          .map(
            (item) => {
              'id': item['id']?.toString() ?? '',
              'weight_kg': (item['weight_kg'] as num?)?.toDouble() ?? 0.0,
              'weight': (item['weight_kg'] as num?)?.toDouble() ??
                  0.0, // Maintain both for compatibility
              'date': DateTime.parse(
                item['recorded_at'] ??
                    item['created_at'] ??
                    DateTime.now().toIso8601String(),
              ),
              'recorded_at': item['recorded_at']?.toString() ??
                  DateTime.now().toIso8601String(),
              'body_fat_percentage':
                  (item['body_fat_percentage'] as num?)?.toDouble(),
              'muscle_mass_kg': (item['muscle_mass_kg'] as num?)?.toDouble(),
              'waist_circumference_cm':
                  (item['waist_circumference_cm'] as num?)?.toDouble(),
              'hip_circumference_cm':
                  (item['hip_circumference_cm'] as num?)?.toDouble(),
              'lean_mass_kg': (item['lean_mass_kg'] as num?)?.toDouble(),
              'fat_mass_kg': (item['fat_mass_kg'] as num?)?.toDouble(),
              'cellular_mass_kg':
                  (item['cellular_mass_kg'] as num?)?.toDouble(),
              'phase_angle_degrees':
                  (item['phase_angle_degrees'] as num?)?.toDouble(),
              'hand_grip_strength_kg':
                  (item['hand_grip_strength_kg'] as num?)?.toDouble(),
              'notes': item['notes']?.toString() ?? '',
            },
          )
          .toList();

      // FIXED: Ensure chronological order (oldest first, newest last)
      // This makes the chart display correctly with recent dates on the right
      weightData.sort((a, b) {
        final dateA = DateTime.parse(a['recorded_at'] as String);
        final dateB = DateTime.parse(b['recorded_at'] as String);
        return dateA.compareTo(dateB); // ascending order
      });

      return weightData;
    } catch (error) {
      print('Error in getWeightProgressData: $error');
      throw Exception('Failed to load weight progress data: $error');
    }
  }

  /// Save weight entry using FIXED database upsert function
  Future<Map<String, dynamic>> saveWeightEntry({
    required double weightKg,
    double? bodyFatPercentage,
    double? muscleMassKg,
    double? waistCircumferenceCm,
    double? hipCircumferenceCm,
    double? leanMassKg,
    double? fatMassKg,
    double? cellularMassKg,
    double? phaseAngleDegrees,
    double? handGripStrengthKg,
    String? notes,
    DateTime? recordedAt,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final recordingDate = recordedAt ?? DateTime.now();
      final normalizedDate = _normalizeToDate(recordingDate);

      print(
        'Saving weight entry for date: ${normalizedDate.toIso8601String()}',
      );

      // FIXED: Use the corrected database upsert function
      final result = await _client.rpc(
        'upsert_weight_entry',
        params: {
          'p_user_id': userId,
          'p_weight_kg': weightKg,
          'p_body_fat_percentage': bodyFatPercentage,
          'p_muscle_mass_kg': muscleMassKg,
          'p_waist_circumference_cm': waistCircumferenceCm,
          'p_hip_circumference_cm': hipCircumferenceCm,
          'p_lean_mass_kg': leanMassKg,
          'p_fat_mass_kg': fatMassKg,
          'p_cellular_mass_kg': cellularMassKg,
          'p_phase_angle_degrees': phaseAngleDegrees,
          'p_hand_grip_strength_kg': handGripStrengthKg,
          'p_notes': notes?.isNotEmpty == true ? notes : null,
          'p_recorded_at': normalizedDate.toIso8601String(),
        },
      );

      print('Weight entry upserted successfully with ID: $result');

      // Fetch the updated record to return complete data - USING PROPER .eq() METHOD
      final savedEntry = await _client
          .from('weight_entries')
          .select('*')
          .eq('id', result)
          .single();

      return savedEntry;
    } catch (error) {
      print('Error saving weight entry: $error');

      // Enhanced fallback method with better error handling
      try {
        print('Attempting enhanced fallback direct insert/update method...');
        final userId = _client.auth.currentUser?.id;
        final recordingDate = recordedAt ?? DateTime.now();
        final normalizedDate = _normalizeToDate(recordingDate);

        // USING PROPER SUPABASE METHODS (.eq, .gte, .lt) - NOT .filter()
        final existingEntries = await _client
            .from('weight_entries')
            .select('id, created_at')
            .eq('user_id', userId!)
            .gte('recorded_at', normalizedDate.toIso8601String())
            .lt(
              'recorded_at',
              normalizedDate.add(const Duration(days: 1)).toIso8601String(),
            );

        final data = {
          'user_id': userId,
          'weight_kg': weightKg,
          'body_fat_percentage': bodyFatPercentage,
          'muscle_mass_kg': muscleMassKg,
          'waist_circumference_cm': waistCircumferenceCm,
          'hip_circumference_cm': hipCircumferenceCm,
          'lean_mass_kg': leanMassKg,
          'fat_mass_kg': fatMassKg,
          'cellular_mass_kg': cellularMassKg,
          'phase_angle_degrees': phaseAngleDegrees,
          'hand_grip_strength_kg': handGripStrengthKg,
          'notes': notes?.isNotEmpty == true ? notes : null,
          'recorded_at': normalizedDate.toIso8601String(),
        };

        Map<String, dynamic> response;

        if (existingEntries.isNotEmpty) {
          // Update the most recent existing entry
          final latestEntry = existingEntries.first;
          response = await _client
              .from('weight_entries')
              .update({
                ...data,
                'created_at':
                    DateTime.now().toIso8601String(), // Update timestamp
              })
              .eq('id', latestEntry['id'])
              .select()
              .single();
          print('Updated existing entry: ${response['id']}');
        } else {
          // Insert new entry
          response = await _client
              .from('weight_entries')
              .insert(data)
              .select()
              .single();
          print('Inserted new entry: ${response['id']}');
        }

        return response;
      } catch (fallbackError) {
        print('Enhanced fallback method also failed: $fallbackError');
        throw Exception('Failed to save weight entry: $fallbackError');
      }
    }
  }

  /// Update medical profile - USING PROPER SUPABASE METHODS
  Future<Map<String, dynamic>> updateMedicalProfile({
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? activityLevel,
    String? goalType,
    List<String>? allergies,
    List<String>? medicalConditions,
    List<String>? medications,
    List<String>? dietaryRestrictions,
    int? targetDailyCalories,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
    int? bmrCalories,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if profile exists - USING PROPER .eq() METHOD
      final existingProfile = await _client
          .from('medical_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      final data = <String, dynamic>{
        'user_id': userId,
        if (heightCm != null) 'height_cm': heightCm,
        if (currentWeightKg != null) 'current_weight_kg': currentWeightKg,
        if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
        if (activityLevel != null) 'activity_level': activityLevel,
        if (goalType != null) 'goal_type': goalType,
        if (allergies != null) 'allergies': allergies,
        if (medicalConditions != null) 'medical_conditions': medicalConditions,
        if (medications != null) 'medications': medications,
        if (dietaryRestrictions != null)
          'dietary_restrictions': dietaryRestrictions,
        if (targetDailyCalories != null)
          'target_daily_calories': targetDailyCalories,
        if (targetProteinG != null) 'target_protein_g': targetProteinG,
        if (targetCarbsG != null) 'target_carbs_g': targetCarbsG,
        if (targetFatG != null) 'target_fat_g': targetFatG,
        if (bmrCalories != null) 'bmr_calories': bmrCalories,
        'updated_at': DateTime.now().toIso8601String(),
      };

      late Map<String, dynamic> response;

      if (existingProfile != null) {
        // Update existing profile - USING PROPER .eq() METHOD
        response = await _client
            .from('medical_profiles')
            .update(data)
            .eq('user_id', userId)
            .select()
            .single();
      } else {
        // Create new profile
        response = await _client
            .from('medical_profiles')
            .insert(data)
            .select()
            .single();
      }

      return response;
    } catch (error) {
      print('Error updating medical profile: $error');
      throw Exception('Failed to update medical profile: $error');
    }
  }

  /// Delete a weight entry - USING PROPER SUPABASE METHODS
  Future<void> deleteWeightEntry(String entryId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // USING PROPER .eq() METHODS - NOT .filter()
      await _client
          .from('weight_entries')
          .delete()
          .eq('id', entryId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to delete weight entry: $error');
    }
  }

  /// ENHANCED: Check if weight/height data is updated today for BMI questionnaire validation
  Future<BMIValidationResult> validateBMIForQuestionnaire() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        print('❌ BMI Validation: User not authenticated');
        return BMIValidationResult(
          isValid: false,
          message: 'Utente non autenticato. Accedi per continuare.',
          requiresWeightUpdate: true,
          requiresHeightUpdate: true,
        );
      }

      final today = _normalizeToDate(DateTime.now());
      print('🔍 BMI Validation: Checking for date ${today.toIso8601String()}');

      // Get today's weight entry with improved validation
      final todayWeightEntry = await _client
          .from('weight_entries')
          .select('weight_kg, recorded_at, created_at')
          .eq('user_id', userId)
          .gte('recorded_at', today.toIso8601String())
          .lt(
            'recorded_at',
            today.add(const Duration(days: 1)).toIso8601String(),
          )
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // Get medical profile for height with better error handling
      final medicalProfile = await _client
          .from('medical_profiles')
          .select('height_cm, updated_at, current_weight_kg')
          .eq('user_id', userId)
          .maybeSingle();

      // Comprehensive validation logic
      final hasWeightToday = todayWeightEntry != null &&
          todayWeightEntry['weight_kg'] != null &&
          todayWeightEntry['weight_kg'] > 0;

      final hasHeight = medicalProfile != null &&
          medicalProfile['height_cm'] != null &&
          medicalProfile['height_cm'] > 0;

      print('📊 BMI Validation Status:');
      print('  - Has weight today: $hasWeightToday');
      print('  - Has height: $hasHeight');
      print('  - Today\'s date: ${today.toIso8601String()}');

      // STRICT VALIDATION: Both weight and height must be current
      if (!hasWeightToday && !hasHeight) {
        print('❌ Missing both weight and height');
        return BMIValidationResult(
          isValid: false,
          message:
              'Per accedere ai questionari nutrizionali, devi aggiornare peso e altezza con la data di oggi.',
          requiresWeightUpdate: true,
          requiresHeightUpdate: true,
        );
      }

      if (!hasWeightToday) {
        print('❌ Missing today\'s weight');
        return BMIValidationResult(
          isValid: false,
          message:
              'Peso non aggiornato oggi. Aggiorna il tuo peso per accedere al questionario.',
          requiresWeightUpdate: true,
          requiresHeightUpdate: false,
        );
      }

      if (!hasHeight) {
        print('❌ Missing height information');
        return BMIValidationResult(
          isValid: false,
          message:
              'Altezza mancante. Inserisci la tua altezza per calcolare il BMI.',
          requiresWeightUpdate: false,
          requiresHeightUpdate: true,
        );
      }

      // Additional validation: Ensure height was recently updated (within last 30 days)
      if (medicalProfile['updated_at'] != null) {
        final heightLastUpdate = DateTime.parse(medicalProfile['updated_at']);
        final daysSinceHeightUpdate =
            today.difference(_normalizeToDate(heightLastUpdate)).inDays;

        if (daysSinceHeightUpdate > 30) {
          print('⚠️ Height data is old (${daysSinceHeightUpdate} days)');
          return BMIValidationResult(
            isValid: false,
            message:
                'I dati dell\'altezza sono obsoleti. Aggiorna l\'altezza per continuare.',
            requiresWeightUpdate: false,
            requiresHeightUpdate: true,
          );
        }
      }

      // Calculate and validate BMI
      final weight = todayWeightEntry['weight_kg'].toDouble();
      final height = medicalProfile['height_cm'].toDouble();

      if (weight <= 0 || height <= 0) {
        print('❌ Invalid weight or height values');
        return BMIValidationResult(
          isValid: false,
          message:
              'Valori di peso o altezza non validi. Controlla i tuoi dati.',
          requiresWeightUpdate: weight <= 0,
          requiresHeightUpdate: height <= 0,
        );
      }

      final bmi = calculateBMI(weightKg: weight, heightCm: height);

      if (bmi == null) {
        print('❌ BMI calculation failed');
        return BMIValidationResult(
          isValid: false,
          message: 'Impossibile calcolare il BMI. Verifica i dati inseriti.',
          requiresWeightUpdate: true,
          requiresHeightUpdate: true,
        );
      }

      // Log successful validation
      print('✅ BMI Validation successful:');
      print('  - Weight: ${weight}kg');
      print('  - Height: ${height}cm');
      print('  - BMI: ${bmi.toStringAsFixed(1)}');

      return BMIValidationResult(
        isValid: true,
        message: 'BMI calcolato correttamente: ${bmi.toStringAsFixed(1)}',
        bmi: bmi,
        weight: weight,
        height: height,
        requiresWeightUpdate: false,
        requiresHeightUpdate: false,
      );
    } catch (error) {
      print('🔥 BMI Validation Error: $error');
      return BMIValidationResult(
        isValid: false,
        message:
            'Errore durante la validazione BMI. Verifica la connessione e riprova.',
        requiresWeightUpdate: true,
        requiresHeightUpdate: false,
      );
    }
  }

  /// NEW: Enhanced method to check if BMI validation should be bypassed for testing
  Future<bool> shouldBypassBMIValidation() async {
    try {
      // Check if user is in development/test mode
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // For production: Always enforce BMI validation
      // For development: Could add bypass logic here if needed
      return false; // Always require BMI validation
    } catch (e) {
      return false; // Default to requiring validation
    }
  }

  /// NEW: Method to check BMI requirements for specific questionnaire types
  bool requiresBMIValidationForQuestionnaire(String questionnaireType) {
    final bmiRequiredTypes = {
      'must',
      'nrs_2002',
      'nutritional_risk_assessment',
      'sarc_f',
      'consolidated_nutritional_assessment'
    };

    return bmiRequiredTypes.contains(questionnaireType.toLowerCase());
  }

  /// ENHANCED: Get last BMI update information for user feedback
  Future<Map<String, dynamic>?> getLastBMIUpdateInfo() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final latestWeight = await _client
          .from('weight_entries')
          .select('weight_kg, recorded_at')
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final medicalProfile = await _client
          .from('medical_profiles')
          .select('height_cm, updated_at')
          .eq('user_id', userId)
          .maybeSingle();

      return {
        'last_weight_date': latestWeight?['recorded_at'],
        'last_weight_value': latestWeight?['weight_kg'],
        'height_last_updated': medicalProfile?['updated_at'],
        'height_value': medicalProfile?['height_cm'],
      };
    } catch (e) {
      print('Error getting BMI update info: $e');
      return null;
    }
  }

  /// Calculate BMI
  double? calculateBMI({required double weightKg, required double heightCm}) {
    if (heightCm <= 0) return null;

    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Sottopeso';
    } else if (bmi < 25) {
      return 'Normale';
    } else if (bmi < 30) {
      return 'Sovrappeso';
    } else {
      return 'Obeso';
    }
  }

  /// Get weight loss percentage
  Future<double?> getWeightLossPercentage() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final weights = await getWeightProgressData(limit: 100);
      if (weights.length < 2) return null;

      // Get first (oldest) and last (newest) weights
      final firstWeight =
          (weights.last['weight_kg'] as num?)?.toDouble() ?? 0.0;
      final lastWeight =
          (weights.first['weight_kg'] as num?)?.toDouble() ?? 0.0;

      if (firstWeight <= 0) return null;

      return ((firstWeight - lastWeight) / firstWeight) * 100;
    } catch (error) {
      return null;
    }
  }

  /// Get ideal weight range based on height
  Map<String, double>? getIdealWeightRange(double heightCm) {
    if (heightCm <= 0) return null;

    final heightM = heightCm / 100;

    // BMI 18.5 to 24.9 is considered normal
    final minWeight = 18.5 * (heightM * heightM);
    final maxWeight = 24.9 * (heightM * heightM);

    return {'min': minWeight, 'max': maxWeight};
  }
}

/// Enhanced BMI Validation Result model
class BMIValidationResult {
  final bool isValid;
  final String message;
  final double? bmi;
  final double? weight;
  final double? height;
  final bool requiresWeightUpdate;
  final bool requiresHeightUpdate;

  BMIValidationResult({
    required this.isValid,
    required this.message,
    this.bmi,
    this.weight,
    this.height,
    required this.requiresWeightUpdate,
    required this.requiresHeightUpdate,
  });

  @override
  String toString() {
    return 'BMIValidationResult(isValid: $isValid, message: $message, BMI: $bmi)';
  }
}
