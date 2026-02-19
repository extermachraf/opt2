import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  static DashboardService get instance => _instance;
  DashboardService._internal();

  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets synchronized dashboard data from the database
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // FIXED: Try multiple data loading strategies with fallbacks
      Map<String, dynamic> dashboardData = {};

      try {
        // Try using the dashboard sync function first
        final response = await _client.rpc(
          'sync_dashboard_data',
          params: {'user_uuid': userId},
        );

        if (response.isNotEmpty) {
          final data = response.first;
          dashboardData = {
            'nutrition_summary': data['nutrition_summary'] ?? {},
            'weight_progress': data['weight_progress'] ?? [],
            'meal_counts': data['meal_counts'] ?? {},
            'assessment_status': data['assessment_status'] ?? {},
          };
        }
      } catch (syncError) {
        print('Dashboard sync function failed, using fallback: $syncError');
        // Fallback to manual data gathering if sync function fails
        dashboardData = await _getFallbackDashboardData(userId);
      }

      // Add individual meals to dashboard data
      try {
        final todaysMeals = await getTodaysMeals();
        dashboardData['todays_meals'] = todaysMeals;
      } catch (mealsError) {
        print('Failed to load individual meals: $mealsError');
        dashboardData['todays_meals'] = [];
      }

      // If still empty, return empty defaults
      if (dashboardData.isEmpty) {
        dashboardData = _getEmptyDashboardData();
        dashboardData['todays_meals'] = [];
      }

      return dashboardData;
    } catch (error) {
      print('Dashboard data loading failed: $error');
      // Return empty data instead of throwing to prevent blank screen
      final emptyData = _getEmptyDashboardData();
      emptyData['todays_meals'] = [];
      return emptyData;
    }
  }

  /// Fallback method to gather dashboard data manually
  Future<Map<String, dynamic>> _getFallbackDashboardData(String userId) async {
    try {
      // Get today's meals for nutrition summary
      final today = DateTime.now().toIso8601String().split('T')[0];
      final mealEntries = await _client.from('meal_entries').select('''
            *,
            meal_foods(
              calories,
              protein_g,
              carbs_g,
              fat_g
            )
          ''').eq('user_id', userId).eq('meal_date', today);

      // Get recent weight entries
      final weightEntries = await _client
          .from('weight_entries')
          .select('*')
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(7);

      // Get recent assessments
      final assessments = await _client
          .from('assessment_sessions')
          .select('status, questionnaire_type, completed_at, total_score')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      return {
        'nutrition_summary': _calculateNutritionTotals(mealEntries),
        'weight_progress': weightEntries,
        'meal_counts': _calculateMealCounts(mealEntries),
        'assessment_status': _calculateAssessmentProgress(assessments),
      };
    } catch (fallbackError) {
      print('Fallback data loading failed: $fallbackError');
      return _getEmptyDashboardData();
    }
  }

  /// Gets today's individual meals from the meal diary
  Future<List<dynamic>> getTodaysMeals() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from('meal_entries')
          .select('''
        *,
        meal_foods(
          quantity_grams,
          calories,
          protein_g,
          carbs_g,
          fat_g,
          food_item_id,
          food_ingredient_code,
          recipe_id,
          food_items(
            id,
            name,
            brand
          ),
          recipes(
            title
          ),
          "Food Ingredients"(
            "Nome Alimento ITA"
          )
        )
      ''')
          .eq('user_id', userId)
          .eq('meal_date', today)
          .order('meal_time', ascending: true);

      // Transform the data to include calculated nutrition for each meal
      return response.map((entry) {
        final mealFoods = entry['meal_foods'] as List<dynamic>? ?? [];

        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        List<String> foodNames = [];

        for (final mealFood in mealFoods) {
          // Use the stored nutrition values directly from meal_foods table
          totalCalories += (mealFood['calories'] as num?)?.toDouble() ?? 0;
          totalProtein += (mealFood['protein_g'] as num?)?.toDouble() ?? 0;
          totalCarbs += (mealFood['carbs_g'] as num?)?.toDouble() ?? 0;
          totalFat += (mealFood['fat_g'] as num?)?.toDouble() ?? 0;

          // Get food name from the appropriate source
          String foodName = 'Unknown Food';

          // Check food_items
          final foodItem = mealFood['food_items'] as Map<String, dynamic>?;
          if (foodItem != null) {
            foodName = foodItem['name'] ?? 'Unknown Food';
          }

          // Check recipes
          final recipe = mealFood['recipes'] as Map<String, dynamic>?;
          if (recipe != null) {
            foodName = recipe['title'] ?? 'Unknown Recipe';
          }

          // Check Food Ingredients
          if (mealFood['food_ingredient_code'] != null) {
            final foodIngredient = mealFood['Food Ingredients'] as Map<String, dynamic>?;
            if (foodIngredient != null) {
              foodName = foodIngredient['Nome Alimento ITA'] ?? 'Ingrediente';
            } else {
              foodName = 'Ingrediente';
            }
          }

          foodNames.add(foodName);
        }

        // Create a meal name from food items or use notes
        final mealName = entry['notes']?.isNotEmpty == true
            ? entry['notes']
            : foodNames.isNotEmpty
                ? foodNames.length > 1
                    ? '${foodNames.first} e ${foodNames.length - 1} altro${foodNames.length > 2 ? 'i' : ''}'
                    : foodNames.first
                : 'Pasto senza nome';

        return {
          'id': entry['id'],
          'name': mealName,
          'type': _translateMealType(entry['meal_type']),
          'meal_type': entry['meal_type'],
          'calories': totalCalories.round(),
          'protein': double.parse(totalProtein.toStringAsFixed(1)),
          'carbs': double.parse(totalCarbs.toStringAsFixed(1)),
          'fat': double.parse(totalFat.toStringAsFixed(1)),
          'meal_date': entry['meal_date'],
          'meal_time': entry['meal_time'],
          'notes': entry['notes'],
          'food_count': mealFoods.length,
          'food_items': foodNames,
          'timestamp': _parseDateTime(entry['meal_date'], entry['meal_time']),
          'imageUrl': _getMealImageUrl(entry['meal_type']),
        };
      }).toList();
    } catch (error) {
      print('Failed to load today\'s meals: $error');
      return [];
    }
  }

  /// Helper method to translate meal types to Italian
  String _translateMealType(String? mealType) {
    switch (mealType?.toLowerCase()) {
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

  /// Helper method to get meal type specific image
  String _getMealImageUrl(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'breakfast':
        return 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=400&h=300&fit=crop';
      case 'lunch':
        return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop';
      case 'dinner':
        return 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&h=300&fit=crop';
      case 'snack':
        return 'https://images.unsplash.com/photo-1559656914-a30970c1affd?w=400&h=300&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop';
    }
  }

  /// Helper method to parse date and time into DateTime
  DateTime _parseDateTime(String? dateStr, String? timeStr) {
    try {
      if (dateStr == null) return DateTime.now();

      final date = DateTime.parse(dateStr);

      if (timeStr != null) {
        final timeParts = timeStr.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          return DateTime(date.year, date.month, date.day, hour, minute);
        }
      }

      return date;
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Helper method to calculate meal counts by type
  Map<String, int> _calculateMealCounts(List<dynamic> mealEntries) {
    final counts = {'breakfast': 0, 'lunch': 0, 'dinner': 0, 'snack': 0};

    for (final entry in mealEntries) {
      final mealType = entry['meal_type'] as String?;
      if (mealType != null && counts.containsKey(mealType)) {
        counts[mealType] = counts[mealType]! + 1;
      }
    }

    return counts;
  }

  /// Gets user's dashboard configuration
  Future<Map<String, dynamic>?> getDashboardConfiguration() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('dashboard_configurations')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to load dashboard configuration: $error');
    }
  }

  /// Gets dashboard widgets for a user
  Future<List<dynamic>> getDashboardWidgets() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('dashboard_widgets')
          .select('''
            *,
            dashboard_configurations!inner(user_id),
            chart_configurations(*)
          ''')
          .eq('dashboard_configurations.user_id', userId)
          .eq('is_visible', true)
          .order('sort_order');

      return response;
    } catch (error) {
      throw Exception('Failed to load dashboard widgets: $error');
    }
  }

  /// Saves dashboard layout and configuration
  Future<Map<String, dynamic>> saveDashboardConfiguration({
    required Map<String, dynamic> layoutConfig,
    Map<String, dynamic>? themeSettings,
    int? autoRefreshInterval,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = {
        'layout_config': layoutConfig,
        if (themeSettings != null) 'theme_settings': themeSettings,
        if (autoRefreshInterval != null)
          'auto_refresh_interval': autoRefreshInterval,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('dashboard_configurations')
          .update(data)
          .eq('user_id', userId)
          .eq('is_active', true)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to save dashboard configuration: $error');
    }
  }

  /// Updates widget configuration
  Future<Map<String, dynamic>> updateWidgetConfiguration({
    required String widgetId,
    Map<String, dynamic>? widgetConfig,
    int? positionX,
    int? positionY,
    int? width,
    int? height,
    bool? isVisible,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (widgetConfig != null) data['widget_config'] = widgetConfig;
      if (positionX != null) data['position_x'] = positionX;
      if (positionY != null) data['position_y'] = positionY;
      if (width != null) data['width'] = width;
      if (height != null) data['height'] = height;
      if (isVisible != null) data['is_visible'] = isVisible;

      if (data.isEmpty) throw Exception('No update data provided');

      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('dashboard_widgets')
          .update(data)
          .eq('id', widgetId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update widget configuration: $error');
    }
  }

  /// Tracks dashboard interactions for analytics using safe logging function
  Future<void> trackDashboardInteraction({
    required String widgetId,
    required String interactionType,
    Map<String, dynamic>? interactionData,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Use the safe logging function that handles widget creation
      await _client.rpc('safe_log_dashboard_interaction', params: {
        'p_user_id': userId,
        'p_widget_identifier': widgetId, // Now accepts string identifiers
        'p_interaction_type': interactionType,
        'p_interaction_data': interactionData ?? {},
      });
    } catch (error) {
      // Log interaction tracking errors but don't throw
      print('Warning: Failed to track dashboard interaction: $error');
    }
  }

  /// NEW: Track assessment navigation interactions
  Future<void> trackAssessmentNavigation(String navigationType) async {
    await trackDashboardInteraction(
      widgetId:
          'quick_action_$navigationType', // This will be auto-created as needed
      interactionType: 'navigation',
      interactionData: {
        'action': 'assessment_navigation',
        'target': navigationType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Gets user's dashboard filters
  Future<List<dynamic>> getDashboardFilters() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('dashboard_filters')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response;
    } catch (error) {
      throw Exception('Failed to load dashboard filters: $error');
    }
  }

  /// Saves a dashboard filter
  Future<Map<String, dynamic>> saveDashboardFilter({
    required String filterName,
    required Map<String, dynamic> filterConfig,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    bool isDefault = false,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // If setting as default, unset other defaults first
      if (isDefault) {
        await _client
            .from('dashboard_filters')
            .update({'is_default': false})
            .eq('user_id', userId)
            .eq('is_default', true);
      }

      final response = await _client
          .from('dashboard_filters')
          .insert({
            'user_id': userId,
            'filter_name': filterName,
            'filter_config': filterConfig,
            'date_range_start': dateRangeStart?.toIso8601String().split('T')[0],
            'date_range_end': dateRangeEnd?.toIso8601String().split('T')[0],
            'is_default': isDefault,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to save dashboard filter: $error');
    }
  }

  /// Gets nutrition summary for a specific date range
  Future<Map<String, dynamic>> getNutritionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final start = startDate ?? DateTime.now();
      final end = endDate ?? DateTime.now();

      final response = await _client
          .from('meal_entries')
          .select('''
            *,
            meal_foods(
              calories,
              protein_g,
              carbs_g,
              fat_g
            )
          ''')
          .eq('user_id', userId)
          .gte('meal_date', start.toIso8601String().split('T')[0])
          .lte('meal_date', end.toIso8601String().split('T')[0]);

      return _calculateNutritionTotals(response);
    } catch (error) {
      throw Exception('Failed to load nutrition summary: $error');
    }
  }

  /// Gets weight progress data
  Future<List<dynamic>> getWeightProgress({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 30,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query =
          _client.from('weight_entries').select('*').eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('recorded_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('recorded_at', endDate.toIso8601String());
      }

      final response =
          await query.order('recorded_at', ascending: false).limit(limit);

      // FIXED: Transform data to ensure consistent field names for dashboard compatibility
      return response
          .map((entry) => {
                ...entry,
                'weight': entry[
                    'weight_kg'], // Add 'weight' field for dashboard compatibility
                'date': DateTime.parse(
                    entry['recorded_at'] ?? DateTime.now().toIso8601String()),
              })
          .toList();
    } catch (error) {
      throw Exception('Failed to load weight progress: $error');
    }
  }

  /// Gets meal statistics
  Future<Map<String, dynamic>> getMealStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();

      final response = await _client
          .from('meal_entries')
          .select('meal_type, meal_date')
          .eq('user_id', userId)
          .gte('meal_date', start.toIso8601String().split('T')[0])
          .lte('meal_date', end.toIso8601String().split('T')[0]);

      return _calculateMealStatistics(response);
    } catch (error) {
      throw Exception('Failed to load meal statistics: $error');
    }
  }

  /// Gets assessment progress
  Future<Map<String, dynamic>> getAssessmentProgress() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('assessment_sessions')
          .select('status, questionnaire_type, completed_at, total_score')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return _calculateAssessmentProgress(response);
    } catch (error) {
      throw Exception('Failed to load assessment progress: $error');
    }
  }

  /// Creates a new dashboard widget
  Future<Map<String, dynamic>> createDashboardWidget({
    required String widgetType,
    required String title,
    required int positionX,
    required int positionY,
    int width = 1,
    int height = 1,
    Map<String, dynamic>? widgetConfig,
    Map<String, dynamic>? dataSourceConfig,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get user's dashboard configuration
      final dashboardConfig = await _client
          .from('dashboard_configurations')
          .select('id')
          .eq('user_id', userId)
          .eq('is_active', true)
          .single();

      final response = await _client
          .from('dashboard_widgets')
          .insert({
            'dashboard_config_id': dashboardConfig['id'],
            'widget_type': widgetType,
            'title': title,
            'position_x': positionX,
            'position_y': positionY,
            'width': width,
            'height': height,
            'widget_config': widgetConfig ?? {},
            'data_source_config': dataSourceConfig ?? {},
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create dashboard widget: $error');
    }
  }

  /// Deletes a dashboard widget
  Future<void> deleteDashboardWidget(String widgetId) async {
    try {
      await _client.from('dashboard_widgets').delete().eq('id', widgetId);
    } catch (error) {
      throw Exception('Failed to delete dashboard widget: $error');
    }
  }

  /// Private helper methods

  Map<String, dynamic> _getEmptyDashboardData() {
    return {
      'nutrition_summary': {
        'total_calories': 0,
        'total_protein': 0,
        'total_carbs': 0,
        'total_fat': 0,
        'meals_logged': 0,
      },
      'weight_progress': [],
      'meal_counts': {'breakfast': 0, 'lunch': 0, 'dinner': 0, 'snack': 0},
      'assessment_status': {
        'completed_assessments': 0,
        'total_assessments': 0,
        'completion_rate': 0,
      },
    };
  }

  Map<String, dynamic> _calculateNutritionTotals(List<dynamic> mealEntries) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    int mealsLogged = mealEntries.length;

    for (final entry in mealEntries) {
      final mealFoods = entry['meal_foods'] as List<dynamic>? ?? [];

      for (final mealFood in mealFoods) {
        // Use the stored nutrition values directly from meal_foods table
        // This works for all food sources: food_items, Food Ingredients, and recipes
        totalCalories += (mealFood['calories'] as num?)?.toDouble() ?? 0;
        totalProtein += (mealFood['protein_g'] as num?)?.toDouble() ?? 0;
        totalCarbs += (mealFood['carbs_g'] as num?)?.toDouble() ?? 0;
        totalFat += (mealFood['fat_g'] as num?)?.toDouble() ?? 0;
      }
    }

    return {
      'total_calories': totalCalories.round(),
      'total_protein': double.parse(totalProtein.toStringAsFixed(1)),
      'total_carbs': double.parse(totalCarbs.toStringAsFixed(1)),
      'total_fat': double.parse(totalFat.toStringAsFixed(1)),
      'meals_logged': mealsLogged,
    };
  }

  Map<String, dynamic> _calculateMealStatistics(List<dynamic> mealEntries) {
    final Map<String, int> mealCounts = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
      'snack': 0,
    };

    final Map<String, Set<String>> uniqueDays = {
      'breakfast': {},
      'lunch': {},
      'dinner': {},
      'snack': {},
    };

    for (final entry in mealEntries) {
      final mealType = entry['meal_type'] as String?;
      final mealDate = entry['meal_date'] as String?;

      if (mealType != null &&
          mealDate != null &&
          mealCounts.containsKey(mealType)) {
        mealCounts[mealType] = mealCounts[mealType]! + 1;
        uniqueDays[mealType]!.add(mealDate);
      }
    }

    return {
      'meal_counts': mealCounts,
      'unique_days': uniqueDays.map(
        (key, value) => MapEntry(key, value.length),
      ),
      'total_meals': mealCounts.values.reduce((a, b) => a + b),
    };
  }

  Map<String, dynamic> _calculateAssessmentProgress(List<dynamic> assessments) {
    int completedAssessments = 0;
    final Map<String, int> statusCounts = {
      'draft': 0,
      'in_progress': 0,
      'completed': 0,
      'cancelled': 0,
    };

    final Map<String, dynamic> latestScores = {};

    for (final assessment in assessments) {
      final status = assessment['status'] as String?;
      final questionnaireType = assessment['questionnaire_type'] as String?;
      final totalScore = assessment['total_score'];

      if (status != null && statusCounts.containsKey(status)) {
        statusCounts[status] = statusCounts[status]! + 1;

        if (status == 'completed') {
          completedAssessments++;

          if (questionnaireType != null && totalScore != null) {
            latestScores[questionnaireType] = totalScore;
          }
        }
      }
    }

    final totalAssessments = assessments.length;
    final completionRate = totalAssessments > 0
        ? (completedAssessments / totalAssessments * 100).round()
        : 0;

    return {
      'completed_assessments': completedAssessments,
      'total_assessments': totalAssessments,
      'completion_rate': completionRate,
      'status_breakdown': statusCounts,
      'latest_scores': latestScores,
    };
  }

  /// Real-time subscription for dashboard data changes - ENHANCED
  void subscribeToDataChanges(Function(Map<String, dynamic>) onDataChanged) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // Subscribe to meal_entries changes
    _client
        .channel('dashboard_meal_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'meal_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            print('Meal entries changed, refreshing dashboard data...');
            final dashboardData = await getDashboardData();
            onDataChanged(dashboardData);
          },
        )
        .subscribe();

    // Subscribe to meal_foods changes - CRITICAL FOR RECIPE ADDITIONS
    _client
        .channel('dashboard_meal_foods_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'meal_foods',
          callback: (payload) async {
            print('Meal foods changed, refreshing dashboard data...');
            // Verify this meal_food belongs to current user by checking meal_entry
            final dashboardData = await getDashboardData();
            onDataChanged(dashboardData);
          },
        )
        .subscribe();

    // Subscribe to weight_entries changes - ENHANCED
    _client
        .channel('dashboard_weight_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'weight_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            print('Weight entries changed, refreshing dashboard data...');
            final dashboardData = await getDashboardData();
            onDataChanged(dashboardData);
          },
        )
        .subscribe();

    // FIXED: Subscribe to medical_profiles changes for target weight updates
    _client
        .channel('dashboard_medical_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'medical_profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            print('Medical profile changed, refreshing dashboard data...');
            final dashboardData = await getDashboardData();
            onDataChanged(dashboardData);
          },
        )
        .subscribe();
  }

  /// Clean up subscriptions
  void unsubscribeFromDataChanges() {
    _client.removeAllChannels();
  }

  /// ENHANCED: Manual refresh method for immediate dashboard updates
  Future<void> refreshDashboardData(
      Function(Map<String, dynamic>) onDataChanged) async {
    try {
      print('Manual dashboard refresh triggered...');
      final dashboardData = await getDashboardData();
      onDataChanged(dashboardData);
      print('Dashboard refresh completed successfully');
    } catch (error) {
      print('Dashboard refresh failed: $error');
    }
  }
}
